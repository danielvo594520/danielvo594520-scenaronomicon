# Scenaronimicon 仕様書

## 1. アプリ概要

### 1.1 アプリ名
**Scenaronimicon**（シナリオノミコン）

### 1.2 目的
TRPG（テーブルトークRPG）のゲームマスター（GM）向けに、所持しているシナリオの管理、プレイ記録の管理、プレイヤー情報の管理を行うAndroidアプリ。

### 1.3 ターゲットユーザー
- TRPGのGMとしてシナリオを回す人
- 複数のシナリオを所持し、管理したい人
- プレイ履歴を記録・振り返りたい人

### 1.4 プラットフォーム
- Android（Flutter製）
- ローカルストレージでのデータ管理

---

## 2. 技術スタック

### 2.1 フレームワーク・言語
| 項目 | 技術 |
|------|------|
| フレームワーク | Flutter |
| 言語 | Dart |
| バージョン管理 | fvm (Flutter Version Management) |
| 推奨Flutterバージョン | 3.24.x 以上（安定版） |

### 2.2 主要パッケージ
| パッケージ | 用途 |
|------------|------|
| drift | ローカルDB（SQLite）ORM |
| drift_dev | Driftコード生成 |
| sqlite3_flutter_libs | SQLiteネイティブライブラリ |
| path_provider | ファイルパス取得 |
| flutter_riverpod | 状態管理 |
| go_router | ルーティング |
| image_picker | 画像選択 |
| url_launcher | URL起動 |
| intl | 日付フォーマット |
| freezed / freezed_annotation | Immutableクラス生成 |
| json_annotation | JSON変換 |

### 2.3 デザイン
- Material Design 3（Material You）
- ダイナミックカラー対応（Android 12+）

---

## 3. 機能一覧

### 3.1 シナリオ管理
- シナリオの一覧表示（カード形式）
- シナリオの追加・編集・削除
- シナリオの詳細表示
- シナリオのフィルタリング（状態、システム、タグ）
- シナリオの検索（タイトル）
- プレイ回数の自動集計（プレイ記録から）

### 3.2 プレイ記録管理
- プレイ記録の一覧表示
- プレイ記録の追加・編集・削除
- プレイ記録の詳細表示
- シナリオ別プレイ記録の表示

### 3.3 プレイヤー管理
- プレイヤーの一覧表示
- プレイヤーの追加・編集・削除
- プレイヤー別参加シナリオ履歴の表示

### 3.4 マスターデータ管理
- システム（ゲームシステム）の追加・編集・削除
- タグの追加・編集・削除

---

## 4. データモデル

### 4.1 ER図（概念）

```
┌─────────────────┐       ┌─────────────────┐
│    System       │       │      Tag        │
│─────────────────│       │─────────────────│
│ id (PK)         │       │ id (PK)         │
│ name            │       │ name            │
│ created_at      │       │ color           │
│ updated_at      │       │ created_at      │
└────────┬────────┘       └────────┬────────┘
         │                         │
         │ 1:N                     │ N:M
         │                         │
┌────────┴────────────────────────┴────────┐
│                 Scenario                  │
│───────────────────────────────────────────│
│ id (PK)                                   │
│ title                                     │
│ system_id (FK) → System                   │
│ min_players                               │
│ max_players                               │
│ play_time_minutes                         │
│ status (enum)                             │
│ purchase_url                              │
│ thumbnail_path                            │
│ memo                                      │
│ created_at                                │
│ updated_at                                │
└────────┬──────────────────────────────────┘
         │
         │ 1:N
         │
┌────────┴────────┐       ┌─────────────────┐
│  PlaySession    │       │     Player      │
│─────────────────│       │─────────────────│
│ id (PK)         │       │ id (PK)         │
│ scenario_id(FK) │       │ name            │
│ played_at       │  N:M  │ note            │
│ memo            │◄─────►│ created_at      │
│ created_at      │       │ updated_at      │
│ updated_at      │       └─────────────────┘
└─────────────────┘

┌─────────────────────┐
│   ScenarioTag       │
│─────────────────────│
│ scenario_id (FK)    │
│ tag_id (FK)         │
└─────────────────────┘

┌─────────────────────┐
│ PlaySessionPlayer   │
│─────────────────────│
│ play_session_id(FK) │
│ player_id (FK)      │
└─────────────────────┘
```

