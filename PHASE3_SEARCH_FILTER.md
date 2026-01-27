# Phase 3: 検索・フィルタ・ソート

## Git ブランチ

```bash
# mainから作成（Phase 2 マージ後）
git checkout main
git pull origin main
git checkout -b feature/phase3-search-filter
```

**ブランチ名:** `feature/phase3-search-filter`

## 概要

シナリオが増えてきた際に、目的のシナリオを素早く見つけるための機能を実装する。
このフェーズ完了後、タイトル検索、タグ/システム/状態によるフィルタリング、各種ソートが可能になる。

## 前提条件

- Phase 1, 2 が完了していること
- シナリオ、プレイ記録、プレイヤーの CRUD が動作していること

## 目標

- タイトルによるシナリオ検索
- タグによるフィルタリング（AND/OR 切替）
- システムによるフィルタリング
- 状態によるフィルタリング
- 複数条件の組み合わせフィルタ
- ソート機能（登録日、タイトル、プレイ回数、状態）
- ソート設定の永続化

## 実装タスク

### 1. 検索・フィルタのデータモデル

- [ ] `ScenarioFilter` クラス作成

```dart
@freezed
class ScenarioFilter with _$ScenarioFilter {
  const factory ScenarioFilter({
    String? titleQuery,           // タイトル検索文字列
    @Default([]) List<int> tagIds, // 選択されたタグID
    @Default(true) bool tagFilterAnd, // true: AND, false: OR
    int? systemId,                 // 選択されたシステムID
    ScenarioStatus? status,        // 選択された状態
  }) = _ScenarioFilter;
  
  // フィルターが設定されているか
  bool get hasFilter =>
      titleQuery != null ||
      tagIds.isNotEmpty ||
      systemId != null ||
      status != null;
}
```

- [ ] `ScenarioSort` Enum 作成

```dart
enum ScenarioSort {
  createdAtDesc('登録日（新しい順）'),
  createdAtAsc('登録日（古い順）'),
  titleAsc('タイトル（あいうえお順）'),
  titleDesc('タイトル（逆順）'),
  playCountDesc('プレイ回数（多い順）'),
  playCountAsc('プレイ回数（少ない順）'),
  statusOrder('状態別');
  
  final String displayName;
  const ScenarioSort(this.displayName);
}
```

### 2. リポジトリ層拡張

- [ ] `ScenarioRepository` に検索・フィルタメソッド追加

```dart
// ScenarioRepository
Future<List<ScenarioWithDetails>> searchAndFilter({
  required ScenarioFilter filter,
  required ScenarioSort sort,
}) async {
  var query = select(scenarios).join([
    leftOuterJoin(systems, systems.id.equalsExp(scenarios.systemId)),
  ]);
  
  // タイトル検索
  if (filter.titleQuery != null && filter.titleQuery!.isNotEmpty) {
    query = query..where(scenarios.title.contains(filter.titleQuery!));
  }
  
  // システムフィルタ
  if (filter.systemId != null) {
    query = query..where(scenarios.systemId.equals(filter.systemId!));
  }
  
  // 状態フィルタ
  if (filter.status != null) {
    query = query..where(scenarios.status.equals(filter.status!.name));
  }
  
  // ソート適用
  switch (sort) {
    case ScenarioSort.createdAtDesc:
      query = query..orderBy([OrderingTerm.desc(scenarios.createdAt)]);
      break;
    case ScenarioSort.createdAtAsc:
      query = query..orderBy([OrderingTerm.asc(scenarios.createdAt)]);
      break;
    case ScenarioSort.titleAsc:
      query = query..orderBy([OrderingTerm.asc(scenarios.title)]);
      break;
    // ... 他のソート
  }
  
  final results = await query.get();
  
  // タグフィルタ（AND/OR）はアプリ側で処理
  if (filter.tagIds.isNotEmpty) {
    return _filterByTags(results, filter.tagIds, filter.tagFilterAnd);
  }
  
  return results;
}

// タグによるフィルタリング
List<ScenarioWithDetails> _filterByTags(
  List<ScenarioWithDetails> scenarios,
  List<int> tagIds,
  bool isAnd,
) {
  return scenarios.where((scenario) {
    final scenarioTagIds = scenario.tags.map((t) => t.id).toSet();
    if (isAnd) {
      // AND: すべてのタグを持っている
      return tagIds.every((id) => scenarioTagIds.contains(id));
    } else {
      // OR: いずれかのタグを持っている
      return tagIds.any((id) => scenarioTagIds.contains(id));
    }
  }).toList();
}
```

### 3. ソート設定の永続化

- [ ] SharedPreferences でソート設定を保存

