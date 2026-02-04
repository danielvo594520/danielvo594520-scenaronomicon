# Scenaronimicon プロジェクト状態

## 現在の状態
- **Phase 1 (MVP)**: 完了・マージ済み（PR #1）
- **Phase 2 (プレイ記録・プレイヤー管理)**: 完了・マージ済み（PR #2）
- **Phase 3 (検索・フィルタ・ソート)**: 完了・マージ済み（PR #3）
- **Phase 4 (画像対応・UI改善)**: 完了・マージ済み（PR #4）
- **全フェーズ完了**: v1.0.0 リリース済み（2025-01-28）
- **現在のバージョン**: 1.0.1（GitHub Actions による自動更新）

## CI/CD
- **GitHub Actions**: `.github/workflows/create-release.yml`
  - 手動トリガー（workflow_dispatch）でリリース作成
  - バージョン自動更新（pubspec.yaml + app_constants.dart）
  - ビルド番号自動インクリメント
  - リリースノートをカテゴリ別自動生成（feat/fix/docs/その他）
  - APKビルド・GitHub Releaseへ添付
  - **実行手順**: Actions > Create Release > Run workflow > バージョン入力

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
- **schemaVersion**: 7
- v1→v2 マイグレーション: players, play_sessions, play_session_players テーブル追加
- v2→v3 マイグレーション: characters テーブル追加、play_session_players に character_id カラム追加
- テーブル: systems, tags, scenarios, scenario_tags, players, play_sessions, play_session_players, characters

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

### Phase 3 で追加したファイル
- モデル: scenario_filter.dart（ScenarioFilterクラス、copyWith付き）
- Enum: scenario_sort.dart（ScenarioSort: 7種のソートオプション）
- ユーティリティ: sort_preferences.dart（SharedPreferencesでソート永続化）, debouncer.dart（300msデバウンス）
- プロバイダー: scenario_filter_provider.dart（scenarioFilterProvider, scenarioSortProvider, filteredScenarioListProvider）
- ウィジェット: filter_bottom_sheet.dart（タグ/システム/状態フィルター）, active_filters_row.dart（適用中フィルターチップ）

### Phase 3 で変更したファイル
- scenario_repository.dart: searchAndFilter(), getAllPlayCounts(), _filterByTags() 追加
- scenario_list_screen.dart: ConsumerStatefulWidget化、検索バー・フィルター・ソート統合
- README.md: Phase 3を完了に更新

### Phase 3 技術的注意事項
- タグフィルタ（AND/OR）はDart側で処理（SQLでは複雑すぎるため）
- プレイ回数ソートは全プレイ記録からMap<scenarioId, count>を事前取得
- ソート設定はSharedPreferencesで永続化
- 検索入力は300msデバウンスでパフォーマンス確保
- フィルター適用中はBadgeアイコンで視覚的に表示

### Phase 4 で追加したファイル
- サービス: image_picker_service.dart, image_storage_service.dart
- ユーティリティ: snackbar_utils.dart
- ウィジェット: scenario_thumbnail.dart, image_selector.dart, animated_list_item.dart

### Phase 4 で変更したファイル
- AndroidManifest.xml: READ_MEDIA_IMAGES, CAMERA パーミッション追加
- pubspec.yaml: image_picker, uuid パッケージ追加
- scenario_repository.dart: create/update に thumbnailPath 追加、delete で画像パス返却
- scenario_provider.dart: thumbnailPath 対応、画像ファイル削除処理追加
- scenario_form_screen.dart: ImageSelector 統合、画像保存・削除ロジック
- scenario_card.dart: ScenarioThumbnail 表示（横レイアウト化）
- scenario_detail_screen.dart: ScenarioThumbnail 表示、エラー時リトライUI、SnackBar改善
- scenario_list_screen.dart: Pull to Refresh、AnimatedListItem、HapticFeedback、Semantics
- app_router.dart: 全画面にフェードトランジション追加

