import 'package:drift/drift.dart';

import 'players_table.dart';

class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer().references(Players, #id)();
  TextColumn get name => text()();
  TextColumn get url => text().nullable()();
  TextColumn get imagePath => text().nullable()();

  // ステータス情報（キャラクターシート取得機能用）
  IntColumn get hp => integer().nullable()();
  IntColumn get maxHp => integer().nullable()();
  IntColumn get mp => integer().nullable()();
  IntColumn get maxMp => integer().nullable()();
  IntColumn get san => integer().nullable()();
  IntColumn get maxSan => integer().nullable()();
  TextColumn get sourceService => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
