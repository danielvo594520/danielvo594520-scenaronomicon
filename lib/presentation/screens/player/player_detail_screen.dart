import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/character_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/character_card.dart';
import '../../widgets/delete_confirm_dialog.dart';
import '../../widgets/player_thumbnail.dart';

/// プレイヤー詳細画面
class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerDetailProvider(id));
    final sessionCountAsync = ref.watch(playerSessionCountProvider(id));
    final playedScenariosAsync = ref.watch(playerPlayedScenariosProvider(id));
    final charactersAsync = ref.watch(characterListProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイヤー詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/players/$id/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: playerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('エラー: $error')),
        data: (player) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコンと名前
              Row(
                children: [
                  PlayerThumbnail(
                    imagePath: player.imagePath,
                    size: 64,
                    borderRadius: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      player.name,
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
                title: const Text('参加セッション数'),
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

              // メモ
              if (player.note != null && player.note!.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'メモ',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(player.note!),
              ],

              const Divider(),
              const SizedBox(height: 8),

              // キャラクターセクション
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'キャラクター',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/players/$id/characters'),
                    icon: const Icon(Icons.list, size: 18),
                    label: const Text('すべて表示'),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              charactersAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('読み込みに失敗しました'),
                data: (characters) {
                  if (characters.isEmpty) {
                    return _buildEmptyCharacterState(context);
                  }
                  // 最大3件表示
                  final displayCharacters = characters.take(3).toList();
                  return Column(
                    children: [
                      ...displayCharacters.map((character) {
                        return CharacterCard(
                          character: character,
                          onTap: () => context.push(
                            '/players/$id/characters/${character.id}',
                          ),
                        );
                      }),
                      if (characters.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '他 ${characters.length - 3} 件',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const Divider(),
              const SizedBox(height: 8),

              // 参加したシナリオ
              Text(
                '参加したシナリオ',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              playedScenariosAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('読み込みに失敗しました'),
                data: (scenarios) {
                  if (scenarios.isEmpty) {
                    return Text(
                      'まだシナリオに参加していません',
                      style: TextStyle(color: Colors.grey[400]),
                    );
                  }
                  return Column(
                    children: scenarios.map((scenario) {
                      return Card(
                        child: ListTile(
                          title: Text(scenario.title),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              context.push('/scenarios/${scenario.id}'),
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

  Widget _buildEmptyCharacterState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.person_add,
              size: 32,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'キャラクターがありません',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () =>
                  GoRouter.of(context).push('/players/$id/characters/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final player = ref.read(playerDetailProvider(id)).valueOrNull;
    if (player == null) return;

    final confirmed = await DeleteConfirmDialog.show(
      context,
      player.name,
    );

    if (confirmed && context.mounted) {
      await ref.read(playerListProvider.notifier).deletePlayer(id);
      if (context.mounted) context.pop();
    }
  }
}
