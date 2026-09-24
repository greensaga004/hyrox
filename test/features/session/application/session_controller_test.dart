// test/features/session/application/session_controller_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox/core/background/session_background_service.dart';
import 'package:hyrox/core/notifications/session_notification_service.dart';
import 'package:hyrox/core/timer/timer_engine.dart';
import 'package:hyrox/core/tts/session_voice_alert_service.dart';
import 'package:hyrox/features/session/application/session_controller.dart';
import 'package:hyrox/features/session/data/session_recovery_models.dart';
import 'package:hyrox/features/session/data/session_recovery_repository.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';

class FakeSessionBackgroundService implements SessionBackgroundService {
  bool initialized = false;
  bool started = false;
  int startCalls = 0;
  int stopCalls = 0;

  @override
  bool get isRunning => started;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> start() async {
    started = true;
    startCalls += 1;
  }

  @override
  Future<void> stop() async {
    started = false;
    stopCalls += 1;
  }
}

class FakeSessionNotificationService implements SessionNotificationService {
  bool initialized = false;
  int showCalls = 0;
  int clearCalls = 0;
  SessionNotificationSnapshot? lastSnapshot;

  final StreamController<SessionNotificationAction> _actions =
      StreamController<SessionNotificationAction>.broadcast();

  @override
  Stream<SessionNotificationAction> get actions => _actions.stream;

  @override
  Future<void> clear() async {
    clearCalls += 1;
  }

  void emit(SessionNotificationAction action) {
    _actions.add(action);
  }

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> showOrUpdate(SessionNotificationSnapshot snapshot) async {
    showCalls += 1;
    lastSnapshot = snapshot;
  }
}

class FakeSessionVoiceAlertService implements SessionVoiceAlertService {
  bool initialized = false;
  int stopCalls = 0;
  final List<String> spoken = <String>[];

  @override
  Future<void> announce(String message) async {
    spoken.add(message);
  }

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }
}

class FakeTimeProvider implements TimeProvider {
  FakeTimeProvider(this._current);

  DateTime _current;

  @override
  DateTime now() => _current;

  void advance(Duration duration) {
    _current = _current.add(duration);
  }
}

