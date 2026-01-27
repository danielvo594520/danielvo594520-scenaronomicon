import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/scenario_provider.dart';

/// シナリオ検索選択ドロップダウン
class ScenarioSearchDropdown extends ConsumerWidget {
  const ScenarioSearchDropdown({
    super.key,
    this.selectedScenarioId,
    required this.onChanged,
  });

  final int? selectedScenarioId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return scenariosAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('シナリオの読み込みに失敗しました'),
      data: (scenarios) {
        return DropdownButtonFormField<int?>(
          value: selectedScenarioId,
          decoration: const InputDecoration(
            labelText: 'シナリオ',
            hintText: 'シナリオを選択',
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('未選択'),
            ),
            ...scenarios.map((scenario) {
              return DropdownMenuItem<int?>(
                value: scenario.id,
                child: Text(
                  scenario.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: onChanged,
          isExpanded: true,
        );
      },
    );
  }
}
