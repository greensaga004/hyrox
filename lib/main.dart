// main.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/app/app.dart';
import 'package:hyrox/core/storage/hive_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBootstrap.initialize();

  runApp(const ProviderScope(child: HyroxApp()));
}
