import 'character_sheet_service.dart';
import 'providers/charasheet_provider.dart';
import 'providers/iachara_provider.dart';

/// キャラクターシート取得サービスのファクトリ
class CharacterSheetServiceFactory {
  CharacterSheetServiceFactory._();

  static final CharacterSheetServiceFactory _instance =
      CharacterSheetServiceFactory._();

  factory CharacterSheetServiceFactory() => _instance;

  /// 登録されているサービスプロバイダー
  final List<CharacterSheetService> _providers = [
    CharasheetProvider(),
    IacharaProvider(),
  ];

  /// URLに対応するサービスを取得
  /// 対応するサービスがない場合はnullを返す
  CharacterSheetService? getServiceForUrl(String url) {
    for (final provider in _providers) {
      if (provider.canHandle(url)) {
        return provider;
      }
    }
    return null;
  }

  /// URLが対応しているかどうかを判定
  bool canHandle(String url) {
    return getServiceForUrl(url) != null;
  }

  /// 対応サービス名を取得
  /// 対応していない場合はnullを返す
  String? getServiceName(String url) {
    return getServiceForUrl(url)?.serviceName;
  }

  /// 対応サービス一覧を取得
  List<String> get supportedServices =>
      _providers.map((p) => p.serviceName).toList();
}
