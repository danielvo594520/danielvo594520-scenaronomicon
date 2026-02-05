/// キャラクターシート取得結果
class CharacterSheetResult {
  const CharacterSheetResult({
    this.name,
    this.externalUrl,
    this.hp,
    this.maxHp,
    this.mp,
    this.maxMp,
    this.san,
    this.maxSan,
    this.imageUrl,
    this.params,
    this.skills,
    this.rawData,
  });

  /// キャラクター名
  final String? name;

  /// キャラクターシートURL（ココフォリア駒のexternalUrl）
  final String? externalUrl;

  /// 現在HP
  final int? hp;

  /// 最大HP
  final int? maxHp;

  /// 現在MP
  final int? mp;

  /// 最大MP
  final int? maxMp;

  /// 現在SAN
  final int? san;

  /// 最大SAN
  final int? maxSan;

  /// プロフィール画像URL
  final String? imageUrl;

  /// 能力値（STR, CON, SIZ, DEX, APP, INT, POW, EDU等）
  final Map<String, int>? params;

  /// 技能値（技能名 → 値）
  final Map<String, int>? skills;

  /// 取得した生データ（デバッグ用）
  final Map<String, dynamic>? rawData;

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

  @override
  String toString() {
    return 'CharacterSheetResult(name: $name, hp: $hp/$maxHp, mp: $mp/$maxMp, san: $san/$maxSan)';
  }
}
