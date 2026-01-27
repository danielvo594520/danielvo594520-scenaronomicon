# Scenaronimicon プロジェクト状態

## 現在の状態
- **Phase 1 (MVP)**: 完了・マージ済み（PR #1）
- **Phase 2 (プレイ記録・プレイヤー管理)**: 完了・PR作成中
- **ブランチ**: `feature/phase2-play-records`
- **次のタスク**: Phase 3（検索・フィルタ・ソート）

## 技術的な注意事項

### バージョン制約
- Flutter 3.24.0 / Dart 3.5.0（fvm経由、PATHは `/Users/miyazawa/fvm/bin`）
- Drift **2.20.3**（最新版はDart >=3.7.0が必要なため使用不可）
- drift_dev **2.20.3**
- **riverpod_generatorは未使用**（Dart 3.5.0と非互換）→ 手動AsyncNotifierで実装
- freezed_annotation 3.x はインストール済みだが、モデルはPlain Dartクラス

### Android ビルド設定
- Gradle 8.6, AGP 8.3.2, Kotlin 1.9.22
- compileSdk 35, minSdk 26, NDK 25.1.8937393
- Java 17

### アーキテクチャ
- Riverpod: 手動AsyncNotifier（NOT @riverpod コード生成）
- DB: Drift with PRAGMA foreign_keys=ON
- ルーティング: go_router StatefulShellRoute.indexedStack（4タブ）
- データ取得: 2クエリ + Dart側マージ（N+1回避パターン）
- カスケード削除:
  - システム削除→scenarioのsystemId=null
  - タグ削除→scenario_tagsエントリ削除
  - シナリオ削除→play_sessionsのscenarioId=null + scenario_tags削除
  - プレイヤー削除→play_session_playersのレコード削除
  - プレイ記録削除→play_session_playersのレコード削除

### DB スキーマ
- **schemaVersion**: 2
- v1→v2 マイグレーション: players, play_sessions, play_session_players テーブル追加
- テーブル: systems, tags, scenarios, scenario_tags, players, play_sessions, play_session_players

### 実装済み画面
- シナリオ: 一覧, 詳細(プレイ記録セクション付き), フォーム
- プレイ記録: 一覧, フォーム（シナリオ選択・日付・プレイヤー複数選択・メモ）
- プレイヤー: 一覧, 詳細(参加シナリオ一覧付き), フォーム
- 設定: トップ, システム管理, タグ管理

### Phase 2 で追加したファイル（18ファイル）
- テーブル: players_table.dart, play_sessions_table.dart, play_session_players_table.dart
- モデル: player_with_stats.dart, play_session_with_details.dart
- リポジトリ: player_repository.dart, play_session_repository.dart
- プロバイダー: player_provider.dart, play_session_provider.dart
- ウィジェット: player_list_tile.dart, play_session_card.dart, player_multi_select.dart, scenario_search_dropdown.dart
- 画面: player_list_screen.dart, player_detail_screen.dart, player_form_screen.dart, play_session_list_screen.dart, play_session_form_screen.dart

### Phase 2 で変更したファイル
- database.dart: テーブル追加・スキーマv2・マイグレーション
- scenario_repository.dart: delete()にplay_sessions.scenarioId NULL化追加
- database_provider.dart: リポジトリプロバイダー2つ追加
- scenario_detail_screen.dart: プレイ記録セクション実装
- app_router.dart: Tab 1, 2 のルート実装

### Phase 3 のドキュメント
- `docs/phases/PHASE3_SEARCH_FILTER.md` に詳細仕様あり