/// プレイヤー + セッション数の表示用モデル
class PlayerWithStats {
  const PlayerWithStats({
    required this.id,
    required this.name,
    this.note,
    required this.sessionCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? note;
  final int sessionCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// プレイ記録内のプレイヤー情報
class PlayerInfo {
  const PlayerInfo({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}
