# Phase 2: プレイ記録・プレイヤー管理

## Git ブランチ

```bash
# mainから作成（Phase 1 マージ後）
git checkout main
git pull origin main
git checkout -b feature/phase2-play-records
```

**ブランチ名:** `feature/phase2-play-records`

## 概要

シナリオをプレイした記録と、一緒にプレイするプレイヤーの管理機能を実装する。
このフェーズ完了後、「誰と」「いつ」「どのシナリオを」回したかを記録・確認できるようになる。

## 前提条件

- Phase 1 が完了していること
- シナリオ、システム、タグの CRUD が動作していること

## 目標

- プレイヤーの CRUD 機能
- プレイ記録の CRUD 機能
- シナリオのプレイ回数自動集計
- プレイヤー別の参加履歴表示

## 実装タスク

### 1. データベース拡張

- [ ] テーブル追加:
  - [ ] `players`
  - [ ] `play_sessions`
  - [ ] `play_session_players`
- [ ] マイグレーション実行

#### players テーブル
```dart
class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```

#### play_sessions テーブル
```dart
class PlaySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scenarioId => integer().nullable().references(Scenarios, #id)();
  DateTimeColumn get playedAt => dateTime()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```

#### play_session_players 中間テーブル
```dart
class PlaySessionPlayers extends Table {
  IntColumn get playSessionId => integer().references(PlaySessions, #id)();
  IntColumn get playerId => integer().references(Players, #id)();

  @override
  Set<Column> get primaryKey => {playSessionId, playerId};
}
```

### 2. リポジトリ層拡張

- [ ] `PlayerRepository` - プレイヤーの CRUD
- [ ] `PlaySessionRepository` - プレイ記録の CRUD

#### 削除時の挙動実装
```dart
// ScenarioRepository (更新)
Future<void> delete(int id) async {
  // タグ紐付き削除
  await (delete(scenarioTags)..where((t) => t.scenarioId.equals(id))).go();
  // プレイ記録のscenario_idをNULLに
  await (update(playSessions)..where((t) => t.scenarioId.equals(id)))
    .write(PlaySessionsCompanion(scenarioId: const Value(null)));
  // シナリオ削除
  await (delete(scenarios)..where((t) => t.id.equals(id))).go();
}

// PlayerRepository
Future<void> delete(int id) async {
  // プレイ記録との紐付き削除
  await (delete(playSessionPlayers)..where((t) => t.playerId.equals(id))).go();
  // プレイヤー削除
  await (delete(players)..where((t) => t.id.equals(id))).go();
}

// PlaySessionRepository
Future<void> delete(int id) async {
  // プレイヤー紐付き削除
  await (delete(playSessionPlayers)..where((t) => t.playSessionId.equals(id))).go();
  // プレイ記録削除
  await (delete(playSessions)..where((t) => t.id.equals(id))).go();
}
```

#### プレイ回数取得
```dart
// ScenarioRepository
Future<int> getPlayCount(int scenarioId) async {
  final result = await (select(playSessions)
    ..where((t) => t.scenarioId.equals(scenarioId)))
    .get();
  return result.length;
}

// シナリオ一覧で使用するための結合クエリ
Stream<List<ScenarioWithPlayCount>> watchAllWithPlayCount() {
  final query = select(scenarios).join([
    leftOuterJoin(
      playSessions,
      playSessions.scenarioId.equalsExp(scenarios.id),
    ),
  ]);
  
  // GROUP BY と COUNT でプレイ回数を取得
  // ...
}
```

#### プレイヤー別参加回数取得
```dart
// PlayerRepository
Future<int> getSessionCount(int playerId) async {
  final result = await (select(playSessionPlayers)
    ..where((t) => t.playerId.equals(playerId)))
    .get();
  return result.length;
}

// プレイヤーが参加したシナリオ一覧
Future<List<Scenario>> getPlayedScenarios(int playerId) async {
  final sessions = await (select(playSessionPlayers)
    .join([
      innerJoin(playSessions, playSessions.id.equalsExp(playSessionPlayers.playSessionId)),
      innerJoin(scenarios, scenarios.id.equalsExp(playSessions.scenarioId)),
    ])
    ..where(playSessionPlayers.playerId.equals(playerId)))
    .get();
  
  // 重複を除いてシナリオリストを返す
  // ...
}
```

