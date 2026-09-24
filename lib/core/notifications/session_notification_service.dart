// core/notifications/session_notification_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:hyrox/l10n/app_localizations.dart';

enum SessionNotificationAction { pause, resume, completeWorkout }

class SessionNotificationSnapshot {
  const SessionNotificationSnapshot({
    required this.title,
    required this.body,
    required this.pauseActionLabel,
    required this.resumeActionLabel,
    required this.completeWorkoutActionLabel,
    required this.showPauseAction,
    required this.showResumeAction,
    required this.showCompleteWorkoutAction,
  });

  final String title;
  final String body;
  final String pauseActionLabel;
  final String resumeActionLabel;
  final String completeWorkoutActionLabel;
  final bool showPauseAction;
  final bool showResumeAction;
  final bool showCompleteWorkoutAction;
}

abstract class SessionNotificationService {
  Future<void> initialize();

  Future<void> showOrUpdate(SessionNotificationSnapshot snapshot);

  Future<void> clear();

  Stream<SessionNotificationAction> get actions;
}

const int sessionForegroundNotificationId = 6201;
const String sessionNotificationChannelId = 'hyrox_session_tracking';

const String _pauseActionId = 'hyrox.pause';
const String _resumeActionId = 'hyrox.resume';
const String _completeWorkoutActionId = 'hyrox.complete_workout';

final StreamController<SessionNotificationAction>
_sessionNotificationActionController =
    StreamController<SessionNotificationAction>.broadcast();

SessionNotificationAction? _mapActionId(String? actionId) {
  switch (actionId) {
    case _pauseActionId:
      return SessionNotificationAction.pause;
    case _resumeActionId:
      return SessionNotificationAction.resume;
    case _completeWorkoutActionId:
      return SessionNotificationAction.completeWorkout;
    default:
      return null;
  }
}

void _handleNotificationResponse(NotificationResponse response) {
  final SessionNotificationAction? action = _mapActionId(response.actionId);
  if (action != null) {
    _sessionNotificationActionController.add(action);
  }
}

@pragma('vm:entry-point')
void onSessionNotificationResponseBackground(NotificationResponse response) {
  _handleNotificationResponse(response);
}

class AndroidSessionNotificationService implements SessionNotificationService {
  AndroidSessionNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  @override
  Stream<SessionNotificationAction> get actions =>
      _sessionNotificationActionController.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onSessionNotificationResponseBackground,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    _isInitialized = true;
  }

  @override
  Future<void> showOrUpdate(SessionNotificationSnapshot snapshot) async {
    if (!_isInitialized) {
      return;
    }

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) {
      return;
    }

    final AppLocalizations l10n = _notificationLocalizations();

    final List<AndroidNotificationAction> actions = <AndroidNotificationAction>[
      if (snapshot.showPauseAction)
        AndroidNotificationAction(
          _pauseActionId,
          snapshot.pauseActionLabel,
          showsUserInterface: false,
          cancelNotification: false,
        ),
      if (snapshot.showResumeAction)
        AndroidNotificationAction(
          _resumeActionId,
          snapshot.resumeActionLabel,
          showsUserInterface: false,
          cancelNotification: false,
        ),
      if (snapshot.showCompleteWorkoutAction)
        AndroidNotificationAction(
          _completeWorkoutActionId,
          snapshot.completeWorkoutActionLabel,
          showsUserInterface: false,
          cancelNotification: false,
        ),
    ];

    final AndroidNotificationDetails details = AndroidNotificationDetails(
      sessionNotificationChannelId,
      l10n.notificationChannelName,
      channelDescription: l10n.notificationChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      actions: actions,
      category: AndroidNotificationCategory.progress,
      playSound: false,
      enableVibration: false,
    );

    await androidPlugin.startForegroundService(
      id: sessionForegroundNotificationId,
      title: snapshot.title,
      body: snapshot.body,
      notificationDetails: details,
      foregroundServiceTypes: <AndroidServiceForegroundType>{
        AndroidServiceForegroundType.foregroundServiceTypeDataSync,
      },
    );
  }

  @override
  Future<void> clear() async {
    if (!_isInitialized) {
      return;
    }

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.stopForegroundService();
    await _plugin.cancel(id: sessionForegroundNotificationId);
  }

  AppLocalizations _notificationLocalizations() {
    final Locale locale = PlatformDispatcher.instance.locale;
    try {
      return lookupAppLocalizations(locale);
    } on FlutterError {
      return lookupAppLocalizations(const Locale('en'));
    }
  }
}

class NoopSessionNotificationService implements SessionNotificationService {
  const NoopSessionNotificationService();

  @override
  Stream<SessionNotificationAction> get actions =>
      const Stream<SessionNotificationAction>.empty();

  @override
  Future<void> clear() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showOrUpdate(SessionNotificationSnapshot snapshot) async {}
}

final Provider<SessionNotificationService> sessionNotificationServiceProvider =
    Provider<SessionNotificationService>((Ref ref) {
      return const NoopSessionNotificationService();
    });
