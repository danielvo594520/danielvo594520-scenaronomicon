import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/player_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/player_list_tile.dart';

/// プレイヤー一覧画面
class PlayerListScreen extends ConsumerWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playerListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('プレイヤー')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'player_list_fab',
        onPressed: () => context.push('/players/new'),
        child: const Icon(Icons.add),
      ),
      body: playersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('エラー: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(playerListProvider),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
        data: (players) {
          if (players.isEmpty) {
            return const EmptyStateWidget(
              message: 'プレイヤーがいません。\n＋ボタンから追加しましょう！',
              icon: Icons.people_outline,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return PlayerListTile(
                player: player,
                onTap: () => context.push('/players/${player.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
