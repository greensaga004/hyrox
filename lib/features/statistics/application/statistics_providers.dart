// features/statistics/application/statistics_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/core/analytics/session_analytics_service.dart';
import 'package:hyrox/features/session/application/session_controller.dart';
import 'package:hyrox/features/statistics/domain/statistics_models.dart';

final Provider<SessionAnalyticsService> sessionAnalyticsServiceProvider =
    Provider<SessionAnalyticsService>((Ref ref) {
      return const SessionAnalyticsService();
    });

final Provider<StatisticsViewState> statisticsViewStateProvider =
    Provider<StatisticsViewState>((Ref ref) {
      final sessionState = ref.watch(sessionControllerProvider);
      if (!sessionState.sessionCompleted) {
        return const StatisticsViewState.unavailable();
      }

      final SessionAnalyticsService analyticsService = ref.watch(
        sessionAnalyticsServiceProvider,
      );
      final SessionAnalyticsSummary summary = analyticsService.analyze(
        events: sessionState.events,
        splits: sessionState.effectiveSplits,
      );

      return StatisticsViewState.completed(summary);
    });
