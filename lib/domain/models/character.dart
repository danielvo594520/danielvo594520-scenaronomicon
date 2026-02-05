/// キャラクターモデル
class Character {
  const Character({
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
    this.params,
    this.skills,
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

  // 能力値・技能値
  final Map<String, int>? params;
  final Map<String, int>? skills;

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

  /// 能力値が存在するかどうか
  bool get hasParams => params != null && params!.isNotEmpty;

  /// 技能値が存在するかどうか
  bool get hasSkills => skills != null && skills!.isNotEmpty;
}
