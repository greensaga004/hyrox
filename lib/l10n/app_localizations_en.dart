// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HYROX Training Tracker';

  @override
  String get foundationReady => 'Foundation scaffold is ready.';

  @override
  String get placeholderDescription =>
      'Core architecture, routing, localization, and storage bootstrap are wired.';
}
