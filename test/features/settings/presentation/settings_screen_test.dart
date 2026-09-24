// test/features/settings/presentation/settings_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox/features/settings/data/app_info_repository.dart';
import 'package:hyrox/features/settings/data/settings_repository.dart';
import 'package:hyrox/features/settings/domain/settings_models.dart';
import 'package:hyrox/features/settings/presentation/screens/settings_screen.dart';
import 'package:hyrox/l10n/app_localizations.dart';

void main() {
  testWidgets('renders language, app information, and future placeholders', (
    WidgetTester tester,
  ) async {
    final InMemorySettingsRepository settingsRepository =
        InMemorySettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          appInfoRepositoryProvider.overrideWithValue(_FakeAppInfoRepository()),
        ],
        child: const _TestApp(child: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Traditional Chinese'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    expect(find.text('Application Information'), findsOneWidget);
    expect(
      find.text('Application Name: HYROX Training Tracker'),
      findsOneWidget,
    );
    expect(find.text('Version: 1.0.0'), findsOneWidget);
    expect(find.text('Build Number: 100'), findsOneWidget);

    expect(find.text('Future Settings'), findsOneWidget);
    expect(find.text('Auto Transition'), findsOneWidget);
    expect(find.text('Voice Alerts'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('Default Rest Duration'), findsOneWidget);
    expect(find.text('Target Finish Time'), findsOneWidget);
    expect(find.text('Coming soon'), findsNWidgets(5));
  });

  testWidgets('selecting language persists selectedLanguage', (
    WidgetTester tester,
  ) async {
    final InMemorySettingsRepository settingsRepository =
        InMemorySettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          appInfoRepositoryProvider.overrideWithValue(_FakeAppInfoRepository()),
        ],
        child: const _TestApp(child: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Traditional Chinese'));
    await tester.pumpAndSettle();

    expect(
      await settingsRepository.loadSelectedLanguage(),
      AppLanguage.traditionalChinese,
    );
  });
}

class _FakeAppInfoRepository implements AppInfoRepository {
  @override
  Future<AppInfoSnapshot> load() async {
    return const AppInfoSnapshot(
      appName: 'HYROX Training Tracker',
      version: '1.0.0',
      buildNumber: '100',
    );
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
