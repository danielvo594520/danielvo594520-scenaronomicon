import 'package:drift/drift.dart';

import 'characters_table.dart';
import 'play_sessions_table.dart';
import 'players_table.dart';

class PlaySessionPlayers extends Table {
  IntColumn get playSessionId => integer().references(PlaySessions, #id)();
  IntColumn get playerId => integer().references(Players, #id)();
  IntColumn get characterId =>
      integer().nullable().references(Characters, #id)();

  @override
  Set<Column> get primaryKey => {playSessionId, playerId};
}
