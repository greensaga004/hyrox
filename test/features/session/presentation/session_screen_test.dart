// test/features/session/presentation/session_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/app/app.dart';
import 'package:hyrox/features/session/data/session_recovery_models.dart';
import 'package:hyrox/features/session/data/session_recovery_repository.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';

void main() {
  testWidgets(
    'session screen shows manual controls and progresses to next event',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: HyroxApp()));
      await tester.pumpAndSettle();

      expect(find.text('1. Run 1'), findsWidgets);
      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('Auto Transition'), findsOneWidget);
      expect(find.text('Enable Auto Transition'), findsOneWidget);
      expect(find.text('Transition Delay'), findsOneWidget);
      expect(find.text('Default Rest Duration'), findsOneWidget);

      await tester.ensureVisible(find.text('Start Workout'));
      await tester.tap(find.text('Start Workout'));
      await tester.pump();

      final Finder pauseButton = find.widgetWithText(ElevatedButton, 'Pause');
      expect(tester.widget<ElevatedButton>(pauseButton).enabled, isTrue);

      await tester.ensureVisible(find.text('Complete Workout'));
      await tester.tap(find.text('Complete Workout'));
      await tester.pump();

      final Finder startRestButton = find.widgetWithText(
        ElevatedButton,
        'Start Rest',
      );
      expect(tester.widget<ElevatedButton>(startRestButton).enabled, isTrue);

      await tester.ensureVisible(find.text('Start Rest'));
      await tester.tap(find.text('Start Rest'));
      await tester.pump();

      final Finder completeRestButton = find.widgetWithText(
        ElevatedButton,
        'Complete Rest',
      );
      expect(tester.widget<ElevatedButton>(completeRestButton).enabled, isTrue);

      await tester.ensureVisible(find.text('Complete Rest'));
      await tester.tap(find.text('Complete Rest'));
      await tester.pump();

      expect(find.text('2. SkiErg'), findsWidgets);
    },
  );

  testWidgets('shows recovery prompt and allows discard', (
    WidgetTester tester,
  ) async {
    final InMemorySessionRecoveryRepository repository =
        InMemorySessionRecoveryRepository();

    await repository.save(
      _recoveryPayload(
        currentEventIndex: 1,
        sessionState: 'workoutRunning',
        timerPhase: 'workoutRunning',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sessionRecoveryRepositoryProvider.overrideWithValue(repository),
        ],
        child: const HyroxApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resume Previous Session?'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.text('Resume Previous Session?'), findsNothing);
    expect(await repository.load(), isNull);
    expect(find.text('1. Run 1'), findsWidgets);
  });
}

SessionRecoveryPayload _recoveryPayload({
  required int currentEventIndex,
  required String sessionState,
  required String timerPhase,
}) {
  return SessionRecoveryPayload(
    schemaVersion: SessionRecoveryPayload.currentSchemaVersion,
    savedAtEpochMs: DateTime(2026, 1, 1, 9).millisecondsSinceEpoch,
    currentEventIndex: currentEventIndex,
    sessionState: sessionState,
    sessionCompleted: false,
    autoTransitionEnabled: true,
    transitionDelayMs: const Duration(seconds: 3).inMilliseconds,
    defaultRestDurationMs: const Duration(seconds: 60).inMilliseconds,
    nextAutoTransitionAtEpochMs: null,
    nextAutoTransitionAction: null,
    timerPhase: timerPhase,
    timerWorkoutMs: 0,
    timerPauseMs: 0,
    timerPauseCount: 0,
    timerRestMs: 0,
    timerWorkoutStartedAtEpochMs: DateTime(
      2026,
      1,
      1,
      9,
    ).millisecondsSinceEpoch,
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
}
