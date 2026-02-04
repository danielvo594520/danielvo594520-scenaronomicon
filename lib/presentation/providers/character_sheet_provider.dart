import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/character_sheet/character_sheet_result.dart';
import '../../core/services/character_sheet/character_sheet_service.dart';
import '../../core/services/character_sheet/character_sheet_service_factory.dart';

/// キャラクターシート取得の状態
sealed class CharacterSheetFetchState {
  const CharacterSheetFetchState();
}

/// 初期状態
class CharacterSheetFetchIdle extends CharacterSheetFetchState {
  const CharacterSheetFetchIdle();
}

/// 取得中
class CharacterSheetFetchLoading extends CharacterSheetFetchState {
  const CharacterSheetFetchLoading({required this.serviceName});

  final String serviceName;
}

/// 取得成功
class CharacterSheetFetchSuccess extends CharacterSheetFetchState {
  const CharacterSheetFetchSuccess({
    required this.result,
    required this.serviceName,
  });

  final CharacterSheetResult result;
  final String serviceName;
}

/// 取得エラー
class CharacterSheetFetchError extends CharacterSheetFetchState {
  const CharacterSheetFetchError({required this.message});

  final String message;
}

/// 非対応URL
class CharacterSheetFetchUnsupported extends CharacterSheetFetchState {
  const CharacterSheetFetchUnsupported();
}

/// キャラクターシート取得のNotifier
class CharacterSheetFetchNotifier extends StateNotifier<CharacterSheetFetchState> {
  CharacterSheetFetchNotifier() : super(const CharacterSheetFetchIdle());

  final _factory = CharacterSheetServiceFactory();

  /// URLが対応しているかチェック
  bool canHandle(String url) {
    if (url.isEmpty) return false;
    return _factory.canHandle(url);
  }

  /// 対応サービス名を取得
  String? getServiceName(String url) {
    return _factory.getServiceName(url);
  }

  /// キャラクター情報を取得
  Future<void> fetch(String url) async {
    if (url.isEmpty) {
      state = const CharacterSheetFetchUnsupported();
      return;
    }

    final service = _factory.getServiceForUrl(url);
    if (service == null) {
      state = const CharacterSheetFetchUnsupported();
      return;
    }

    state = CharacterSheetFetchLoading(serviceName: service.serviceName);

    try {
      final result = await service.fetchCharacter(url);
      state = CharacterSheetFetchSuccess(
        result: result,
        serviceName: service.serviceName,
      );
    } on CharacterSheetFetchException catch (e) {
      state = CharacterSheetFetchError(message: e.message);
    } catch (e) {
      state = CharacterSheetFetchError(message: '予期しないエラーが発生しました: $e');
    }
  }

  /// 状態をリセット
  void reset() {
    state = const CharacterSheetFetchIdle();
  }
}

/// キャラクターシート取得のProvider
final characterSheetFetchProvider =
    StateNotifierProvider.autoDispose<CharacterSheetFetchNotifier, CharacterSheetFetchState>(
  (ref) => CharacterSheetFetchNotifier(),
);
