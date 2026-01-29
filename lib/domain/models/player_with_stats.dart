/// プレイヤー + セッション数の表示用モデル
class PlayerWithStats {
  const PlayerWithStats({
    required this.id,
    required this.name,
    this.note,
    this.imagePath,
    required this.sessionCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? note;
  final String? imagePath;
  final int sessionCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// プレイ記録内のプレイヤー情報（キャラクター情報含む）
class PlayerInfo {
  const PlayerInfo({
    required this.id,
    required this.name,
    this.imagePath,
    this.characterId,
    this.characterName,
    this.characterImagePath,
  });

  final int id;
  final String name;
  final String? imagePath;
  final int? characterId;
  final String? characterName;
  final String? characterImagePath;

  /// 表示用の名前（キャラクター名がある場合は「プレイヤー名（キャラクター名）」）
  String get displayName {
    if (characterName != null) {
      return '$name（$characterName）';
    }
    return name;
  }
}
