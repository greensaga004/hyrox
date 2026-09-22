// app/app.dart
import 'package:flutter/material.dart';
import 'package:hyrox/l10n/app_localizations.dart';
import 'package:hyrox/app/localization/locale_config.dart';
import 'package:hyrox/app/router/app_router.dart';
import 'package:hyrox/app/theme/app_theme.dart';

class HyroxApp extends StatelessWidget {
  const HyroxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: AppLocaleConfig.resolve,
      routerConfig: appRouter,
    );
  }
}
