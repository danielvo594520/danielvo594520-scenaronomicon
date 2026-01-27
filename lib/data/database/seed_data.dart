import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'database.dart';

Future<void> seedDefaultData(AppDatabase db) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(AppConstants.initializedKey) == true) return;

  final now = DateTime.now();

  await db.batch((batch) {
    // デフォルトシステム
    batch.insertAll(db.systems, [
      SystemsCompanion.insert(name: '新クトゥルフ神話TRPG', createdAt: now, updatedAt: now),
      SystemsCompanion.insert(name: 'クトゥルフ神話TRPG（6版）', createdAt: now, updatedAt: now),
      SystemsCompanion.insert(name: 'エモクロアTRPG', createdAt: now, updatedAt: now),
      SystemsCompanion.insert(name: 'マーダーミステリー', createdAt: now, updatedAt: now),
      SystemsCompanion.insert(name: 'ソード・ワールド2.5', createdAt: now, updatedAt: now),
      SystemsCompanion.insert(name: 'インセイン', createdAt: now, updatedAt: now),
      SystemsCompanion.insert(name: 'シノビガミ', createdAt: now, updatedAt: now),
      SystemsCompanion.insert(name: 'ダブルクロス', createdAt: now, updatedAt: now),
      SystemsCompanion.insert(name: 'その他', createdAt: now, updatedAt: now),
    ]);

    // デフォルトタグ
    batch.insertAll(db.tags, [
      TagsCompanion.insert(name: 'ホラー', color: '#8B0000', createdAt: now, updatedAt: now),
      TagsCompanion.insert(name: 'ファンタジー', color: '#4169E1', createdAt: now, updatedAt: now),
      TagsCompanion.insert(name: '現代', color: '#2E8B57', createdAt: now, updatedAt: now),
      TagsCompanion.insert(name: 'SF', color: '#9932CC', createdAt: now, updatedAt: now),
      TagsCompanion.insert(name: 'ミステリー', color: '#DAA520', createdAt: now, updatedAt: now),
      TagsCompanion.insert(name: 'コメディ', color: '#FF6347', createdAt: now, updatedAt: now),
      TagsCompanion.insert(name: 'シリアス', color: '#2F4F4F', createdAt: now, updatedAt: now),
    ]);
  });

  await prefs.setBool(AppConstants.initializedKey, true);
}
