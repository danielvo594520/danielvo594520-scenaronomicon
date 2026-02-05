import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/image_storage_service.dart';
import '../../domain/models/character.dart' as model;
import '../../domain/models/character_with_stats.dart';
import 'database_provider.dart';

/// 特定プレイヤーのキャラクター一覧のProvider（Family）
final characterListProvider = AsyncNotifierProvider.family<CharacterListNotifier,
    List<CharacterWithStats>, int>(
  CharacterListNotifier.new,
);

class CharacterListNotifier
    extends FamilyAsyncNotifier<List<CharacterWithStats>, int> {
  @override
  Future<List<CharacterWithStats>> build(int arg) {
    return ref.watch(characterRepositoryProvider).getByPlayerId(arg);
  }

  Future<void> add({
    required String name,
    String? url,
    File? imageFile,
    int? hp,
    int? maxHp,
    int? mp,
    int? maxMp,
    int? san,
    int? maxSan,
    String? sourceService,
    Map<String, int>? params,
    Map<String, int>? skills,
  }) async {
    String? imagePath;
    if (imageFile != null) {
      imagePath = await ImageStorageService().saveImage(imageFile);
    }

    await ref.read(characterRepositoryProvider).create(
          playerId: arg,
          name: name,
          url: url,
          imagePath: imagePath,
          hp: hp,
          maxHp: maxHp,
          mp: mp,
          maxMp: maxMp,
          san: san,
          maxSan: maxSan,
          sourceService: sourceService,
          params: params,
          skills: skills,
        );
    ref.invalidateSelf();
  }

  Future<void> updateCharacter({
    required int id,
    required String name,
    String? url,
    File? newImageFile,
    bool deleteImage = false,
    int? hp,
    int? maxHp,
    int? mp,
    int? maxMp,
    int? san,
    int? maxSan,
    String? sourceService,
    Map<String, int>? params,
    Map<String, int>? skills,
  }) async {
    String? imagePath;

    if (deleteImage) {
      imagePath = null;
    } else if (newImageFile != null) {
      imagePath = await ImageStorageService().saveImage(newImageFile);
    } else {
      // 既存の画像を維持
      final existing = await ref.read(characterRepositoryProvider).getById(id);
      imagePath = existing.imagePath;
    }

    final oldPath = await ref.read(characterRepositoryProvider).update(
          id: id,
          name: name,
          url: url,
          imagePath: imagePath,
          hp: hp,
          maxHp: maxHp,
          mp: mp,
          maxMp: maxMp,
          san: san,
          maxSan: maxSan,
          sourceService: sourceService,
          params: params,
          skills: skills,
        );

    // 古い画像を削除
    if (oldPath != null) {
      await ImageStorageService().deleteImage(oldPath);
    }

    ref.invalidateSelf();
  }

  Future<void> deleteCharacter(int id) async {
    final imagePath =
        await ref.read(characterRepositoryProvider).delete(id);

    // 画像ファイル削除
    if (imagePath != null) {
      await ImageStorageService().deleteImage(imagePath);
    }

    ref.invalidateSelf();
  }
}

/// 個別キャラクター詳細のProvider（Family）
final characterDetailProvider =
    FutureProvider.family<model.Character, int>((ref, id) {
  return ref.watch(characterRepositoryProvider).getById(id);
});

/// キャラクターのセッション数
final characterSessionCountProvider =
    FutureProvider.family<int, int>((ref, characterId) {
  return ref.watch(characterRepositoryProvider).getSessionCount(characterId);
});

/// キャラクターが参加したセッション一覧
final characterPlayedSessionsProvider =
    FutureProvider.family<List<CharacterSessionInfo>, int>((ref, characterId) {
  return ref
      .watch(characterRepositoryProvider)
      .getPlayedSessions(characterId);
});
