import 'package:drift/drift.dart';

import 'systems_table.dart';

class Scenarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get systemId => integer().nullable().references(Systems, #id)();
  IntColumn get minPlayers => integer().withDefault(const Constant(1))();
  IntColumn get maxPlayers => integer().withDefault(const Constant(4))();
  IntColumn get playTimeMinutes => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get purchaseUrl => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