### 4.2 テーブル定義

#### systems（ゲームシステム）
| カラム名 | 型 | 制約 | 説明 |
|----------|-----|------|------|
| id | INTEGER | PK, AUTO INCREMENT | ID |
| name | TEXT | NOT NULL, UNIQUE | システム名（例：新クトゥルフ神話TRPG） |
| created_at | DATETIME | NOT NULL | 作成日時 |
| updated_at | DATETIME | NOT NULL | 更新日時 |

#### tags（タグ）
| カラム名 | 型 | 制約 | 説明 |
|----------|-----|------|------|
| id | INTEGER | PK, AUTO INCREMENT | ID |
| name | TEXT | NOT NULL, UNIQUE | タグ名（例：ホラー、ファンタジー） |
| color | TEXT | NOT NULL | 色コード（例：#FF5733） |
| created_at | DATETIME | NOT NULL | 作成日時 |
| updated_at | DATETIME | NOT NULL | 更新日時 |

#### scenarios（シナリオ）
| カラム名 | 型 | 制約 | 説明 |
|----------|-----|------|------|
| id | INTEGER | PK, AUTO INCREMENT | ID |
| title | TEXT | NOT NULL | シナリオタイトル |
| system_id | INTEGER | FK → systems | ゲームシステムID |
| min_players | INTEGER | NOT NULL, DEFAULT 1 | 最小プレイヤー数 |
| max_players | INTEGER | NOT NULL, DEFAULT 4 | 最大プレイヤー数 |
| play_time_minutes | INTEGER | | 想定プレイ時間（分） |
| status | TEXT | NOT NULL | 状態（後述のEnum参照） |
| purchase_url | TEXT | | 購入元URL |
| thumbnail_path | TEXT | | サムネイル画像パス |
| memo | TEXT | | メモ |
| created_at | DATETIME | NOT NULL | 作成日時 |
| updated_at | DATETIME | NOT NULL | 更新日時 |

#### scenario_tags（シナリオ-タグ中間テーブル）
| カラム名 | 型 | 制約 | 説明 |
|----------|-----|------|------|
| scenario_id | INTEGER | PK, FK → scenarios | シナリオID |
| tag_id | INTEGER | PK, FK → tags | タグID |

#### players（プレイヤー）
| カラム名 | 型 | 制約 | 説明 |
|----------|-----|------|------|
| id | INTEGER | PK, AUTO INCREMENT | ID |
| name | TEXT | NOT NULL | プレイヤー名 |
| note | TEXT | | メモ（連絡先など） |
| created_at | DATETIME | NOT NULL | 作成日時 |
| updated_at | DATETIME | NOT NULL | 更新日時 |

#### play_sessions（プレイ記録）
| カラム名 | 型 | 制約 | 説明 |
|----------|-----|------|------|
| id | INTEGER | PK, AUTO INCREMENT | ID |
| scenario_id | INTEGER | NOT NULL, FK → scenarios | シナリオID |
| played_at | DATE | NOT NULL | プレイ日 |
| memo | TEXT | | 感想・メモ |
| created_at | DATETIME | NOT NULL | 作成日時 |
| updated_at | DATETIME | NOT NULL | 更新日時 |

#### play_session_players（プレイ記録-プレイヤー中間テーブル）
| カラム名 | 型 | 制約 | 説明 |
|----------|-----|------|------|
| play_session_id | INTEGER | PK, FK → play_sessions | プレイ記録ID |
| player_id | INTEGER | PK, FK → players | プレイヤーID |

### 4.3 Enum定義

