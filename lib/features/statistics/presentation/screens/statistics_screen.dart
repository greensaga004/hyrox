// features/statistics/presentation/screens/statistics_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/core/analytics/session_analytics_service.dart';
import 'package:hyrox/core/extensions/hyrox_station_localization.dart';
import 'package:hyrox/features/statistics/application/statistics_providers.dart';
import 'package:hyrox/features/statistics/domain/statistics_models.dart';
import 'package:hyrox/l10n/app_localizations.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StatisticsViewState viewState = ref.watch(
      statisticsViewStateProvider,
    );
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle)),
      body: viewState.isAvailable
          ? _StatisticsBody(summary: viewState.summary!)
          : _StatisticsUnavailableBody(
              title: l10n.statisticsUnavailableTitle,
              message: l10n.statisticsUnavailableMessage,
            ),
    );
  }
}

class _StatisticsUnavailableBody extends StatelessWidget {
  const _StatisticsUnavailableBody({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.query_stats_outlined, size: 40),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({required this.summary});

  final SessionAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.sessionTotalsLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _MetricTile(
                label: l10n.totalWorkoutLabel,
                value: _formatDuration(summary.totals.totalWorkoutTime),
              ),
              _MetricTile(
                label: l10n.totalPauseLabel,
                value: _formatDuration(summary.totals.totalPauseTime),
              ),
              _MetricTile(
                label: l10n.totalPauseCountLabel,
                value: summary.totals.totalPauseCount.toString(),
              ),
              _MetricTile(
                label: l10n.totalRestLabel,
                value: _formatDuration(summary.totals.totalRestTime),
              ),
              _MetricTile(
                label: l10n.totalEventTimeLabel,
                value: _formatDuration(summary.totals.totalEventTime),
              ),
              _MetricTile(
                label: l10n.totalSessionLabel,
                value: _formatDuration(summary.totals.totalSessionTime),
              ),
              _MetricTile(
                label: l10n.averagePauseTimeLabel,
                value: _formatDuration(summary.averagePauseTime),
              ),
              _MetricTile(
                label: l10n.averageRestTimeLabel,
                value: _formatDuration(summary.averageRestTime),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.eventHighlightsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _HighlightTile(
            label: l10n.fastestEventLabel,
            value: _eventWithDuration(
              l10n,
              summary.fastestEvent,
              summary.fastestEvent.totalEventTime,
            ),
          ),
          _HighlightTile(
            label: l10n.slowestEventLabel,
            value: _eventWithDuration(
              l10n,
              summary.slowestEvent,
              summary.slowestEvent.totalEventTime,
            ),
          ),
          _HighlightTile(
            label: l10n.mostInterruptedEventLabel,
            value:
                '${_eventLabel(l10n, summary.mostInterruptedEvent)} (${summary.mostInterruptedEvent.split.pauseCount})',
          ),
          _HighlightTile(
            label: l10n.longestPauseEventLabel,
            value: _eventWithDuration(
              l10n,
              summary.longestPauseEvent,
              summary.longestPauseEvent.split.pauseTime,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.runAnalysisTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _HighlightTile(
            label: l10n.fastestRunLabel,
            value: _eventWithDuration(
              l10n,
              summary.runSummary.fastestRun,
              summary.runSummary.fastestRun.totalEventTime,
            ),
          ),
          _HighlightTile(
            label: l10n.slowestRunLabel,
            value: _eventWithDuration(
              l10n,
              summary.runSummary.slowestRun,
              summary.runSummary.slowestRun.totalEventTime,
            ),
          ),
          _HighlightTile(
            label: l10n.averageRunTimeLabel,
            value: _formatDuration(summary.runSummary.averageRunTime),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.fatigueIndexLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _HighlightTile(
            label: l10n.fatigueIndexFormulaLabel,
            value: _formatSignedDuration(summary.fatigueIndex),
          ),
          const SizedBox(height: 24),
          _ChartCard(
            title: l10n.workoutDurationChartTitle,
            child: _DurationBarChart(
              timeline: summary.timeline,
              selector: (EventAnalyticsPoint point) => point.split.workoutTime,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: l10n.pauseDurationChartTitle,
            child: _DurationBarChart(
              timeline: summary.timeline,
              selector: (EventAnalyticsPoint point) => point.split.pauseTime,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: l10n.restDurationChartTitle,
            child: _DurationBarChart(
              timeline: summary.timeline,
              selector: (EventAnalyticsPoint point) => point.split.restTime,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: l10n.cumulativeTimeChartTitle,
            child: _CumulativeLineChart(timeline: summary.timeline),
          ),
        ],
      ),
    );
  }

  String _eventLabel(AppLocalizations l10n, EventAnalyticsPoint point) {
    return '${point.event.order}. ${point.event.station.localizedName(l10n)}';
  }

  String _eventWithDuration(
    AppLocalizations l10n,
    EventAnalyticsPoint point,
    Duration duration,
  ) {
    return '${_eventLabel(l10n, point)} (${_formatDuration(duration)})';
  }

  static String _formatDuration(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    final int seconds = value.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatSignedDuration(Duration value) {
    final String sign = value.isNegative ? '-' : '+';
    return '$sign${_formatDuration(value.abs())}';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: child),
        ],
      ),
    );
  }
}

class _DurationBarChart extends StatelessWidget {
  const _DurationBarChart({
    required this.timeline,
    required this.selector,
    required this.color,
  });

  final List<EventAnalyticsPoint> timeline;
  final Duration Function(EventAnalyticsPoint point) selector;
  final Color color;

  @override
  Widget build(BuildContext context) {
    double maxY = 1;
    final List<BarChartGroupData> bars = <BarChartGroupData>[];

    for (int index = 0; index < timeline.length; index += 1) {
      final double value = selector(timeline[index]).inSeconds.toDouble();
      if (value > maxY) {
        maxY = value;
      }

      bars.add(
        BarChartGroupData(
          x: index + 1,
          barRods: <BarChartRodData>[
            BarChartRodData(
              toY: value,
              color: color,
              width: 10,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: maxY + 5,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: bars,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value % 2 == 0) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(value.toInt().toString()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CumulativeLineChart extends StatelessWidget {
  const _CumulativeLineChart({required this.timeline});

  final List<EventAnalyticsPoint> timeline;

  @override
  Widget build(BuildContext context) {
    double maxY = 1;
    final List<FlSpot> spots = <FlSpot>[];

    for (int index = 0; index < timeline.length; index += 1) {
      final double value = timeline[index].cumulativeTime.inSeconds.toDouble();
      if (value > maxY) {
        maxY = value;
      }

      spots.add(FlSpot(index + 1, value));
    }

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: timeline.length.toDouble(),
        minY: 0,
        maxY: maxY + 10,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value % 2 == 0) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(value.toInt().toString()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
