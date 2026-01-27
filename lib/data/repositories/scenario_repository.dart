import 'package:drift/drift.dart';

import '../../domain/enums/scenario_sort.dart';
import '../../domain/enums/scenario_status.dart';
import '../../domain/models/scenario_filter.dart';
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

  /// 検索・フィルタ・ソート適用済みのシナリオ一覧を取得
  ///
  /// [playCountMap] はプレイ回数でソートする場合に必要。
  /// 外部から事前に取得して渡すことで、リポジトリ層の責務を分離する。
  Future<List<ScenarioWithTags>> searchAndFilter({
    required ScenarioFilter filter,
    required ScenarioSort sort,
    Map<int, int> playCountMap = const {},
  }) async {
    // 1. シナリオ + システム名をjoinで取得
    final query = _db.select(_db.scenarios).join([
      leftOuterJoin(
          _db.systems, _db.systems.id.equalsExp(_db.scenarios.systemId)),
    ]);

    // タイトル検索
    if (filter.titleQuery != null && filter.titleQuery!.isNotEmpty) {
      query.where(_db.scenarios.title.contains(filter.titleQuery!));
    }

    // システムフィルタ
    if (filter.systemId != null) {
      query.where(_db.scenarios.systemId.equals(filter.systemId!));
    }

    // 状態フィルタ
    if (filter.status != null) {
      query.where(_db.scenarios.status.equals(filter.status!.name));
    }

    // ソート適用（プレイ回数・状態別以外はDB側で処理）
    switch (sort) {
      case ScenarioSort.createdAtDesc:
        query.orderBy([OrderingTerm.desc(_db.scenarios.createdAt)]);
        break;
      case ScenarioSort.createdAtAsc:
        query.orderBy([OrderingTerm.asc(_db.scenarios.createdAt)]);
        break;
      case ScenarioSort.titleAsc:
        query.orderBy([OrderingTerm.asc(_db.scenarios.title)]);
        break;
      case ScenarioSort.titleDesc:
        query.orderBy([OrderingTerm.desc(_db.scenarios.title)]);
        break;
      case ScenarioSort.playCountDesc:
      case ScenarioSort.playCountAsc:
      case ScenarioSort.statusOrder:
        // アプリ側でソート
        query.orderBy([OrderingTerm.desc(_db.scenarios.createdAt)]);
        break;
    }

    final scenarioRows = await query.get();

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
    var results = scenarioRows.map((row) {
      final scenario = row.readTable(_db.scenarios);
      final system = row.readTableOrNull(_db.systems);
      return _toScenarioWithTags(
        scenario,
        system?.name,
        tagsByScenario[scenario.id] ?? [],
      );
    }).toList();

    // 5. タグフィルタ（AND/OR）はアプリ側で処理
    if (filter.tagIds.isNotEmpty) {
      results = _filterByTags(results, filter.tagIds, filter.tagFilterAnd);
    }

    // 6. アプリ側ソート（プレイ回数・状態別）
    switch (sort) {
      case ScenarioSort.playCountDesc:
        results.sort((a, b) {
          final countA = playCountMap[a.id] ?? 0;
          final countB = playCountMap[b.id] ?? 0;
          return countB.compareTo(countA);
        });
        break;
      case ScenarioSort.playCountAsc:
        results.sort((a, b) {
          final countA = playCountMap[a.id] ?? 0;
          final countB = playCountMap[b.id] ?? 0;
          return countA.compareTo(countB);
        });
        break;
      case ScenarioSort.statusOrder:
        results.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
      default:
        break;
    }

    return results;
  }

  /// 全シナリオのプレイ回数マップを取得
  Future<Map<int, int>> getAllPlayCounts() async {
    final rows = await _db.select(_db.playSessions).get();
    final counts = <int, int>{};
    for (final row in rows) {
      if (row.scenarioId != null) {
        counts[row.scenarioId!] = (counts[row.scenarioId!] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// タグによるフィルタリング
  List<ScenarioWithTags> _filterByTags(
    List<ScenarioWithTags> scenarios,
    List<int> tagIds,
    bool isAnd,
  ) {
    return scenarios.where((scenario) {
      final scenarioTagIds = scenario.tags.map((t) => t.id).toSet();
      if (isAnd) {
        return tagIds.every((id) => scenarioTagIds.contains(id));
      } else {
        return tagIds.any((id) => scenarioTagIds.contains(id));
      }
    }).toList();
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