#### ScenarioStatus（シナリオ状態）
| 値 | 表示名 | 説明 |
|----|--------|------|
| unread | 未読 | まだ読んでいない |
| reading | 読み中 | 現在読んでいる |
| preparing | 準備中 | 準備作業中 |
| ready | 準備完了 | いつでも回せる状態 |
| played | 回した | 一度以上回した |
| archived | アーカイブ | もう回す予定がない |

---

## 5. 画面設計

### 5.1 画面一覧

| 画面ID | 画面名 | 説明 |
|--------|--------|------|
| SC-001 | ホーム（シナリオ一覧） | シナリオをカード形式で一覧表示 |
| SC-002 | シナリオ詳細 | シナリオの詳細情報とプレイ履歴 |
| SC-003 | シナリオ追加/編集 | シナリオの登録・編集フォーム |
| PS-001 | プレイ記録一覧 | 全プレイ記録の一覧 |
| PS-002 | プレイ記録追加/編集 | プレイ記録の登録・編集フォーム |
| PL-001 | プレイヤー一覧 | 登録プレイヤーの一覧 |
| PL-002 | プレイヤー詳細 | プレイヤー情報と参加履歴 |
| PL-003 | プレイヤー追加/編集 | プレイヤーの登録・編集フォーム |
| ST-001 | 設定 | システム・タグの管理 |
| ST-002 | システム管理 | ゲームシステムの追加・編集・削除 |
| ST-003 | タグ管理 | タグの追加・編集・削除 |

### 5.2 ナビゲーション構造

```
BottomNavigationBar
├── シナリオ（SC-001）
│   ├── シナリオ詳細（SC-002）
│   │   └── プレイ記録追加（PS-002）
│   └── シナリオ追加/編集（SC-003）
├── プレイ記録（PS-001）
│   └── プレイ記録追加/編集（PS-002）
├── プレイヤー（PL-001）
│   ├── プレイヤー詳細（PL-002）
│   └── プレイヤー追加/編集（PL-003）
└── 設定（ST-001）
    ├── システム管理（ST-002）
    └── タグ管理（ST-003）
```

### 5.3 画面詳細

#### SC-001: ホーム（シナリオ一覧）

**レイアウト:**
- AppBar: タイトル「シナリオ」、検索アイコン、フィルターアイコン
- Body: カードリスト（グリッドまたはリスト切替可能）
- FAB: シナリオ追加ボタン

**カード表示内容:**
- サムネイル画像（なければプレースホルダー）
- タイトル
- システム名（バッジ）
- 状態（チップ）
- プレイ人数
- プレイ回数

**フィルター項目:**
- 状態
- システム
- タグ

**検索:**
- タイトルで部分一致検索
- タグで絞り込み検索（複数タグのAND/OR切替可能）

---

#### SC-002: シナリオ詳細

**表示内容:**
- サムネイル画像（大）
- タイトル
- システム名
- 状態
- 推奨人数（○〜○人）
- プレイ時間（○時間○分 or ○分）
- タグ一覧（チップ）
- 購入元URL（タップでブラウザ起動）
- メモ
- プレイ回数
- プレイ履歴一覧（簡易表示）

**アクション:**
- 編集ボタン
- 削除ボタン（確認ダイアログ）
- プレイ記録追加ボタン
- URLコピーボタン

---

#### SC-003: シナリオ追加/編集

**入力項目:**
| 項目 | 入力形式 | 必須 | バリデーション |
|------|----------|------|----------------|
| タイトル | テキスト | ○ | 空文字不可 |
| システム | ドロップダウン | - | - |
| 最小プレイヤー数 | 数値 | ○ | 1以上 |
| 最大プレイヤー数 | 数値 | ○ | 最小以上 |
| プレイ時間（分） | 数値 | - | 0以上 |
| 状態 | ドロップダウン | ○ | - |
| タグ | マルチセレクトチップ | - | - |
| 購入元URL | テキスト（URL） | - | URL形式 |
| サムネイル | 画像選択 | - | - |
| メモ | テキストエリア | - | - |

---

#### PS-001: プレイ記録一覧

**レイアウト:**
- AppBar: タイトル「プレイ記録」
- Body: リスト（日付降順）
- FAB: プレイ記録追加ボタン

