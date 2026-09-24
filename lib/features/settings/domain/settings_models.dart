// features/settings/domain/settings_models.dart
import 'package:flutter/material.dart';

enum AppLanguage { english, traditionalChinese }

extension AppLanguageCodec on AppLanguage {
  static AppLanguage? fromStorage(String? value) {
    switch (value) {
      case 'en':
        return AppLanguage.english;
      case 'zh_TW':
        return AppLanguage.traditionalChinese;
      default:
        return null;
    }
  }

  String get storageValue {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.traditionalChinese:
        return 'zh_TW';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.traditionalChinese:
        return const Locale('zh', 'TW');
    }
  }
}

class AppInfoSnapshot {
  const AppInfoSnapshot({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });

  const AppInfoSnapshot.unknown()
    : appName = '-',
      version = '-',
      buildNumber = '-';

  final String appName;
  final String version;
  final String buildNumber;
}
