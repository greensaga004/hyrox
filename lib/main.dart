// main.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/app/app.dart';
import 'package:hyrox/core/storage/hive_bootstrap.dart';
import 'package:hyrox/features/session/data/session_recovery_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: <Override>[
        sessionRecoveryRepositoryProvider.overrideWithValue(
          HiveSessionRecoveryRepository(),
        ),
      ],
      child: const HyroxApp(),
    ),
  );
}
