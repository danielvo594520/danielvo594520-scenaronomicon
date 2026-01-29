import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/player_with_stats.dart';
import '../providers/player_provider.dart';
import 'player_thumbnail.dart';

/// KP（ゲームマスター）選択ウィジェット
class KpSelect extends ConsumerWidget {
  const KpSelect({
    super.key,
    required this.selectedKpIds,
    required this.onChanged,
  });

  final List<int> selectedKpIds;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playerListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.theater_comedy, size: 20),
                const SizedBox(width: 8),
                Text(
                  'KP（ゲームマスター）',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showKpSelectDialog(context, ref),
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
            if (selectedKpIds.isEmpty) {
              return InkWell(
                onTap: () => _showKpSelectDialog(context, ref),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withAlpha(128),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'タップしてKPを選択',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: selectedKpIds.map((kpId) {
                final player = players.firstWhere(
                  (p) => p.id == kpId,
                  orElse: () => PlayerWithStats(
                    id: kpId,
                    name: '不明',
                    sessionCount: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                return _KpRow(
                  player: player,
                  onRemove: () {
                    final newIds =
                        selectedKpIds.where((id) => id != kpId).toList();
                    onChanged(newIds);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showKpSelectDialog(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.read(playerListProvider);
    playersAsync.whenData((players) {
      // 既に選択済みのKPを除外（参加プレイヤーとの重複は許可）
      final availablePlayers = players
          .where((p) => !selectedKpIds.contains(p.id))
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
                  'KPを選択',
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
                      leading: PlayerThumbnail(
                        imagePath: player.imagePath,
                        size: 40,
                      ),
                      title: Text(player.name),
                      onTap: () {
                        Navigator.pop(context);
                        final newIds = [...selectedKpIds, player.id];
                        onChanged(newIds);
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

class _KpRow extends StatelessWidget {
  const _KpRow({
    required this.player,
    required this.onRemove,
  });

  final PlayerWithStats player;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PlayerThumbnail(
              imagePath: player.imagePath,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                player.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
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
}
