// features/session/domain/session_models.dart
import 'package:flutter/foundation.dart';
import 'package:hyrox/core/timer/timer_engine.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';

enum SessionFlowState {
  idle,
  workoutRunning,
  eventPaused,
  workoutCompleted,
  restRunning,
  completed,
}

enum AutoTransitionAction { startRest, startNextWorkout }

@immutable
class EventSplit {
  const EventSplit({
    required this.workoutTime,
    required this.pauseTime,
    required this.pauseCount,
    required this.restTime,
    required this.completed,
  });

  const EventSplit.zero()
    : workoutTime = Duration.zero,
      pauseTime = Duration.zero,
      pauseCount = 0,
      restTime = Duration.zero,
      completed = false;

  final Duration workoutTime;
  final Duration pauseTime;
  final int pauseCount;
  final Duration restTime;
  final bool completed;

  Duration get totalEventTime => workoutTime + pauseTime;

  EventSplit copyWith({
    Duration? workoutTime,
    Duration? pauseTime,
    int? pauseCount,
    Duration? restTime,
    bool? completed,
  }) {
    return EventSplit(
      workoutTime: workoutTime ?? this.workoutTime,
      pauseTime: pauseTime ?? this.pauseTime,
      pauseCount: pauseCount ?? this.pauseCount,
      restTime: restTime ?? this.restTime,
      completed: completed ?? this.completed,
    );
  }

  factory EventSplit.fromSnapshot(
    TimerSnapshot snapshot, {
    required bool completed,
  }) {
    return EventSplit(
      workoutTime: snapshot.workoutTime,
      pauseTime: snapshot.pauseTime,
      pauseCount: snapshot.pauseCount,
      restTime: snapshot.restTime,
      completed: completed,
    );
  }
}

@immutable
class SessionTotals {
  const SessionTotals({
    required this.totalWorkoutTime,
    required this.totalPauseTime,
    required this.totalPauseCount,
    required this.totalRestTime,
  });

  final Duration totalWorkoutTime;
  final Duration totalPauseTime;
  final int totalPauseCount;
  final Duration totalRestTime;

  Duration get totalEventTime => totalWorkoutTime + totalPauseTime;

  Duration get totalSessionTime =>
      totalWorkoutTime + totalPauseTime + totalRestTime;
}

@immutable
class SessionViewState {
  SessionViewState({
    required List<HyroxEventDefinition> events,
    required List<EventSplit> splits,
    required this.currentEventIndex,
    required this.sessionState,
    required this.timerSnapshot,
    required this.sessionCompleted,
    required this.autoTransitionEnabled,
    required this.transitionDelay,
    required this.defaultRestDuration,
    this.nextAutoTransitionAt,
    this.nextAutoTransitionAction,
  }) : events = List<HyroxEventDefinition>.unmodifiable(events),
       splits = List<EventSplit>.unmodifiable(splits);

  final List<HyroxEventDefinition> events;
  final List<EventSplit> splits;
  final int currentEventIndex;
  final SessionFlowState sessionState;
  final TimerSnapshot timerSnapshot;
  final bool sessionCompleted;
  final bool autoTransitionEnabled;
  final Duration transitionDelay;
  final Duration defaultRestDuration;
  final DateTime? nextAutoTransitionAt;
  final AutoTransitionAction? nextAutoTransitionAction;

  factory SessionViewState.initial(
    List<HyroxEventDefinition> events, {
    required bool autoTransitionEnabled,
    required Duration transitionDelay,
    required Duration defaultRestDuration,
  }) {
    return SessionViewState(
      events: events,
      splits: List<EventSplit>.filled(events.length, const EventSplit.zero()),
      currentEventIndex: 0,
      sessionState: SessionFlowState.idle,
      timerSnapshot: const TimerSnapshot(
        phase: TimerPhase.idle,
        workoutTime: Duration.zero,
        pauseTime: Duration.zero,
        pauseCount: 0,
        restTime: Duration.zero,
      ),
      sessionCompleted: false,
      autoTransitionEnabled: autoTransitionEnabled,
      transitionDelay: transitionDelay,
      defaultRestDuration: defaultRestDuration,
    );
  }