**リスト表示内容:**
- プレイ日
- シナリオタイトル
- 参加プレイヤー数
- サムネイル（小）

---

#### PS-002: プレイ記録追加/編集

**入力項目:**
| 項目 | 入力形式 | 必須 | バリデーション |
|------|----------|------|----------------|
| シナリオ | ドロップダウン/検索 | ○ | - |
| プレイ日 | 日付ピッカー | ○ | - |
| 参加プレイヤー | マルチセレクト | - | - |
| メモ | テキストエリア | - | - |

---

#### PL-001: プレイヤー一覧

**レイアウト:**
- AppBar: タイトル「プレイヤー」
- Body: リスト
- FAB: プレイヤー追加ボタン

**リスト表示内容:**
- プレイヤー名
- 参加セッション数

---

#### PL-002: プレイヤー詳細

**表示内容:**
- プレイヤー名
- メモ
- 参加セッション数
- 参加したシナリオ一覧

---

#### PL-003: プレイヤー追加/編集

**入力項目:**
| 項目 | 入力形式 | 必須 | バリデーション |
|------|----------|------|----------------|
| 名前 | テキスト | ○ | 空文字不可 |
| メモ | テキストエリア | - | - |

---

## 6. ディレクトリ構成（推奨）

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── date_utils.dart
├── data/
│   ├── database/
│   │   ├── database.dart
│   │   ├── database.g.dart
│   │   └── tables/
│   │       ├── systems_table.dart
│   │       ├── tags_table.dart
│   │       ├── scenarios_table.dart
│   │       ├── players_table.dart
│   │       └── play_sessions_table.dart
│   └── repositories/
│       ├── scenario_repository.dart
│       ├── player_repository.dart
│       ├── play_session_repository.dart
│       ├── system_repository.dart
│       └── tag_repository.dart
├── domain/
│   ├── models/
│   │   ├── scenario.dart
│   │   ├── player.dart
│   │   ├── play_session.dart
│   │   ├── system.dart
│   │   └── tag.dart
│   └── enums/
│       └── scenario_status.dart
├── presentation/
│   ├── providers/
│   │   ├── scenario_provider.dart
│   │   ├── player_provider.dart
│   │   └── play_session_provider.dart
│   ├── screens/
│   │   ├── scenario/
│   │   │   ├── scenario_list_screen.dart
│   │   │   ├── scenario_detail_screen.dart
│   │   │   └── scenario_form_screen.dart
│   │   ├── play_session/
│   │   │   ├── play_session_list_screen.dart
│   │   │   └── play_session_form_screen.dart
│   │   ├── player/
│   │   │   ├── player_list_screen.dart
│   │   │   ├── player_detail_screen.dart
│   │   │   └── player_form_screen.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       ├── system_management_screen.dart
│   │       └── tag_management_screen.dart
│   ├── widgets/
│   │   ├── scenario_card.dart
│   │   ├── status_chip.dart
│   │   ├── tag_chip.dart
│   │   └── player_avatar.dart
│   └── router/
│       └── app_router.dart
└── l10n/
    └── app_ja.arb
