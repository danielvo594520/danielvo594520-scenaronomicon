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

  // 能力値・技能値（JSON形式で保存）
  TextColumn get params => text().nullable()();
  TextColumn get skills => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
