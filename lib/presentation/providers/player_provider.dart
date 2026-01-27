import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../domain/models/player_with_stats.dart';
import 'database_provider.dart';

final playerListProvider =
    AsyncNotifierProvider<PlayerListNotifier, List<PlayerWithStats>>(
  PlayerListNotifier.new,
);

class PlayerListNotifier extends AsyncNotifier<List<PlayerWithStats>> {
  @override
  Future<List<PlayerWithStats>> build() {
    return ref.watch(playerRepositoryProvider).getAll();
  }

  Future<void> add({
    required String name,
    String? note,
  }) async {
    await ref.read(playerRepositoryProvider).create(
          name: name,
          note: note,
        );
    ref.invalidateSelf();
  }

  Future<void> updatePlayer({
    required int id,
    required String name,
    String? note,
  }) async {
    await ref.read(playerRepositoryProvider).update(
          id: id,
          name: name,
          note: note,
        );
    ref.invalidateSelf();
  }

  Future<void> deletePlayer(int id) async {
    await ref.read(playerRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

/// 個別プレイヤー詳細のProvider（Family）
final playerDetailProvider = FutureProvider.family<Player, int>((ref, id) {
  return ref.watch(playerRepositoryProvider).getById(id);
});

/// プレイヤーの参加セッション数
final playerSessionCountProvider =
    FutureProvider.family<int, int>((ref, playerId) {
  return ref.watch(playerRepositoryProvider).getSessionCount(playerId);
});

/// プレイヤーが参加したシナリオ一覧
final playerPlayedScenariosProvider =
    FutureProvider.family<List<Scenario>, int>((ref, playerId) {
  return ref.watch(playerRepositoryProvider).getPlayedScenarios(playerId);
});
