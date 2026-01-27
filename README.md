# Scenaronimicon

TRPGのゲームマスター向けシナリオ管理Androidアプリ。

シナリオの管理、プレイ記録、プレイヤー情報をローカルで管理します。

## 技術スタック

| 項目 | 技術 |
|------|------|
| フレームワーク | Flutter 3.24.0 |
| バージョン管理 | fvm |
| ローカルDB | Drift (SQLite) |
| 状態管理 | Riverpod |
| ルーティング | go_router |
| UI | Material Design 3 |

## セットアップ

```bash
# fvm でFlutterバージョンを設定
fvm install 3.24.0
fvm use 3.24.0

# 依存関係のインストール
fvm flutter pub get

# コード生成（Driftテーブル変更時）
fvm flutter pub run build_runner build --delete-conflicting-outputs

# デバッグ実行
fvm flutter run

# APKビルド
fvm flutter build apk --debug
```

## 開発フェーズ

| フェーズ | 内容 | 状態 |
|----------|------|------|
| Phase 1 | シナリオCRUD、システム/タグ管理 | 完了 |
| Phase 2 | プレイ記録、プレイヤー管理 | 未着手 |
| Phase 3 | 検索・フィルタ・ソート | 未着手 |
| Phase 4 | 画像対応、UI改善 | 未着手 |

詳細は [docs/](docs/) を参照。