```dart
class SortPreferences {
  static const _key = 'scenario_sort';
  
  static Future<ScenarioSort> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) return ScenarioSort.createdAtDesc;
    return ScenarioSort.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ScenarioSort.createdAtDesc,
    );
  }
  
  static Future<void> save(ScenarioSort sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, sort.name);
  }
}
```

### 4. Riverpod プロバイダー

- [ ] `scenarioFilterProvider` - 現在のフィルタ状態
- [ ] `scenarioSortProvider` - 現在のソート設定
- [ ] `filteredScenarioListProvider` - フィルタ・ソート適用済みリスト

```dart
// フィルタ状態
@riverpod
class ScenarioFilterNotifier extends _$ScenarioFilterNotifier {
  @override
  ScenarioFilter build() => const ScenarioFilter();
  
  void setTitleQuery(String? query) {
    state = state.copyWith(titleQuery: query);
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
    state = state.copyWith(systemId: id);
  }
  
  void setStatus(ScenarioStatus? status) {
    state = state.copyWith(status: status);
  }
  
  void clearAll() {
    state = const ScenarioFilter();
  }
}

// ソート状態（永続化あり）
@riverpod
class ScenarioSortNotifier extends _$ScenarioSortNotifier {
  @override
  Future<ScenarioSort> build() async {
    return SortPreferences.load();
  }
  
  Future<void> setSort(ScenarioSort sort) async {
    await SortPreferences.save(sort);
    state = AsyncValue.data(sort);
  }
}
```

### 5. UI実装

#### 検索バー
- [ ] AppBar に検索アイコン
- [ ] タップで検索モードに切り替え
- [ ] リアルタイム検索（デバウンス 300ms）

```dart
class ScenarioSearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'シナリオを検索...',
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            // 検索クリア
          },
        ),
      ),
      onChanged: (value) {
        // デバウンスして検索実行
        ref.read(scenarioFilterProvider.notifier).setTitleQuery(value);
      },
    );
  }
}
```

#### フィルターボトムシート
- [ ] フィルターアイコンタップで表示
- [ ] タグ選択（チップ形式、複数選択可）
- [ ] AND/OR 切り替えスイッチ
- [ ] システム選択（ドロップダウン）
- [ ] 状態選択（チップ形式）
- [ ] 「フィルターをクリア」ボタン
- [ ] 適用ボタン

```dart
void _showFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => FilterBottomSheet(
        scrollController: scrollController,
      ),
    ),
  );
}
```

#### ソートメニュー
- [ ] ソートアイコンまたはドロップダウン
- [ ] 現在のソート設定を表示
- [ ] タップで選択

```dart
PopupMenuButton<ScenarioSort>(
  icon: Icon(Icons.sort),
  onSelected: (sort) {
    ref.read(scenarioSortProvider.notifier).setSort(sort);
  },
  itemBuilder: (context) => ScenarioSort.values.map((sort) {
    return PopupMenuItem(
      value: sort,
      child: Text(sort.displayName),
    );
  }).toList(),
)
```

#### フィルター適用中の表示
- [ ] AppBar 下にフィルターチップを表示
- [ ] 各チップに×ボタンで個別解除
- [ ] 「すべて解除」リンク

```dart
class ActiveFiltersRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(scenarioFilterProvider);
    if (!filter.hasFilter) return SizedBox.shrink();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (filter.titleQuery != null)
            FilterChip(
              label: Text('「${filter.titleQuery}」'),
              onDeleted: () => ref.read(...).setTitleQuery(null),
            ),
          // タグ、システム、状態のチップ...
          TextButton(
            onPressed: () => ref.read(...).clearAll(),
            child: Text('すべて解除'),
          ),
        ],
      ),
    );
  }
}
```

#### 検索結果の空状態
- [ ] 「該当するシナリオが見つかりません」メッセージ
- [ ] 「フィルターを解除」ボタン

### 6. パフォーマンス最適化

- [ ] 検索入力のデバウンス（300ms）
- [ ] リスト表示の `ListView.builder` 使用
- [ ] 画像の遅延読み込み（Phase 4 で詳細実装）

```dart
// デバウンス実装
class Debouncer {
  final Duration duration;
  Timer? _timer;
  
  Debouncer({this.duration = const Duration(milliseconds: 300)});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}
```

## 画面モックアップ（参考）