```

---

## 7. 初期データ

### 7.1 デフォルトシステム
アプリ初回起動時に以下のシステムを自動登録：

| システム名 |
|------------|
| 新クトゥルフ神話TRPG |
| クトゥルフ神話TRPG（6版） |
| エモクロアTRPG |
| マーダーミステリー |
| ソード・ワールド2.5 |
| インセイン |
| シノビガミ |
| ダブルクロス |
| その他 |

### 7.2 デフォルトタグ
| タグ名 | 色 |
|--------|-----|
| ホラー | #8B0000 |
| ファンタジー | #4169E1 |
| 現代 | #2E8B57 |
| SF | #9932CC |
| ミステリー | #DAA520 |
| コメディ | #FF6347 |
| シリアス | #2F4F4F |

---

## 8. 削除時の挙動

### 8.1 カスケード処理

| 削除対象 | 関連データの処理 |
|----------|------------------|
| システム | 紐づくシナリオの `system_id` を NULL に設定 |
| タグ | `scenario_tags` の該当レコードを削除 |
| シナリオ | 紐づく `play_sessions` の `scenario_id` を NULL に設定 |
| プレイヤー | `play_session_players` の該当レコードを削除 |
| プレイ記録 | `play_session_players` の該当レコードを削除 |

### 8.2 削除確認

すべての削除操作で確認ダイアログを表示：
- タイトル: 「削除の確認」
- メッセージ: 「〇〇を削除しますか？この操作は取り消せません。」
- ボタン: 「キャンセル」「削除」

---

## 9. UX/UI設計

### 9.1 空状態（Empty State）

データがない場合の表示：

| 画面 | メッセージ | アクション |
|------|------------|------------|
| シナリオ一覧 | 「シナリオがありません」<br>「＋ボタンから追加しましょう！」 | FABを目立たせる |
| プレイ記録一覧 | 「プレイ記録がありません」<br>「シナリオを回したら記録しましょう！」 | - |
| プレイヤー一覧 | 「プレイヤーがいません」<br>「一緒に遊ぶ仲間を登録しましょう！」 | FABを目立たせる |
| 検索結果 | 「該当するシナリオが見つかりません」 | フィルタ解除ボタン |

### 9.2 ローディング表示

- リスト読み込み: `CircularProgressIndicator`（中央）
- ボタン操作中: ボタン内にスピナー表示
- 画像読み込み: シマーエフェクト or プレースホルダー

### 9.3 エラー表示

- 軽微なエラー: `SnackBar`（下部、3秒で消える）
- 重大なエラー: ダイアログ表示

### 9.4 ソート機能

シナリオ一覧で利用可能なソート順：

| ソートキー | 説明 |
|------------|------|
| 登録日（新しい順） | デフォルト |
| 登録日（古い順） | - |
| タイトル（あいうえお順） | - |
| タイトル（逆順） | - |
| プレイ回数（多い順） | - |
| プレイ回数（少ない順） | - |
| 状態別 | 未読→読み中→準備中→準備完了→回した→アーカイブ |

ソート設定はアプリ終了後も保持（SharedPreferences）。

---

## 10. カラーテーマ

### 10.1 テーマ方針

- Material Design 3（Material You）採用
- 緑系の落ち着いた配色
- テーマカラーは `core/theme/app_theme.dart` で一元管理
- 将来的なダークモード対応を考慮した設計

### 10.2 カラーパレット（ライトモード）

```dart
// Primary: 落ち着いた緑
static const Color primaryColor = Color(0xFF2E7D32); // Green 800
static const Color onPrimaryColor = Color(0xFFFFFFFF);

// Secondary: 補色（ティール系）
static const Color secondaryColor = Color(0xFF00695C); // Teal 800
static const Color onSecondaryColor = Color(0xFFFFFFFF);

// Background
static const Color backgroundColor = Color(0xFFF5F5F5);
static const Color surfaceColor = Color(0xFFFFFFFF);

