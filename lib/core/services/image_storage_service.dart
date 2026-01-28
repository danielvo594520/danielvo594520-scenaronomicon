import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  static const _imagesDirName = 'images';
  static const _uuid = Uuid();

  /// 画像をアプリ専用ディレクトリに保存し、保存先パスを返す
  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/$_imagesDirName');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}.jpg';
    final savedPath = '${imagesDir.path}/$fileName';

    await imageFile.copy(savedPath);
    return savedPath;
  }

  /// 画像ファイルを削除する
  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// シナリオ更新時に古い画像を置き換える
  Future<void> replaceImage(String? oldPath, String newPath) async {
    if (oldPath != null && oldPath != newPath) {
      await deleteImage(oldPath);
    }
  }
}
