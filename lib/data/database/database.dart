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
import 'tables/characters_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Systems,
  Tags,
  Scenarios,
  ScenarioTags,
  Players,
  PlaySessions,
  PlaySessionPlayers,
  Characters,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 7;

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
          if (from < 3) {
            await m.createTable(characters);
            await customStatement(
              'ALTER TABLE play_session_players ADD COLUMN character_id INTEGER REFERENCES characters(id)',
            );
          }
          if (from < 4) {
            await customStatement(
              'ALTER TABLE players ADD COLUMN image_path TEXT',
            );
          }
          if (from < 5) {
            await customStatement(
              'ALTER TABLE play_session_players ADD COLUMN is_kp INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (from < 6) {
            // 主キーを (playSessionId, playerId) から (playSessionId, playerId, isKp) に変更
            // SQLiteでは主キー変更にテーブル再作成が必要
            await customStatement('''
              CREATE TABLE play_session_players_new (
                play_session_id INTEGER NOT NULL REFERENCES play_sessions(id),
                player_id INTEGER NOT NULL REFERENCES players(id),
                character_id INTEGER REFERENCES characters(id),
                is_kp INTEGER NOT NULL DEFAULT 0,
                PRIMARY KEY (play_session_id, player_id, is_kp)
              )
            ''');
            await customStatement('''
              INSERT INTO play_session_players_new (play_session_id, player_id, character_id, is_kp)
              SELECT play_session_id, player_id, character_id, is_kp FROM play_session_players
            ''');
            await customStatement('DROP TABLE play_session_players');
            await customStatement('ALTER TABLE play_session_players_new RENAME TO play_session_players');
          }
          if (from < 7) {
            // キャラクターにステータス情報カラムを追加
            await customStatement(
              'ALTER TABLE characters ADD COLUMN hp INTEGER',
            );
            await customStatement(
              'ALTER TABLE characters ADD COLUMN max_hp INTEGER',
            );
            await customStatement(
              'ALTER TABLE characters ADD COLUMN mp INTEGER',
            );
            await customStatement(
              'ALTER TABLE characters ADD COLUMN max_mp INTEGER',
            );
            await customStatement(
              'ALTER TABLE characters ADD COLUMN san INTEGER',
            );
            await customStatement(
              'ALTER TABLE characters ADD COLUMN max_san INTEGER',
            );
            await customStatement(
              'ALTER TABLE characters ADD COLUMN source_service TEXT',
            );
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
