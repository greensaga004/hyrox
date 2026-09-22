// features/session/presentation/screens/session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/features/session/application/session_controller.dart';
import 'package:hyrox/features/session/domain/hyrox_events.dart';
import 'package:hyrox/features/session/domain/session_models.dart';
import 'package:hyrox/l10n/app_localizations.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionViewState state = ref.watch(sessionControllerProvider);
    final SessionController controller = ref.read(
      sessionControllerProvider.notifier,
    );
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SessionTotals totals = state.totals;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              state.sessionCompleted
                  ? l10n.sessionCompletedTitle
                  : l10n.currentEventLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _eventTitle(l10n, state.currentEvent),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.progressLabel}: ${state.currentEventIndex + 1}/${state.eventCount}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _MetricTile(
                  label: l10n.workoutTimeLabel,
                  value: _formatDuration(state.currentEventSplit.workoutTime),
                ),
                _MetricTile(
                  label: l10n.pauseTimeLabel,
                  value: _formatDuration(state.currentEventSplit.pauseTime),
                ),
                _MetricTile(
                  label: l10n.pauseCountLabel,
                  value: state.currentEventSplit.pauseCount.toString(),
                ),
                _MetricTile(
                  label: l10n.restTimeLabel,
                  value: _formatDuration(state.currentEventSplit.restTime),
                ),
                _MetricTile(
                  label: l10n.totalEventTimeLabel,
                  value: _formatDuration(
                    state.currentEventSplit.totalEventTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _ActionButton(
                  label: l10n.startWorkoutButton,
                  enabled: state.canStartWorkout,
                  onPressed: controller.startWorkout,
                ),
                _ActionButton(
                  label: l10n.pauseButton,
                  enabled: state.canStartPause,
                  onPressed: controller.startPause,
                ),
                _ActionButton(
                  label: l10n.resumeButton,
                  enabled: state.canResumeWorkout,
                  onPressed: controller.resumeWorkout,
                ),
                _ActionButton(
                  label: l10n.completeWorkoutButton,
                  enabled: state.canCompleteWorkout,
                  onPressed: controller.completeWorkout,
                ),
                _ActionButton(
                  label: l10n.startRestButton,
                  enabled: state.canStartRest,
                  onPressed: controller.startRest,
                ),
                _ActionButton(
                  label: l10n.completeRestButton,
                  enabled: state.canCompleteRest,
                  onPressed: controller.completeRest,
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                  value: _formatDuration(totals.totalWorkoutTime),
                ),
                _MetricTile(
                  label: l10n.totalPauseLabel,
                  value: _formatDuration(totals.totalPauseTime),
                ),
                _MetricTile(
                  label: l10n.totalPauseCountLabel,
                  value: totals.totalPauseCount.toString(),
                ),
                _MetricTile(
                  label: l10n.totalRestLabel,
                  value: _formatDuration(totals.totalRestTime),
                ),
                _MetricTile(
                  label: l10n.totalEventTimeLabel,
                  value: _formatDuration(totals.totalEventTime),
                ),
                _MetricTile(
                  label: l10n.totalSessionLabel,
                  value: _formatDuration(totals.totalSessionTime),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.completedEventsLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...state.splits.asMap().entries.map((
              MapEntry<int, EventSplit> entry,
            ) {
              final int index = entry.key;
              final EventSplit split = entry.value;
              final HyroxEventDefinition event = state.events[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_eventTitle(l10n, event)),
                subtitle: Text(
                  '${l10n.totalEventTimeLabel}: ${_formatDuration(split.totalEventTime)}',
                ),
                trailing: split.completed
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked),
              );
            }),
          ],
        ),
      ),
    );
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

  String _eventTitle(AppLocalizations l10n, HyroxEventDefinition event) {
    return '${event.order}. ${_eventName(l10n, event.station)}';
  }

  String _eventName(AppLocalizations l10n, HyroxStation station) {
    switch (station) {
      case HyroxStation.run1:
        return l10n.eventRun1;
      case HyroxStation.skiErg:
        return l10n.eventSkiErg;
      case HyroxStation.run2:
        return l10n.eventRun2;
      case HyroxStation.sledPush:
        return l10n.eventSledPush;
      case HyroxStation.run3:
        return l10n.eventRun3;
      case HyroxStation.sledPull:
        return l10n.eventSledPull;
      case HyroxStation.run4:
        return l10n.eventRun4;
      case HyroxStation.burpeeBroadJump:
        return l10n.eventBurpeeBroadJump;
      case HyroxStation.run5:
        return l10n.eventRun5;
      case HyroxStation.rowing:
        return l10n.eventRowing;
      case HyroxStation.run6:
        return l10n.eventRun6;
      case HyroxStation.farmersCarry:
        return l10n.eventFarmersCarry;
      case HyroxStation.run7:
        return l10n.eventRun7;
      case HyroxStation.sandbagLunges:
        return l10n.eventSandbagLunges;
      case HyroxStation.run8:
        return l10n.eventRun8;
      case HyroxStation.wallBalls:
        return l10n.eventWallBalls;
    }
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: Text(label),
      ),
    );
  }
}
