import 'package:drift/drift.dart';

import '../../domain/models/character.dart' as model;
import '../../domain/models/character_with_stats.dart';
import '../database/database.dart';

class CharacterRepository {
  CharacterRepository(this._db);

  final AppDatabase _db;

  /// 指定プレイヤーの全キャラクターをセッション数付きで取得
  Future<List<CharacterWithStats>> getByPlayerId(int playerId) async {
    final query = _db.select(_db.characters)
      ..where((c) => c.playerId.equals(playerId))
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    final characterRows = await query.get();

    // セッション数を集計
    final countRows = await (_db.select(_db.playSessionPlayers)
          ..where((p) => p.characterId.isNotNull()))
        .get();
    final sessionCounts = <int, int>{};
    for (final row in countRows) {
      if (row.characterId != null) {
        sessionCounts[row.characterId!] =
            (sessionCounts[row.characterId!] ?? 0) + 1;
      }
    }

    return characterRows.map((character) {
      return CharacterWithStats(
        id: character.id,
        playerId: character.playerId,
        name: character.name,
        url: character.url,
        imagePath: character.imagePath,
        sessionCount: sessionCounts[character.id] ?? 0,
        createdAt: character.createdAt,
        updatedAt: character.updatedAt,
      );
    }).toList();
  }

  /// キャラクターをIDで取得
  Future<model.Character> getById(int id) async {
    final row = await (_db.select(_db.characters)
          ..where((c) => c.id.equals(id)))
        .getSingle();
    return model.Character(
      id: row.id,
      playerId: row.playerId,
      name: row.name,
      url: row.url,
      imagePath: row.imagePath,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// キャラクターのセッション数
  Future<int> getSessionCount(int characterId) async {
    final result = await (_db.select(_db.playSessionPlayers)
          ..where((p) => p.characterId.equals(characterId)))
        .get();
    return result.length;
  }

  /// キャラクターが参加したセッション一覧
  Future<List<CharacterSessionInfo>> getPlayedSessions(int characterId) async {
    final query = _db.select(_db.playSessionPlayers).join([
      innerJoin(
        _db.playSessions,
        _db.playSessions.id.equalsExp(_db.playSessionPlayers.playSessionId),
      ),
      leftOuterJoin(
        _db.scenarios,
        _db.scenarios.id.equalsExp(_db.playSessions.scenarioId),
      ),
    ])
      ..where(_db.playSessionPlayers.characterId.equals(characterId))
      ..orderBy([OrderingTerm.desc(_db.playSessions.playedAt)]);

    final rows = await query.get();

    return rows.map((row) {
      final session = row.readTable(_db.playSessions);
      final scenario = row.readTableOrNull(_db.scenarios);
      return CharacterSessionInfo(
        sessionId: session.id,
        playedAt: session.playedAt,
        scenarioId: session.scenarioId,
        scenarioTitle: scenario?.title,
        memo: session.memo,
      );
    }).toList();
  }

  /// キャラクター作成
  Future<int> create({
    required int playerId,
    required String name,
    String? url,
    String? imagePath,
  }) {
    final now = DateTime.now();
    return _db.into(_db.characters).insert(
          CharactersCompanion.insert(
            playerId: playerId,
            name: name,
            url: Value(url),
            imagePath: Value(imagePath),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// キャラクター更新（画像パスを返す：削除用）
  Future<String?> update({
    required int id,
    required String name,
    String? url,
    String? imagePath,
  }) async {
    // 既存の画像パスを取得
    final existing = await getById(id);
    final oldImagePath = existing.imagePath;

    await (_db.update(_db.characters)..where((c) => c.id.equals(id))).write(
      CharactersCompanion(
        name: Value(name),
        url: Value(url),
        imagePath: Value(imagePath),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // 画像が変更された場合、古いパスを返す
    if (oldImagePath != null && oldImagePath != imagePath) {
      return oldImagePath;
    }
    return null;
  }

  /// キャラクター削除（play_session_playersのcharacterIdをNULLに）
  /// 画像パスを返す（削除用）
  Future<String?> delete(int id) async {
    // 画像パスを取得
    final character = await getById(id);
    final imagePath = character.imagePath;

    // play_session_players の characterId を NULL に
    await (_db.update(_db.playSessionPlayers)
          ..where((p) => p.characterId.equals(id)))
        .write(const PlaySessionPlayersCompanion(
      characterId: Value(null),
    ));

    await (_db.delete(_db.characters)..where((c) => c.id.equals(id))).go();

    return imagePath;
  }

  /// 指定プレイヤーの全キャラクターを削除
  /// 画像パスのリストを返す（削除用）
  Future<List<String>> deleteAllByPlayerId(int playerId) async {
    // 削除対象のキャラクターを取得
    final characters = await (_db.select(_db.characters)
          ..where((c) => c.playerId.equals(playerId)))
        .get();

    final imagePaths = characters
        .where((c) => c.imagePath != null)
        .map((c) => c.imagePath!)
        .toList();

    // play_session_players の characterId を NULL に
    for (final character in characters) {
      await (_db.update(_db.playSessionPlayers)
            ..where((p) => p.characterId.equals(character.id)))
          .write(const PlaySessionPlayersCompanion(
        characterId: Value(null),
      ));
    }

    await (_db.delete(_db.characters)
          ..where((c) => c.playerId.equals(playerId)))
        .go();

    return imagePaths;
  }

  /// 同名のキャラクターが存在するかチェック（同一プレイヤー内、編集時は自身を除外）
  Future<bool> isNameExists(
    int playerId,
    String name, {
    int? excludeId,
  }) async {
    var query = _db.select(_db.characters)
      ..where((c) => c.playerId.equals(playerId) & c.name.equals(name));
    if (excludeId != null) {
      query = query..where((c) => c.id.equals(excludeId).not());
    }
    final results = await query.get();
    return results.isNotEmpty;
  }
}
