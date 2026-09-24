// test/features/statistics/presentation/statistics_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox/core/analytics/session_analytics_service.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';
import 'package:hyrox/features/statistics/application/statistics_providers.dart';
import 'package:hyrox/features/statistics/domain/statistics_models.dart';
import 'package:hyrox/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:hyrox/l10n/app_localizations.dart';

void main() {
  testWidgets('shows empty state when no completed session is available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          statisticsViewStateProvider.overrideWithValue(
            const StatisticsViewState.unavailable(),
          ),
        ],
        child: const _TestApp(child: StatisticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Statistics & Analytics'), findsOneWidget);
    expect(find.text('Statistics unavailable'), findsOneWidget);
    expect(
      find.text('Complete a session to unlock statistics.'),
      findsOneWidget,
    );
  });

  testWidgets('renders totals, insights, and chart sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          statisticsViewStateProvider.overrideWithValue(
            StatisticsViewState.completed(_buildSummary()),
          ),
        ],
        child: const _TestApp(child: StatisticsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session Totals'), findsOneWidget);
    expect(find.text('Event Highlights'), findsOneWidget);
    expect(find.text('Run Analysis'), findsOneWidget);
    expect(find.text('Fatigue Index'), findsOneWidget);
    expect(find.text('Workout Duration by Event'), findsOneWidget);
    expect(find.text('Pause Duration by Event'), findsOneWidget);
    expect(find.text('Rest Duration by Event'), findsOneWidget);
    expect(find.text('Cumulative Time by Event'), findsOneWidget);
    expect(find.text('Fastest Event'), findsOneWidget);
    expect(find.text('Fastest Run'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}

SessionAnalyticsSummary _buildSummary() {
  final List<EventAnalyticsPoint> timeline = <EventAnalyticsPoint>[];
  Duration cumulative = Duration.zero;

  final List<EventSplit> splits = List<EventSplit>.generate(16, (int index) {
    final Duration workout = Duration(seconds: 120 + index * 5);
    final Duration pause = Duration(seconds: 10 + (index % 3));
    final Duration rest = Duration(seconds: 20 + (index % 4));
    final EventSplit split = EventSplit(
      workoutTime: workout,
      pauseTime: pause,
      pauseCount: (index % 2) + 1,
      restTime: rest,
      completed: true,
    );

    cumulative += split.totalEventTime;
    timeline.add(
      EventAnalyticsPoint(
        event: hyroxEventDefinitions[index],
        split: split,
        cumulativeTime: cumulative,
      ),
    );

    return split;
  });

  final SessionTotals totals = _totalsFromSplits(splits);

  return SessionAnalyticsSummary(
    totals: totals,
    averagePauseTime: const Duration(seconds: 10),
    averageRestTime: const Duration(seconds: 21),
    fastestEvent: timeline.first,
    slowestEvent: timeline.last,
    mostInterruptedEvent: timeline[1],
    longestPauseEvent: timeline[2],
    runSummary: RunAnalyticsSummary(
      runs: <EventAnalyticsPoint>[
        timeline[0],
        timeline[2],
        timeline[4],
        timeline[6],
        timeline[8],
        timeline[10],
        timeline[12],
        timeline[14],
      ],
      fastestRun: timeline[0],
      slowestRun: timeline[14],
      averageRunTime: const Duration(seconds: 145),
    ),
    fatigueIndex: const Duration(seconds: 8),
    timeline: timeline,
  );
}

SessionTotals _totalsFromSplits(List<EventSplit> splits) {
  Duration workout = Duration.zero;
  Duration pause = Duration.zero;
  Duration rest = Duration.zero;
  int pauseCount = 0;

  for (final EventSplit split in splits) {
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
