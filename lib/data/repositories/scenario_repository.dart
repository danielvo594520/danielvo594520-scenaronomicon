import 'package:drift/drift.dart';

import '../../domain/enums/scenario_status.dart';
import '../../domain/models/scenario_with_tags.dart';
import '../database/database.dart';

class ScenarioRepository {
  ScenarioRepository(this._db);

  final AppDatabase _db;

  /// 全シナリオをタグ・システム名付きで取得（N+1回避）
  Future<List<ScenarioWithTags>> getAll() async {
    // 1. シナリオ + システム名をjoinで取得
    final scenarioQuery = _db.select(_db.scenarios).join([
      leftOuterJoin(_db.systems, _db.systems.id.equalsExp(_db.scenarios.systemId)),
    ])
      ..orderBy([OrderingTerm.desc(_db.scenarios.createdAt)]);

    final scenarioRows = await scenarioQuery.get();

    // 2. 全scenario_tags + tagsをjoinで取得
    final tagQuery = _db.select(_db.scenarioTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.scenarioTags.tagId)),
    ]);
    final tagRows = await tagQuery.get();

    // 3. タグをscenarioIdでグルーピング
    final tagsByScenario = <int, List<TagInfo>>{};
    for (final row in tagRows) {
      final scenarioId = row.readTable(_db.scenarioTags).scenarioId;
      final tag = row.readTable(_db.tags);
      tagsByScenario
          .putIfAbsent(scenarioId, () => [])
          .add(TagInfo(id: tag.id, name: tag.name, color: tag.color));
    }

    // 4. 結合
    return scenarioRows.map((row) {
      final scenario = row.readTable(_db.scenarios);
      final system = row.readTableOrNull(_db.systems);
      return _toScenarioWithTags(
        scenario,
        system?.name,
        tagsByScenario[scenario.id] ?? [],
      );
    }).toList();
  }

  /// 特定シナリオをタグ・システム名付きで取得
  Future<ScenarioWithTags> getById(int id) async {
    final scenarioQuery = _db.select(_db.scenarios).join([
      leftOuterJoin(_db.systems, _db.systems.id.equalsExp(_db.scenarios.systemId)),
    ])
      ..where(_db.scenarios.id.equals(id));

    final row = await scenarioQuery.getSingle();
    final scenario = row.readTable(_db.scenarios);
    final system = row.readTableOrNull(_db.systems);

    // タグ取得
    final tagQuery = _db.select(_db.scenarioTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.scenarioTags.tagId)),
    ])
      ..where(_db.scenarioTags.scenarioId.equals(id));

    final tagRows = await tagQuery.get();
    final tags = tagRows
        .map((r) {
          final tag = r.readTable(_db.tags);
          return TagInfo(id: tag.id, name: tag.name, color: tag.color);
        })
        .toList();

    return _toScenarioWithTags(scenario, system?.name, tags);
  }

  /// シナリオ作成（タグ割当含む）
  Future<int> create({
    required String title,
    int? systemId,
    int minPlayers = 1,
    int maxPlayers = 4,
    int? playTimeMinutes,
    required ScenarioStatus status,
    String? purchaseUrl,
    String? memo,
    List<int> tagIds = const [],
  }) async {
    return _db.transaction(() async {
      final now = DateTime.now();
      final scenarioId = await _db.into(_db.scenarios).insert(
            ScenariosCompanion.insert(
              title: title,
              systemId: Value(systemId),
              minPlayers: Value(minPlayers),
              maxPlayers: Value(maxPlayers),
              playTimeMinutes: Value(playTimeMinutes),
              status: status.name,
              purchaseUrl: Value(purchaseUrl),
              memo: Value(memo),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // タグの割当
      for (final tagId in tagIds) {
        await _db.into(_db.scenarioTags).insert(
              ScenarioTagsCompanion.insert(
                scenarioId: scenarioId,
                tagId: tagId,
              ),
            );
      }

      return scenarioId;
    });
  }

  /// シナリオ更新（タグ割当の再設定含む）
  Future<void> update({
    required int id,
    required String title,
    int? systemId,
    int minPlayers = 1,
    int maxPlayers = 4,
    int? playTimeMinutes,
    required ScenarioStatus status,
    String? purchaseUrl,
    String? memo,
    List<int> tagIds = const [],
  }) async {
    await _db.transaction(() async {
      final now = DateTime.now();
      await (_db.update(_db.scenarios)..where((t) => t.id.equals(id))).write(
        ScenariosCompanion(
          title: Value(title),
          systemId: Value(systemId),
          minPlayers: Value(minPlayers),
          maxPlayers: Value(maxPlayers),
          playTimeMinutes: Value(playTimeMinutes),
          status: Value(status.name),
          purchaseUrl: Value(purchaseUrl),
          memo: Value(memo),
          updatedAt: Value(now),
        ),
      );

      // タグの再割当: 既存を削除 → 新規挿入
      await (_db.delete(_db.scenarioTags)
            ..where((t) => t.scenarioId.equals(id)))
          .go();

      for (final tagId in tagIds) {
        await _db.into(_db.scenarioTags).insert(
              ScenarioTagsCompanion.insert(
                scenarioId: id,
                tagId: tagId,
              ),
            );
      }
    });
  }

  /// シナリオ削除（タグ割当削除 + プレイ記録のscenarioIdをnullに設定）
  Future<void> delete(int id) async {
    await _db.transaction(() async {
      // タグ割当を削除
      await (_db.delete(_db.scenarioTags)
            ..where((t) => t.scenarioId.equals(id)))
          .go();
      // プレイ記録のscenarioIdをnullに設定
      await (_db.update(_db.playSessions)
            ..where((s) => s.scenarioId.equals(id)))
          .write(const PlaySessionsCompanion(scenarioId: Value(null)));
      // シナリオ削除
      await (_db.delete(_db.scenarios)..where((t) => t.id.equals(id))).go();
    });
  }

  ScenarioWithTags _toScenarioWithTags(
    Scenario scenario,
    String? systemName,
    List<TagInfo> tags,
  ) {
    return ScenarioWithTags(
      id: scenario.id,
      title: scenario.title,
      systemId: scenario.systemId,
      systemName: systemName,
      minPlayers: scenario.minPlayers,
      maxPlayers: scenario.maxPlayers,
      playTimeMinutes: scenario.playTimeMinutes,
      status: ScenarioStatus.values.byName(scenario.status),
      purchaseUrl: scenario.purchaseUrl,
      thumbnailPath: scenario.thumbnailPath,
      memo: scenario.memo,
      tags: tags,
      createdAt: scenario.createdAt,
      updatedAt: scenario.updatedAt,
    );
  }
}