void main() {
  late FakeTimeProvider timeProvider;
  late SessionController controller;

  setUp(() {
    timeProvider = FakeTimeProvider(DateTime(2026, 1, 1, 8, 0, 0));
    controller = SessionController(
      timeProvider: timeProvider,
      enableTicker: false,
      autoTransitionEnabled: false,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('manual flow completes one event and advances to the next event', () {
    controller.startWorkout();
    timeProvider.advance(const Duration(seconds: 10));
    controller.startPause();
    timeProvider.advance(const Duration(seconds: 5));
    controller.resumeWorkout();
    timeProvider.advance(const Duration(seconds: 20));
    controller.completeWorkout();
    controller.startRest();
    timeProvider.advance(const Duration(seconds: 15));
    controller.completeRest();

    final SessionViewState state = controller.state;
    final EventSplit firstEvent = state.splits.first;

    expect(state.currentEventIndex, 1);
    expect(state.sessionState, SessionFlowState.idle);
    expect(firstEvent.completed, isTrue);
    expect(firstEvent.workoutTime, const Duration(seconds: 30));
    expect(firstEvent.pauseTime, const Duration(seconds: 5));
    expect(firstEvent.pauseCount, 1);
    expect(firstEvent.restTime, const Duration(seconds: 15));

    expect(state.totals.totalWorkoutTime, const Duration(seconds: 30));
    expect(state.totals.totalPauseTime, const Duration(seconds: 5));
    expect(state.totals.totalPauseCount, 1);
    expect(state.totals.totalRestTime, const Duration(seconds: 15));
  });

  test('complete workout does not auto-advance event in manual mode', () {
    controller.startWorkout();
    timeProvider.advance(const Duration(seconds: 8));
    controller.completeWorkout();

    final SessionViewState state = controller.state;

    expect(state.currentEventIndex, 0);
    expect(state.sessionState, SessionFlowState.workoutCompleted);
    expect(state.completedEventCount, 0);
  });

  test('repeated pause and resume accumulates pause count and duration', () {
    controller.startWorkout();
    timeProvider.advance(const Duration(seconds: 12));

    controller.startPause();
    timeProvider.advance(const Duration(seconds: 3));
    controller.resumeWorkout();

    controller.startPause();
    timeProvider.advance(const Duration(seconds: 4));
    controller.resumeWorkout();

    controller.completeWorkout();

    final EventSplit current = controller.state.currentEventSplit;

    expect(current.pauseCount, 2);
    expect(current.pauseTime, const Duration(seconds: 7));
  });

  test('invalid transitions throw StateError', () {
    expect(controller.startPause, throwsStateError);
    expect(controller.completeWorkout, throwsStateError);
    expect(controller.startRest, throwsStateError);
  });

  test('session becomes completed after final event rest completes', () {
    final List<HyroxEventDefinition> twoEvents = <HyroxEventDefinition>[
      const HyroxEventDefinition(order: 1, station: HyroxStation.run1),
      const HyroxEventDefinition(order: 2, station: HyroxStation.skiErg),
    ];

    final SessionController smallController = SessionController(
      events: twoEvents,
      timeProvider: timeProvider,
      enableTicker: false,
      autoTransitionEnabled: false,
    );

    addTearDown(smallController.dispose);

    smallController.startWorkout();
    timeProvider.advance(const Duration(seconds: 5));
    smallController.completeWorkout();
    smallController.startRest();
    timeProvider.advance(const Duration(seconds: 5));
    smallController.completeRest();

    smallController.startWorkout();
    timeProvider.advance(const Duration(seconds: 7));
    smallController.completeWorkout();
    smallController.startRest();
    timeProvider.advance(const Duration(seconds: 2));
    smallController.completeRest();

    final SessionViewState state = smallController.state;

    expect(state.sessionCompleted, isTrue);
    expect(state.sessionState, SessionFlowState.completed);
    expect(state.currentEventIndex, 1);
    expect(state.completedEventCount, 2);
  });

  test('auto mode starts rest and next workout after configured delays', () {
    final List<HyroxEventDefinition> twoEvents = <HyroxEventDefinition>[
      const HyroxEventDefinition(order: 1, station: HyroxStation.run1),
      const HyroxEventDefinition(order: 2, station: HyroxStation.skiErg),
    ];

    final SessionController autoController = SessionController(
      events: twoEvents,
      timeProvider: timeProvider,
      enableTicker: false,
      autoTransitionEnabled: true,
      transitionDelay: const Duration(seconds: 3),
      defaultRestDuration: const Duration(seconds: 5),
    );

    addTearDown(autoController.dispose);

    autoController.startWorkout();
    timeProvider.advance(const Duration(seconds: 4));
    autoController.completeWorkout();

    expect(
      autoController.state.sessionState,
      SessionFlowState.workoutCompleted,
    );

    timeProvider.advance(const Duration(seconds: 2));
    autoController.refresh();
    expect(
      autoController.state.sessionState,
      SessionFlowState.workoutCompleted,
    );

    timeProvider.advance(const Duration(seconds: 1));
    autoController.refresh();
    expect(autoController.state.sessionState, SessionFlowState.restRunning);

    timeProvider.advance(const Duration(seconds: 4));
    autoController.refresh();
    expect(autoController.state.sessionState, SessionFlowState.restRunning);

    timeProvider.advance(const Duration(seconds: 1));
    autoController.refresh();
    expect(autoController.state.currentEventIndex, 1);
    expect(autoController.state.sessionState, SessionFlowState.idle);
    expect(autoController.state.splits.first.completed, isTrue);
    expect(
      autoController.state.splits.first.restTime,
      const Duration(seconds: 5),
    );

    timeProvider.advance(const Duration(seconds: 3));
    autoController.refresh();
    expect(autoController.state.sessionState, SessionFlowState.workoutRunning);
    expect(autoController.state.currentEventIndex, 1);
  });

  test('auto mode is enabled by default with supported delay options', () {
    final SessionController autoController = SessionController(
      timeProvider: timeProvider,
      enableTicker: false,
    );

    addTearDown(autoController.dispose);

    expect(autoController.state.autoTransitionEnabled, isTrue);
    expect(
      SessionController.transitionDelayOptions,
      contains(const Duration(seconds: 3)),
    );
  });

  test(
    'restoreFromRecovery keeps elapsed timing consistent after downtime',
    () async {
      final InMemorySessionRecoveryRepository repository =
          InMemorySessionRecoveryRepository();

      final SessionController writer = SessionController(
        timeProvider: timeProvider,
        enableTicker: false,
        autoTransitionEnabled: false,
        recoveryRepository: repository,
      );
      addTearDown(writer.dispose);

      writer.startWorkout();
      timeProvider.advance(const Duration(seconds: 10));
      writer.startPause();

      final SessionRecoveryPayload? payload = await writer
          .loadRecoveryCandidate();
      expect(payload, isNotNull);

      timeProvider.advance(const Duration(seconds: 7));

      final SessionController restored = SessionController(
        timeProvider: timeProvider,
        enableTicker: false,
        autoTransitionEnabled: false,
        recoveryRepository: repository,
      );
      addTearDown(restored.dispose);

      await restored.restoreFromRecovery(payload!);

      expect(restored.state.sessionState, SessionFlowState.eventPaused);
      expect(
        restored.state.currentEventSplit.workoutTime,
        const Duration(seconds: 10),
      );
      expect(
        restored.state.currentEventSplit.pauseTime,
        const Duration(seconds: 7),
      );
      expect(restored.state.currentEventSplit.pauseCount, 0);
    },
  );

  test(
    'discardRecovery clears stored payload and resets session state',
    () async {
      final InMemorySessionRecoveryRepository repository =
          InMemorySessionRecoveryRepository();

      final SessionController persistedController = SessionController(
        timeProvider: timeProvider,
        enableTicker: false,
        autoTransitionEnabled: false,
        recoveryRepository: repository,
      );
      addTearDown(persistedController.dispose);

      persistedController.startWorkout();
      timeProvider.advance(const Duration(seconds: 6));
      persistedController.startPause();

      expect(await repository.load(), isNotNull);

      await persistedController.discardRecovery();

      expect(await repository.load(), isNull);
      expect(persistedController.state.currentEventIndex, 0);
      expect(persistedController.state.sessionState, SessionFlowState.idle);
      expect(persistedController.state.totals.totalSessionTime, Duration.zero);
    },
  );

  test('loadRecoveryCandidate clears incompatible schema payload', () async {
    final InMemorySessionRecoveryRepository repository =
        InMemorySessionRecoveryRepository();
    final SessionController persistedController = SessionController(
      timeProvider: timeProvider,
      enableTicker: false,
      autoTransitionEnabled: false,
      recoveryRepository: repository,
    );
    addTearDown(persistedController.dispose);

    final SessionRecoveryPayload payload = SessionRecoveryPayload(
      schemaVersion: SessionRecoveryPayload.currentSchemaVersion + 1,
      savedAtEpochMs: timeProvider.now().millisecondsSinceEpoch,
      currentEventIndex: 0,
      sessionState: SessionFlowState.idle.name,
      sessionCompleted: false,
      autoTransitionEnabled: true,
      transitionDelayMs: const Duration(seconds: 3).inMilliseconds,
      defaultRestDurationMs: const Duration(seconds: 60).inMilliseconds,
      nextAutoTransitionAtEpochMs: null,
      nextAutoTransitionAction: null,
      timerPhase: TimerPhase.idle.name,
      timerWorkoutMs: 0,
      timerPauseMs: 0,
      timerPauseCount: 0,
      timerRestMs: 0,
      timerWorkoutStartedAtEpochMs: null,
      timerPauseStartedAtEpochMs: null,
      timerRestStartedAtEpochMs: null,
      splits: List<PersistedEventSplit>.filled(
        hyroxEventDefinitions.length,
        const PersistedEventSplit(
          workoutMs: 0,
          pauseMs: 0,
          pauseCount: 0,
          restMs: 0,
          completed: false,
        ),
      ),
    );

    await repository.save(payload);

    final SessionRecoveryPayload? loaded = await persistedController
        .loadRecoveryCandidate();

    expect(loaded, isNull);
    expect(await repository.load(), isNull);
  });

  test(
    'runtime services start on active session and stop after completion',
    () async {
      final FakeSessionBackgroundService background =
          FakeSessionBackgroundService();
      final FakeSessionNotificationService notifications =
          FakeSessionNotificationService();
      final List<HyroxEventDefinition> oneEvent = <HyroxEventDefinition>[
        const HyroxEventDefinition(order: 1, station: HyroxStation.run1),
      ];

      final SessionController runtimeController = SessionController(
        events: oneEvent,
        timeProvider: timeProvider,
        enableTicker: false,
        autoTransitionEnabled: false,
        backgroundService: background,
        notificationService: notifications,
      );
      addTearDown(runtimeController.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(background.initialized, isTrue);
      expect(notifications.initialized, isTrue);

      final int initialStartCalls = background.startCalls;
      final int initialShowCalls = notifications.showCalls;

      runtimeController.startWorkout();
      await Future<void>.delayed(Duration.zero);

      expect(
        runtimeController.state.sessionState,
        SessionFlowState.workoutRunning,
      );
      expect(background.startCalls, greaterThan(initialStartCalls));
      expect(notifications.showCalls, greaterThan(initialShowCalls));

      runtimeController.completeWorkout();
      runtimeController.startRest();
      runtimeController.completeRest();
      await Future<void>.delayed(Duration.zero);

      expect(runtimeController.state.sessionCompleted, isTrue);
      expect(background.isRunning, isFalse);
      expect(background.stopCalls, greaterThan(0));
      expect(notifications.clearCalls, greaterThan(0));
    },
  );

  test(
    'notification actions dispatch to controller with phase guardrails',
    () async {
      final FakeSessionBackgroundService background =
          FakeSessionBackgroundService();
      final FakeSessionNotificationService notifications =
          FakeSessionNotificationService();

      final SessionController runtimeController = SessionController(
        timeProvider: timeProvider,
        enableTicker: false,
        autoTransitionEnabled: false,
        backgroundService: background,
        notificationService: notifications,
      );
      addTearDown(runtimeController.dispose);

      await Future<void>.delayed(Duration.zero);

      notifications.emit(SessionNotificationAction.pause);
      await Future<void>.delayed(Duration.zero);
      expect(runtimeController.state.sessionState, SessionFlowState.idle);

      runtimeController.startWorkout();
      await Future<void>.delayed(Duration.zero);
      expect(
        runtimeController.state.sessionState,
        SessionFlowState.workoutRunning,
      );

      notifications.emit(SessionNotificationAction.pause);
      await Future<void>.delayed(Duration.zero);
      expect(
        runtimeController.state.sessionState,
        SessionFlowState.eventPaused,
      );

      notifications.emit(SessionNotificationAction.resume);
      await Future<void>.delayed(Duration.zero);
      expect(
        runtimeController.state.sessionState,
        SessionFlowState.workoutRunning,
      );

      notifications.emit(SessionNotificationAction.completeWorkout);
      await Future<void>.delayed(Duration.zero);
      expect(
        runtimeController.state.sessionState,
        SessionFlowState.workoutCompleted,
      );
    },
  );

  test('voice alerts announce key session transitions', () async {
    final FakeSessionVoiceAlertService voiceAlerts =
        FakeSessionVoiceAlertService();
    final List<HyroxEventDefinition> twoEvents = <HyroxEventDefinition>[
      const HyroxEventDefinition(order: 1, station: HyroxStation.run1),
      const HyroxEventDefinition(order: 2, station: HyroxStation.skiErg),
    ];

    final SessionController voiceController = SessionController(
      events: twoEvents,
      timeProvider: timeProvider,
      enableTicker: false,
      autoTransitionEnabled: false,
      voiceAlertService: voiceAlerts,
    );
    addTearDown(voiceController.dispose);

    await Future<void>.delayed(Duration.zero);
    expect(voiceAlerts.initialized, isTrue);

    voiceController.startWorkout();
    voiceController.startPause();
    voiceController.resumeWorkout();
    voiceController.completeWorkout();
    voiceController.startRest();
    voiceController.completeRest();

    voiceController.startWorkout();
    voiceController.completeWorkout();
    voiceController.startRest();
    voiceController.completeRest();

    await Future<void>.delayed(Duration.zero);

    expect(voiceController.state.sessionCompleted, isTrue);
    expect(voiceAlerts.spoken, <String>[
      'Start Run 1',
      'Pause started',
      'Pause ended',
      'Workout complete',
      'Start rest',
      'Rest complete',
      'Start SkiErg',
      'Workout complete',
      'Start rest',
      'Rest complete',
      'Session complete',
    ]);
  });
}
