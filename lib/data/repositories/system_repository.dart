import 'package:drift/drift.dart';

import '../database/database.dart';

class SystemRepository {
  SystemRepository(this._db);

  final AppDatabase _db;

  Future<List<System>> getAll() {
    return (_db.select(_db.systems)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<System> getById(int id) {
    return (_db.select(_db.systems)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<int> create(String name) {
    final now = DateTime.now();
    return _db.into(_db.systems).insert(
          SystemsCompanion.insert(
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> update(int id, String name) {
    return (_db.update(_db.systems)..where((t) => t.id.equals(id))).write(
      SystemsCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 削除時: 参照しているシナリオのsystemIdをnullに設定してから削除
  Future<void> delete(int id) async {
    await (_db.update(_db.scenarios)
          ..where((t) => t.systemId.equals(id)))
        .write(const ScenariosCompanion(systemId: Value(null)));
    await (_db.delete(_db.systems)..where((t) => t.id.equals(id))).go();
  }

  /// 同名のシステムが存在するかチェック（編集時は自身を除外）
  Future<bool> isNameExists(String name, {int? excludeId}) async {
    final query = _db.select(_db.systems)
      ..where((t) => t.name.equals(name));
    if (excludeId != null) {
      query.where((t) => t.id.equals(excludeId).not());
    }
    final results = await query.get();
    return results.isNotEmpty;
  }
}
