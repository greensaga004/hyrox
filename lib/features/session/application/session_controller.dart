// features/session/application/session_controller.dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/core/background/session_background_service.dart';
import 'package:hyrox/core/notifications/session_notification_service.dart';
import 'package:hyrox/core/timer/timer_engine.dart';
import 'package:hyrox/features/session/data/session_recovery_mapper.dart';
import 'package:hyrox/features/session/data/session_recovery_models.dart';
import 'package:hyrox/features/session/data/session_recovery_repository.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';
import 'package:hyrox/l10n/app_localizations.dart';

final StateNotifierProvider<SessionController, SessionViewState>
sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionViewState>((Ref ref) {
      final SessionRecoveryRepository repository = ref.watch(
        sessionRecoveryRepositoryProvider,
      );
      final SessionBackgroundService backgroundService = ref.watch(
        sessionBackgroundServiceProvider,
      );
      final SessionNotificationService notificationService = ref.watch(
        sessionNotificationServiceProvider,
      );
      return SessionController(
        recoveryRepository: repository,
        backgroundService: backgroundService,
        notificationService: notificationService,
      );
    });

class SessionController extends StateNotifier<SessionViewState> {
  static const List<Duration> transitionDelayOptions = <Duration>[
    Duration.zero,
    Duration(seconds: 3),
    Duration(seconds: 5),
    Duration(seconds: 10),
  ];

  static const List<Duration> defaultRestDurationOptions = <Duration>[
    Duration(seconds: 30),
    Duration(seconds: 45),
    Duration(seconds: 60),
    Duration(seconds: 75),
    Duration(seconds: 90),
    Duration(seconds: 120),
  ];

  SessionController({
    List<HyroxEventDefinition>? events,
    TimeProvider? timeProvider,
    SessionRecoveryRepository? recoveryRepository,
    SessionBackgroundService? backgroundService,
    SessionNotificationService? notificationService,
    this.enableTicker = true,
    this.tickInterval = const Duration(seconds: 1),
    this.autoTransitionEnabled = true,
    this.transitionDelay = const Duration(seconds: 3),
    this.defaultRestDuration = const Duration(seconds: 60),
  }) : _events = events ?? hyroxEventDefinitions,
       _timeProvider = timeProvider ?? const SystemTimeProvider(),
       _recoveryRepository =
           recoveryRepository ?? InMemorySessionRecoveryRepository(),
       _backgroundService = backgroundService ?? NoopSessionBackgroundService(),
       _notificationService =
           notificationService ?? const NoopSessionNotificationService(),
       _initialAutoTransitionEnabled = autoTransitionEnabled,
       _initialTransitionDelay = transitionDelay,
       _initialDefaultRestDuration = defaultRestDuration,
       super(
         SessionViewState.initial(
           events ?? hyroxEventDefinitions,
           autoTransitionEnabled: autoTransitionEnabled,
           transitionDelay: transitionDelay,
           defaultRestDuration: defaultRestDuration,
         ),
       ) {
    _requireValidTransitionDelay(transitionDelay);
    if (defaultRestDuration.isNegative) {
      throw ArgumentError.value(
        defaultRestDuration,
        'defaultRestDuration',
        'Must be non-negative.',
      );
    }

    _engine = TimerEngine(timeProvider: _timeProvider);
    _applySnapshot(_engine.snapshot);
    _startTicker();
    unawaited(_initializeRuntimeIntegrations());
  }

  final List<HyroxEventDefinition> _events;
  final TimeProvider _timeProvider;
  final SessionRecoveryRepository _recoveryRepository;
  final SessionBackgroundService _backgroundService;
  final SessionNotificationService _notificationService;
  final bool enableTicker;
  final Duration tickInterval;
  final bool autoTransitionEnabled;
  final Duration transitionDelay;
  final Duration defaultRestDuration;
  final bool _initialAutoTransitionEnabled;
  final Duration _initialTransitionDelay;
  final Duration _initialDefaultRestDuration;

  late TimerEngine _engine;
  Timer? _ticker;
  StreamSubscription<SessionNotificationAction>? _notificationActions;
  bool _isHydrating = false;
  bool _runtimeReady = false;
  bool _runtimeSyncInProgress = false;
  bool _runtimeSyncQueued = false;

  void refresh() {
    _processAutoTransitions();
    _applySnapshot(_engine.snapshot);
    _processAutoTransitions();
    unawaited(_syncRuntimeIntegrations());
  }

