# Phase 1: MVP（最小実行可能製品）

## Git ブランチ

```bash
# mainから作成
git checkout main
git pull origin main
git checkout -b feature/phase1-mvp
```

**ブランチ名:** `feature/phase1-mvp`

## 概要

アプリの基盤となるシナリオ管理機能を実装する。
このフェーズ完了後、シナリオの登録・閲覧・編集・削除が可能になる。

## 目標

- プロジェクトのセットアップ（fvm, Flutter）
- データベース基盤の構築（Drift）
- シナリオのCRUD機能
- システム（ゲームシステム）の管理
- タグの管理
- 基本的なUI/ナビゲーション

## 実装タスク

### 1. プロジェクトセットアップ

- [ ] fvmのインストールと設定
- [ ] Flutterプロジェクト作成
- [ ] 依存パッケージの追加
- [ ] ディレクトリ構成の作成
- [ ] Android設定（minSdkVersion 26）

```bash
# プロジェクト作成
fvm flutter create --org com.yourname scenaronimicon
cd scenaronimicon
fvm use 3.24.0

# 依存関係追加
fvm flutter pub add drift sqlite3_flutter_libs path_provider
fvm flutter pub add flutter_riverpod go_router intl
fvm flutter pub add freezed_annotation json_annotation
fvm flutter pub add --dev drift_dev build_runner freezed json_serializable
```

### 2. テーマ設定

