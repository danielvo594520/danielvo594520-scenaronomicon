import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/player_with_stats.dart';
import '../../providers/play_session_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/character_thumbnail.dart';
import '../../widgets/delete_confirm_dialog.dart';
import '../../widgets/player_thumbnail.dart';
import '../../widgets/scenario_thumbnail.dart';

/// プレイ記録詳細画面
class PlaySessionDetailScreen extends ConsumerWidget {
  const PlaySessionDetailScreen({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(playSessionDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイ記録詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/sessions/$id/edit'),
            tooltip: '編集',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: '削除',
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('エラー: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(playSessionDetailProvider(id)),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
        data: (session) {
          final dateFormatter = DateFormat('yyyy年MM月dd日');
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // プレイ日
                _SectionTile(
                  icon: Icons.calendar_today,
                  title: 'プレイ日',
                  content: dateFormatter.format(session.playedAt),
                ),
                const Divider(height: 1),

                // シナリオ
                InkWell(
                  onTap: session.scenarioId != null
                      ? () => context.push('/scenarios/${session.scenarioId}')
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScenarioThumbnail(
                          imagePath: session.scenarioThumbnailPath,
                          width: 80,
                          height: 100,
                          borderRadius: 8,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'シナリオ',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.scenarioDisplayTitle,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: session.scenarioId == null
                                          ? Colors.grey
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (session.scenarioId != null)
                          const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // KP
                _ParticipantSection(
                  icon: Icons.theater_comedy,
                  title: 'KP',
                  count: session.kps.length,
                  participants: session.kps,
                  emptyMessage: 'KPの記録なし',
                ),
                const Divider(height: 1),

                // 参加プレイヤー
                _ParticipantSection(
                  icon: Icons.people,
                  title: '参加プレイヤー',
                  count: session.players.length,
                  participants: session.players,
                  emptyMessage: '参加プレイヤーの記録なし',
                ),
                const Divider(height: 1),

                // メモ
                if (session.memo != null && session.memo!.isNotEmpty) ...[
                  _SectionTile(
                    icon: Icons.notes,
                    title: 'メモ',
                    content: session.memo!,
                    multiline: true,
                  ),
                  const Divider(height: 1),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await DeleteConfirmDialog.show(
      context,
      'このプレイ記録',
    );
    if (confirmed && context.mounted) {
      await ref.read(playSessionListProvider.notifier).deleteSession(id);
      // プレイヤーの参加数を更新
      ref.invalidate(playerListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プレイ記録を削除しました')),
        );
        context.pop();
      }
    }
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.title,
    required this.content,
    this.trailing,
    this.contentColor,
    this.multiline = false,
  });

  final IconData icon;
  final String title;
  final String content;
  final Widget? trailing;
  final Color? contentColor;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: contentColor,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ParticipantSection extends StatelessWidget {
  const _ParticipantSection({
    required this.icon,
    required this.title,
    required this.count,
    required this.participants,
    required this.emptyMessage,
  });

  final IconData icon;
  final String title;
  final int count;
  final List<PlayerInfo> participants;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Colors.grey[600]),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$count人',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (participants.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                emptyMessage,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...participants.map((p) => _ParticipantTile(participant: p)),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});

  final PlayerInfo participant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, bottom: 8),
      child: Row(
        children: [
          PlayerThumbnail(
            imagePath: participant.imagePath,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (participant.characterName != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      CharacterThumbnail(
                        imagePath: participant.characterImagePath,
                        size: 16,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        participant.characterName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
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
    );
  }
}
