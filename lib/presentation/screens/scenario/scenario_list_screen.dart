import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/scenario_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/scenario_card.dart';

class ScenarioListScreen extends ConsumerWidget {
  const ScenarioListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('シナリオ')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scenarios/new'),
        child: const Icon(Icons.add),
      ),
      body: scenariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('エラー: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(scenarioListProvider),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return const EmptyStateWidget(
              message: 'シナリオがありません。\n＋ボタンから追加しましょう！',
              icon: Icons.auto_stories_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: scenarios.length,
            itemBuilder: (context, index) {
              final scenario = scenarios[index];
              return ScenarioCard(
                scenario: scenario,
                onTap: () => context.push('/scenarios/${scenario.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
