import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../character_sheet_result.dart';
import '../character_sheet_service.dart';

/// いあきゃら（iachara.com）のサービス実装
///
/// WebViewでページを読み込み、__NEXT_DATA__またはDOMからデータを抽出
class IacharaProvider implements CharacterSheetService {
  /// URLからIDを抽出するパターン
  /// 例: https://iachara.com/view/9927371
  static final RegExp _urlPattern = RegExp(
    r'iachara\.com/view/(\d+)',
    caseSensitive: false,
  );

  @override
  String get serviceName => 'いあきゃら';

  @override
  bool canHandle(String url) {
    return _urlPattern.hasMatch(url);
  }

  @override
  Future<CharacterSheetResult> fetchCharacter(String url) async {
    if (!canHandle(url)) {
      throw const CharacterSheetFetchException('無効なURLです');
    }

    final completer = Completer<CharacterSheetResult>();
    late WebViewController controller;

    // タイムアウト設定
    final timeout = Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        completer.completeError(
          const CharacterSheetFetchException('タイムアウトしました'),
        );
      }
    });

    try {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String finishedUrl) async {
              // SPAの場合、少し待機してからデータ取得を試みる
              await Future.delayed(const Duration(milliseconds: 1500));

              if (completer.isCompleted) return;

              try {
                final result = await _extractData(controller);
                if (!completer.isCompleted) {
                  completer.complete(result);
                }
              } catch (e) {
                if (!completer.isCompleted) {
                  completer.completeError(
                    CharacterSheetFetchException('データの取得に失敗しました: $e'),
                  );
                }
              }
            },
            onWebResourceError: (error) {
              if (!completer.isCompleted) {
                completer.completeError(
                  CharacterSheetFetchException('ページの読み込みに失敗しました: ${error.description}'),
                );
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(url));

      return await completer.future;
    } finally {
      timeout.cancel();
    }
  }

  /// WebViewからデータを抽出
  Future<CharacterSheetResult> _extractData(WebViewController controller) async {
    // まず __NEXT_DATA__ からの取得を試みる
    final nextDataResult = await _tryExtractFromNextData(controller);
    if (nextDataResult != null) {
      return nextDataResult;
    }

    // 次にDOMからの取得を試みる
    final domResult = await _tryExtractFromDom(controller);
    if (domResult != null) {
      return domResult;
    }

    throw const CharacterSheetFetchException('キャラクターデータを取得できませんでした');
  }

  /// __NEXT_DATA__ スクリプトタグからデータ抽出を試みる
  Future<CharacterSheetResult?> _tryExtractFromNextData(
    WebViewController controller,
  ) async {
    const script = '''
      (function() {
        const nextData = document.getElementById('__NEXT_DATA__');
        if (!nextData) return null;
        try {
          const data = JSON.parse(nextData.textContent);
          // pagePropsにキャラクターデータがある場合
          const props = data?.props?.pageProps;
          if (props?.character || props?.data) {
            return JSON.stringify(props);
          }
          return null;
        } catch (e) {
          return null;
        }
      })()
    ''';

    final result = await controller.runJavaScriptReturningResult(script);

    // 結果が"null"の場合はnullを返す
    if (result == 'null' || result.toString().isEmpty) {
      return null;
    }

    try {
      // WebView返り値のエンコードを処理（iOSとAndroidで異なる）
      String jsonStr = result.toString();
      // 引用符で囲まれている場合は除去
      if (jsonStr.startsWith('"') && jsonStr.endsWith('"')) {
        jsonStr = jsonStr.substring(1, jsonStr.length - 1);
        // エスケープされた引用符を戻す
        jsonStr = jsonStr.replaceAll(r'\"', '"');
        jsonStr = jsonStr.replaceAll(r'\\', r'\');
      }

      final data = json.decode(jsonStr) as Map<String, dynamic>;
      return _parseNextDataProps(data);
    } catch (e) {
      debugPrint('__NEXT_DATA__ parse error: $e');
      return null;
    }
  }

  /// Next.js propsからデータをパース
  CharacterSheetResult? _parseNextDataProps(Map<String, dynamic> props) {
    // characterキーまたはdataキーからデータを取得
    final character =
        props['character'] as Map<String, dynamic>? ??
        props['data'] as Map<String, dynamic>?;

    if (character == null) return null;

    // 名前の取得（複数の可能性のあるキーを試す）
    final name = character['name'] as String? ??
        character['pc_name'] as String? ??
        character['characterName'] as String?;

    // ステータスの取得
    final stats = character['stats'] as Map<String, dynamic>? ??
        character['status'] as Map<String, dynamic>? ??
        character;

    final hp = _parseInt(stats['hp'] ?? stats['HP']);
    final maxHp = _parseInt(stats['maxHp'] ?? stats['maxHP'] ?? stats['HP_MAX']);
    final mp = _parseInt(stats['mp'] ?? stats['MP']);
    final maxMp = _parseInt(stats['maxMp'] ?? stats['maxMP'] ?? stats['MP_MAX']);
    final san = _parseInt(stats['san'] ?? stats['SAN'] ?? stats['sanity']);
    final maxSan = _parseInt(stats['maxSan'] ?? stats['maxSAN'] ?? stats['SAN_MAX']);

    return CharacterSheetResult(
      name: name,
      hp: hp,
      maxHp: maxHp,
      mp: mp,
      maxMp: maxMp,
      san: san,
      maxSan: maxSan,
      rawData: character,
    );
  }

  /// DOMから直接データ抽出を試みる
  Future<CharacterSheetResult?> _tryExtractFromDom(
    WebViewController controller,
  ) async {
    const script = '''
      (function() {
        // キャラクター名を取得（複数のセレクタを試す）
        const nameSelectors = [
          '.character-name',
          '.charaName',
          '[class*="characterName"]',
          'h1',
          'h2'
        ];
        let name = null;
        for (const sel of nameSelectors) {
          const el = document.querySelector(sel);
          if (el && el.textContent.trim()) {
            name = el.textContent.trim();
            break;
          }
        }

        // ステータステーブルからHP/MP/SANを探す
        const allText = document.body.innerText || '';

        // 正規表現でステータス値を抽出
        const hpMatch = allText.match(/HP[\\s:：]*(\\d+)\\s*[/／]\\s*(\\d+)/i);
        const mpMatch = allText.match(/MP[\\s:：]*(\\d+)\\s*[/／]\\s*(\\d+)/i);
        const sanMatch = allText.match(/SAN[\\s:：]*(\\d+)\\s*[/／]\\s*(\\d+)/i);

        return JSON.stringify({
          name: name,
          hp: hpMatch ? parseInt(hpMatch[1]) : null,
          maxHp: hpMatch ? parseInt(hpMatch[2]) : null,
          mp: mpMatch ? parseInt(mpMatch[1]) : null,
          maxMp: mpMatch ? parseInt(mpMatch[2]) : null,
          san: sanMatch ? parseInt(sanMatch[1]) : null,
          maxSan: sanMatch ? parseInt(sanMatch[2]) : null
        });
      })()
    ''';

    final result = await controller.runJavaScriptReturningResult(script);

    if (result == 'null' || result.toString().isEmpty) {
      return null;
    }

    try {
      String jsonStr = result.toString();
      if (jsonStr.startsWith('"') && jsonStr.endsWith('"')) {
        jsonStr = jsonStr.substring(1, jsonStr.length - 1);
        jsonStr = jsonStr.replaceAll(r'\"', '"');
        jsonStr = jsonStr.replaceAll(r'\\', r'\');
      }

      final data = json.decode(jsonStr) as Map<String, dynamic>;

      // 名前がない場合は失敗とみなす
      if (data['name'] == null) return null;

      return CharacterSheetResult(
        name: data['name'] as String?,
        hp: data['hp'] as int?,
        maxHp: data['maxHp'] as int?,
        mp: data['mp'] as int?,
        maxMp: data['maxMp'] as int?,
        san: data['san'] as int?,
        maxSan: data['maxSan'] as int?,
        rawData: data,
      );
    } catch (e) {
      debugPrint('DOM parse error: $e');
      return null;
    }
  }

  /// 文字列を整数にパース
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }
}
