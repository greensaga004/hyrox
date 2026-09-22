// test/features/session/data/session_recovery_repository_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hyrox/features/session/data/session_recovery_models.dart';
import 'package:hyrox/features/session/data/session_recovery_repository.dart';

void main() {
  test('hive recovery repository round-trips payload and clears it', () async {
    final Directory dir = await Directory.systemTemp.createTemp(
      'hyrox_recovery_repo_test_',
    );

    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    Hive.init(dir.path);

    final HiveSessionRecoveryRepository repository =
        HiveSessionRecoveryRepository();

    final SessionRecoveryPayload payload = SessionRecoveryPayload(
      schemaVersion: SessionRecoveryPayload.currentSchemaVersion,
      savedAtEpochMs: DateTime(2026, 1, 1, 8).millisecondsSinceEpoch,
      currentEventIndex: 1,
      sessionState: 'eventPaused',
      sessionCompleted: false,
      autoTransitionEnabled: true,
      transitionDelayMs: const Duration(seconds: 3).inMilliseconds,
      defaultRestDurationMs: const Duration(seconds: 60).inMilliseconds,
      nextAutoTransitionAtEpochMs: null,
      nextAutoTransitionAction: null,
      timerPhase: 'eventPaused',
      timerWorkoutMs: const Duration(seconds: 10).inMilliseconds,
      timerPauseMs: const Duration(seconds: 4).inMilliseconds,
      timerPauseCount: 1,
      timerRestMs: 0,
      timerWorkoutStartedAtEpochMs: null,
      timerPauseStartedAtEpochMs: DateTime(
        2026,
        1,
        1,
        8,
        0,
        10,
      ).millisecondsSinceEpoch,
      timerRestStartedAtEpochMs: null,
      splits: const <PersistedEventSplit>[
        PersistedEventSplit(
          workoutMs: 10000,
          pauseMs: 4000,
          pauseCount: 1,
          restMs: 0,
          completed: false,
        ),
        PersistedEventSplit(
          workoutMs: 0,
          pauseMs: 0,
          pauseCount: 0,
          restMs: 0,
          completed: false,
        ),
      ],
    );

    await repository.save(payload);
    final SessionRecoveryPayload? loaded = await repository.load();

    expect(loaded, isNotNull);
    expect(loaded!.schemaVersion, SessionRecoveryPayload.currentSchemaVersion);
    expect(loaded.currentEventIndex, 1);
    expect(loaded.timerPhase, 'eventPaused');
    expect(loaded.timerPauseMs, const Duration(seconds: 4).inMilliseconds);
    expect(loaded.splits.length, 2);
    expect(loaded.splits.first.pauseCount, 1);

    await repository.clear();
    final SessionRecoveryPayload? cleared = await repository.load();
    expect(cleared, isNull);
  });
}
