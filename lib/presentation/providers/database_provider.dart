import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/repositories/character_repository.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/repositories/play_session_repository.dart';
import '../../data/repositories/scenario_repository.dart';
import '../../data/repositories/system_repository.dart';
import '../../data/repositories/tag_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('AppDatabase must be overridden in ProviderScope');
});

final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepository(ref.watch(appDatabaseProvider));
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository(ref.watch(appDatabaseProvider));
});

final scenarioRepositoryProvider = Provider<ScenarioRepository>((ref) {
  return ScenarioRepository(ref.watch(appDatabaseProvider));
});

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(ref.watch(appDatabaseProvider));
});

final playSessionRepositoryProvider = Provider<PlaySessionRepository>((ref) {
  return PlaySessionRepository(ref.watch(appDatabaseProvider));
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository(ref.watch(appDatabaseProvider));
});
