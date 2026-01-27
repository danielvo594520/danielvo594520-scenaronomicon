import 'package:drift/drift.dart';

import '../database/database.dart';

class TagRepository {
  TagRepository(this._db);

  final AppDatabase _db;

  Future<List<Tag>> getAll() {
    return (_db.select(_db.tags)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<Tag> getById(int id) {
    return (_db.select(_db.tags)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> create(String name, String color) {
    final now = DateTime.now();
    return _db.into(_db.tags).insert(
          TagsCompanion.insert(
            name: name,
            color: color,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> update(int id, String name, String color) {
    return (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
      TagsCompanion(
        name: Value(name),
        color: Value(color),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 削除時: scenario_tagsの関連エントリを先に削除
  Future<void> delete(int id) async {
    await (_db.delete(_db.scenarioTags)..where((t) => t.tagId.equals(id)))
        .go();
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> isNameExists(String name, {int? excludeId}) async {
    final query = _db.select(_db.tags)..where((t) => t.name.equals(name));
    if (excludeId != null) {
      query.where((t) => t.id.equals(excludeId).not());
    }
    final results = await query.get();
    return results.isNotEmpty;
  }
}
