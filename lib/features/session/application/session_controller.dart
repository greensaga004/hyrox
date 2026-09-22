// features/session/application/session_controller.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/core/timer/timer_engine.dart';
import 'package:hyrox/features/session/data/session_recovery_mapper.dart';
import 'package:hyrox/features/session/data/session_recovery_models.dart';
import 'package:hyrox/features/session/data/session_recovery_repository.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';

final StateNotifierProvider<SessionController, SessionViewState>
sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionViewState>((Ref ref) {
      final SessionRecoveryRepository repository = ref.watch(
        sessionRecoveryRepositoryProvider,
      );
      return SessionController(recoveryRepository: repository);
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
    this.enableTicker = true,
    this.tickInterval = const Duration(seconds: 1),
    this.autoTransitionEnabled = true,
    this.transitionDelay = const Duration(seconds: 3),
    this.defaultRestDuration = const Duration(seconds: 60),
  }) : _events = events ?? hyroxEventDefinitions,
       _timeProvider = timeProvider ?? const SystemTimeProvider(),
       _recoveryRepository =
           recoveryRepository ?? InMemorySessionRecoveryRepository(),
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
  }

  final List<HyroxEventDefinition> _events;
  final TimeProvider _timeProvider;
  final SessionRecoveryRepository _recoveryRepository;
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
  bool _isHydrating = false;

  void refresh() {
    _processAutoTransitions();
    _applySnapshot(_engine.snapshot);
    _processAutoTransitions();
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
  }

  @override
  void dispose() {
    _ticker?.cancel();
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
}
