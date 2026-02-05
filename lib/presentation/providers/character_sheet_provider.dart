import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/ccfolia_parser.dart';
import '../../core/services/character_sheet/character_sheet_result.dart';

/// ココフォリア駒パースの状態
sealed class CcfoliaParseState {
  const CcfoliaParseState();
}

/// 初期状態
class CcfoliaParseIdle extends CcfoliaParseState {
  const CcfoliaParseIdle();
}

/// パース成功
class CcfoliaParseSuccess extends CcfoliaParseState {
  const CcfoliaParseSuccess({required this.result});

  final CharacterSheetResult result;
}

/// パースエラー
class CcfoliaParseError extends CcfoliaParseState {
  const CcfoliaParseError({required this.message});

  final String message;
}

/// ココフォリア駒パースのNotifier
class CcfoliaParseNotifier extends StateNotifier<CcfoliaParseState> {
  CcfoliaParseNotifier() : super(const CcfoliaParseIdle());

  /// JSONテキストをパース
  void parse(String jsonText) {
    if (jsonText.trim().isEmpty) {
      state = const CcfoliaParseError(message: 'テキストが入力されていません');
      return;
    }

    // フォーマットチェック
    if (!CcfoliaParser.isValidFormat(jsonText)) {
      state = const CcfoliaParseError(
        message: 'ココフォリア駒出力の形式ではありません。\n「駒を出力」でコピーしたJSONを貼り付けてください。',
      );
      return;
    }

    final result = CcfoliaParser.parse(jsonText);
    if (result == null) {
      state = const CcfoliaParseError(message: 'パースに失敗しました');
      return;
    }

    state = CcfoliaParseSuccess(result: result);
  }

  /// 状態をリセット
  void reset() {
    state = const CcfoliaParseIdle();
  }
}

/// ココフォリア駒パースのProvider
final ccfoliaParseProvider =
    StateNotifierProvider.autoDispose<CcfoliaParseNotifier, CcfoliaParseState>(
  (ref) => CcfoliaParseNotifier(),
);
