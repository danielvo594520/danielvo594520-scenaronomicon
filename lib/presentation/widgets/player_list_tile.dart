import 'package:flutter/material.dart';

import '../../domain/models/player_with_stats.dart';
import 'player_thumbnail.dart';

/// プレイヤー一覧用のリストタイル
class PlayerListTile extends StatelessWidget {
  const PlayerListTile({
    super.key,
    required this.player,
    this.onTap,
  });

  final PlayerWithStats player;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: PlayerThumbnail(
          imagePath: player.imagePath,
          size: 40,
          borderRadius: 20,
        ),
        title: Text(player.name),
        subtitle: Text('参加: ${player.sessionCount}回'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