### シナリオ一覧（検索・フィルタ適用中）
```
┌─────────────────────────────┐
│ 🔍 狂気              ✕     │
├─────────────────────────────┤
│ [ホラー ✕] [準備完了 ✕]    │
│ [すべて解除]                │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 狂気山脈                │ │
│ │ [新クトゥルフ] [準備完了]│ │
│ │ [ホラー] [シリアス]     │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 狂気の宴                │ │
│ │ [新クトゥルフ] [準備完了]│ │
│ │ [ホラー]                │ │
│ └─────────────────────────┘ │
│                             │
│ 2件見つかりました           │
├─────────────────────────────┤
│ 📋    📝    👥    ⚙️      │
└─────────────────────────────┘
```

### フィルターボトムシート
```
┌─────────────────────────────┐
│ ──────                      │
│                             │
│ フィルター                  │
│                             │
│ タグ                        │
│ [ホラー✓] [ファンタジー]    │
│ [現代] [SF] [ミステリー]    │
│                             │
│ タグの条件                  │
│ ○ すべて含む (AND)         │
│ ● いずれか含む (OR)         │
│                             │
│ ───────────────────────     │
│                             │
│ システム                    │
│ ┌─────────────────────────┐ │
│ │ すべて              ▼   │ │
│ └─────────────────────────┘ │
│                             │
│ 状態                        │
│ [未読] [準備中] [準備完了✓] │
│ [回した] [アーカイブ]       │
│                             │
│ ───────────────────────     │
│                             │
│ [フィルターをクリア]        │
│                             │
│    ┌─────────────────┐      │
│    │      適用       │      │
│    └─────────────────┘      │
└─────────────────────────────┘
```

### ソートメニュー
```
┌─────────────────────────────┐
│ ● 登録日（新しい順）        │
│ ○ 登録日（古い順）          │
│ ○ タイトル（あいうえお順）  │
│ ○ タイトル（逆順）          │
│ ○ プレイ回数（多い順）      │
│ ○ プレイ回数（少ない順）    │
│ ○ 状態別                    │
└─────────────────────────────┘
```

### 検索結果なし
```
┌─────────────────────────────┐
│ 🔍 存在しないシナリオ  ✕   │
├─────────────────────────────┤
│                             │
│                             │
│         🔍                  │
│                             │
│ 該当するシナリオが          │
│ 見つかりません              │
│                             │
│ [フィルターを解除]          │
│                             │
│                             │
├─────────────────────────────┤
│ 📋    📝    👥    ⚙️      │
└─────────────────────────────┘
```

## 完了条件

- [ ] タイトルで検索できる
- [ ] タグで絞り込みできる（AND/OR 切り替え可能）
- [ ] システムで絞り込みできる
- [ ] 状態で絞り込みできる
- [ ] 複数条件を組み合わせてフィルタできる
- [ ] 登録日、タイトル、プレイ回数、状態でソートできる
- [ ] ソート設定がアプリ再起動後も保持される
- [ ] フィルター適用中に現在の条件が表示される
- [ ] 検索結果がない場合に適切なメッセージが表示される
- [ ] 検索入力がスムーズ（デバウンス）

## 注意事項

- タグのAND検索は、シナリオ数が多い場合パフォーマンスに影響する可能性があるため、アプリ側でフィルタリング
- 検索は大文字小文字を区別しない（日本語は関係なし）
- プレイ回数でのソートは、事前に集計しておくか、毎回計算するか検討（データ量次第）

## PR作成

Phase 3 の全タスクが完了したら、PRを作成してmainにマージする。

```bash
# 変更をプッシュ
git push origin feature/phase3-search-filter
```

### PR テンプレート

```markdown
## Phase 3: 検索・フィルタ・ソート

### 概要
シナリオの検索・フィルタリング・ソート機能を実装しました。

### 変更内容
- タイトルによるシナリオ検索
- タグによるフィルタリング（AND/OR切替）
- システムによるフィルタリング
- 状態によるフィルタリング
- 複数条件の組み合わせフィルタ
- ソート機能（登録日、タイトル、プレイ回数、状態）
- ソート設定の永続化

### 完了条件
- [ ] タイトルで検索できる
- [ ] タグで絞り込みできる（AND/OR切り替え可能）
- [ ] システムで絞り込みできる
- [ ] 状態で絞り込みできる
- [ ] 複数条件を組み合わせてフィルタできる
- [ ] 登録日、タイトル、プレイ回数、状態でソートできる
- [ ] ソート設定がアプリ再起動後も保持される
- [ ] フィルター適用中に現在の条件が表示される
- [ ] 検索結果がない場合に適切なメッセージが表示される
- [ ] 検索入力がスムーズ（デバウンス）

### スクリーンショット
（画面キャプチャを添付）
```

## 次のフェーズへ

PRがマージされたら、Phase 4（画像対応・UI改善）に進む。

```bash
git checkout main
git pull origin main
git checkout -b feature/phase4-polish
```
