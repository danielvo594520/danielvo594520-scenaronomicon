import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';

/// プレイヤー複数選択ウィジェット（FilterChipベース）
class PlayerMultiSelect extends ConsumerWidget {
  const PlayerMultiSelect({
    super.key,
    required this.selectedPlayerIds,
    required this.onChanged,
  });

  final Set<int> selectedPlayerIds;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playerListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '参加プレイヤー',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 8),
        playersAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('プレイヤーの読み込みに失敗しました'),
          data: (players) {
            if (players.isEmpty) {
              return Text(
                'プレイヤーが登録されていません',
                style: TextStyle(color: Colors.grey[400]),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 4,
              children: players.map((player) {
                final isSelected = selectedPlayerIds.contains(player.id);
                return FilterChip(
                  label: Text(player.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newSet = Set<int>.from(selectedPlayerIds);
                    if (selected) {
                      newSet.add(player.id);
                    } else {
                      newSet.remove(player.id);
                    }
                    onChanged(newSet);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
