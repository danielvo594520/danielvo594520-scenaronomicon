import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import 'database_provider.dart';

final systemListProvider =
    AsyncNotifierProvider<SystemListNotifier, List<System>>(
  SystemListNotifier.new,
);

class SystemListNotifier extends AsyncNotifier<List<System>> {
  @override
  Future<List<System>> build() {
    return ref.watch(systemRepositoryProvider).getAll();
  }

  Future<void> add(String name) async {
    await ref.read(systemRepositoryProvider).create(name);
    ref.invalidateSelf();
  }

  Future<void> updateSystem(int id, String name) async {
    await ref.read(systemRepositoryProvider).update(id, name);
    ref.invalidateSelf();
  }

  Future<void> deleteSystem(int id) async {
    await ref.read(systemRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  Future<bool> isNameExists(String name, {int? excludeId}) {
    return ref
        .read(systemRepositoryProvider)
        .isNameExists(name, excludeId: excludeId);
  }
}
