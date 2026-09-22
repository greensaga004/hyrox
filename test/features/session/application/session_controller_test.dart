// test/features/session/application/session_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox/core/timer/timer_engine.dart';
import 'package:hyrox/features/session/application/session_controller.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';

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
}
