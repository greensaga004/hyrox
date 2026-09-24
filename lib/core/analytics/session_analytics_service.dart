// core/analytics/session_analytics_service.dart
import 'package:flutter/foundation.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';

@immutable
class EventAnalyticsPoint {
  const EventAnalyticsPoint({
    required this.event,
    required this.split,
    required this.cumulativeTime,
  });

  final HyroxEventDefinition event;
  final EventSplit split;
  final Duration cumulativeTime;

  Duration get totalEventTime => split.totalEventTime;
}

@immutable
class RunAnalyticsSummary {
  const RunAnalyticsSummary({
    required this.runs,
    required this.fastestRun,
    required this.slowestRun,
    required this.averageRunTime,
  });

  final List<EventAnalyticsPoint> runs;
  final EventAnalyticsPoint fastestRun;
  final EventAnalyticsPoint slowestRun;
  final Duration averageRunTime;
}

@immutable
class SessionAnalyticsSummary {
  const SessionAnalyticsSummary({
    required this.totals,
    required this.averagePauseTime,
    required this.averageRestTime,
    required this.fastestEvent,
    required this.slowestEvent,
    required this.mostInterruptedEvent,
    required this.longestPauseEvent,
    required this.runSummary,
    required this.fatigueIndex,
    required this.timeline,
  });

  final SessionTotals totals;
  final Duration averagePauseTime;
  final Duration averageRestTime;
  final EventAnalyticsPoint fastestEvent;
  final EventAnalyticsPoint slowestEvent;
  final EventAnalyticsPoint mostInterruptedEvent;
  final EventAnalyticsPoint longestPauseEvent;
  final RunAnalyticsSummary runSummary;
  final Duration fatigueIndex;
  final List<EventAnalyticsPoint> timeline;
}

class SessionAnalyticsService {
  const SessionAnalyticsService();

  SessionAnalyticsSummary analyze({
    required List<HyroxEventDefinition> events,
    required List<EventSplit> splits,
  }) {
    if (events.isEmpty) {
      throw ArgumentError.value(events, 'events', 'Must not be empty.');
    }

    if (events.length != splits.length) {
      throw ArgumentError(
        'events and splits must have the same length. '
        'Received events=${events.length}, splits=${splits.length}.',
      );
    }

    final List<EventAnalyticsPoint> timeline = <EventAnalyticsPoint>[];
    Duration cumulative = Duration.zero;

    for (int index = 0; index < events.length; index += 1) {
      final EventSplit split = splits[index];
      cumulative += split.totalEventTime;
      timeline.add(
        EventAnalyticsPoint(
          event: events[index],
          split: split,
          cumulativeTime: cumulative,
        ),
      );
    }

    final SessionTotals totals = _calculateTotals(splits);
    final int completedEvents = splits
        .where((EventSplit split) => split.completed)
        .length;

    final EventAnalyticsPoint fastestEvent = _minByDuration(
      timeline,
      (EventAnalyticsPoint point) => point.totalEventTime,
    );
    final EventAnalyticsPoint slowestEvent = _maxByDuration(
      timeline,
      (EventAnalyticsPoint point) => point.totalEventTime,
    );
    final EventAnalyticsPoint mostInterruptedEvent = _maxByInt(
      timeline,
      (EventAnalyticsPoint point) => point.split.pauseCount,
    );
    final EventAnalyticsPoint longestPauseEvent = _maxByDuration(
      timeline,
      (EventAnalyticsPoint point) => point.split.pauseTime,
    );

    final List<EventAnalyticsPoint> runs = timeline
        .where((EventAnalyticsPoint point) => point.event.station.isRun)
        .toList(growable: false);
    final EventAnalyticsPoint fastestRun = _minByDuration(
      runs,
      (EventAnalyticsPoint point) => point.totalEventTime,
    );
    final EventAnalyticsPoint slowestRun = _maxByDuration(
      runs,
      (EventAnalyticsPoint point) => point.totalEventTime,
    );
    Duration runTotal = Duration.zero;
    for (final EventAnalyticsPoint run in runs) {
      runTotal += run.totalEventTime;
    }

    final Duration fatigueIndex = _calculateFatigueIndex(timeline);

    return SessionAnalyticsSummary(
      totals: totals,
      averagePauseTime: _divideDuration(
        totals.totalPauseTime,
        totals.totalPauseCount,
      ),
      averageRestTime: _divideDuration(totals.totalRestTime, completedEvents),
      fastestEvent: fastestEvent,
      slowestEvent: slowestEvent,
      mostInterruptedEvent: mostInterruptedEvent,
      longestPauseEvent: longestPauseEvent,
      runSummary: RunAnalyticsSummary(
        runs: runs,
        fastestRun: fastestRun,
        slowestRun: slowestRun,
        averageRunTime: _divideDuration(runTotal, runs.length),
      ),
      fatigueIndex: fatigueIndex,
      timeline: List<EventAnalyticsPoint>.unmodifiable(timeline),
    );
  }

