import 'dart:convert';

import 'character_sheet/character_sheet_result.dart';

/// ココフォリア駒出力JSONパーサー
class CcfoliaParser {
  /// HP/MP/SANとして認識するラベル（これ以外のstatusは技能値として扱う）
  static const _basicStatusLabels = {'HP', 'MP', 'SAN'};

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
      final paramsRaw = data['params'] as List<dynamic>? ?? [];

      // 能力値を抽出（params配列から）
      final params = _extractParams(paramsRaw);

      // 技能値を抽出（status配列からHP/MP/SAN以外）
      final skills = _extractSkills(status);

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
        params: params.isNotEmpty ? params : null,
        skills: skills.isNotEmpty ? skills : null,
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

  /// params配列から能力値を抽出
  static Map<String, int> _extractParams(List<dynamic> paramsRaw) {
    final result = <String, int>{};
    for (final item in paramsRaw) {
      if (item is Map<String, dynamic>) {
        final label = item['label'] as String?;
        final value = int.tryParse(item['value']?.toString() ?? '');
        if (label != null && value != null) {
          result[label] = value;
        }
      }
    }
    return result;
  }

  /// status配列から技能値を抽出（HP/MP/SAN以外）
  static Map<String, int> _extractSkills(List<dynamic> status) {
    final result = <String, int>{};
    for (final item in status) {
      if (item is Map<String, dynamic>) {
        final label = item['label'] as String?;
        final value = int.tryParse(item['value']?.toString() ?? '');
        if (label != null &&
            value != null &&
            !_basicStatusLabels.contains(label)) {
          result[label] = value;
        }
      }
    }
    return result;
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
