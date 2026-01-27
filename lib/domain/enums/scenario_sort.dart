/// シナリオのソート順
enum ScenarioSort {
  createdAtDesc('登録日（新しい順）'),
  createdAtAsc('登録日（古い順）'),
  titleAsc('タイトル（あいうえお順）'),
  titleDesc('タイトル（逆順）'),
  playCountDesc('プレイ回数（多い順）'),
  playCountAsc('プレイ回数（少ない順）'),
  statusOrder('状態別');

  const ScenarioSort(this.displayName);

  final String displayName;
}
