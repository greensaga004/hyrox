// features/session/data/session_recovery_mapper.dart
import 'package:flutter/foundation.dart';
import 'package:hyrox/core/timer/timer_engine.dart';
import 'package:hyrox/features/session/data/session_recovery_models.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';

@immutable
class SessionRecoveryHydration {
  const SessionRecoveryHydration({
    required this.state,
    required this.timerSnapshot,
    required this.savedAt,
  });

  final SessionViewState state;
  final TimerSnapshot timerSnapshot;
  final DateTime savedAt;
}

class SessionRecoveryMapper {
  static SessionRecoveryPayload toPayload(
    SessionViewState state, {
    required DateTime savedAt,
  }) {
    final TimerSnapshot timer = state.timerSnapshot;

    return SessionRecoveryPayload(
      schemaVersion: SessionRecoveryPayload.currentSchemaVersion,
      savedAtEpochMs: savedAt.millisecondsSinceEpoch,
      currentEventIndex: state.currentEventIndex,
      sessionState: state.sessionState.name,
      sessionCompleted: state.sessionCompleted,
      autoTransitionEnabled: state.autoTransitionEnabled,
      transitionDelayMs: state.transitionDelay.inMilliseconds,
      defaultRestDurationMs: state.defaultRestDuration.inMilliseconds,
      nextAutoTransitionAtEpochMs:
          state.nextAutoTransitionAt?.millisecondsSinceEpoch,
      nextAutoTransitionAction: state.nextAutoTransitionAction?.name,
      timerPhase: timer.phase.name,
      timerWorkoutMs: timer.workoutTime.inMilliseconds,
      timerPauseMs: timer.pauseTime.inMilliseconds,
      timerPauseCount: timer.pauseCount,
      timerRestMs: timer.restTime.inMilliseconds,
      timerWorkoutStartedAtEpochMs:
          timer.workoutStartedAt?.millisecondsSinceEpoch,
      timerPauseStartedAtEpochMs: timer.pauseStartedAt?.millisecondsSinceEpoch,
      timerRestStartedAtEpochMs: timer.restStartedAt?.millisecondsSinceEpoch,
      splits: state.effectiveSplits
          .map(
            (EventSplit split) => PersistedEventSplit(
              workoutMs: split.workoutTime.inMilliseconds,
              pauseMs: split.pauseTime.inMilliseconds,
              pauseCount: split.pauseCount,
              restMs: split.restTime.inMilliseconds,
              completed: split.completed,
            ),
          )
          .toList(growable: false),
    );
  }

  static SessionRecoveryHydration hydrate(
    SessionRecoveryPayload payload, {
    required List<HyroxEventDefinition> events,
  }) {
    if (payload.currentEventIndex < 0 ||
        payload.currentEventIndex >= events.length) {
      throw const FormatException(
        'Invalid recovery payload: event index out of range.',
      );
    }

    if (payload.splits.length != events.length) {
      throw const FormatException(
        'Invalid recovery payload: split length mismatch.',
      );
    }

    final TimerPhase timerPhase = _timerPhaseFromName(payload.timerPhase);
    final SessionFlowState sessionState = _sessionStateFromName(
      payload.sessionState,
    );

    final TimerSnapshot snapshot = TimerSnapshot(
      phase: timerPhase,
      workoutTime: Duration(milliseconds: payload.timerWorkoutMs),
      pauseTime: Duration(milliseconds: payload.timerPauseMs),
      pauseCount: payload.timerPauseCount,
      restTime: Duration(milliseconds: payload.timerRestMs),
      workoutStartedAt: _dateTimeFromEpochMs(
        payload.timerWorkoutStartedAtEpochMs,
      ),
      pauseStartedAt: _dateTimeFromEpochMs(payload.timerPauseStartedAtEpochMs),
      restStartedAt: _dateTimeFromEpochMs(payload.timerRestStartedAtEpochMs),
    );

    final DateTime savedAt = DateTime.fromMillisecondsSinceEpoch(
      payload.savedAtEpochMs,
    );

    final List<EventSplit> splits = payload.splits
        .map(
          (PersistedEventSplit split) => EventSplit(
            workoutTime: Duration(milliseconds: split.workoutMs),
            pauseTime: Duration(milliseconds: split.pauseMs),
            pauseCount: split.pauseCount,
            restTime: Duration(milliseconds: split.restMs),
            completed: split.completed,
          ),
        )
        .toList(growable: false);

    return SessionRecoveryHydration(
      state: SessionViewState(
        events: events,
        splits: splits,
        currentEventIndex: payload.currentEventIndex,
        sessionState: sessionState,
        timerSnapshot: snapshot,
        sessionCompleted: payload.sessionCompleted,
        autoTransitionEnabled: payload.autoTransitionEnabled,
        transitionDelay: Duration(milliseconds: payload.transitionDelayMs),
        defaultRestDuration: Duration(
          milliseconds: payload.defaultRestDurationMs,
        ),
        nextAutoTransitionAt: _dateTimeFromEpochMs(
          payload.nextAutoTransitionAtEpochMs,
        ),
        nextAutoTransitionAction: _autoTransitionActionFromName(
          payload.nextAutoTransitionAction,
        ),
      ),
      timerSnapshot: snapshot,
      savedAt: savedAt,
    );
  }

  static DateTime? _dateTimeFromEpochMs(int? value) {
    if (value == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static TimerPhase _timerPhaseFromName(String value) {
    return _enumByName<TimerPhase>(TimerPhase.values, value, 'timerPhase');
  }

  static SessionFlowState _sessionStateFromName(String value) {
    return _enumByName<SessionFlowState>(
      SessionFlowState.values,
      value,
      'sessionState',
    );
  }

  static AutoTransitionAction? _autoTransitionActionFromName(String? value) {
    if (value == null) {
      return null;
    }

    return _enumByName<AutoTransitionAction>(
      AutoTransitionAction.values,
      value,
      'nextAutoTransitionAction',
    );
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String name,
    String field,
  ) {
    for (final T value in values) {
      if (value.name == name) {
        return value;
      }
    }

    throw FormatException('Invalid recovery payload: unknown $field "$name".');
  }
}
