import 'character_sheet_result.dart';

/// キャラクターシート取得サービスの抽象インターフェース
abstract class CharacterSheetService {
  /// サービス名
  String get serviceName;

  /// 対応するURLかどうかを判定
  bool canHandle(String url);

  /// キャラクター情報を取得
  ///
  /// [url] キャラクターシートのURL
  /// 取得失敗時は例外をスロー
  Future<CharacterSheetResult> fetchCharacter(String url);
}

/// キャラクターシート取得エラー
class CharacterSheetFetchException implements Exception {
  const CharacterSheetFetchException(this.message);

  final String message;

  @override
  String toString() => 'CharacterSheetFetchException: $message';
}
