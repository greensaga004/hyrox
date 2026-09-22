// core/storage/hive_bootstrap.dart
import 'package:hive_flutter/hive_flutter.dart';

class HiveBootstrap {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await Hive.initFlutter();
    _isInitialized = true;
  }
}
