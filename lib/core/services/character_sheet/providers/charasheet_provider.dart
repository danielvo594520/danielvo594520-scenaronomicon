import 'dart:convert';

import 'package:http/http.dart' as http;

import '../character_sheet_result.dart';
import '../character_sheet_service.dart';

/// キャラクター保管所（charasheet.vampire-blood.net）のサービス実装
class CharasheetProvider implements CharacterSheetService {
  CharasheetProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'charasheet.vampire-blood.net';

  /// URLからIDを抽出するパターン
  /// 例: https://charasheet.vampire-blood.net/120888
  static final RegExp _urlPattern = RegExp(
    r'charasheet\.vampire-blood\.net/(\d+)',
    caseSensitive: false,
  );

  @override
  String get serviceName => 'キャラクター保管所';

  @override
  bool canHandle(String url) {
    return _urlPattern.hasMatch(url);
  }

  /// URLからキャラクターIDを抽出
  String? _extractId(String url) {
    final match = _urlPattern.firstMatch(url);
    return match?.group(1);
  }

  @override
  Future<CharacterSheetResult> fetchCharacter(String url) async {
    final id = _extractId(url);
    if (id == null) {
      throw const CharacterSheetFetchException('無効なURLです');
    }

    final jsonUrl = Uri.https(_baseUrl, '/$id.json');

    try {
      final response = await _client
          .get(jsonUrl)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw const CharacterSheetFetchException('キャラクターが見つかりません');
      }

      if (response.statusCode != 200) {
        throw CharacterSheetFetchException(
          'データの取得に失敗しました (${response.statusCode})',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return _parseResponse(data);
    } on FormatException {
      throw const CharacterSheetFetchException('データの解析に失敗しました');
    } on http.ClientException {
      throw const CharacterSheetFetchException('ネットワークエラーが発生しました');
    }
  }

  /// JSONレスポンスをパース
  CharacterSheetResult _parseResponse(Map<String, dynamic> data) {
    // ゲームシステムを確認（CoC / CoC7 で異なるフィールドがある可能性）
    // 将来的にシステム別のパース処理に使用する可能性があるため、取得のみ行う
    // final game = data['game'] as String?;

    // 名前
    final name = data['pc_name'] as String?;

    // HP（耐久力）
    final hp = _parseInt(data['TS_Total']);
    final maxHp = _parseInt(data['TS_Maximum']);

    // MP（マジックポイント）
    final mp = _parseInt(data['TK_Total']);
    final maxMp = _parseInt(data['TK_Maximum']);

    // SAN（正気度）
    final san = _parseInt(data['SAN_Left']);
    final maxSan = _parseInt(data['SAN_Max']);

    return CharacterSheetResult(
      name: name,
      hp: hp,
      maxHp: maxHp,
      mp: mp,
      maxMp: maxMp,
      san: san,
      maxSan: maxSan,
      rawData: data,
    );
  }

  /// 文字列を整数にパース（nullまたは空文字はnullを返す）
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }
}