### 3. Riverpod プロバイダー拡張

- [ ] `playerListProvider` - プレイヤー一覧
- [ ] `playerDetailProvider` - プレイヤー詳細（参加履歴含む）
- [ ] `playSessionListProvider` - プレイ記録一覧
- [ ] `playSessionsByScenarioProvider` - シナリオ別プレイ記録
- [ ] `scenarioPlayCountProvider` - シナリオのプレイ回数

### 4. 画面実装

#### プレイヤー関連
- [ ] **PL-001: プレイヤー一覧**
  - リスト形式
  - 名前と参加セッション数を表示
  - FABで追加
  - 空状態の表示
- [ ] **PL-002: プレイヤー詳細**
  - 名前、メモ表示
  - 参加セッション数
  - 参加したシナリオ一覧（タップでシナリオ詳細へ）
  - 編集・削除ボタン
- [ ] **PL-003: プレイヤー追加/編集**
  - 名前（必須）
  - メモ（任意）

#### プレイ記録関連
- [ ] **PS-001: プレイ記録一覧**
  - 日付降順でリスト表示
  - シナリオタイトル、プレイ日、参加人数
  - シナリオが削除されている場合は「削除されたシナリオ」と表示
  - FABで追加
  - 空状態の表示
- [ ] **PS-002: プレイ記録追加/編集**
  - シナリオ選択（検索可能ドロップダウン）
  - プレイ日（DatePicker）
  - 参加プレイヤー（マルチセレクト）
  - メモ

#### シナリオ詳細画面の更新
- [ ] **SC-002: シナリオ詳細**（更新）
  - プレイ回数を表示
  - プレイ履歴一覧を表示（日付、参加者）
  - 「プレイ記録を追加」ボタン

### 5. 共通ウィジェット追加

- [ ] `PlayerListTile` - プレイヤー一覧用
- [ ] `PlaySessionCard` - プレイ記録カード
- [ ] `PlayerMultiSelect` - プレイヤー複数選択ウィジェット
- [ ] `ScenarioSearchDropdown` - シナリオ検索選択

## 画面モックアップ（参考）

### プレイヤー一覧
```
┌─────────────────────────────┐
│ プレイヤー                  │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 👤 田中さん             │ │
│ │    参加: 5回            │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 👤 鈴木さん             │ │
│ │    参加: 3回            │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 👤 佐藤さん             │ │
│ │    参加: 8回            │ │
│ └─────────────────────────┘ │
│                             │
│                         [+] │
├─────────────────────────────┤
│ 📋    📝    👥    ⚙️      │
└─────────────────────────────┘
```

### プレイ記録一覧
```
┌─────────────────────────────┐
│ プレイ記録                  │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 2025/01/20              │ │
│ │ 狂気山脈                │ │
│ │ 👥 田中、鈴木、佐藤     │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 2025/01/15              │ │
│ │ 毒入りスープ            │ │
│ │ 👥 田中、山田           │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 2025/01/10              │ │
│ │ [削除されたシナリオ]    │ │
│ │ 👥 鈴木                 │ │
│ └─────────────────────────┘ │
│                             │
│                         [+] │
├─────────────────────────────┤
│ 📋    📝    👥    ⚙️      │
└─────────────────────────────┘
```

