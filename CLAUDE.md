# Scenaronimicon - Claude Code ガイド

## プロジェクト概要

TRPGのゲームマスター向けシナリオ管理Androidアプリ「Scenaronimicon」。
シナリオの管理、プレイ記録、プレイヤー情報をローカルで管理する。

## ドキュメント構成

```
docs/
├── SPECIFICATION.md           # 仕様書（全体）
└── phases/
    ├── PHASE1_MVP.md          # Phase 1: シナリオCRUD、システム/タグ管理
    ├── PHASE2_PLAY_RECORDS.md # Phase 2: プレイ記録、プレイヤー管理
    ├── PHASE3_SEARCH_FILTER.md # Phase 3: 検索・フィルタ・ソート
    └── PHASE4_POLISH.md       # Phase 4: 画像対応、UI改善
```

**開発順序:** Phase 1 → Phase 2 → Phase 3 → Phase 4

各フェーズのドキュメントには、タスクリスト、コード例、完了条件が記載されています。

## Git ワークフロー

### ブランチ戦略

各フェーズごとにブランチを作成し、完了後にPRを作成してmainにマージする。

```
main
 ├── feature/phase1-mvp
 ├── feature/phase2-play-records
 ├── feature/phase3-search-filter
 └── feature/phase4-polish
```

### フェーズごとの作業フロー

```bash
# 1. 新しいフェーズのブランチを作成
git checkout main
git pull origin main
git checkout -b feature/phase1-mvp

# 2. 作業中は適宜コミット
git add .
git commit -m "feat: シナリオ一覧画面を実装"

# 3. フェーズ完了後、プッシュ
git push origin feature/phase1-mvp

# 4. GitHub/GitLab でPR作成
#    - タイトル: "Phase 1: MVP - シナリオCRUD、システム/タグ管理"
#    - 説明: 完了条件のチェックリストを含める

# 5. レビュー後、mainにマージ

# 6. 次のフェーズへ
git checkout main
git pull origin main
git checkout -b feature/phase2-play-records
```

### ブランチ名一覧

| フェーズ | ブランチ名 |
|----------|------------|
| Phase 1 | `feature/phase1-mvp` |
| Phase 2 | `feature/phase2-play-records` |
| Phase 3 | `feature/phase3-search-filter` |
| Phase 4 | `feature/phase4-polish` |

### コミットメッセージ規約

```
<type>: <description>

# type の種類
# feat:     新機能
# fix:      バグ修正
# docs:     ドキュメント
# style:    コードスタイル（動作に影響なし）
# refactor: リファクタリング
# test:     テスト
# chore:    ビルド、設定など
```

**例:**
```
feat: シナリオ一覧画面を実装
feat: タグのCRUD機能を追加
fix: シナリオ削除時のエラーを修正
docs: READMEを更新
refactor: ScenarioRepositoryの共通処理を抽出
```

### PR作成時のチェックリスト

PRの説明に以下を含める：

```markdown
## 概要
Phase X の実装

## 変更内容
- [ ] 機能A
- [ ] 機能B
- [ ] 機能C

## 完了条件
- [ ] 条件1
- [ ] 条件2
- [ ] 条件3

## スクリーンショット
（該当する場合）
```

## 技術スタック

| 項目 | 技術 |
|------|------|
| フレームワーク | Flutter 3.24.x |
| バージョン管理 | fvm |
| 言語 | Dart |
| ローカルDB | Drift (SQLite) |
| 状態管理 | Riverpod |
| ルーティング | go_router |
| UIデザイン | Material Design 3 |

## 開発コマンド

```bash
# Flutter コマンドは必ず fvm 経由で実行
fvm flutter run
fvm flutter build apk
fvm flutter test

# コード生成（Drift, Freezed）
fvm flutter pub run build_runner build --delete-conflicting-outputs

# 依存関係の更新
fvm flutter pub get
```

## ディレクトリ構成

```
lib/
├── main.dart                 # エントリーポイント
├── app.dart                  # MaterialApp設定
├── core/                     # 共通ユーティリティ
│   ├── constants/            # 定数
│   ├── theme/                # テーマ設定
│   └── utils/                # ユーティリティ関数
├── data/                     # データ層
│   ├── database/             # Drift DB定義
│   │   ├── database.dart     # DB本体（@DriftDatabase）
│   │   └── tables/           # テーブル定義
│   └── repositories/         # リポジトリ（DBアクセス）
├── domain/                   # ドメイン層
│   ├── models/               # ドメインモデル（Freezed）
│   └── enums/                # Enum定義
├── presentation/             # プレゼンテーション層
│   ├── providers/            # Riverpodプロバイダー
│   ├── screens/              # 画面
│   ├── widgets/              # 共通ウィジェット
│   └── router/               # go_router設定
└── l10n/                     # 国際化（日本語）
```

## データベース設計

### テーブル一覧
- `systems` - ゲームシステム（CoC, マダミス等）
- `tags` - ジャンルタグ（色付き）
- `scenarios` - シナリオ本体
- `scenario_tags` - シナリオ-タグ中間テーブル
- `players` - プレイヤー
- `play_sessions` - プレイ記録
- `play_session_players` - プレイ記録-プレイヤー中間テーブル

### ScenarioStatus Enum
```dart
enum ScenarioStatus {
  unread,    // 未読
  reading,   // 読み中
  preparing, // 準備中
  ready,     // 準備完了
  played,    // 回した
  archived,  // アーカイブ
}
```

## コーディング規約

### 命名規則
- ファイル名: `snake_case.dart`
- クラス名: `PascalCase`
- 変数・関数: `camelCase`
- 定数: `camelCase` または `SCREAMING_SNAKE_CASE`
- プライベート: `_` プレフィックス