// Status Colors
static const Color errorColor = Color(0xFFB00020);
static const Color successColor = Color(0xFF4CAF50);
static const Color warningColor = Color(0xFFFFC107);
```

### 10.3 シナリオ状態の色

| 状態 | 色 | カラーコード |
|------|-----|-------------|
| 未読 | グレー | #9E9E9E |
| 読み中 | ブルー | #2196F3 |
| 準備中 | オレンジ | #FF9800 |
| 準備完了 | グリーン | #4CAF50 |
| 回した | パープル | #9C27B0 |
| アーカイブ | ブラウン | #795548 |

---

## 11. 非機能要件

### 11.1 パフォーマンス
- シナリオ一覧は100件程度でもスムーズにスクロール可能
- 画像は適切にキャッシュ・リサイズ

### 11.2 データ保護
- 全データはローカルDBに保存
- 外部通信なし（購入URLのブラウザ起動を除く）

### 11.3 対応OS
- Android 8.0 (API 26) 以上
- 画像選択はAndroid 13+の `READ_MEDIA_IMAGES` パーミッションを使用

---

## 12. 将来の拡張案（スコープ外）

以下は今回の実装スコープ外とするが、将来的に検討する機能：

- データのエクスポート/インポート（JSON/CSV）
- クラウドバックアップ
- シナリオの共有機能
- カレンダー連携（プレイ予定）
- 統計・分析機能
- ダークモード切替
- お気に入り機能
- 最近見たシナリオ履歴

---

## 13. 開発フェーズ

開発は以下の4フェーズに分けて進行：

| フェーズ | 内容 | 詳細ドキュメント |
|----------|------|------------------|
| Phase 1（MVP） | シナリオCRUD、システム/タグ管理 | `docs/phases/PHASE1_MVP.md` |
| Phase 2 | プレイ記録、プレイヤー管理 | `docs/phases/PHASE2_PLAY_RECORDS.md` |
| Phase 3 | 検索・フィルタ、ソート | `docs/phases/PHASE3_SEARCH_FILTER.md` |
| Phase 4 | 画像対応、UI改善 | `docs/phases/PHASE4_POLISH.md` |

---

## 14. 開発環境セットアップ手順

### 14.1 前提条件
- macOS / Windows / Linux
- Android Studio または VS Code
- Git

### 14.2 fvm セットアップ

```bash
# fvmのインストール（Dart pubを使用）
dart pub global activate fvm

# または Homebrew（macOS）
brew tap leoafarias/fvm
brew install fvm

# プロジェクトディレクトリで
fvm install 3.24.0
fvm use 3.24.0
```

### 14.3 プロジェクト作成

```bash
# fvm経由でFlutterプロジェクト作成
fvm flutter create --org com.example scenaronimicon
cd scenaronimicon

# fvm設定
fvm use 3.24.0

# 依存関係追加
fvm flutter pub add drift sqlite3_flutter_libs path_provider
fvm flutter pub add flutter_riverpod go_router
fvm flutter pub add image_picker url_launcher intl
fvm flutter pub add freezed_annotation json_annotation

# 開発用依存関係
fvm flutter pub add --dev drift_dev build_runner freezed
```

### 14.4 Android設定

`android/app/build.gradle` でminSdkVersionを26に設定：

```gradle
android {
    defaultConfig {
        minSdkVersion 26
    }
}
```

---

## 15. リリース管理

### 15.1 バージョニング

セマンティックバージョニング（`MAJOR.MINOR.PATCH`）を採用：

| 要素 | 意味 | 例 |
|------|------|-----|
| MAJOR | 破壊的変更 | 2.0.0 |
| MINOR | 新機能追加 | 1.1.0 |
| PATCH | バグ修正 | 1.0.1 |

バージョンは2箇所で管理：
- `pubspec.yaml` — `version: X.Y.Z+N`（`+N` はAndroidビルド番号、リリース毎に自動インクリメント）
- `lib/core/constants/app_constants.dart` — `appVersion`（アプリ内表示用）

### 15.2 リリースワークフロー

GitHub Actionsの手動トリガー（`workflow_dispatch`）で以下を自動実行：

1. バージョン入力（例: `1.1.0`）
2. `pubspec.yaml` と `app_constants.dart` のバージョンを自動更新・コミット
3. リリースノートをコミット履歴からカテゴリ別に自動生成
4. リリースAPKをビルド（オプション）
5. GitHub Releaseを作成、タグ付け、APK添付

**実行手順:** GitHub > Actions > Create Release > Run workflow > バージョン入力

### 15.3 APK配布

- リリースAPKは GitHub Releases の Assets に添付
- ファイル名: `scenaronimicon-vX.Y.Z.apk`
- ダウンロード: リポジトリの Releases ページから取得可能

---

## 改訂履歴

| バージョン | 日付 | 内容 |
|------------|------|------|
| 1.0 | 2025-01-27 | 初版作成 |
| 1.1 | 2025-01-28 | 全フェーズ完了、リリース管理セクション追加 |
