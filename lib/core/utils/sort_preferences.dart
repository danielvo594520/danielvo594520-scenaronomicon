import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/enums/scenario_sort.dart';

/// ソート設定の永続化
class SortPreferences {
  static const _key = 'scenario_sort';

  static Future<ScenarioSort> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) return ScenarioSort.createdAtDesc;
    return ScenarioSort.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ScenarioSort.createdAtDesc,
    );
  }

  static Future<void> save(ScenarioSort sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, sort.name);
  }
}
