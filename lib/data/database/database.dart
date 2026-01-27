import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/systems_table.dart';
import 'tables/tags_table.dart';
import 'tables/scenarios_table.dart';
import 'tables/scenario_tags_table.dart';
import 'tables/players_table.dart';
import 'tables/play_sessions_table.dart';
import 'tables/play_session_players_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Systems,
  Tags,
  Scenarios,
  ScenarioTags,
  Players,
  PlaySessions,
  PlaySessionPlayers,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(players);
            await m.createTable(playSessions);
            await m.createTable(playSessionPlayers);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'scenaronimicon.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
