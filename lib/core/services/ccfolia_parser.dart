import 'dart:convert';

import 'character_sheet/character_sheet_result.dart';

/// ココフォリア駒出力JSONパーサー
class CcfoliaParser {
  /// ココフォリア駒出力JSONをパース
  ///
  /// 正常にパースできた場合は[CharacterSheetResult]を返す。
  /// パースに失敗した場合はnullを返す。
  static CharacterSheetResult? parse(String jsonText) {
    try {
      final json = jsonDecode(jsonText);

      // kindがcharacterでない場合は非対応
      if (json['kind'] != 'character') return null;

      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final status = data['status'] as List<dynamic>? ?? [];

      return CharacterSheetResult(
        name: data['name'] as String?,
        externalUrl: data['externalUrl'] as String?,
        hp: _findStatusValue(status, 'HP'),
        maxHp: null, // ココフォリア駒には最大値がないためnull
        mp: _findStatusValue(status, 'MP'),
        maxMp: null,
        san: _findStatusValue(status, 'SAN'),
        maxSan: null,
        imageUrl: data['iconUrl'] as String?,
        rawData: {
          'externalUrl': data['externalUrl'],
          'iconUrl': data['iconUrl'],
        },
      );
    } catch (e) {
      return null;
    }
  }

  /// status配列から指定ラベルの値を取得
  static int? _findStatusValue(List<dynamic> status, String label) {
    for (final item in status) {
      if (item is Map<String, dynamic> && item['label'] == label) {
        return int.tryParse(item['value']?.toString() ?? '');
      }
    }
    return null;
  }

  /// JSONテキストがココフォリア駒形式かどうかを簡易チェック
  static bool isValidFormat(String jsonText) {
    try {
      final json = jsonDecode(jsonText);
      return json is Map<String, dynamic> &&
          json['kind'] == 'character' &&
          json['data'] != null;
    } catch (e) {
      return false;
    }
  }
}
