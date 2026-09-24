// core/background/session_background_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class SessionBackgroundService {
  Future<void> initialize();

  Future<void> start();

  Future<void> stop();

  bool get isRunning;
}

class AndroidSessionBackgroundService implements SessionBackgroundService {
  AndroidSessionBackgroundService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isRunning = false;
  bool _isInitialized = false;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> start() async {
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    if (_isInitialized) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.stopForegroundService();
    }
    _isRunning = false;
  }
}

class NoopSessionBackgroundService implements SessionBackgroundService {
  NoopSessionBackgroundService();

  bool _isRunning = false;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> start() async {
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
  }
}

final Provider<SessionBackgroundService> sessionBackgroundServiceProvider =
    Provider<SessionBackgroundService>((Ref ref) {
      return NoopSessionBackgroundService();
    });
