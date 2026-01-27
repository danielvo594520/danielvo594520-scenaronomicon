# Phase 4: 画像対応・UI改善

## Git ブランチ

```bash
# mainから作成（Phase 3 マージ後）
git checkout main
git pull origin main
git checkout -b feature/phase4-polish
```

**ブランチ名:** `feature/phase4-polish`

## 概要

シナリオのサムネイル画像機能を実装し、全体的なUIの改善・ポリッシュを行う。
このフェーズ完了後、アプリが完成状態となる。

## 前提条件

- Phase 1, 2, 3 が完了していること
- 全ての CRUD 機能と検索・フィルタが動作していること

## 目標

- サムネイル画像の選択・保存・表示
- 画像のキャッシュと最適化
- UIアニメーション・トランジション
- エラーハンドリングの改善
- アクセシビリティ対応
- 全体的なポリッシュ

## 実装タスク

### 1. パーミッション設定

- [ ] AndroidManifest.xml にパーミッション追加

```xml
<!-- android/app/src/main/AndroidManifest.xml -->

<!-- Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- カメラから撮影する場合（オプション） -->
<uses-permission android:name="android.permission.CAMERA" />
```

- [ ] `permission_handler` パッケージ追加

```bash
fvm flutter pub add permission_handler
```

### 2. 画像選択機能

- [ ] `image_picker` による画像選択
- [ ] ギャラリーからの選択
- [ ] カメラ撮影（オプション）

```dart
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  
  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }
  
  Future<File?> takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }
}
```

### 3. 画像保存・管理

- [ ] アプリ専用ディレクトリへの保存
- [ ] UUID によるファイル名管理
- [ ] 古い画像の削除処理

```dart
class ImageStorageService {
  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/images');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    final fileName = '${const Uuid().v4()}.jpg';
    final savedPath = '${imagesDir.path}/$fileName';
    
    await imageFile.copy(savedPath);
    return savedPath;
  }
  
  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  // シナリオ更新時に古い画像を削除
  Future<void> replaceImage(String? oldPath, String newPath) async {
    if (oldPath != null && oldPath != newPath) {
      await deleteImage(oldPath);
    }
  }
}
```

### 4. 画像表示・キャッシュ

- [ ] `cached_network_image` または自前キャッシュ
- [ ] プレースホルダー表示
- [ ] ローディング表示
- [ ] エラー時のフォールバック

```dart
class ScenarioThumbnail extends StatelessWidget {
  final String? imagePath;
  final double width;
  final double height;
  
  const ScenarioThumbnail({
    this.imagePath,
    this.width = 120,
    this.height = 80,
  });
  
  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return _buildPlaceholder();
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: frame != null ? child : _buildShimmer(),
          );
        },
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.auto_stories,
        color: Colors.grey[400],
        size: 32,
      ),
    );
  }
  
  Widget _buildShimmer() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
```

### 5. シナリオフォーム更新

- [ ] 画像選択 UI
- [ ] 画像プレビュー
- [ ] 画像削除ボタン

```dart
class ImageSelector extends StatelessWidget {
  final String? currentImagePath;
  final ValueChanged<File?> onImageSelected;
  final VoidCallback onImageRemoved;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('サムネイル', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        
        if (currentImagePath != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(currentImagePath!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onImageRemoved,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          )
        else
          InkWell(
            onTap: () => _showImageSourceDialog(context),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('画像を追加', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                // ギャラリーから選択
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(context);
                // カメラ起動
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6. UIアニメーション

- [ ] 画面遷移アニメーション
- [ ] リストアイテムのフェードイン
- [ ] FABの表示/非表示アニメーション
- [ ] 削除時のアニメーション

```dart
// go_router でのカスタムトランジション
GoRoute(
  path: '/scenarios/:id',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      child: ScenarioDetailScreen(id: state.pathParameters['id']!),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  },
),

// リストアイテムのスタガードアニメーション
class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

### 7. エラーハンドリング改善

- [ ] グローバルエラーハンドラー
- [ ] SnackBar によるエラー表示
- [ ] リトライ機能

```dart
// エラー種別
enum AppError {
  database('データベースエラーが発生しました'),
  fileNotFound('ファイルが見つかりません'),
  permission('権限がありません'),
  unknown('予期しないエラーが発生しました');
  
  final String message;
  const AppError(this.message);
}

// エラー表示ユーティリティ
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: '閉じる',
        textColor: Colors.white,
        onPressed: () {},
      ),
    ),
  );
}

// 成功表示
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
```

### 8. アクセシビリティ対応

- [ ] セマンティックラベル
- [ ] コントラスト比の確認
- [ ] タップターゲットサイズ（48x48以上）
- [ ] スクリーンリーダー対応

```dart
// セマンティックラベル例
Semantics(
  label: 'シナリオ「${scenario.title}」を追加',
  child: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
)

// 画像にラベル
Image.file(
  file,
  semanticLabel: '${scenario.title}のサムネイル画像',
)
```

### 9. 全体的なポリッシュ

- [ ] ローディング状態の統一
- [ ] 空状態イラストの追加（オプション）
- [ ] ボタンの Haptic Feedback
- [ ] Pull to Refresh
- [ ] スプラッシュ画面（オプション）

```dart
// Pull to Refresh
RefreshIndicator(
  onRefresh: () async {
    await ref.refresh(scenarioListProvider.future);
  },
  child: ListView.builder(...),
)

// Haptic Feedback
onTap: () {
  HapticFeedback.lightImpact();
  // 処理
}
```

### 10. パフォーマンス最適化