  Future<SessionRecoveryPayload?> loadRecoveryCandidate() async {
    final SessionRecoveryPayload? payload = await _recoveryRepository.load();
    if (payload == null) {
      return null;
    }

    if (payload.schemaVersion != SessionRecoveryPayload.currentSchemaVersion ||
        payload.sessionCompleted) {
      await _recoveryRepository.clear();
      return null;
    }

    try {
      SessionRecoveryMapper.hydrate(payload, events: _events);
    } on FormatException {
      await _recoveryRepository.clear();
      return null;
    }

    return payload;
  }

  Future<void> restoreFromRecovery(SessionRecoveryPayload payload) async {
    if (payload.schemaVersion != SessionRecoveryPayload.currentSchemaVersion) {
      await _recoveryRepository.clear();
      return;
    }

    try {
      final SessionRecoveryHydration hydration = SessionRecoveryMapper.hydrate(
        payload,
        events: _events,
      );

      _isHydrating = true;
      state = hydration.state;
      _engine = TimerEngine.restored(
        snapshot: hydration.timerSnapshot,
        capturedAt: hydration.savedAt,
        timeProvider: _timeProvider,
      );
      _applySnapshot(_engine.snapshot);
      _processAutoTransitions();
    } on FormatException {
      await _recoveryRepository.clear();
    } finally {
      _isHydrating = false;
    }

    unawaited(_persistRecoveryState());
  }

  Future<void> discardRecovery() async {
    _clearAutoTransitionSchedule();
    _engine = TimerEngine(timeProvider: _timeProvider);

    state = SessionViewState.initial(
      _events,
      autoTransitionEnabled: _initialAutoTransitionEnabled,
      transitionDelay: _initialTransitionDelay,
      defaultRestDuration: _initialDefaultRestDuration,
    );
    _applySnapshot(_engine.snapshot);

    await _recoveryRepository.clear();
  }

  void startWorkout() {
    _clearAutoTransitionSchedule();
    final TimerSnapshot snapshot = _engine.startWorkout();
    _applySnapshot(snapshot);
    unawaited(_persistRecoveryState());
  }

  void startPause() {
    final TimerSnapshot snapshot = _engine.startPause();
    _applySnapshot(snapshot);
    unawaited(_persistRecoveryState());
  }

  void resumeWorkout() {
    final TimerSnapshot snapshot = _engine.resumeWorkout();
    _applySnapshot(snapshot);
    unawaited(_persistRecoveryState());
  }

  void completeWorkout() {
    _clearAutoTransitionSchedule();
    final TimerSnapshot snapshot = _engine.completeWorkout();
    _applySnapshot(snapshot);

    if (state.autoTransitionEnabled) {
      _scheduleAutoTransition(AutoTransitionAction.startRest);
    }

    unawaited(_persistRecoveryState());
  }

  void startRest() {
    _clearAutoTransitionSchedule();
    final TimerSnapshot snapshot = _engine.startRest();
    _applySnapshot(snapshot);
    _processAutoTransitions();
    unawaited(_persistRecoveryState());
  }

  void completeRest() {
    _clearAutoTransitionSchedule();
    final TimerSnapshot snapshot = _engine.completeRest();
    _completeRestAndAdvance(
      snapshot,
      scheduleNextWorkout: state.autoTransitionEnabled,
    );
    unawaited(_persistRecoveryState());
  }

  void setAutoTransitionEnabled(bool enabled) {
    if (enabled == state.autoTransitionEnabled) {
      return;
    }

    state = state.copyWith(
      autoTransitionEnabled: enabled,
      clearAutoTransition: !enabled,
    );

    _processAutoTransitions();
    unawaited(_persistRecoveryState());
  }

  void setTransitionDelay(Duration delay) {
    _requireValidTransitionDelay(delay);

    state = state.copyWith(transitionDelay: delay);
    _processAutoTransitions();
    unawaited(_persistRecoveryState());
  }

  void setDefaultRestDuration(Duration duration) {
    if (duration.isNegative) {
      throw ArgumentError.value(duration, 'duration', 'Must be non-negative.');
    }

    state = state.copyWith(defaultRestDuration: duration);
    _processAutoTransitions();
    unawaited(_persistRecoveryState());
  }

