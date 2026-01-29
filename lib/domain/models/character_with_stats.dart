/// キャラクター + セッション数の表示用モデル
class CharacterWithStats {
  const CharacterWithStats({
    required this.id,
    required this.playerId,
    required this.name,
    this.url,
    this.imagePath,
    required this.sessionCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int playerId;
  final String name;
  final String? url;
  final String? imagePath;
  final int sessionCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// キャラクターの参加セッション情報
class CharacterSessionInfo {
  const CharacterSessionInfo({
    required this.sessionId,
    required this.playedAt,
    this.scenarioId,
    this.scenarioTitle,
    this.memo,
  });

  final int sessionId;
  final DateTime playedAt;
  final int? scenarioId;
  final String? scenarioTitle;
  final String? memo;

  String get scenarioDisplayTitle => scenarioTitle ?? '削除されたシナリオ';
}
