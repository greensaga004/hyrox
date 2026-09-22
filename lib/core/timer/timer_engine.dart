// core/timer/timer_engine.dart
import 'package:flutter/foundation.dart';

enum TimerPhase {
  idle,
  workoutRunning,
  eventPaused,
  workoutCompleted,
  restRunning,
  completed,
}

@immutable
class TimerSnapshot {
  const TimerSnapshot({
    required this.phase,
    required this.workoutTime,
    required this.pauseTime,
    required this.pauseCount,
    required this.restTime,
    this.workoutStartedAt,
    this.pauseStartedAt,
    this.restStartedAt,
  });

  final TimerPhase phase;
  final Duration workoutTime;
  final Duration pauseTime;
  final int pauseCount;
  final Duration restTime;
  final DateTime? workoutStartedAt;
  final DateTime? pauseStartedAt;
  final DateTime? restStartedAt;

  Duration get totalEventTime => workoutTime + pauseTime;
}

abstract class TimeProvider {
  DateTime now();
}

class SystemTimeProvider implements TimeProvider {
  const SystemTimeProvider();

  @override
  DateTime now() => DateTime.now();
}

class TimerEngine {
  TimerEngine({TimeProvider? timeProvider})
    : _timeProvider = timeProvider ?? const SystemTimeProvider();

  final TimeProvider _timeProvider;

  TimerPhase _phase = TimerPhase.idle;
  Duration _accumulatedWorkout = Duration.zero;
  Duration _accumulatedPause = Duration.zero;
  Duration _accumulatedRest = Duration.zero;
  int _pauseCount = 0;

  DateTime? _workoutStartedAt;
  DateTime? _pauseStartedAt;
  DateTime? _restStartedAt;

  TimerPhase get phase => _phase;

  TimerSnapshot get snapshot => _buildSnapshot();

  TimerSnapshot startWorkout() {
    _requirePhase(<TimerPhase>{TimerPhase.idle}, 'start workout');

    _workoutStartedAt = _timeProvider.now();
    _phase = TimerPhase.workoutRunning;

    return _buildSnapshot();
  }

  TimerSnapshot startPause() {
    _requirePhase(<TimerPhase>{TimerPhase.workoutRunning}, 'start pause');

    final DateTime startedAt = _workoutStartedAt!;
    _accumulatedWorkout += _timeProvider.now().difference(startedAt);
    _workoutStartedAt = null;

    _pauseStartedAt = _timeProvider.now();
    _phase = TimerPhase.eventPaused;

    return _buildSnapshot();
  }

  TimerSnapshot resumeWorkout() {
    _requirePhase(<TimerPhase>{TimerPhase.eventPaused}, 'resume workout');

    final DateTime startedAt = _pauseStartedAt!;
    _accumulatedPause += _timeProvider.now().difference(startedAt);
    _pauseStartedAt = null;
    _pauseCount += 1;

    _workoutStartedAt = _timeProvider.now();
    _phase = TimerPhase.workoutRunning;

    return _buildSnapshot();
  }

  TimerSnapshot completeWorkout() {
    _requirePhase(
      <TimerPhase>{TimerPhase.workoutRunning, TimerPhase.eventPaused},
      'complete workout',
    );

    if (_phase == TimerPhase.workoutRunning) {
      final DateTime startedAt = _workoutStartedAt!;
      _accumulatedWorkout += _timeProvider.now().difference(startedAt);
      _workoutStartedAt = null;
    } else {
      final DateTime startedAt = _pauseStartedAt!;
      _accumulatedPause += _timeProvider.now().difference(startedAt);
      _pauseStartedAt = null;
      _pauseCount += 1;
    }

    _phase = TimerPhase.workoutCompleted;

    return _buildSnapshot();
  }

  TimerSnapshot startRest() {
    _requirePhase(<TimerPhase>{TimerPhase.workoutCompleted}, 'start rest');

    _restStartedAt = _timeProvider.now();
    _phase = TimerPhase.restRunning;

    return _buildSnapshot();
  }

  TimerSnapshot completeRest() {
    _requirePhase(<TimerPhase>{TimerPhase.restRunning}, 'complete rest');

    final DateTime startedAt = _restStartedAt!;
    _accumulatedRest += _timeProvider.now().difference(startedAt);
    _restStartedAt = null;

    _phase = TimerPhase.completed;

    return _buildSnapshot();
  }

  void _requirePhase(Set<TimerPhase> allowedPhases, String action) {
    if (allowedPhases.contains(_phase)) {
      return;
    }

    throw StateError('Cannot $action while phase is $_phase.');
  }

  TimerSnapshot _buildSnapshot() {
    final DateTime now = _timeProvider.now();

    Duration workout = _accumulatedWorkout;
    Duration pause = _accumulatedPause;
    Duration rest = _accumulatedRest;

    if (_phase == TimerPhase.workoutRunning && _workoutStartedAt != null) {
      workout += now.difference(_workoutStartedAt!);
    }

    if (_phase == TimerPhase.eventPaused && _pauseStartedAt != null) {
      pause += now.difference(_pauseStartedAt!);
    }

    if (_phase == TimerPhase.restRunning && _restStartedAt != null) {
      rest += now.difference(_restStartedAt!);
    }

    return TimerSnapshot(
      phase: _phase,
      workoutTime: workout,
      pauseTime: pause,
      pauseCount: _pauseCount,
      restTime: rest,
      workoutStartedAt: _workoutStartedAt,
      pauseStartedAt: _pauseStartedAt,
      restStartedAt: _restStartedAt,
    );
  }
}
