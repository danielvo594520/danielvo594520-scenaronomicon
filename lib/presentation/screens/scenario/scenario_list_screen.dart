import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/debouncer.dart';
import '../../../domain/enums/scenario_sort.dart';
import '../../providers/scenario_filter_provider.dart';
import '../../providers/scenario_provider.dart';
import '../../widgets/active_filters_row.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/scenario_card.dart';

class ScenarioListScreen extends ConsumerStatefulWidget {
  const ScenarioListScreen({super.key});

  @override
  ConsumerState<ScenarioListScreen> createState() =>
      _ScenarioListScreenState();
}

class _ScenarioListScreenState extends ConsumerState<ScenarioListScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(scenarioFilterProvider.notifier).setTitleQuery(null);
      }
    });
  }

  void _onSearchChanged(String value) {
    _debouncer.run(() {
      ref.read(scenarioFilterProvider.notifier).setTitleQuery(value);
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => FilterBottomSheet(
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showSortMenu() {
    final sortAsync = ref.read(scenarioSortProvider);
    final currentSort = sortAsync.valueOrNull ?? ScenarioSort.createdAtDesc;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'ソート',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...ScenarioSort.values.map((sort) {
                return RadioListTile<ScenarioSort>(
                  title: Text(sort.displayName),
                  value: sort,
                  groupValue: currentSort,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(scenarioSortProvider.notifier).setSort(value);
                    }
                    Navigator.of(context).pop();
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    ref.invalidate(scenarioListProvider);
    ref.invalidate(filteredScenarioListProvider);
    // providerの再読み込みを待つ
    await ref.read(filteredScenarioListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final scenariosAsync = ref.watch(filteredScenarioListProvider);
    final filter = ref.watch(scenarioFilterProvider);

    // scenarioListProviderのCRUD後にfilteredScenarioListProviderも更新
    ref.listen(scenarioListProvider, (_, __) {
      ref.invalidate(filteredScenarioListProvider);
    });

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'シナリオを検索...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('シナリオ'),
        actions: [
          // 検索ボタン
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? '検索を閉じる' : '検索',
          ),
          // フィルターボタン
          IconButton(
            icon: Badge(
              isLabelVisible: filter.hasFilter,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterSheet,
            tooltip: 'フィルター',
          ),
          // ソートボタン
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
            tooltip: 'ソート',
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: 'シナリオを追加',
        child: FloatingActionButton(
          heroTag: 'scenario_list_fab',
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/scenarios/new');
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: Column(
        children: [
          // アクティブフィルター行
          const ActiveFiltersRow(),

          // シナリオ一覧
          Expanded(
            child: scenariosAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('読み込みに失敗しました',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.invalidate(filteredScenarioListProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('再読み込み'),
                    ),
                  ],
                ),
              ),
              data: (scenarios) {
                if (scenarios.isEmpty) {
                  if (filter.hasFilter) {
                    // フィルター適用中で結果なし
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            '該当するシナリオが\n見つかりません',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              ref
                                  .read(scenarioFilterProvider.notifier)
                                  .clearAll();
                              _searchController.clear();
                              setState(() => _isSearching = false);
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('フィルターを解除'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const EmptyStateWidget(
                    message: 'シナリオがありません。\n＋ボタンから追加しましょう！',
                    icon: Icons.auto_stories_outlined,
                  );
                }

                return Column(
                  children: [
                    // 件数表示
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${scenarios.length}件',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: scenarios.length,
                          itemBuilder: (context, index) {
                            final scenario = scenarios[index];
                            return AnimatedListItem(
                              index: index,
                              child: ScenarioCard(
                                scenario: scenario,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.push(
                                      '/scenarios/${scenario.id}');
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
