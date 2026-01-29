import 'package:drift/drift.dart';

import '../../domain/models/player_with_stats.dart';
import '../database/database.dart';

class PlayerRepository {
  PlayerRepository(this._db);

  final AppDatabase _db;

  /// 全プレイヤーをセッション数付きで取得（N+1回避）
  Future<List<PlayerWithStats>> getAll() async {
    // 1. 全プレイヤー取得
    final playersQuery = _db.select(_db.players)
      ..orderBy([(p) => OrderingTerm.asc(p.name)]);
    final playerRows = await playersQuery.get();

    // 2. セッション数を集計（N+1回避）
    // 同じセッションでKPとプレイヤー両方に登録されていても1回としてカウント
    final countRows = await (_db.select(_db.playSessionPlayers)).get();
    final sessionCounts = <int, int>{};
    final playerSessionSet = <int, Set<int>>{}; // playerId -> Set<sessionId>
    for (final row in countRows) {
      playerSessionSet.putIfAbsent(row.playerId, () => {}).add(row.playSessionId);
    }
    for (final entry in playerSessionSet.entries) {
      sessionCounts[entry.key] = entry.value.length;
    }

    // 3. 結合
    return playerRows.map((player) {
      return PlayerWithStats(
        id: player.id,
        name: player.name,
        note: player.note,
        imagePath: player.imagePath,
        sessionCount: sessionCounts[player.id] ?? 0,
        createdAt: player.createdAt,
        updatedAt: player.updatedAt,
      );
    }).toList();
  }

  /// プレイヤーをIDで取得
  Future<Player> getById(int id) {
    return (_db.select(_db.players)..where((p) => p.id.equals(id))).getSingle();
  }

  /// プレイヤーの参加セッション数（同じセッションでKPとプレイヤー両方でも1回）
  Future<int> getSessionCount(int playerId) async {
    final result = await (_db.select(_db.playSessionPlayers)
          ..where((p) => p.playerId.equals(playerId)))
        .get();
    // セッションIDでユニークにカウント
    final sessionIds = result.map((r) => r.playSessionId).toSet();
    return sessionIds.length;
  }

  /// プレイヤーが参加したシナリオ一覧（重複除外）
  Future<List<Scenario>> getPlayedScenarios(int playerId) async {
    final query = _db.select(_db.playSessionPlayers).join([
      innerJoin(
        _db.playSessions,
        _db.playSessions.id
            .equalsExp(_db.playSessionPlayers.playSessionId),
      ),
      innerJoin(
        _db.scenarios,
        _db.scenarios.id.equalsExp(_db.playSessions.scenarioId),
      ),
    ])
      ..where(_db.playSessionPlayers.playerId.equals(playerId));

    final rows = await query.get();

    // シナリオIDで重複除外
    final scenarioMap = <int, Scenario>{};
    for (final row in rows) {
      final scenario = row.readTable(_db.scenarios);
      scenarioMap[scenario.id] = scenario;
    }

    return scenarioMap.values.toList();
  }

  /// プレイヤー作成
  Future<int> create({
    required String name,
    String? note,
    String? imagePath,
  }) {
    final now = DateTime.now();
    return _db.into(_db.players).insert(
          PlayersCompanion.insert(
            name: name,
            note: Value(note),
            imagePath: Value(imagePath),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// プレイヤー更新
  Future<void> update({
    required int id,
    required String name,
    String? note,
    String? imagePath,
  }) {
    return (_db.update(_db.players)..where((p) => p.id.equals(id))).write(
      PlayersCompanion(
        name: Value(name),
        note: Value(note),
        imagePath: Value(imagePath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// プレイヤー削除（play_session_playersから先に削除）
  Future<void> delete(int id) async {
    await (_db.delete(_db.playSessionPlayers)
          ..where((p) => p.playerId.equals(id)))
        .go();
    await (_db.delete(_db.players)..where((p) => p.id.equals(id))).go();
  }

  /// 同名のプレイヤーが存在するかチェック（編集時は自身を除外）
  Future<bool> isNameExists(String name, {int? excludeId}) async {
    final query = _db.select(_db.players)
      ..where((p) => p.name.equals(name));
    if (excludeId != null) {
      query.where((p) => p.id.equals(excludeId).not());
    }
    final results = await query.get();
    return results.isNotEmpty;
  }
}
