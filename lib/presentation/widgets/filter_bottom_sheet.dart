import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/color_utils.dart';
import '../../domain/enums/scenario_status.dart';
import '../providers/scenario_filter_provider.dart';
import '../providers/system_provider.dart';
import '../providers/tag_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(scenarioFilterProvider);
    final tagsAsync = ref.watch(tagListProvider);
    final systemsAsync = ref.watch(systemListProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        controller: scrollController,
        children: [
          // ハンドル
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // タイトル
          Text(
            'フィルター',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // タグセクション
          Text(
            'タグ',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          tagsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('エラー: $e'),
            data: (tags) {
              if (tags.isEmpty) {
                return const Text('タグがありません',
                    style: TextStyle(color: Colors.grey));
              }
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tags.map((tag) {
                  final isSelected = filter.tagIds.contains(tag.id);
                  final color = ColorUtils.hexToColor(tag.color);
                  return FilterChip(
                    label: Text(tag.name),
                    selected: isSelected,
                    selectedColor: color.withOpacity(0.3),
                    checkmarkColor: color,
                    onSelected: (_) {
                      ref
                          .read(scenarioFilterProvider.notifier)
                          .toggleTag(tag.id);
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),

          // タグ条件（AND/OR）
          if (filter.tagIds.isNotEmpty) ...[
            Text(
              'タグの条件',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('すべて含む (AND)'),
                    value: true,
                    groupValue: filter.tagFilterAnd,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(scenarioFilterProvider.notifier)
                            .setTagFilterMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('いずれか含む (OR)'),
                    value: false,
                    groupValue: filter.tagFilterAnd,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(scenarioFilterProvider.notifier)
                            .setTagFilterMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          const Divider(),
          const SizedBox(height: 8),

          // システムセクション
          Text(
            'システム',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          systemsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('エラー: $e'),
            data: (systems) {
              return DropdownButtonFormField<int?>(
                value: filter.systemId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('すべて'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('すべて'),
                  ),
                  ...systems.map((system) {
                    return DropdownMenuItem<int?>(
                      value: system.id,
                      child: Text(system.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  ref
                      .read(scenarioFilterProvider.notifier)
                      .setSystemId(value);
                },
              );
            },
          ),
          const SizedBox(height: 16),

          const Divider(),
          const SizedBox(height: 8),

          // 状態セクション
          Text(
            '状態',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ScenarioStatus.values.map((status) {
              final isSelected = filter.status == status;
              return FilterChip(
                label: Text(status.displayName),
                selected: isSelected,
                selectedColor: status.color.withOpacity(0.3),
                checkmarkColor: status.color,
                onSelected: (_) {
                  ref.read(scenarioFilterProvider.notifier).setStatus(
                        isSelected ? null : status,
                      );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const Divider(),
          const SizedBox(height: 8),

          // フィルタークリアボタン
          if (filter.hasFilter)
            TextButton.icon(
              onPressed: () {
                ref.read(scenarioFilterProvider.notifier).clearAll();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('フィルターをクリア'),
            ),

          const SizedBox(height: 8),

          // 適用ボタン
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('適用'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
