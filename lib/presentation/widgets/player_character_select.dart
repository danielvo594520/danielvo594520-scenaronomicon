import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/player_character_pair.dart';
import '../../domain/models/player_with_stats.dart';
import '../providers/character_provider.dart';
import '../providers/player_provider.dart';
import 'character_thumbnail.dart';

/// プレイヤーとキャラクターを選択するウィジェット
class PlayerCharacterSelect extends ConsumerStatefulWidget {
  const PlayerCharacterSelect({
    super.key,
    required this.selectedPairs,
    required this.onChanged,
  });

  final List<PlayerCharacterPair> selectedPairs;
  final ValueChanged<List<PlayerCharacterPair>> onChanged;

  @override
  ConsumerState<PlayerCharacterSelect> createState() =>
      _PlayerCharacterSelectState();
}

class _PlayerCharacterSelectState extends ConsumerState<PlayerCharacterSelect> {
  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playerListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '参加プレイヤー',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextButton.icon(
              onPressed: () => _showPlayerSelectDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('追加'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        playersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('プレイヤーの読み込みに失敗しました'),
          data: (players) {
            if (widget.selectedPairs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withAlpha(128),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'プレイヤーを選択してください',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              );
            }

            return Column(
              children: widget.selectedPairs.map((pair) {
                final player = players.firstWhere(
                  (p) => p.id == pair.playerId,
                  orElse: () => PlayerWithStats(
                    id: pair.playerId,
                    name: '不明',
                    sessionCount: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                return _PlayerCharacterRow(
                  player: player,
                  characterId: pair.characterId,
                  onCharacterChanged: (charId) {
                    final newPairs = widget.selectedPairs.map((p) {
                      if (p.playerId == pair.playerId) {
                        return p.copyWith(characterId: () => charId);
                      }
                      return p;
                    }).toList();
                    widget.onChanged(newPairs);
                  },
                  onRemove: () {
                    final newPairs = widget.selectedPairs
                        .where((p) => p.playerId != pair.playerId)
                        .toList();
                    widget.onChanged(newPairs);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showPlayerSelectDialog(BuildContext context) {
    final playersAsync = ref.read(playerListProvider);
    playersAsync.whenData((players) {
      // 既に選択済みのプレイヤーを除外
      final availablePlayers = players
          .where((p) =>
              !widget.selectedPairs.any((pair) => pair.playerId == p.id))
          .toList();

      if (availablePlayers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('追加できるプレイヤーがありません')),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'プレイヤーを選択',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: availablePlayers.length,
                  itemBuilder: (context, index) {
                    final player = availablePlayers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(player.name.substring(0, 1)),
                      ),
                      title: Text(player.name),
                      onTap: () {
                        Navigator.pop(context);
                        final newPairs = [
                          ...widget.selectedPairs,
                          PlayerCharacterPair(playerId: player.id),
                        ];
                        widget.onChanged(newPairs);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PlayerCharacterRow extends ConsumerWidget {
  const _PlayerCharacterRow({
    required this.player,
    required this.characterId,
    required this.onCharacterChanged,
    required this.onRemove,
  });

  final PlayerWithStats player;
  final int? characterId;
  final ValueChanged<int?> onCharacterChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(characterListProvider(player.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // プレイヤー情報
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    child: Text(
                      player.name.substring(0, 1),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            // キャラクター選択
            Expanded(
              flex: 3,
              child: charactersAsync.when(
                loading: () => const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Text('-'),
                data: (characters) {
                  if (characters.isEmpty) {
                    return Text(
                      'キャラクターなし',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }

                  final selectedCharacter = characterId != null
                      ? characters.firstWhere(
                          (c) => c.id == characterId,
                          orElse: () => characters.first,
                        )
                      : null;

                  return InkWell(
                    onTap: () => _showCharacterSelect(context, characters),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withAlpha(128),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (selectedCharacter != null) ...[
                            CharacterThumbnail(
                              imagePath: selectedCharacter.imagePath,
                              size: 24,
                              borderRadius: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedCharacter.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.person_outline, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '選択なし',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 削除ボタン
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                onRemove();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  void _showCharacterSelect(
    BuildContext context,
    List<dynamic> characters,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'キャラクターを選択',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('選択なし'),
              onTap: () {
                Navigator.pop(context);
                onCharacterChanged(null);
              },
            ),
            ...characters.map((character) {
              return ListTile(
                leading: CharacterThumbnail(
                  imagePath: character.imagePath,
                  size: 40,
                  borderRadius: 20,
                ),
                title: Text(character.name),
                trailing: character.id == characterId
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onCharacterChanged(character.id);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