### Dart/Flutter スタイル
```dart
// Riverpod Provider
@riverpod
class ScenarioList extends _$ScenarioList {
  @override
  Future<List<Scenario>> build() async {
    return ref.watch(scenarioRepositoryProvider).getAll();
  }
}

// Freezed Model
@freezed
class Scenario with _$Scenario {
  const factory Scenario({
    required int id,
    required String title,
    // ...
  }) = _Scenario;
}

// Drift Table
class Scenarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  // ...
}
```

### ウィジェット構成
- 画面は `StatelessWidget` + `ConsumerWidget`（Riverpod）
- 状態管理はプロバイダーに委譲
- UIロジックは画面から分離

### コメント
- 日本語でOK
- 複雑なロジックには説明コメントを追加
- TODOは `// TODO:` 形式で

## フェーズ完了時のルール

### ドキュメント更新（必須）

各フェーズの作業が完了したら、以下のドキュメントを更新すること：

- **README.md** — フェーズの状態（完了/未着手）を更新
- **Serenaメモリ** (`project-status.md`) — プロジェクト状態・技術的注意事項・次フェーズへの引き継ぎ情報を更新

### 実機テスト（必須）

フェーズ完了前に実機（Xiaomi 15T Pro / Android 15）でテストを実施すること：

1. `fvm flutter run` でアプリをインストール・起動
2. 該当フェーズの全画面・全機能を手動で動作確認
3. 問題があればその場で修正してから完了とする

## リリース

### リリース作成（GitHub Actions）

バージョン指定でタグ・GitHub Release・APKを自動作成：

1. GitHub > **Actions** > **Create Release** > **Run workflow**
2. バージョンを入力（例: `1.1.0`）
3. 自動で以下が実行される：
   - `pubspec.yaml` と `app_constants.dart` のバージョン更新＆コミット
   - ビルド番号（`+N`）の自動インクリメント
   - リリースノート自動生成（カテゴリ別）
   - APKビルド＆GitHub Releaseに添付

### バージョン管理

バージョンは以下の2箇所で管理（リリースワークフローが自動更新）：

- `pubspec.yaml` — `version: X.Y.Z+N`
- `lib/core/constants/app_constants.dart` — `appVersion`

## 重要な注意点

### fvm 必須
```bash
# ❌ NG
flutter run

# ✅ OK
fvm flutter run
```

### Drift コード生成
テーブル定義を変更したら必ず実行：
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 画像保存
- サムネイル画像は `path_provider` で取得したアプリ専用ディレクトリに保存
- ファイル名はUUIDで管理
- 画像削除時はファイルも削除すること

### URL処理
- 購入URLは `url_launcher` で外部ブラウザ起動
- URL形式のバリデーションを実装

### 日本語対応
- UIテキストは日本語で直接記述してOK
- 将来の多言語対応を考慮する場合は `l10n` を使用

## 画面一覧

| 画面 | パス | 説明 |
|------|------|------|
| シナリオ一覧 | `/scenarios` | ホーム画面、カード一覧 |
| シナリオ詳細 | `/scenarios/:id` | 詳細+プレイ履歴 |
| シナリオ追加 | `/scenarios/new` | フォーム |
| シナリオ編集 | `/scenarios/:id/edit` | フォーム |
| プレイ記録一覧 | `/sessions` | リスト |
| プレイ記録追加 | `/sessions/new` | フォーム |
| プレイ記録編集 | `/sessions/:id/edit` | フォーム |
| プレイヤー一覧 | `/players` | リスト |
| プレイヤー詳細 | `/players/:id` | 詳細+参加履歴 |
| プレイヤー追加 | `/players/new` | フォーム |
| プレイヤー編集 | `/players/:id/edit` | フォーム |
| 設定 | `/settings` | システム/タグ管理へ |
| システム管理 | `/settings/systems` | CRUD |
| タグ管理 | `/settings/tags` | CRUD |

## 主要機能の実装ポイント

### シナリオ検索・フィルタ
```dart
// 検索クエリ例（Drift）
Future<List<Scenario>> searchScenarios({
  String? titleQuery,
  List<int>? tagIds,
  ScenarioStatus? status,
  int? systemId,
  bool tagFilterAnd = true, // AND/OR切替
}) async {
  // クエリ構築...
}
```

### プレイ回数集計
```dart
// シナリオのプレイ回数はplay_sessionsからCOUNT
Future<int> getPlayCount(int scenarioId) async {
  final count = await (select(playSessions)
    ..where((t) => t.scenarioId.equals(scenarioId)))
    .get();
  return count.length;
}
```

### タグ検索（AND/OR）
- AND検索: 選択したすべてのタグを持つシナリオ
- OR検索: 選択したいずれかのタグを持つシナリオ
- UIでトグル切替可能に

## テスト

```bash
# ユニットテスト
fvm flutter test

# 特定ファイルのテスト
fvm flutter test test/data/repositories/scenario_repository_test.dart
```

### テスト対象
- Repository層のCRUD操作
- Provider層のビジネスロジック
- ウィジェットテスト（主要画面）

## ビルド

```bash
# デバッグAPK
fvm flutter build apk --debug

# リリースAPK
fvm flutter build apk --release

# App Bundle（Google Play用）
fvm flutter build appbundle --release
```

## トラブルシューティング

### build_runner エラー
```bash
# キャッシュクリア後に再実行
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Gradle エラー
```bash
cd android
./gradlew clean
cd ..
fvm flutter run
```

### fvm が認識されない
```bash
# PATHを確認
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## 参考リンク

- [Flutter 公式ドキュメント](https://docs.flutter.dev/)
- [Drift ドキュメント](https://drift.simonbinder.eu/)
- [Riverpod ドキュメント](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)
- [go_router](https://pub.dev/packages/go_router)
