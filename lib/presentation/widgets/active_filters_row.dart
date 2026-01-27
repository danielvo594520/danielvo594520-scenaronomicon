import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../providers/scenario_filter_provider.dart';
import '../providers/system_provider.dart';
import '../providers/tag_provider.dart';

/// フィルター適用中に表示するチップ行
class ActiveFiltersRow extends ConsumerWidget {
  const ActiveFiltersRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(scenarioFilterProvider);
    if (!filter.hasFilter) return const SizedBox.shrink();

    final tagsAsync = ref.watch(tagListProvider);
    final systemsAsync = ref.watch(systemListProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // タイトル検索チップ
          if (filter.titleQuery != null && filter.titleQuery!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InputChip(
                label: Text('「${filter.titleQuery}」'),
                onDeleted: () {
                  ref
                      .read(scenarioFilterProvider.notifier)
                      .setTitleQuery(null);
                },
              ),
            ),

          // タグチップ
          ...tagsAsync.whenOrNull(
                data: (tags) {
                  return filter.tagIds.map((tagId) {
                    final tag = tags.cast<Tag?>().firstWhere(
                          (t) => t?.id == tagId,
                          orElse: () => null,
                        );
                    if (tag == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        label: Text(tag.name),
                        onDeleted: () {
                          ref
                              .read(scenarioFilterProvider.notifier)
                              .toggleTag(tagId);
                        },
                      ),
                    );
                  }).toList();
                },
              ) ??
              [],

          // AND/OR表示
          if (filter.tagIds.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(filter.tagFilterAnd ? 'AND' : 'OR'),
                visualDensity: VisualDensity.compact,
              ),
            ),

          // システムチップ
          if (filter.systemId != null)
            ...systemsAsync.whenOrNull(
                  data: (systems) {
                    final system = systems.cast<System?>().firstWhere(
                          (s) => s?.id == filter.systemId,
                          orElse: () => null,
                        );
                    if (system == null) return <Widget>[];
                    return [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InputChip(
                          label: Text(system.name),
                          onDeleted: () {
                            ref
                                .read(scenarioFilterProvider.notifier)
                                .setSystemId(null);
                          },
                        ),
                      ),
                    ];
                  },
                ) ??
                [],

          // 状態チップ
          if (filter.status != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InputChip(
                label: Text(filter.status!.displayName),
                onDeleted: () {
                  ref
                      .read(scenarioFilterProvider.notifier)
                      .setStatus(null);
                },
              ),
            ),

          // すべて解除
          TextButton(
            onPressed: () {
              ref.read(scenarioFilterProvider.notifier).clearAll();
            },
            child: const Text('すべて解除'),
          ),
        ],
      ),
    );
  }
}
