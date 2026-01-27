import 'package:drift/drift.dart';

import 'scenarios_table.dart';

class PlaySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scenarioId => integer().nullable().references(Scenarios, #id)();
  DateTimeColumn get playedAt => dateTime()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