  HyroxEventDefinition get currentEvent => events[currentEventIndex];

  int get eventCount => events.length;

  int get completedEventCount =>
      splits.where((EventSplit split) => split.completed).length;

  List<EventSplit> get effectiveSplits {
    final List<EventSplit> result = List<EventSplit>.from(splits);

    if (!sessionCompleted && currentEventIndex < result.length) {
      final EventSplit current = result[currentEventIndex];
      if (!current.completed) {
        result[currentEventIndex] = current.copyWith(
          workoutTime: timerSnapshot.workoutTime,
          pauseTime: timerSnapshot.pauseTime,
          pauseCount: timerSnapshot.pauseCount,
          restTime: timerSnapshot.restTime,
        );
      }
    }

    return result;
  }

  EventSplit get currentEventSplit => effectiveSplits[currentEventIndex];

  bool get hasPendingAutoTransition {
    return nextAutoTransitionAt != null && nextAutoTransitionAction != null;
  }

  SessionTotals get totals {
    Duration workout = Duration.zero;
    Duration pause = Duration.zero;
    Duration rest = Duration.zero;
    int pauseCount = 0;

    for (final EventSplit split in effectiveSplits) {
      workout += split.workoutTime;
      pause += split.pauseTime;
      rest += split.restTime;
      pauseCount += split.pauseCount;
    }

    return SessionTotals(
      totalWorkoutTime: workout,
      totalPauseTime: pause,
      totalPauseCount: pauseCount,
      totalRestTime: rest,
    );
  }

  bool get canStartWorkout =>
      !sessionCompleted && sessionState == SessionFlowState.idle;

  bool get canStartPause =>
      !sessionCompleted && sessionState == SessionFlowState.workoutRunning;

  bool get canResumeWorkout =>
      !sessionCompleted && sessionState == SessionFlowState.eventPaused;

  bool get canCompleteWorkout =>
      !sessionCompleted &&
      (sessionState == SessionFlowState.workoutRunning ||
          sessionState == SessionFlowState.eventPaused);

  bool get canStartRest =>
      !sessionCompleted && sessionState == SessionFlowState.workoutCompleted;

  bool get canCompleteRest =>
      !sessionCompleted && sessionState == SessionFlowState.restRunning;

  SessionViewState copyWith({
    List<HyroxEventDefinition>? events,
    List<EventSplit>? splits,
    int? currentEventIndex,
    SessionFlowState? sessionState,
    TimerSnapshot? timerSnapshot,
    bool? sessionCompleted,
    bool? autoTransitionEnabled,
    Duration? transitionDelay,
    Duration? defaultRestDuration,
    DateTime? nextAutoTransitionAt,
    AutoTransitionAction? nextAutoTransitionAction,
    bool clearAutoTransition = false,
  }) {
    final DateTime? effectiveAutoTransitionAt = clearAutoTransition
        ? null
        : (nextAutoTransitionAt ?? this.nextAutoTransitionAt);
    final AutoTransitionAction? effectiveAutoTransitionAction =
        clearAutoTransition
        ? null
        : (nextAutoTransitionAction ?? this.nextAutoTransitionAction);

    return SessionViewState(
      events: events ?? this.events,
      splits: splits ?? this.splits,
      currentEventIndex: currentEventIndex ?? this.currentEventIndex,
      sessionState: sessionState ?? this.sessionState,
      timerSnapshot: timerSnapshot ?? this.timerSnapshot,
      sessionCompleted: sessionCompleted ?? this.sessionCompleted,
      autoTransitionEnabled:
          autoTransitionEnabled ?? this.autoTransitionEnabled,
      transitionDelay: transitionDelay ?? this.transitionDelay,
      defaultRestDuration: defaultRestDuration ?? this.defaultRestDuration,
      nextAutoTransitionAt: effectiveAutoTransitionAt,
      nextAutoTransitionAction: effectiveAutoTransitionAction,
    );
  }
}
