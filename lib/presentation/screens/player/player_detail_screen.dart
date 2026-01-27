import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/player_provider.dart';
import '../../widgets/delete_confirm_dialog.dart';

/// プレイヤー詳細画面
class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerDetailProvider(id));
    final sessionCountAsync = ref.watch(playerSessionCountProvider(id));
    final playedScenariosAsync = ref.watch(playerPlayedScenariosProvider(id));

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
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
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
