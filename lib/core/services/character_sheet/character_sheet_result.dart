/// キャラクターシート取得結果
class CharacterSheetResult {
  const CharacterSheetResult({
    this.name,
    this.hp,
    this.maxHp,
    this.mp,
    this.maxMp,
    this.san,
    this.maxSan,
    this.imageUrl,
    this.rawData,
  });

  /// キャラクター名
  final String? name;

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

  @override
  String toString() {
    return 'CharacterSheetResult(name: $name, hp: $hp/$maxHp, mp: $mp/$maxMp, san: $san/$maxSan)';
  }
}
