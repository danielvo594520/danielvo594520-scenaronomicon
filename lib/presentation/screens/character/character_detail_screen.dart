import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/character_provider.dart';
import '../../widgets/character_thumbnail.dart';
import '../../widgets/delete_confirm_dialog.dart';

/// キャラクター詳細画面
class CharacterDetailScreen extends ConsumerWidget {
  const CharacterDetailScreen({
    super.key,
    required this.playerId,
    required this.characterId,
  });

  final int playerId;
  final int characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(characterDetailProvider(characterId));
    final sessionCountAsync =
        ref.watch(characterSessionCountProvider(characterId));
    final sessionsAsync =
        ref.watch(characterPlayedSessionsProvider(characterId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('キャラクター詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(
              '/players/$playerId/characters/$characterId/edit',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: characterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('エラー: $error')),
        data: (character) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコンと名前
              Row(
                children: [
                  CharacterThumbnail(
                    imagePath: character.imagePath,
                    size: 80,
                    borderRadius: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      character.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),

              // 参加セッション数
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('プレイ回数'),
                trailing: sessionCountAsync.when(
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text('-'),
                  data: (count) => Text(
                    '$count回',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

              // URL
              if (character.url != null && character.url!.isNotEmpty) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.link),
                  title: const Text('キャラクターシートURL'),
                  subtitle: Text(
                    character.url!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openUrl(context, character.url!),
                ),
              ],

              const Divider(),
              const SizedBox(height: 8),

              // 参加したセッション
              Text(
                '参加したセッション',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              sessionsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('読み込みに失敗しました'),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Text(
                      'まだセッションに参加していません',
                      style: TextStyle(color: Colors.grey[400]),
                    );
                  }
                  final dateFormatter = DateFormat('yyyy/MM/dd');
                  return Column(
                    children: sessions.map((session) {
                      return Card(
                        child: ListTile(
                          title: Text(session.scenarioDisplayTitle),
                          subtitle: Text(
                            dateFormatter.format(session.playedAt),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: session.scenarioId != null
                              ? () => context
                                  .push('/scenarios/${session.scenarioId}')
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無効なURLです')),
        );
      }
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URLを開けませんでした')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final character = ref.read(characterDetailProvider(characterId)).valueOrNull;
    if (character == null) return;

    final confirmed = await DeleteConfirmDialog.show(
      context,
      character.name,
    );

    if (confirmed && context.mounted) {
      await ref
          .read(characterListProvider(playerId).notifier)
          .deleteCharacter(characterId);
      if (context.mounted) context.pop();
    }
  }
}