### プレイ記録追加
```
┌─────────────────────────────┐
│ ← プレイ記録を追加          │
├─────────────────────────────┤
│                             │
│ シナリオ *                  │
│ ┌─────────────────────────┐ │
│ │ 🔍 シナリオを検索...    │ │
│ └─────────────────────────┘ │
│                             │
│ プレイ日 *                  │
│ ┌─────────────────────────┐ │
│ │ 📅 2025/01/27           │ │
│ └─────────────────────────┘ │
│                             │
│ 参加プレイヤー              │
│ [田中] [鈴木] [+ 追加]      │
│                             │
│ メモ                        │
│ ┌─────────────────────────┐ │
│ │                         │ │
│ │                         │ │
│ └─────────────────────────┘ │
│                             │
│    ┌─────────────────┐      │
│    │      保存       │      │
│    └─────────────────┘      │
└─────────────────────────────┘
```

### シナリオ詳細（更新後）
```
┌─────────────────────────────┐
│ ← 狂気山脈         ✏️  🗑️  │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │      🖼️ サムネイル      │ │
│ └─────────────────────────┘ │
│                             │
│ [新クトゥルフ]  [準備完了]  │
│                             │
│ 👥 3-4人  ⏱️ 4時間         │
│                             │
│ タグ                        │
│ [ホラー] [シリアス]         │
│                             │
│ 🔗 購入元                   │
│ https://booth.pm/...        │
│                             │
│ 📝 メモ                     │
│ 前回の続きから...           │
│                             │
│ ───────────────────────     │
│ 🎲 プレイ回数: 2回          │
│                             │
│ プレイ履歴                  │
│ ┌─────────────────────────┐ │
│ │ 2025/01/20              │ │
│ │ 田中、鈴木、佐藤        │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 2024/12/15              │ │
│ │ 山田、高橋              │ │
│ └─────────────────────────┘ │
│                             │
│    ┌─────────────────┐      │
│    │ + プレイ記録追加 │      │
│    └─────────────────┘      │
└─────────────────────────────┘
```

## 完了条件

- [ ] プレイヤーの追加・閲覧・編集・削除ができる
- [ ] プレイ記録の追加・閲覧・編集・削除ができる
- [ ] プレイ記録にプレイヤーを紐づけできる
- [ ] シナリオ詳細でプレイ回数・履歴が表示される
- [ ] プレイヤー詳細で参加したシナリオ一覧が表示される
- [ ] シナリオ削除時、プレイ記録が「削除されたシナリオ」と表示される
- [ ] プレイヤー削除時、プレイ記録から該当プレイヤーが消える
- [ ] 削除時に確認ダイアログが表示される
- [ ] 空状態が適切に表示される

## 注意事項

- シナリオ選択UIは検索しやすくする（数が増えると選択が大変）
- プレイ日のデフォルトは今日の日付
- プレイヤーは事前登録制（プレイ記録追加時に新規登録はしない）

## PR作成

Phase 2 の全タスクが完了したら、PRを作成してmainにマージする。

```bash
# 変更をプッシュ
git push origin feature/phase2-play-records
```

### PR テンプレート

```markdown
## Phase 2: プレイ記録・プレイヤー管理

### 概要
プレイ記録とプレイヤー管理機能を実装しました。

### 変更内容
- プレイヤーのCRUD機能
- プレイ記録のCRUD機能
- シナリオのプレイ回数自動集計
- プレイヤー別の参加履歴表示
- シナリオ詳細画面にプレイ履歴を追加

### 完了条件
- [ ] プレイヤーの追加・閲覧・編集・削除ができる
- [ ] プレイ記録の追加・閲覧・編集・削除ができる
- [ ] プレイ記録にプレイヤーを紐づけできる
- [ ] シナリオ詳細でプレイ回数・履歴が表示される
- [ ] プレイヤー詳細で参加したシナリオ一覧が表示される
- [ ] シナリオ削除時、プレイ記録が「削除されたシナリオ」と表示される
- [ ] プレイヤー削除時、プレイ記録から該当プレイヤーが消える
- [ ] 削除時に確認ダイアログが表示される
- [ ] 空状態が適切に表示される

### スクリーンショット
（画面キャプチャを添付）
```

## 次のフェーズへ

PRがマージされたら、Phase 3（検索・フィルタ・ソート）に進む。

```bash
git checkout main
git pull origin main
git checkout -b feature/phase3-search-filter
```