### Phase 4 技術的注意事項
- 画像は1024x1024以下、JPEG 85%で圧縮（image_picker側で処理）
- ファイル名はUUID v4で生成、アプリ専用ディレクトリ（getApplicationDocumentsDirectory/images/）に保存
- シナリオ削除時にthumbnailPathのファイルも物理削除
- 画像更新時に古い画像ファイルも削除（replaceパターン）

### キャラクター機能（feature/add-character-feature）で追加したファイル
- テーブル: characters_table.dart
- モデル: character.dart, character_with_stats.dart, player_character_pair.dart
- リポジトリ: character_repository.dart
- プロバイダー: character_provider.dart
- ウィジェット: character_thumbnail.dart, character_card.dart, character_dropdown.dart, player_character_select.dart
- 画面: character_list_screen.dart, character_detail_screen.dart, character_form_screen.dart

### キャラクター機能で変更したファイル
- database.dart: Characters追加、schemaVersion 3、マイグレーション追加
- play_session_players_table.dart: characterId カラム追加
- player_with_stats.dart: PlayerInfo にキャラクター情報追加（characterId, characterName, characterImagePath）
- play_session_with_details.dart: playerNamesDisplay でキャラクター名表示対応
- play_session_repository.dart: create/update でPlayerCharacterPair対応、getPlayerCharacterPairs()追加
- play_session_provider.dart: playerCharacterPairs対応、playSessionPlayerCharacterPairsProvider追加
- player_provider.dart: deletePlayer でキャラクター画像も削除
- database_provider.dart: characterRepositoryProvider追加
- player_detail_screen.dart: キャラクターセクション追加
- play_session_form_screen.dart: PlayerCharacterSelect統合
- app_router.dart: キャラクター関連ルート追加（/players/:id/characters系）

### キャラクター機能 技術的注意事項
- Character モデルは Drift生成の Character と名前衝突するため、import時に `as model` で回避
- キャラクター削除時は play_session_players.characterId を NULL に（カスケード削除ではない）
- プレイヤー削除時は先にそのプレイヤーの全キャラクターを削除（画像も削除）
- 画像保存はシナリオと同じ仕組みを再利用（ImageStorageService）

### キャラクターシートURL情報取得機能（feature/character-sheet-fetch）で追加したファイル
- サービス: lib/core/services/character_sheet/
  - character_sheet_service.dart（抽象インターフェース）
  - character_sheet_result.dart（取得結果モデル）
  - character_sheet_service_factory.dart（サービスファクトリ）
  - providers/charasheet_provider.dart（キャラクター保管所対応）
  - providers/iachara_provider.dart（いあきゃら対応、WebView方式）
- プロバイダー: character_sheet_provider.dart（CharacterSheetFetchNotifier）

### キャラクターシートURL情報取得機能で変更したファイル
- pubspec.yaml: http, webview_flutter パッケージ追加
- characters_table.dart: hp, maxHp, mp, maxMp, san, maxSan, sourceService カラム追加
- character.dart: ステータスフィールド追加、hasStats getter追加
- character_with_stats.dart: ステータスフィールド追加、hasStats getter追加
- character_repository.dart: create/update にステータスパラメータ追加
- character_provider.dart: add/updateCharacter にステータスパラメータ追加
- database.dart: schemaVersion 7、v6→v7 マイグレーション追加
- character_form_screen.dart: URL横に「取得」ボタン、取得結果プレビュー、ステータス表示・保存
- character_detail_screen.dart: ステータス情報セクション表示

### キャラクターシートURL情報取得機能 技術的注意事項
- キャラクター保管所: JSON API (`/{id}.json`) を使用、CoC用フィールドマッピング
- いあきゃら: WebView方式で__NEXT_DATA__またはDOMからデータ抽出（SPA対応）
- 対応サービス: キャラクター保管所、いあきゃら
- ステータス情報: HP/MaxHP, MP/MaxMP, SAN/MaxSAN をnullableで保存
- sourceService: データ取得元サービス名を保存（「キャラクター保管所」「いあきゃら」）