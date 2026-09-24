// app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/l10n/app_localizations.dart';
import 'package:hyrox/app/localization/locale_config.dart';
import 'package:hyrox/app/router/app_router.dart';
import 'package:hyrox/app/theme/app_theme.dart';
import 'package:hyrox/features/settings/application/settings_controller.dart';

class HyroxApp extends ConsumerWidget {
  const HyroxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? localeOverride = ref.watch(appLocaleOverrideProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeOverride,
      localeResolutionCallback: AppLocaleConfig.resolve,
      routerConfig: appRouter,
    );
  }
}
