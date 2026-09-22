// features/session/data/session_recovery_models.dart
import 'package:flutter/foundation.dart';

@immutable
class PersistedEventSplit {
  const PersistedEventSplit({
    required this.workoutMs,
    required this.pauseMs,
    required this.pauseCount,
    required this.restMs,
    required this.completed,
  });

  final int workoutMs;
  final int pauseMs;
  final int pauseCount;
  final int restMs;
  final bool completed;

  Map<String, Object> toJson() {
    return <String, Object>{
      'workoutMs': workoutMs,
      'pauseMs': pauseMs,
      'pauseCount': pauseCount,
      'restMs': restMs,
      'completed': completed,
    };
  }

  factory PersistedEventSplit.fromJson(Map<String, dynamic> json) {
    return PersistedEventSplit(
      workoutMs: _readInt(json, 'workoutMs'),
      pauseMs: _readInt(json, 'pauseMs'),
      pauseCount: _readInt(json, 'pauseCount'),
      restMs: _readInt(json, 'restMs'),
      completed: _readBool(json, 'completed'),
    );
  }
}

@immutable
class SessionRecoveryPayload {
  const SessionRecoveryPayload({
    required this.schemaVersion,
    required this.savedAtEpochMs,
    required this.currentEventIndex,
    required this.sessionState,
    required this.sessionCompleted,
    required this.autoTransitionEnabled,
    required this.transitionDelayMs,
    required this.defaultRestDurationMs,
    required this.timerPhase,
    required this.timerWorkoutMs,
    required this.timerPauseMs,
    required this.timerPauseCount,
    required this.timerRestMs,
    required this.splits,
    this.nextAutoTransitionAtEpochMs,
    this.nextAutoTransitionAction,
    this.timerWorkoutStartedAtEpochMs,
    this.timerPauseStartedAtEpochMs,
    this.timerRestStartedAtEpochMs,
  });

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final int savedAtEpochMs;
  final int currentEventIndex;
  final String sessionState;
  final bool sessionCompleted;
  final bool autoTransitionEnabled;
  final int transitionDelayMs;
  final int defaultRestDurationMs;
  final int? nextAutoTransitionAtEpochMs;
  final String? nextAutoTransitionAction;
  final String timerPhase;
  final int timerWorkoutMs;
  final int timerPauseMs;
  final int timerPauseCount;
  final int timerRestMs;
  final int? timerWorkoutStartedAtEpochMs;
  final int? timerPauseStartedAtEpochMs;
  final int? timerRestStartedAtEpochMs;
  final List<PersistedEventSplit> splits;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'savedAtEpochMs': savedAtEpochMs,
      'currentEventIndex': currentEventIndex,
      'sessionState': sessionState,
      'sessionCompleted': sessionCompleted,
      'autoTransitionEnabled': autoTransitionEnabled,
      'transitionDelayMs': transitionDelayMs,
      'defaultRestDurationMs': defaultRestDurationMs,
      'nextAutoTransitionAtEpochMs': nextAutoTransitionAtEpochMs,
      'nextAutoTransitionAction': nextAutoTransitionAction,
      'timerPhase': timerPhase,
      'timerWorkoutMs': timerWorkoutMs,
      'timerPauseMs': timerPauseMs,
      'timerPauseCount': timerPauseCount,
      'timerRestMs': timerRestMs,
      'timerWorkoutStartedAtEpochMs': timerWorkoutStartedAtEpochMs,
      'timerPauseStartedAtEpochMs': timerPauseStartedAtEpochMs,
      'timerRestStartedAtEpochMs': timerRestStartedAtEpochMs,
      'splits': splits
          .map((PersistedEventSplit split) => split.toJson())
          .toList(),
    };
  }

  factory SessionRecoveryPayload.fromJson(Map<String, dynamic> json) {
    final Object? rawSplits = json['splits'];
    if (rawSplits is! List) {
      throw const FormatException(
        'Invalid recovery payload: splits is not a list.',
      );
    }

    final List<PersistedEventSplit> parsedSplits = rawSplits
        .map((Object? item) {
          if (item is! Map) {
            throw const FormatException(
              'Invalid recovery payload: split entry is not a map.',
            );
          }

          return PersistedEventSplit.fromJson(
            item.map(
              (Object? key, Object? value) => MapEntry(key.toString(), value),
            ),
          );
        })
        .toList(growable: false);

    return SessionRecoveryPayload(
      schemaVersion: _readInt(json, 'schemaVersion'),
      savedAtEpochMs: _readInt(json, 'savedAtEpochMs'),
      currentEventIndex: _readInt(json, 'currentEventIndex'),
      sessionState: _readString(json, 'sessionState'),
      sessionCompleted: _readBool(json, 'sessionCompleted'),
      autoTransitionEnabled: _readBool(json, 'autoTransitionEnabled'),
      transitionDelayMs: _readInt(json, 'transitionDelayMs'),
      defaultRestDurationMs: _readInt(json, 'defaultRestDurationMs'),
      nextAutoTransitionAtEpochMs: _readOptionalInt(
        json,
        'nextAutoTransitionAtEpochMs',
      ),
      nextAutoTransitionAction: _readOptionalString(
        json,
        'nextAutoTransitionAction',
      ),
      timerPhase: _readString(json, 'timerPhase'),
      timerWorkoutMs: _readInt(json, 'timerWorkoutMs'),
      timerPauseMs: _readInt(json, 'timerPauseMs'),
      timerPauseCount: _readInt(json, 'timerPauseCount'),
      timerRestMs: _readInt(json, 'timerRestMs'),
      timerWorkoutStartedAtEpochMs: _readOptionalInt(
        json,
        'timerWorkoutStartedAtEpochMs',
      ),
      timerPauseStartedAtEpochMs: _readOptionalInt(
        json,
        'timerPauseStartedAtEpochMs',
      ),
      timerRestStartedAtEpochMs: _readOptionalInt(
        json,
        'timerRestStartedAtEpochMs',
      ),
      splits: parsedSplits,
    );
  }
}

int _readInt(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is int) {
    return value;
  }

  throw FormatException('Invalid recovery payload: "$key" is not an int.');
}

int? _readOptionalInt(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  throw FormatException('Invalid recovery payload: "$key" is not an int.');
}

bool _readBool(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is bool) {
    return value;
  }

  throw FormatException('Invalid recovery payload: "$key" is not a bool.');
}

String _readString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is String) {
    return value;
  }

  throw FormatException('Invalid recovery payload: "$key" is not a string.');
}

String? _readOptionalString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }

  if (value is String) {
    return value;
  }

  throw FormatException('Invalid recovery payload: "$key" is not a string.');
}
