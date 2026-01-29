/// キャラクターモデル
class Character {
  const Character({
    required this.id,
    required this.playerId,
    required this.name,
    this.url,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int playerId;
  final String name;
  final String? url;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
}
