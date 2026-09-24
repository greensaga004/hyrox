// features/statistics/domain/statistics_models.dart
import 'package:flutter/foundation.dart';
import 'package:hyrox/core/analytics/session_analytics_service.dart';

@immutable
class StatisticsViewState {
  const StatisticsViewState._({
    required this.hasCompletedSession,
    this.summary,
  });

  const StatisticsViewState.unavailable()
    : this._(hasCompletedSession: false, summary: null);

  const StatisticsViewState.completed(SessionAnalyticsSummary summary)
    : this._(hasCompletedSession: true, summary: summary);

  final bool hasCompletedSession;
  final SessionAnalyticsSummary? summary;

  bool get isAvailable => summary != null;
}