- [ ] 画像の遅延読み込み
- [ ] リストのスクロールパフォーマンス確認
- [ ] 不要な再ビルドの削減
- [ ] メモリ使用量の確認

```dart
// 画像の遅延読み込み
ListView.builder(
  itemBuilder: (context, index) {
    return VisibilityDetector(
      key: Key('scenario-$index'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) {
          // 画像の読み込みを開始
        }
      },
      child: ScenarioCard(scenario: scenarios[index]),
    );
  },
)

// ConsumerWidget で必要な部分だけ watch
class ScenarioCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 個別のシナリオだけを watch
    final scenario = ref.watch(
      scenarioListProvider.select((list) => list[index]),
    );
    // ...
  }
}
```

## 画面モックアップ（参考）

### シナリオ追加（画像選択）
```
┌─────────────────────────────┐
│ ← シナリオを追加            │
├─────────────────────────────┤
│                             │
│ サムネイル                  │
│ ┌─────────────────────────┐ │
│ │                         │ │
│ │     📷 ＋              │ │
│ │                         │ │
│ │     画像を追加          │ │
│ │                         │ │
│ └─────────────────────────┘ │
│                             │
│ タイトル *                  │
│ ┌─────────────────────────┐ │
│ │                         │ │
│ └─────────────────────────┘ │
│                             │
│ ...                         │
└─────────────────────────────┘
```

### 画像選択後
```
┌─────────────────────────────┐
│ ← シナリオを追加            │
├─────────────────────────────┤
│                             │
│ サムネイル                  │
│ ┌─────────────────────────┐ │
│ │ ┌─┐                     │ │
│ │ │✕│    🖼️ 画像         │ │
│ │ └─┘                     │ │
│ │                         │ │
│ └─────────────────────────┘ │
│                             │
│ タイトル *                  │
│ ┌─────────────────────────┐ │
│ │ 狂気山脈                │ │
│ └─────────────────────────┘ │
│                             │
│ ...                         │
└─────────────────────────────┘
```

### 画像ソース選択
```
┌─────────────────────────────┐
│ ┌─────────────────────────┐ │
│ │ 🖼️ ギャラリーから選択   │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 📷 カメラで撮影         │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

## 完了条件

- [ ] シナリオにサムネイル画像を設定できる
- [ ] ギャラリーから画像を選択できる
- [ ] カメラで撮影できる（オプション）
- [ ] 画像が適切にリサイズ・圧縮される
- [ ] シナリオ削除時に画像ファイルも削除される
- [ ] 画像がない場合にプレースホルダーが表示される
- [ ] 画面遷移がスムーズ
- [ ] エラー時に適切なメッセージが表示される
- [ ] アプリ全体の動作がスムーズ

## 最終チェックリスト

### 機能
- [ ] 全 CRUD 操作が正常に動作
- [ ] 検索・フィルタが正常に動作
- [ ] ソートが正常に動作
- [ ] 画像機能が正常に動作
- [ ] プレイ回数が正しく集計される

### UI/UX
- [ ] テーマカラー（緑系）が統一されている
- [ ] 空状態が適切に表示される
- [ ] ローディング状態が表示される
- [ ] エラーが適切にハンドリングされる
- [ ] 削除確認ダイアログが表示される

### パフォーマンス
- [ ] 100件のシナリオでスムーズにスクロール
- [ ] 画像読み込みが遅延なく行われる
- [ ] メモリリークがない

### その他
- [ ] Android 8.0 (API 26) 以上で動作
- [ ] パーミッションリクエストが適切
- [ ] クラッシュしない

## 注意事項

- 画像は 1024x1024 以下にリサイズし、JPEG 85% で圧縮
- 画像ファイル名は UUID を使用し、重複を防ぐ
- シナリオ削除時に画像ファイルを削除し忘れないこと
- カメラ機能はオプション（なくても良い）

## PR作成

Phase 4 の全タスクが完了したら、PRを作成してmainにマージする。

```bash
# 変更をプッシュ
git push origin feature/phase4-polish
```

### PR テンプレート

```markdown
## Phase 4: 画像対応・UI改善

### 概要
サムネイル画像機能とUI改善を実装しました。

### 変更内容
- サムネイル画像の選択・保存・表示
- 画像のキャッシュと最適化
- UIアニメーション・トランジション
- エラーハンドリングの改善
- アクセシビリティ対応
- 全体的なポリッシュ

### 完了条件
- [ ] シナリオにサムネイル画像を設定できる
- [ ] ギャラリーから画像を選択できる
- [ ] カメラで撮影できる（オプション）
- [ ] 画像が適切にリサイズ・圧縮される
- [ ] シナリオ削除時に画像ファイルも削除される
- [ ] 画像がない場合にプレースホルダーが表示される
- [ ] 画面遷移がスムーズ
- [ ] エラー時に適切なメッセージが表示される
- [ ] アプリ全体の動作がスムーズ

### 最終チェックリスト
- [ ] 全CRUD操作が正常に動作
- [ ] 検索・フィルタが正常に動作
- [ ] ソートが正常に動作
- [ ] 画像機能が正常に動作
- [ ] 100件のシナリオでスムーズにスクロール

### スクリーンショット
（画面キャプチャを添付）
```

## 完成後

PRがマージされたら、アプリの完成です！🎉

```bash
git checkout main
git pull origin main
git tag v1.0.0
git push origin v1.0.0
```

### 今後の改善案
- データのエクスポート/インポート
- ダークモード対応
- タブレット対応
- ウィジェット（ホーム画面に次回予定を表示）
- Google Drive バックアップ
