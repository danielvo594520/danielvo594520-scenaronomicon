# Scenaronimicon プロジェクト状態

## 現在の状態
- **Phase 1 (MVP)**: 完了・PR作成済み（#1）
- **ブランチ**: `feature/phase1-mvp` → mainへのPRが未マージ
- **次のタスク**: Phase 2（プレイ記録・プレイヤー管理）

## 技術的な注意事項

### バージョン制約
- Flutter 3.24.0 / Dart 3.5.0（fvm経由、PATHは `/Users/miyazawa/fvm/bin`）
- Drift **2.20.3**（最新版はDart >=3.7.0が必要なため使用不可）
- drift_dev **2.20.3**
- **riverpod_generatorは未使用**（Dart 3.5.0と非互換）→ 手動AsyncNotifierで実装
- freezed_annotation 3.x はインストール済みだが、ScenarioWithTagsはPlain Dartクラス

### Android ビルド設定
- Gradle 8.6, AGP 8.3.2, Kotlin 1.9.22
- compileSdk 35, minSdk 26, NDK 25.1.8937393
- Java 17

### アーキテクチャ
- Riverpod: 手動AsyncNotifier（NOT @riverpod コード生成）
- DB: Drift with PRAGMA foreign_keys=ON
- ルーティング: go_router StatefulShellRoute.indexedStack（4タブ）
- シナリオ取得: 2クエリ + Dart側マージ（N+1回避）
- カスケード: システム削除→scenarioのsystemId=null、タグ削除→scenario_tagsエントリ削除

### Phase 1 実装済み画面
- シナリオ: 一覧(SC-001), 詳細(SC-002), フォーム(SC-003)
- 設定: トップ(ST-001), システム管理(ST-002), タグ管理(ST-003)
- プレースホルダー: プレイ記録タブ, プレイヤータブ

### Phase 2 で必要なテーブル（CLAUDE.mdより）
- `players` - プレイヤー
- `play_sessions` - プレイ記録
- `play_session_players` - プレイ記録-プレイヤー中間テーブル

### Phase 2 のドキュメント
- `docs/phases/PHASE2_PLAY_RECORDS.md` に詳細仕様あり
