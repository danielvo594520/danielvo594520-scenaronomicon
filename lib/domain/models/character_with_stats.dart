/// キャラクター + セッション数の表示用モデル
class CharacterWithStats {
  const CharacterWithStats({
    required this.id,
    required this.playerId,
    required this.name,
    this.url,
    this.imagePath,
    this.hp,
    this.maxHp,
    this.mp,
    this.maxMp,
    this.san,
    this.maxSan,
    this.sourceService,
    required this.sessionCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int playerId;
  final String name;
  final String? url;
  final String? imagePath;

  // ステータス情報
  final int? hp;
  final int? maxHp;
  final int? mp;
  final int? maxMp;
  final int? san;
  final int? maxSan;
  final String? sourceService;

  final int sessionCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ステータス情報が存在するかどうか
  bool get hasStats =>
      hp != null ||
      maxHp != null ||
      mp != null ||
      maxMp != null ||
      san != null ||
      maxSan != null;
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
