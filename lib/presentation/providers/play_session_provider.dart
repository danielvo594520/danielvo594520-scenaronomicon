import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/play_session_with_details.dart';
import '../../domain/models/player_character_pair.dart';
import 'database_provider.dart';

final playSessionListProvider = AsyncNotifierProvider<PlaySessionListNotifier,
    List<PlaySessionWithDetails>>(
  PlaySessionListNotifier.new,
);

class PlaySessionListNotifier
    extends AsyncNotifier<List<PlaySessionWithDetails>> {
  @override
  Future<List<PlaySessionWithDetails>> build() {
    return ref.watch(playSessionRepositoryProvider).getAll();
  }

  Future<void> add({
    int? scenarioId,
    required DateTime playedAt,
    String? memo,
    List<PlayerCharacterPair> playerCharacterPairs = const [],
  }) async {
    await ref.read(playSessionRepositoryProvider).create(
          scenarioId: scenarioId,
          playedAt: playedAt,
          memo: memo,
          playerCharacterPairs: playerCharacterPairs,
        );
    ref.invalidateSelf();
  }

  Future<void> updateSession({
    required int id,
    int? scenarioId,
    required DateTime playedAt,
    String? memo,
    List<PlayerCharacterPair> playerCharacterPairs = const [],
  }) async {
    await ref.read(playSessionRepositoryProvider).update(
          id: id,
          scenarioId: scenarioId,
          playedAt: playedAt,
          memo: memo,
          playerCharacterPairs: playerCharacterPairs,
        );
    ref.invalidateSelf();
  }

  Future<void> deleteSession(int id) async {
    await ref.read(playSessionRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

/// 個別プレイ記録詳細のProvider（Family）
final playSessionDetailProvider =
    FutureProvider.family<PlaySessionWithDetails, int>((ref, id) {
  return ref.watch(playSessionRepositoryProvider).getById(id);
});

/// プレイ記録の参加者情報（プレイヤーID + キャラクターID）を取得
final playSessionPlayerCharacterPairsProvider =
    FutureProvider.family<List<PlayerCharacterPair>, int>((ref, sessionId) {
  return ref
      .watch(playSessionRepositoryProvider)
      .getPlayerCharacterPairs(sessionId);
});

/// シナリオ別プレイ履歴
final playSessionsByScenarioProvider =
    FutureProvider.family<List<PlaySessionSummary>, int>((ref, scenarioId) {
  return ref
      .watch(playSessionRepositoryProvider)
      .getByScenarioId(scenarioId);
});

/// シナリオのプレイ回数
final scenarioPlayCountProvider =
    FutureProvider.family<int, int>((ref, scenarioId) {
  return ref.watch(playSessionRepositoryProvider).getPlayCount(scenarioId);
});
