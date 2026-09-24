// main.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/app/app.dart';
import 'package:hyrox/core/background/session_background_service.dart';
import 'package:hyrox/core/notifications/session_notification_service.dart';
import 'package:hyrox/core/storage/hive_bootstrap.dart';
import 'package:hyrox/core/tts/session_voice_alert_service.dart';
import 'package:hyrox/features/session/data/session_recovery_repository.dart';
import 'package:hyrox/features/settings/data/app_info_repository.dart';
import 'package:hyrox/features/settings/data/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: <Override>[
        sessionRecoveryRepositoryProvider.overrideWithValue(
          HiveSessionRecoveryRepository(),
        ),
        sessionBackgroundServiceProvider.overrideWithValue(
          AndroidSessionBackgroundService(),
        ),
        sessionNotificationServiceProvider.overrideWithValue(
          AndroidSessionNotificationService(),
        ),
        sessionVoiceAlertServiceProvider.overrideWithValue(
          AndroidSessionVoiceAlertService(),
        ),
        settingsRepositoryProvider.overrideWithValue(HiveSettingsRepository()),
        appInfoRepositoryProvider.overrideWithValue(
          PackageInfoAppInfoRepository(),
        ),
      ],
      child: const HyroxApp(),
    ),
  );
}
