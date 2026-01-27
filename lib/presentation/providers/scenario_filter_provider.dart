import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/sort_preferences.dart';
import '../../domain/enums/scenario_sort.dart';
import '../../domain/enums/scenario_status.dart';
import '../../domain/models/scenario_filter.dart';
import '../../domain/models/scenario_with_tags.dart';
import 'database_provider.dart';

/// フィルタ状態のプロバイダー
final scenarioFilterProvider =
    NotifierProvider<ScenarioFilterNotifier, ScenarioFilter>(
  ScenarioFilterNotifier.new,
);

class ScenarioFilterNotifier extends Notifier<ScenarioFilter> {
  @override
  ScenarioFilter build() => const ScenarioFilter();

  void setTitleQuery(String? query) {
    state = state.copyWith(
      titleQuery: () => (query != null && query.isEmpty) ? null : query,
    );
  }

  void toggleTag(int tagId) {
    final current = List<int>.from(state.tagIds);
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }
    state = state.copyWith(tagIds: current);
  }

  void setTagFilterMode(bool isAnd) {
    state = state.copyWith(tagFilterAnd: isAnd);
  }

  void setSystemId(int? id) {
    state = state.copyWith(systemId: () => id);
  }

  void setStatus(ScenarioStatus? status) {
    state = state.copyWith(status: () => status);
  }

  void clearAll() {
    state = const ScenarioFilter();
  }
}

/// ソート状態のプロバイダー（永続化あり）
final scenarioSortProvider =
    AsyncNotifierProvider<ScenarioSortNotifier, ScenarioSort>(
  ScenarioSortNotifier.new,
);

class ScenarioSortNotifier extends AsyncNotifier<ScenarioSort> {
  @override
  Future<ScenarioSort> build() async {
    return SortPreferences.load();
  }

  Future<void> setSort(ScenarioSort sort) async {
    await SortPreferences.save(sort);
    state = AsyncValue.data(sort);
  }
}

/// フィルタ・ソート適用済みシナリオ一覧のプロバイダー
final filteredScenarioListProvider =
    AsyncNotifierProvider<FilteredScenarioListNotifier, List<ScenarioWithTags>>(
  FilteredScenarioListNotifier.new,
);

class FilteredScenarioListNotifier
    extends AsyncNotifier<List<ScenarioWithTags>> {
  @override
  Future<List<ScenarioWithTags>> build() async {
    final filter = ref.watch(scenarioFilterProvider);
    final sortAsync = ref.watch(scenarioSortProvider);
    final sort = sortAsync.valueOrNull ?? ScenarioSort.createdAtDesc;

    final repo = ref.watch(scenarioRepositoryProvider);

    // プレイ回数ソートの場合はプレイ回数マップを取得
    Map<int, int> playCountMap = {};
    if (sort == ScenarioSort.playCountDesc ||
        sort == ScenarioSort.playCountAsc) {
      playCountMap = await repo.getAllPlayCounts();
    }

    return repo.searchAndFilter(
      filter: filter,
      sort: sort,
      playCountMap: playCountMap,
    );
  }

  void refresh() {
    ref.invalidateSelf();
  }
}
