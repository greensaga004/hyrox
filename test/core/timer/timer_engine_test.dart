// test/core/timer/timer_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox/core/timer/timer_engine.dart';

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
  late TimerEngine engine;

  setUp(() {
    timeProvider = FakeTimeProvider(DateTime(2026, 1, 1, 10, 0, 0));
    engine = TimerEngine(timeProvider: timeProvider);
  });

  test('tracks workout time from timestamp deltas', () {
    engine.startWorkout();
    timeProvider.advance(const Duration(seconds: 30));

    final TimerSnapshot snapshot = engine.snapshot;

    expect(snapshot.phase, TimerPhase.workoutRunning);
    expect(snapshot.workoutTime, const Duration(seconds: 30));
    expect(snapshot.pauseTime, Duration.zero);
    expect(snapshot.restTime, Duration.zero);
    expect(snapshot.pauseCount, 0);
    expect(snapshot.totalEventTime, const Duration(seconds: 30));
  });

  test('accumulates multiple pause and resume cycles', () {
    engine.startWorkout();
    timeProvider.advance(const Duration(seconds: 40));

    engine.startPause();
    timeProvider.advance(const Duration(seconds: 15));

    engine.resumeWorkout();
    timeProvider.advance(const Duration(seconds: 20));

    engine.startPause();
    timeProvider.advance(const Duration(seconds: 5));

    engine.resumeWorkout();
    timeProvider.advance(const Duration(seconds: 10));

    final TimerSnapshot snapshot = engine.completeWorkout();

    expect(snapshot.phase, TimerPhase.workoutCompleted);
    expect(snapshot.workoutTime, const Duration(seconds: 70));
    expect(snapshot.pauseTime, const Duration(seconds: 20));
    expect(snapshot.pauseCount, 2);
    expect(snapshot.totalEventTime, const Duration(seconds: 90));
  });

  test('tracks rest separately and excludes it from total event time', () {
    engine.startWorkout();
    timeProvider.advance(const Duration(seconds: 25));
    engine.completeWorkout();

    engine.startRest();
    timeProvider.advance(const Duration(seconds: 35));

    final TimerSnapshot snapshot = engine.completeRest();

    expect(snapshot.phase, TimerPhase.completed);
    expect(snapshot.workoutTime, const Duration(seconds: 25));
    expect(snapshot.pauseTime, Duration.zero);
    expect(snapshot.restTime, const Duration(seconds: 35));
    expect(snapshot.totalEventTime, const Duration(seconds: 25));
  });

  test('increments pause count when workout is completed while paused', () {
    engine.startWorkout();
    timeProvider.advance(const Duration(seconds: 10));

    engine.startPause();
    timeProvider.advance(const Duration(seconds: 3));

    final TimerSnapshot snapshot = engine.completeWorkout();

    expect(snapshot.phase, TimerPhase.workoutCompleted);
    expect(snapshot.workoutTime, const Duration(seconds: 10));
    expect(snapshot.pauseTime, const Duration(seconds: 3));
    expect(snapshot.pauseCount, 1);
    expect(snapshot.totalEventTime, const Duration(seconds: 13));
  });

  test('throws StateError for invalid transitions', () {
    expect(engine.startPause, throwsStateError);
    expect(engine.resumeWorkout, throwsStateError);
    expect(engine.startRest, throwsStateError);
    expect(engine.completeRest, throwsStateError);

    engine.startWorkout();
    expect(engine.startRest, throwsStateError);

    engine.completeWorkout();
    expect(engine.resumeWorkout, throwsStateError);
  });
}
