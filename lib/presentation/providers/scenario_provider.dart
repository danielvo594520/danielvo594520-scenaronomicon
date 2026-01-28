import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/image_storage_service.dart';
import '../../domain/enums/scenario_status.dart';
import '../../domain/models/scenario_with_tags.dart';
import 'database_provider.dart';

final scenarioListProvider =
    AsyncNotifierProvider<ScenarioListNotifier, List<ScenarioWithTags>>(
  ScenarioListNotifier.new,
);

class ScenarioListNotifier extends AsyncNotifier<List<ScenarioWithTags>> {
  @override
  Future<List<ScenarioWithTags>> build() {
    return ref.watch(scenarioRepositoryProvider).getAll();
  }

  Future<void> add({
    required String title,
    int? systemId,
    int minPlayers = 1,
    int maxPlayers = 4,
    int? playTimeMinutes,
    required ScenarioStatus status,
    String? purchaseUrl,
    String? thumbnailPath,
    String? memo,
    List<int> tagIds = const [],
  }) async {
    await ref.read(scenarioRepositoryProvider).create(
          title: title,
          systemId: systemId,
          minPlayers: minPlayers,
          maxPlayers: maxPlayers,
          playTimeMinutes: playTimeMinutes,
          status: status,
          purchaseUrl: purchaseUrl,
          thumbnailPath: thumbnailPath,
          memo: memo,
          tagIds: tagIds,
        );
    ref.invalidateSelf();
  }

  Future<void> updateScenario({
    required int id,
    required String title,
    int? systemId,
    int minPlayers = 1,
    int maxPlayers = 4,
    int? playTimeMinutes,
    required ScenarioStatus status,
    String? purchaseUrl,
    String? thumbnailPath,
    String? oldThumbnailPath,
    String? memo,
    List<int> tagIds = const [],
  }) async {
    await ref.read(scenarioRepositoryProvider).update(
          id: id,
          title: title,
          systemId: systemId,
          minPlayers: minPlayers,
          maxPlayers: maxPlayers,
          playTimeMinutes: playTimeMinutes,
          status: status,
          purchaseUrl: purchaseUrl,
          thumbnailPath: thumbnailPath,
          memo: memo,
          tagIds: tagIds,
        );
    // 古い画像ファイルを削除
    if (oldThumbnailPath != null && oldThumbnailPath != thumbnailPath) {
      await ImageStorageService().deleteImage(oldThumbnailPath);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteScenario(int id) async {
    final deletedThumbnailPath =
        await ref.read(scenarioRepositoryProvider).delete(id);
    // 画像ファイルを削除
    if (deletedThumbnailPath != null) {
      await ImageStorageService().deleteImage(deletedThumbnailPath);
    }
    ref.invalidateSelf();
  }
}

/// 個別シナリオ詳細のProvider（Family）
final scenarioDetailProvider =
    FutureProvider.family<ScenarioWithTags, int>((ref, id) {
  return ref.watch(scenarioRepositoryProvider).getById(id);
});
