// test/app/localization/notification_localization_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox/l10n/app_localizations.dart';

void main() {
  test('notification channel localization keys exist in English', () {
    final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

    expect(en.notificationChannelName, isNotEmpty);
    expect(en.notificationChannelDescription, isNotEmpty);
  });

  test(
    'notification channel localization keys exist in Traditional Chinese',
    () {
      final AppLocalizations zhTw = lookupAppLocalizations(
        const Locale('zh', 'TW'),
      );

      expect(zhTw.notificationChannelName, isNotEmpty);
      expect(zhTw.notificationChannelDescription, isNotEmpty);
    },
  );
}