- [ ] `core/theme/app_theme.dart` 作成
- [ ] 緑系のカラーパレット定義
- [ ] Material 3テーマ設定
- [ ] 状態別カラー定義

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Primary
  static const Color primary = Color(0xFF2E7D32);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary
  static const Color secondary = Color(0xFF00695C);
  
  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Status colors for ScenarioStatus
  static const Color statusUnread = Color(0xFF9E9E9E);
  static const Color statusReading = Color(0xFF2196F3);
  static const Color statusPreparing = Color(0xFFFF9800);
  static const Color statusReady = Color(0xFF4CAF50);
  static const Color statusPlayed = Color(0xFF9C27B0);
  static const Color statusArchived = Color(0xFF795548);
}
```

### 3. データベース構築

- [ ] Enum定義: `ScenarioStatus`
- [ ] テーブル定義:
  - [ ] `systems`
  - [ ] `tags`
  - [ ] `scenarios`
  - [ ] `scenario_tags`
- [ ] Database クラス作成
- [ ] build_runner でコード生成

#### systems テーブル
```dart
class Systems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```

#### tags テーブル
```dart
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get color => text()(); // Hex color code
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```

#### scenarios テーブル
```dart
class Scenarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get systemId => integer().nullable().references(Systems, #id)();
  IntColumn get minPlayers => integer().withDefault(const Constant(1))();
  IntColumn get maxPlayers => integer().withDefault(const Constant(4))();
  IntColumn get playTimeMinutes => integer().nullable()();
  TextColumn get status => text()(); // ScenarioStatus enum value
  TextColumn get purchaseUrl => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```

#### scenario_tags 中間テーブル
```dart
class ScenarioTags extends Table {
  IntColumn get scenarioId => integer().references(Scenarios, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {scenarioId, tagId};
}
```

### 4. リポジトリ層

- [ ] `SystemRepository` - システムのCRUD
- [ ] `TagRepository` - タグのCRUD
- [ ] `ScenarioRepository` - シナリオのCRUD（タグ含む）

#### 削除時の挙動実装
```dart
// SystemRepository
Future<void> delete(int id) async {
  // シナリオのsystem_idをNULLに
  await (update(scenarios)..where((t) => t.systemId.equals(id)))
    .write(ScenariosCompanion(systemId: const Value(null)));
  // システム削除
  await (delete(systems)..where((t) => t.id.equals(id))).go();
}

// TagRepository
Future<void> delete(int id) async {
  // 紐付き削除
  await (delete(scenarioTags)..where((t) => t.tagId.equals(id))).go();
  // タグ削除
  await (delete(tags)..where((t) => t.id.equals(id))).go();
}
```

### 5. Riverpod プロバイダー

- [ ] `systemProvider` - システム一覧
- [ ] `tagProvider` - タグ一覧
- [ ] `scenarioListProvider` - シナリオ一覧
- [ ] `scenarioDetailProvider` - シナリオ詳細

### 6. 画面実装

#### ナビゲーション（BottomNavigationBar）
- [ ] シナリオ（この Phase で実装）
- [ ] プレイ記録（Phase 2 で実装、この Phase ではプレースホルダー）
- [ ] プレイヤー（Phase 2 で実装、この Phase ではプレースホルダー）
- [ ] 設定（この Phase で実装）

#### シナリオ関連
- [ ] **SC-001: シナリオ一覧**
  - カード形式で表示
  - FABで追加
  - 空状態の表示
- [ ] **SC-002: シナリオ詳細**
  - 全情報表示
  - 編集・削除ボタン
  - 削除確認ダイアログ
- [ ] **SC-003: シナリオ追加/編集**
  - フォームバリデーション
  - システム選択（ドロップダウン）
  - タグ選択（マルチセレクトチップ）
  - 状態選択

#### 設定関連
- [ ] **ST-001: 設定画面**
  - システム管理へのリンク
  - タグ管理へのリンク
- [ ] **ST-002: システム管理**
  - 一覧表示
  - 追加・編集・削除
  - 削除確認ダイアログ
- [ ] **ST-003: タグ管理**
  - 一覧表示（色付き）
  - 追加・編集・削除（色選択含む）
  - 削除確認ダイアログ

### 7. 初期データ投入

- [ ] アプリ初回起動時にデフォルトシステムを登録
- [ ] アプリ初回起動時にデフォルトタグを登録

```dart
Future<void> _insertDefaultData() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('initialized') == true) return;

  // デフォルトシステム
  final defaultSystems = [
    '新クトゥルフ神話TRPG',
    'クトゥルフ神話TRPG（6版）',
    'エモクロアTRPG',
    'マーダーミステリー',
    'ソード・ワールド2.5',
    'インセイン',
    'シノビガミ',
    'ダブルクロス',
    'その他',
  ];

  // デフォルトタグ
  final defaultTags = [
    ('ホラー', '#8B0000'),
    ('ファンタジー', '#4169E1'),
    ('現代', '#2E8B57'),
    ('SF', '#9932CC'),
    ('ミステリー', '#DAA520'),
    ('コメディ', '#FF6347'),
    ('シリアス', '#2F4F4F'),
  ];

  // 登録処理...
  
  await prefs.setBool('initialized', true);
}
```

### 8. 共通ウィジェット

- [ ] `StatusChip` - 状態表示チップ
- [ ] `TagChip` - タグ表示チップ
- [ ] `DeleteConfirmDialog` - 削除確認ダイアログ
- [ ] `EmptyStateWidget` - 空状態表示
- [ ] `ScenarioCard` - シナリオカード

## 完了条件

- [ ] シナリオの追加・閲覧・編集・削除ができる
- [ ] システムの追加・編集・削除ができる
- [ ] タグの追加・編集・削除ができる
- [ ] シナリオにシステムとタグを設定できる
- [ ] 空状態が適切に表示される
- [ ] 削除時に確認ダイアログが表示される
- [ ] テーマカラー（緑系）が適用されている

## 画面モックアップ（参考）

### シナリオ一覧
```
┌─────────────────────────────┐
│ シナリオ           🔍  ≡   │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 🖼️                      │ │
│ │ シナリオタイトル        │ │
│ │ [新クトゥルフ] [準備完了]│ │
│ │ 👥 3-4人                │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 🖼️                      │ │
│ │ 別のシナリオ            │ │
│ │ [マダミス]    [未読]    │ │
│ │ 👥 5-6人                │ │
│ └─────────────────────────┘ │
│                             │
│                         [+] │
├─────────────────────────────┤
│ 📋    📝    👥    ⚙️      │
└─────────────────────────────┘
```

### 設定画面
```
┌─────────────────────────────┐
│ ← 設定                      │
├─────────────────────────────┤
│                             │
│ ┌─────────────────────────┐ │
│ │ 🎮 ゲームシステム管理  >│ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 🏷️ タグ管理            >│ │
│ └─────────────────────────┘ │
│                             │
│ ───────────────────────     │
│ バージョン: 1.0.0           │
│                             │
└─────────────────────────────┘
```

## 注意事項

- 画像機能は Phase 4 で実装するため、この Phase ではプレースホルダー表示
- プレイ回数は Phase 2 でプレイ記録実装後に表示
- 検索・フィルタは Phase 3 で実装

## PR作成

Phase 1 の全タスクが完了したら、PRを作成してmainにマージする。

```bash
# 変更をプッシュ
git push origin feature/phase1-mvp
```

### PR テンプレート

```markdown
## Phase 1: MVP - シナリオCRUD、システム/タグ管理

### 概要
アプリの基盤となるシナリオ管理機能を実装しました。

### 変更内容
- プロジェクトセットアップ（fvm, Flutter, 依存パッケージ）
- データベース構築（Drift）
- シナリオのCRUD機能
- システム（ゲームシステム）の管理
- タグの管理
- 基本的なUI/ナビゲーション
- テーマ設定（緑系）

### 完了条件
- [ ] シナリオの追加・閲覧・編集・削除ができる
- [ ] システムの追加・編集・削除ができる
- [ ] タグの追加・編集・削除ができる
- [ ] シナリオにシステムとタグを設定できる
- [ ] 空状態が適切に表示される
- [ ] 削除時に確認ダイアログが表示される
- [ ] テーマカラー（緑系）が適用されている

### スクリーンショット
（画面キャプチャを添付）
```

## 次のフェーズへ

PRがマージされたら、Phase 2（プレイ記録・プレイヤー管理）に進む。

```bash
git checkout main
git pull origin main
git checkout -b feature/phase2-play-records
```