  SessionTotals _calculateTotals(List<EventSplit> splits) {
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

  Duration _calculateFatigueIndex(List<EventAnalyticsPoint> timeline) {
    if (timeline.length < 8) {
      return Duration.zero;
    }

    final List<EventAnalyticsPoint> firstFour = timeline.take(4).toList();
    final List<EventAnalyticsPoint> lastFour = timeline
        .skip(timeline.length - 4)
        .toList();

    Duration firstTotal = Duration.zero;
    for (final EventAnalyticsPoint point in firstFour) {
      firstTotal += point.totalEventTime;
    }

    Duration lastTotal = Duration.zero;
    for (final EventAnalyticsPoint point in lastFour) {
      lastTotal += point.totalEventTime;
    }

    final Duration firstAverage = _divideDuration(firstTotal, firstFour.length);
    final Duration lastAverage = _divideDuration(lastTotal, lastFour.length);

    return lastAverage - firstAverage;
  }

  Duration _divideDuration(Duration total, int divisor) {
    if (divisor <= 0) {
      return Duration.zero;
    }

    return Duration(microseconds: total.inMicroseconds ~/ divisor);
  }

  EventAnalyticsPoint _minByDuration(
    List<EventAnalyticsPoint> items,
    Duration Function(EventAnalyticsPoint point) selector,
  ) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Must not be empty.');
    }

    EventAnalyticsPoint best = items.first;
    Duration bestValue = selector(best);

    for (final EventAnalyticsPoint item in items.skip(1)) {
      final Duration candidateValue = selector(item);
      if (candidateValue < bestValue) {
        best = item;
        bestValue = candidateValue;
      }
    }

    return best;
  }

  EventAnalyticsPoint _maxByDuration(
    List<EventAnalyticsPoint> items,
    Duration Function(EventAnalyticsPoint point) selector,
  ) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Must not be empty.');
    }

    EventAnalyticsPoint best = items.first;
    Duration bestValue = selector(best);

    for (final EventAnalyticsPoint item in items.skip(1)) {
      final Duration candidateValue = selector(item);
      if (candidateValue > bestValue) {
        best = item;
        bestValue = candidateValue;
      }
    }

    return best;
  }

  EventAnalyticsPoint _maxByInt(
    List<EventAnalyticsPoint> items,
    int Function(EventAnalyticsPoint point) selector,
  ) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Must not be empty.');
    }

    EventAnalyticsPoint best = items.first;
    int bestValue = selector(best);

    for (final EventAnalyticsPoint item in items.skip(1)) {
      final int candidateValue = selector(item);
      if (candidateValue > bestValue) {
        best = item;
        bestValue = candidateValue;
      }
    }

    return best;
  }
}

extension on HyroxStation {
  bool get isRun {
    switch (this) {
      case HyroxStation.run1:
      case HyroxStation.run2:
      case HyroxStation.run3:
      case HyroxStation.run4:
      case HyroxStation.run5:
      case HyroxStation.run6:
      case HyroxStation.run7:
      case HyroxStation.run8:
        return true;
      case HyroxStation.skiErg:
      case HyroxStation.sledPush:
      case HyroxStation.sledPull:
      case HyroxStation.burpeeBroadJump:
      case HyroxStation.rowing:
      case HyroxStation.farmersCarry:
      case HyroxStation.sandbagLunges:
      case HyroxStation.wallBalls:
        return false;
    }
  }
}
