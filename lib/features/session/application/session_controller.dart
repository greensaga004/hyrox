// features/session/application/session_controller.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/core/timer/timer_engine.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';

final StateNotifierProvider<SessionController, SessionViewState>
sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionViewState>((Ref ref) {
      return SessionController();
    });

class SessionController extends StateNotifier<SessionViewState> {
  SessionController({
    List<HyroxEventDefinition>? events,
    TimeProvider? timeProvider,
    this.enableTicker = true,
    this.tickInterval = const Duration(seconds: 1),
  }) : _events = events ?? hyroxEventDefinitions,
       _timeProvider = timeProvider ?? const SystemTimeProvider(),
       super(SessionViewState.initial(events ?? hyroxEventDefinitions)) {
    _engine = TimerEngine(timeProvider: _timeProvider);
    _applySnapshot(_engine.snapshot);
    _startTicker();
  }

  final List<HyroxEventDefinition> _events;
  final TimeProvider _timeProvider;
  final bool enableTicker;
  final Duration tickInterval;

  late TimerEngine _engine;
  Timer? _ticker;

  void refresh() {
    _applySnapshot(_engine.snapshot);
  }

  void startWorkout() {
    final TimerSnapshot snapshot = _engine.startWorkout();
    _applySnapshot(snapshot);
  }

  void startPause() {
    final TimerSnapshot snapshot = _engine.startPause();
    _applySnapshot(snapshot);
  }

  void resumeWorkout() {
    final TimerSnapshot snapshot = _engine.resumeWorkout();
    _applySnapshot(snapshot);
  }

  void completeWorkout() {
    final TimerSnapshot snapshot = _engine.completeWorkout();
    _applySnapshot(snapshot);
  }

  void startRest() {
    final TimerSnapshot snapshot = _engine.startRest();
    _applySnapshot(snapshot);
  }

  void completeRest() {
    final TimerSnapshot snapshot = _engine.completeRest();

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
        state.sessionState == SessionFlowState.restRunning;
  }

  void _applySnapshot(TimerSnapshot snapshot) {
    state = state.copyWith(
      timerSnapshot: snapshot,
      sessionState: _mapPhase(snapshot.phase),
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
