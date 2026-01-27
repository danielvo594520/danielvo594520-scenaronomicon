import 'package:drift/drift.dart';

import 'scenarios_table.dart';
import 'tags_table.dart';

class ScenarioTags extends Table {
  IntColumn get scenarioId => integer().references(Scenarios, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {scenarioId, tagId};
}
