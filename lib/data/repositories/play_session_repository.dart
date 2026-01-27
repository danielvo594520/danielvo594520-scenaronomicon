import 'package:drift/drift.dart';

import '../../domain/models/play_session_with_details.dart';
import '../../domain/models/player_with_stats.dart';
import '../database/database.dart';

class PlaySessionRepository {
  PlaySessionRepository(this._db);

  final AppDatabase _db;

  /// 全プレイ記録をシナリオ名・プレイヤー情報付きで取得（N+1回避）
  Future<List<PlaySessionWithDetails>> getAll() async {
    // 1. セッション + シナリオ名（LEFT JOINで削除済みシナリオ対応）
    final sessionQuery = _db.select(_db.playSessions).join([
      leftOuterJoin(
        _db.scenarios,
        _db.scenarios.id.equalsExp(_db.playSessions.scenarioId),
      ),
    ])
      ..orderBy([OrderingTerm.desc(_db.playSessions.playedAt)]);

    final sessionRows = await sessionQuery.get();

    // 2. 全プレイヤー関連を取得（N+1回避）
    final playerQuery = _db.select(_db.playSessionPlayers).join([
      innerJoin(
        _db.players,
        _db.players.id.equalsExp(_db.playSessionPlayers.playerId),
      ),
    ]);
    final playerRows = await playerQuery.get();

    // セッションIDでグルーピング
    final playersBySession = <int, List<PlayerInfo>>{};
    for (final row in playerRows) {
      final sessionId = row.readTable(_db.playSessionPlayers).playSessionId;
      final player = row.readTable(_db.players);
      playersBySession
          .putIfAbsent(sessionId, () => [])
          .add(PlayerInfo(id: player.id, name: player.name));
    }

    // 3. 結合
    return sessionRows.map((row) {
      final session = row.readTable(_db.playSessions);
      final scenario = row.readTableOrNull(_db.scenarios);
      return PlaySessionWithDetails(
        id: session.id,
        scenarioId: session.scenarioId,
        scenarioTitle: scenario?.title,
        playedAt: session.playedAt,
        memo: session.memo,
        players: playersBySession[session.id] ?? [],
        createdAt: session.createdAt,
        updatedAt: session.updatedAt,
      );
    }).toList();
  }

  /// 特定シナリオのプレイ履歴サマリー
  Future<List<PlaySessionSummary>> getByScenarioId(int scenarioId) async {
    final query = _db.select(_db.playSessions)
      ..where((s) => s.scenarioId.equals(scenarioId))
      ..orderBy([(s) => OrderingTerm.desc(s.playedAt)]);

    final sessions = await query.get();

    final results = <PlaySessionSummary>[];
    for (final session in sessions) {
      final playerQuery = _db.select(_db.playSessionPlayers).join([
        innerJoin(
          _db.players,
          _db.players.id.equalsExp(_db.playSessionPlayers.playerId),
        ),
      ])
        ..where(_db.playSessionPlayers.playSessionId.equals(session.id));

      final playerRows = await playerQuery.get();
      final playerNames =
          playerRows.map((r) => r.readTable(_db.players).name).join('、');

      results.add(PlaySessionSummary(
        id: session.id,
        playedAt: session.playedAt,
        playerNames: playerNames,
        memo: session.memo,
      ));
    }

    return results;
  }

  /// プレイ記録をIDで取得（詳細情報付き）
  Future<PlaySessionWithDetails> getById(int id) async {
    final query = _db.select(_db.playSessions).join([
      leftOuterJoin(
        _db.scenarios,
        _db.scenarios.id.equalsExp(_db.playSessions.scenarioId),
      ),
    ])
      ..where(_db.playSessions.id.equals(id));

    final row = await query.getSingle();
    final session = row.readTable(_db.playSessions);
    final scenario = row.readTableOrNull(_db.scenarios);

    // プレイヤー取得
    final playerQuery = _db.select(_db.playSessionPlayers).join([
      innerJoin(
        _db.players,
        _db.players.id.equalsExp(_db.playSessionPlayers.playerId),
      ),
    ])
      ..where(_db.playSessionPlayers.playSessionId.equals(id));

    final playerRows = await playerQuery.get();
    final players = playerRows
        .map((r) {
          final player = r.readTable(_db.players);
          return PlayerInfo(id: player.id, name: player.name);
        })
        .toList();

    return PlaySessionWithDetails(
      id: session.id,
      scenarioId: session.scenarioId,
      scenarioTitle: scenario?.title,
      playedAt: session.playedAt,
      memo: session.memo,
      players: players,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
    );
  }

  /// シナリオのプレイ回数
  Future<int> getPlayCount(int scenarioId) async {
    final result = await (_db.select(_db.playSessions)
          ..where((s) => s.scenarioId.equals(scenarioId)))
        .get();
    return result.length;
  }

  /// プレイ記録作成（プレイヤー関連付け含む）
  Future<int> create({
    int? scenarioId,
    required DateTime playedAt,
    String? memo,
    List<int> playerIds = const [],
  }) async {
    return _db.transaction(() async {
      final now = DateTime.now();
      final sessionId = await _db.into(_db.playSessions).insert(
            PlaySessionsCompanion.insert(
              scenarioId: Value(scenarioId),
              playedAt: playedAt,
              memo: Value(memo),
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (final playerId in playerIds) {
        await _db.into(_db.playSessionPlayers).insert(
              PlaySessionPlayersCompanion.insert(
                playSessionId: sessionId,
                playerId: playerId,
              ),
            );
      }

      return sessionId;
    });
  }

  /// プレイ記録更新（プレイヤー関連付けの再設定含む）
  Future<void> update({
    required int id,
    int? scenarioId,
    required DateTime playedAt,
    String? memo,
    List<int> playerIds = const [],
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.playSessions)..where((s) => s.id.equals(id)))
          .write(
        PlaySessionsCompanion(
          scenarioId: Value(scenarioId),
          playedAt: Value(playedAt),
          memo: Value(memo),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // プレイヤーの再割当: 既存を削除 → 新規挿入
      await (_db.delete(_db.playSessionPlayers)
            ..where((p) => p.playSessionId.equals(id)))
          .go();

      for (final playerId in playerIds) {
        await _db.into(_db.playSessionPlayers).insert(
              PlaySessionPlayersCompanion.insert(
                playSessionId: id,
                playerId: playerId,
              ),
            );
      }
    });
  }

  /// プレイ記録削除（プレイヤー関連付けも削除）
  Future<void> delete(int id) async {
    await (_db.delete(_db.playSessionPlayers)
          ..where((p) => p.playSessionId.equals(id)))
        .go();
    await (_db.delete(_db.playSessions)..where((s) => s.id.equals(id))).go();
  }
}
