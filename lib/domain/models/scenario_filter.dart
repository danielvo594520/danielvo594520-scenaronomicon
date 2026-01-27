import '../enums/scenario_status.dart';

/// シナリオ検索・フィルタの条件を保持するモデル
class ScenarioFilter {
  const ScenarioFilter({
    this.titleQuery,
    this.tagIds = const [],
    this.tagFilterAnd = true,
    this.systemId,
    this.status,
  });

  /// タイトル検索文字列
  final String? titleQuery;

  /// 選択されたタグID
  final List<int> tagIds;

  /// true: AND検索（すべて含む）, false: OR検索（いずれか含む）
  final bool tagFilterAnd;

  /// 選択されたシステムID
  final int? systemId;

  /// 選択された状態
  final ScenarioStatus? status;

  /// フィルターが設定されているか
  bool get hasFilter =>
      (titleQuery != null && titleQuery!.isNotEmpty) ||
      tagIds.isNotEmpty ||
      systemId != null ||
      status != null;

  ScenarioFilter copyWith({
    String? Function()? titleQuery,
    List<int>? tagIds,
    bool? tagFilterAnd,
    int? Function()? systemId,
    ScenarioStatus? Function()? status,
  }) {
    return ScenarioFilter(
      titleQuery: titleQuery != null ? titleQuery() : this.titleQuery,
      tagIds: tagIds ?? this.tagIds,
      tagFilterAnd: tagFilterAnd ?? this.tagFilterAnd,
      systemId: systemId != null ? systemId() : this.systemId,
      status: status != null ? status() : this.status,
    );
  }
}
