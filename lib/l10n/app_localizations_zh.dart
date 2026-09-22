// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'HYROX 訓練追蹤器';

  @override
  String get foundationReady => '基礎架構已完成。';

  @override
  String get placeholderDescription => '核心架構、路由、本地化與儲存啟動已串接完成。';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'HYROX 訓練追蹤器';

  @override
  String get foundationReady => '基礎架構已完成。';

  @override
  String get placeholderDescription => '核心架構、路由、本地化與儲存啟動已串接完成。';
}
