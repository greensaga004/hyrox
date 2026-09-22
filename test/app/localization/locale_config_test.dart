// test/app/localization/locale_config_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox/app/localization/locale_config.dart';

void main() {
  const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  test('returns fallback locale when device locale is null', () {
    final Locale resolved = AppLocaleConfig.resolve(null, supportedLocales);

    expect(resolved, const Locale('en'));
  });

  test('returns exact zh_TW locale when available', () {
    const Locale deviceLocale = Locale('zh', 'TW');

    final Locale resolved = AppLocaleConfig.resolve(
      deviceLocale,
      supportedLocales,
    );

    expect(resolved, const Locale('zh', 'TW'));
  });

  test('falls back to English for unsupported locales', () {
    const Locale deviceLocale = Locale('es', 'ES');

    final Locale resolved = AppLocaleConfig.resolve(
      deviceLocale,
      supportedLocales,
    );

    expect(resolved, const Locale('en'));
  });
}
