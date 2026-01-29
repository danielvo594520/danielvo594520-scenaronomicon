import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/play_session_with_details.dart';
import 'scenario_thumbnail.dart';

/// プレイ記録一覧用のカード
class PlaySessionCard extends StatelessWidget {
  const PlaySessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

  final PlaySessionWithDetails session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy/MM/dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // シナリオ画像
              ScenarioThumbnail(
                imagePath: session.scenarioThumbnailPath,
                width: 80,
                height: 100,
                borderRadius: 8,
              ),
              const SizedBox(width: 12),
              // コンテンツ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 日付
                    Text(
                      dateFormatter.format(session.playedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    // シナリオタイトル
                    Text(
                      session.scenarioDisplayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                session.scenarioId == null ? Colors.grey : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // KP
                    if (session.kps.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.theater_comedy, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'KP: ${session.kpNamesDisplay}',
                              style: TextStyle(color: Colors.grey[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // プレイヤー
                    if (session.players.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'PL: ${session.playerNamesOnlyDisplay}',
                              style: TextStyle(color: Colors.grey[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
