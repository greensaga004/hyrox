// test/core/analytics/session_analytics_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox/core/analytics/session_analytics_service.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';

void main() {
  const SessionAnalyticsService service = SessionAnalyticsService();

  test('calculates totals, highlights, run analysis, and fatigue index', () {
    final List<EventSplit> splits = _buildSplits();

    final SessionAnalyticsSummary summary = service.analyze(
      events: hyroxEventDefinitions,
      splits: splits,
    );

    expect(summary.totals.totalWorkoutTime, const Duration(seconds: 5387));
    expect(summary.totals.totalPauseTime, const Duration(seconds: 303));
    expect(summary.totals.totalPauseCount, 24);
    expect(summary.totals.totalRestTime, const Duration(seconds: 450));
    expect(summary.totals.totalEventTime, const Duration(seconds: 5690));
    expect(summary.totals.totalSessionTime, const Duration(seconds: 6140));

    expect(summary.fastestEvent.event.order, 1);
    expect(summary.slowestEvent.event.order, 2);
    expect(summary.mostInterruptedEvent.event.order, 4);
    expect(summary.longestPauseEvent.event.order, 2);

    expect(summary.runSummary.fastestRun.event.station, HyroxStation.run1);
    expect(summary.runSummary.slowestRun.event.station, HyroxStation.run6);
    expect(
      summary.runSummary.averageRunTime,
      const Duration(microseconds: 325625000),
    );

    expect(summary.averagePauseTime, const Duration(microseconds: 12625000));
    expect(summary.averageRestTime, const Duration(microseconds: 28125000));
    expect(summary.fatigueIndex, const Duration(milliseconds: 12500));

    expect(summary.timeline, hasLength(16));
    expect(summary.timeline.last.cumulativeTime, const Duration(seconds: 5690));
  });

  test('throws when events and splits lengths do not match', () {
    expect(
      () => service.analyze(
        events: hyroxEventDefinitions,
        splits: const <EventSplit>[EventSplit.zero()],
      ),
      throwsArgumentError,
    );
  });
}

List<EventSplit> _buildSplits() {
  const List<int> totalEventSeconds = <int>[
    300,
    420,
    330,
    360,
    320,
    355,
    340,
    400,
    310,
    380,
    345,
    370,
    335,
    390,
    325,
    410,
  ];
  const List<int> pauseSeconds = <int>[
    20,
    30,
    15,
    30,
    10,
    25,
    20,
    30,
    12,
    18,
    14,
    16,
    11,
    22,
    13,
    17,
  ];
  const List<int> pauseCounts = <int>[
    1,
    2,
    1,
    3,
    1,
    2,
    1,
    2,
    1,
    3,
    1,
    1,
    1,
    2,
    1,
    1,
  ];
  const List<int> restSeconds = <int>[
    30,
    35,
    33,
    34,
    31,
    32,
    30,
    29,
    28,
    27,
    26,
    25,
    24,
    23,
    22,
    21,
  ];

  return List<EventSplit>.generate(16, (int index) {
    final int pause = pauseSeconds[index];
    final int total = totalEventSeconds[index];
    final int workout = total - pause;

    return EventSplit(
      workoutTime: Duration(seconds: workout),
      pauseTime: Duration(seconds: pause),
      pauseCount: pauseCounts[index],
      restTime: Duration(seconds: restSeconds[index]),
      completed: true,
    );
  });
}
