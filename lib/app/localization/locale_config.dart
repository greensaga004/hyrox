// app/localization/locale_config.dart
import 'package:flutter/material.dart';

class AppLocaleConfig {
  static const Locale fallbackLocale = Locale('en');

  static Locale resolve(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale == null) {
      return fallbackLocale;
    }

    for (final Locale supportedLocale in supportedLocales) {
      final bool sameLanguage = supportedLocale.languageCode == locale.languageCode;
      final bool sameScript = (supportedLocale.scriptCode ?? '') == (locale.scriptCode ?? '');
      final bool sameCountry = (supportedLocale.countryCode ?? '') == (locale.countryCode ?? '');
      if (sameLanguage && sameScript && sameCountry) {
        return supportedLocale;
      }
    }

    for (final Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    return fallbackLocale;
  }
}
