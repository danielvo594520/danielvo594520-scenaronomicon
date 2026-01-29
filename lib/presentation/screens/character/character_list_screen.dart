import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/character_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/character_card.dart';

/// キャラクター一覧画面
class CharacterListScreen extends ConsumerWidget {
  const CharacterListScreen({
    super.key,
    required this.playerId,
  });

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerDetailProvider(playerId));
    final charactersAsync = ref.watch(characterListProvider(playerId));

    return Scaffold(
      appBar: AppBar(
        title: playerAsync.when(
          loading: () => const Text('キャラクター一覧'),
          error: (_, __) => const Text('キャラクター一覧'),
          data: (player) => Text('${player.name}のキャラクター'),
        ),
      ),
      body: charactersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('エラー: $error')),
        data: (characters) {
          if (characters.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'キャラクターがありません',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        context.push('/players/$playerId/characters/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('キャラクターを追加'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return CharacterCard(
                character: character,
                onTap: () => context.push(
                  '/players/$playerId/characters/${character.id}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'character_list_fab',
        onPressed: () => context.push('/players/$playerId/characters/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
