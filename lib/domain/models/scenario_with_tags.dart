import '../enums/scenario_status.dart';

/// シナリオ + タグ + システム名を結合した表示用モデル
class ScenarioWithTags {
  const ScenarioWithTags({
    required this.id,
    required this.title,
    this.systemId,
    this.systemName,
    required this.minPlayers,
    required this.maxPlayers,
    this.playTimeMinutes,
    required this.status,
    this.purchaseUrl,
    this.thumbnailPath,
    this.memo,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final int? systemId;
  final String? systemName;
  final int minPlayers;
  final int maxPlayers;
  final int? playTimeMinutes;
  final ScenarioStatus status;
  final String? purchaseUrl;
  final String? thumbnailPath;
  final String? memo;
  final List<TagInfo> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// プレイ人数の表示文字列
  String get playerCountDisplay {
    if (minPlayers == maxPlayers) return '$minPlayers人';
    return '$minPlayers〜$maxPlayers人';
  }

  /// プレイ時間の表示文字列
  String? get playTimeDisplay {
    if (playTimeMinutes == null) return null;
    final hours = playTimeMinutes! ~/ 60;
    final minutes = playTimeMinutes! % 60;
    if (hours > 0 && minutes > 0) return '$hours時間$minutes分';
    if (hours > 0) return '$hours時間';
    return '$minutes分';
  }
}

/// タグの表示用情報
class TagInfo {
  const TagInfo({
    required this.id,
    required this.name,
    required this.color,
  });

  final int id;
  final String name;
  final String color;
}
