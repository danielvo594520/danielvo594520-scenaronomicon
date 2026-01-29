# 開発者向けドキュメント

## 開発フェーズ

| フェーズ | 内容 | 状態 |
|----------|------|------|
| Phase 1 | シナリオCRUD、システム/タグ管理 | 完了 |
| Phase 2 | プレイ記録、プレイヤー管理 | 完了 |
| Phase 3 | 検索・フィルタ・ソート | 完了 |
| Phase 4 | 画像対応、UI改善 | 完了 |

各フェーズの詳細：
- [Phase 1: MVP](phases/PHASE1_MVP.md)
- [Phase 2: プレイ記録](phases/PHASE2_PLAY_RECORDS.md)
- [Phase 3: 検索・フィルタ](phases/PHASE3_SEARCH_FILTER.md)
- [Phase 4: UI改善](phases/PHASE4_POLISH.md)

## セットアップ

### 前提条件

- [fvm](https://fvm.app/) がインストールされていること
- Android SDK がインストールされていること

### 環境構築

```bash
# fvm でFlutterバージョンを設定
fvm install 3.24.0
fvm use 3.24.0

# 依存関係のインストール
fvm flutter pub get

# コード生成（Drift, Freezed）
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 開発コマンド

```bash
# デバッグ実行
fvm flutter run

# テスト実行
fvm flutter test

# APKビルド（デバッグ）
fvm flutter build apk --debug

# APKビルド（リリース）
fvm flutter build apk --release
```

## 技術スタック

| 項目 | 技術 |
|------|------|
| フレームワーク | Flutter 3.24.0 |
| バージョン管理 | fvm |
| ローカルDB | Drift (SQLite) |
| 状態管理 | Riverpod |
| ルーティング | go_router |
| UI | Material Design 3 |

## ディレクトリ構成

```
lib/
├── main.dart                 # エントリーポイント
├── app.dart                  # MaterialApp設定
├── core/                     # 共通ユーティリティ
├── data/                     # データ層（DB, リポジトリ）
├── domain/                   # ドメイン層（モデル, Enum）
└── presentation/             # プレゼンテーション層（画面, Provider）
```

詳細は [CLAUDE.md](../CLAUDE.md) を参照してください。