  Duration autoTransitionRemaining() {
    if (!state.hasPendingAutoTransition || state.nextAutoTransitionAt == null) {
      return Duration.zero;
    }

    final Duration remaining = state.nextAutoTransitionAt!.difference(
      _timeProvider.now(),
    );

    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _completeRestAndAdvance(
    TimerSnapshot snapshot, {
    required bool scheduleNextWorkout,
  }) {
    final List<EventSplit> updatedSplits = List<EventSplit>.from(state.splits);
    updatedSplits[state.currentEventIndex] = EventSplit.fromSnapshot(
      snapshot,
      completed: true,
    );

    final bool isLastEvent = state.currentEventIndex == _events.length - 1;

    if (isLastEvent) {
      state = state.copyWith(
        splits: updatedSplits,
        sessionCompleted: true,
        sessionState: SessionFlowState.completed,
        timerSnapshot: snapshot,
        clearAutoTransition: true,
      );
      unawaited(_syncRuntimeIntegrations());
      return;
    }

    _engine = TimerEngine(timeProvider: _timeProvider);

    state = state.copyWith(
      splits: updatedSplits,
      currentEventIndex: state.currentEventIndex + 1,
      sessionState: SessionFlowState.idle,
      timerSnapshot: _engine.snapshot,
    );

    if (scheduleNextWorkout && state.autoTransitionEnabled) {
      _scheduleAutoTransition(AutoTransitionAction.startNextWorkout);
    }

    unawaited(_syncRuntimeIntegrations());
  }

  @override
  void dispose() {
    _runtimeReady = false;
    _runtimeSyncQueued = false;
    _ticker?.cancel();
    unawaited(_notificationActions?.cancel());
    unawaited(_shutdownRuntimeIntegrations());
    super.dispose();
  }

  void _startTicker() {
    if (!enableTicker) {
      return;
    }

    _ticker?.cancel();
    _ticker = Timer.periodic(tickInterval, (_) {
      if (_needsLiveRefresh) {
        refresh();
      }
    });
  }

  bool get _needsLiveRefresh {
    return state.sessionState == SessionFlowState.workoutRunning ||
        state.sessionState == SessionFlowState.eventPaused ||
        state.sessionState == SessionFlowState.restRunning ||
        state.hasPendingAutoTransition;
  }

  void _applySnapshot(TimerSnapshot snapshot) {
    state = state.copyWith(
      timerSnapshot: snapshot,
      sessionState: _mapPhase(snapshot.phase),
    );
    unawaited(_syncRuntimeIntegrations());
  }

  void _scheduleAutoTransition(AutoTransitionAction action) {
    final DateTime runAt = _timeProvider.now().add(state.transitionDelay);
    state = state.copyWith(
      nextAutoTransitionAction: action,
      nextAutoTransitionAt: runAt,
    );

    _processAutoTransitions();
  }

  void _clearAutoTransitionSchedule() {
    if (!state.hasPendingAutoTransition) {
      return;
    }

    state = state.copyWith(clearAutoTransition: true);
  }

  void _processAutoTransitions() {
    if (!state.autoTransitionEnabled || state.sessionCompleted) {
      return;
    }

    bool progressedAny = false;
    int guard = 0;
    while (guard < 6) {
      guard += 1;
      bool progressed = false;

      if (_canAutoCompleteRest) {
        _clearAutoTransitionSchedule();
        final TimerSnapshot snapshot = _engine.completeRest();
        _completeRestAndAdvance(snapshot, scheduleNextWorkout: true);
        progressed = true;
        progressedAny = true;
      }

      if (_shouldRunScheduledAutoTransition) {
        final AutoTransitionAction action = state.nextAutoTransitionAction!;
        _clearAutoTransitionSchedule();

        if (action == AutoTransitionAction.startRest && state.canStartRest) {
          final TimerSnapshot snapshot = _engine.startRest();
          _applySnapshot(snapshot);
          progressed = true;
          progressedAny = true;
        }

        if (action == AutoTransitionAction.startNextWorkout &&
            state.canStartWorkout) {
          final TimerSnapshot snapshot = _engine.startWorkout();
          _applySnapshot(snapshot);
          progressed = true;
          progressedAny = true;
        }
      }

      if (!progressed) {
        break;
      }
    }

    if (progressedAny) {
      unawaited(_persistRecoveryState());
    }
  }

  Future<void> _persistRecoveryState() async {
    if (_isHydrating) {
      return;
    }

    if (state.sessionCompleted) {
      await _recoveryRepository.clear();
      return;
    }

    final SessionRecoveryPayload payload = SessionRecoveryMapper.toPayload(
      state,
      savedAt: _timeProvider.now(),
    );
    await _recoveryRepository.save(payload);
  }

  bool get _shouldRunScheduledAutoTransition {
    if (!state.hasPendingAutoTransition || state.nextAutoTransitionAt == null) {
      return false;
    }

    return !_timeProvider.now().isBefore(state.nextAutoTransitionAt!);
  }

  bool get _canAutoCompleteRest {
    if (state.sessionState != SessionFlowState.restRunning) {
      return false;
    }

    final Duration restElapsed = _engine.snapshot.restTime;
    return restElapsed >= state.defaultRestDuration;
  }

  void _requireValidTransitionDelay(Duration delay) {
    if (transitionDelayOptions.contains(delay)) {
      return;
    }

    throw ArgumentError.value(
      delay,
      'delay',
      'Unsupported delay. Use one of: ${transitionDelayOptions.map((Duration value) => value.inSeconds).join(', ')} seconds.',
    );
  }

  SessionFlowState _mapPhase(TimerPhase phase) {
    switch (phase) {
      case TimerPhase.idle:
        return SessionFlowState.idle;
      case TimerPhase.workoutRunning:
        return SessionFlowState.workoutRunning;
      case TimerPhase.eventPaused:
        return SessionFlowState.eventPaused;
      case TimerPhase.workoutCompleted:
        return SessionFlowState.workoutCompleted;
      case TimerPhase.restRunning:
        return SessionFlowState.restRunning;
      case TimerPhase.completed:
        return SessionFlowState.completed;
    }
  }

  Future<void> _initializeRuntimeIntegrations() async {
    await _backgroundService.initialize();
    if (!mounted) {
      return;
    }

    await _notificationService.initialize();
    if (!mounted) {
      return;
    }

    _notificationActions = _notificationService.actions.listen(
      _handleNotificationAction,
    );
    _runtimeReady = true;
    await _syncRuntimeIntegrations();
  }

  Future<void> _handleNotificationAction(
    SessionNotificationAction action,
  ) async {
    if (!mounted) {
      return;
    }

    try {
      switch (action) {
        case SessionNotificationAction.pause:
          if (state.canStartPause) {
            startPause();
          }
          return;
        case SessionNotificationAction.resume:
          if (state.canResumeWorkout) {
            resumeWorkout();
          }
          return;
        case SessionNotificationAction.completeWorkout:
          if (state.canCompleteWorkout) {
            completeWorkout();
          }
          return;
      }
    } on StateError {
      // Ignore stale action taps that race with phase changes.
    }
  }

  bool get _hasActiveSession {
    if (state.sessionCompleted) {
      return false;
    }

    if (state.sessionState != SessionFlowState.idle) {
      return true;
    }

    if (state.currentEventIndex > 0) {
      return true;
    }

    return state.splits.any((EventSplit split) {
      return split.completed ||
          split.workoutTime > Duration.zero ||
          split.pauseTime > Duration.zero ||
          split.restTime > Duration.zero ||
          split.pauseCount > 0;
    });
  }

  SessionNotificationSnapshot _buildNotificationSnapshot() {
    final AppLocalizations l10n = _notificationLocalizations();
    final EventSplit split = state.currentEventSplit;
    final int eventPosition = state.currentEventIndex + 1;
    final String title =
        '${l10n.appTitle} • ${l10n.progressLabel} $eventPosition/${state.eventCount}';
    final String body =
        '${l10n.workoutTimeLabel} ${_formatDuration(split.workoutTime)} | ${l10n.pauseTimeLabel} ${_formatDuration(split.pauseTime)} | ${l10n.restTimeLabel} ${_formatDuration(split.restTime)}';

    return SessionNotificationSnapshot(
      title: title,
      body: body,
      pauseActionLabel: l10n.pauseButton,
      resumeActionLabel: l10n.resumeButton,
      completeWorkoutActionLabel: l10n.completeWorkoutButton,
      showPauseAction: state.canStartPause,
      showResumeAction: state.canResumeWorkout,
      showCompleteWorkoutAction: state.canCompleteWorkout,
    );
  }

  AppLocalizations _notificationLocalizations() {
    final Locale locale = PlatformDispatcher.instance.locale;
    try {
      return lookupAppLocalizations(locale);
    } on FlutterError {
      return lookupAppLocalizations(const Locale('en'));
    }
  }

  static String _formatDuration(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    final int seconds = value.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _syncRuntimeIntegrations() async {
    if (!mounted || !_runtimeReady) {
      return;
    }

    if (_runtimeSyncInProgress) {
      _runtimeSyncQueued = true;
      return;
    }

    _runtimeSyncInProgress = true;
    try {
      do {
        _runtimeSyncQueued = false;

        if (!mounted || !_runtimeReady) {
          return;
        }

        if (_hasActiveSession) {
          if (!_backgroundService.isRunning) {
            await _backgroundService.start();
          }
          if (!mounted) {
            return;
          }
          await _notificationService.showOrUpdate(_buildNotificationSnapshot());
        } else {
          await _notificationService.clear();
          if (_backgroundService.isRunning) {
            await _backgroundService.stop();
          }
        }
      } while (_runtimeSyncQueued && mounted && _runtimeReady);
    } finally {
      _runtimeSyncInProgress = false;
    }
  }

  Future<void> _shutdownRuntimeIntegrations() async {
    if (!mounted) {
      return;
    }

    await _notificationService.clear();
    if (_backgroundService.isRunning) {
      await _backgroundService.stop();
    }
  }
}
