import 'player_with_stats.dart';

/// プレイ記録 + シナリオ名 + プレイヤーリストの表示用モデル
class PlaySessionWithDetails {
  const PlaySessionWithDetails({
    required this.id,
    this.scenarioId,
    this.scenarioTitle,
    required this.playedAt,
    this.memo,
    required this.players,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int? scenarioId;
  final String? scenarioTitle;
  final DateTime playedAt;
  final String? memo;
  final List<PlayerInfo> players;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 削除されたシナリオの場合の表示テキスト
  String get scenarioDisplayTitle => scenarioTitle ?? '削除されたシナリオ';

  /// カンマ区切りのプレイヤー名（キャラクター名含む）
  String get playerNamesDisplay {
    if (players.isEmpty) return '';
    return players.map((p) => p.displayName).join('、');
  }

  /// プレイヤー名のみ（キャラクター名なし）
  String get playerNamesOnlyDisplay {
    if (players.isEmpty) return '';
    return players.map((p) => p.name).join('、');
  }
}

/// シナリオ詳細画面用のプレイ履歴サマリー
class PlaySessionSummary {
  const PlaySessionSummary({
    required this.id,
    required this.playedAt,
    required this.playerNames,
    this.memo,
  });

  final int id;
  final DateTime playedAt;
  final String playerNames;
  final String? memo;
}
