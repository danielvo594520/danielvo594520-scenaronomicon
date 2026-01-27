import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import 'database_provider.dart';

final tagListProvider =
    AsyncNotifierProvider<TagListNotifier, List<Tag>>(
  TagListNotifier.new,
);

class TagListNotifier extends AsyncNotifier<List<Tag>> {
  @override
  Future<List<Tag>> build() {
    return ref.watch(tagRepositoryProvider).getAll();
  }

  Future<void> add(String name, String color) async {
    await ref.read(tagRepositoryProvider).create(name, color);
    ref.invalidateSelf();
  }

  Future<void> updateTag(int id, String name, String color) async {
    await ref.read(tagRepositoryProvider).update(id, name, color);
    ref.invalidateSelf();
  }

  Future<void> deleteTag(int id) async {
    await ref.read(tagRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  Future<bool> isNameExists(String name, {int? excludeId}) {
    return ref
        .read(tagRepositoryProvider)
        .isNameExists(name, excludeId: excludeId);
  }
}
