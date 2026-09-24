// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HYROX Training Tracker';

  @override
  String get foundationReady => 'Foundation scaffold is ready.';

  @override
  String get placeholderDescription =>
      'Core architecture, routing, localization, and storage bootstrap are wired.';

  @override
  String get currentEventLabel => 'Current Event';

  @override
  String get progressLabel => 'Progress';

  @override
  String get workoutTimeLabel => 'Workout Time';

  @override
  String get pauseTimeLabel => 'Pause Time';

  @override
  String get pauseCountLabel => 'Pause Count';

  @override
  String get restTimeLabel => 'Rest Time';

  @override
  String get totalEventTimeLabel => 'Event Total';

  @override
  String get sessionTotalsLabel => 'Session Totals';

  @override
  String get totalWorkoutLabel => 'Workout Total';

  @override
  String get totalPauseLabel => 'Pause Total';

  @override
  String get totalPauseCountLabel => 'Pause Count Total';

  @override
  String get totalRestLabel => 'Rest Total';

  @override
  String get totalSessionLabel => 'Session Total';

  @override
  String get completedEventsLabel => 'Completed Events';

  @override
  String get sessionCompletedTitle => 'Session Complete';

  @override
  String get voiceWorkoutComplete => 'Workout complete';

  @override
  String get voicePauseStarted => 'Pause started';

  @override
  String get voicePauseEnded => 'Pause ended';

  @override
  String get voiceStartRest => 'Start rest';

  @override
  String get voiceRestComplete => 'Rest complete';

  @override
  String get voiceSessionComplete => 'Session complete';

  @override
  String voiceStartEvent(Object eventName) {
    return 'Start $eventName';
  }

  @override
  String get startWorkoutButton => 'Start Workout';

  @override
  String get pauseButton => 'Pause';

  @override
  String get resumeButton => 'Resume';

  @override
  String get completeWorkoutButton => 'Complete Workout';

  @override
  String get startRestButton => 'Start Rest';

  @override
  String get completeRestButton => 'Complete Rest';

  @override
  String get autoTransitionSettingsTitle => 'Auto Transition';

  @override
  String get autoTransitionEnabledLabel => 'Enable Auto Transition';

  @override
  String get transitionDelayLabel => 'Transition Delay';

  @override
  String get defaultRestDurationLabel => 'Default Rest Duration';

  @override
  String get secondsLabel => 'sec';

  @override
  String get autoTransitionPendingLabel => 'Next Auto Action';

  @override
  String get autoTransitionActionStartRest => 'Start Rest';

  @override
  String get autoTransitionActionStartNextWorkout => 'Start Next Event';

  @override
  String get recoveryPromptTitle => 'Resume Previous Session?';

  @override
  String get recoveryPromptMessage =>
      'An unfinished session was found. Resume it or discard and start a new session.';

  @override
  String get recoveryResumeButton => 'Resume';

  @override
  String get recoveryDiscardButton => 'Discard';

  @override
  String get viewSettingsTooltip => 'Open settings';

  @override
  String get viewStatisticsTooltip => 'View statistics';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSectionTitle => 'Language';

  @override
  String get languageTraditionalChineseLabel => 'Traditional Chinese';

  @override
  String get languageEnglishLabel => 'English';

  @override
  String get settingsAppInfoSectionTitle => 'Application Information';

  @override
  String get settingsAppNameLabel => 'Application Name';

  @override
  String get settingsVersionLabel => 'Version';

  @override
  String get settingsBuildNumberLabel => 'Build Number';

  @override
  String get settingsFutureSectionTitle => 'Future Settings';

  @override
  String get settingsFutureAutoTransition => 'Auto Transition';

  @override
  String get settingsFutureVoiceAlerts => 'Voice Alerts';

  @override
  String get settingsFutureNotificationSettings => 'Notification Settings';

  @override
  String get settingsFutureDefaultRestDuration => 'Default Rest Duration';

  @override
  String get settingsFutureTargetFinishTime => 'Target Finish Time';

  @override
  String get settingsComingSoonLabel => 'Coming soon';

  @override
  String get statisticsTitle => 'Statistics & Analytics';

  @override
  String get statisticsUnavailableTitle => 'Statistics unavailable';

  @override
  String get statisticsUnavailableMessage =>
      'Complete a session to unlock statistics.';

  @override
  String get eventHighlightsTitle => 'Event Highlights';

  @override
  String get runAnalysisTitle => 'Run Analysis';

  @override
  String get fastestEventLabel => 'Fastest Event';

  @override
  String get slowestEventLabel => 'Slowest Event';

  @override
  String get mostInterruptedEventLabel => 'Most Interrupted Event';

  @override
  String get longestPauseEventLabel => 'Longest Pause Event';

  @override
  String get fastestRunLabel => 'Fastest Run';

  @override
  String get slowestRunLabel => 'Slowest Run';

  @override
  String get averageRunTimeLabel => 'Average Run Time';

  @override
  String get fatigueIndexLabel => 'Fatigue Index';

  @override
  String get fatigueIndexFormulaLabel => 'Average Last 4 - Average First 4';

  @override
  String get averagePauseTimeLabel => 'Average Pause Time';

  @override
  String get averageRestTimeLabel => 'Average Rest Time';

  @override
  String get workoutDurationChartTitle => 'Workout Duration by Event';

  @override
  String get pauseDurationChartTitle => 'Pause Duration by Event';

  @override
  String get restDurationChartTitle => 'Rest Duration by Event';

  @override
  String get cumulativeTimeChartTitle => 'Cumulative Time by Event';

  @override
  String get notificationChannelName => 'Session Tracking';

  @override
  String get notificationChannelDescription =>
      'Background tracking controls for active HYROX sessions.';

  @override
  String get eventRun1 => 'Run 1';

  @override
  String get eventSkiErg => 'SkiErg';

  @override
  String get eventRun2 => 'Run 2';

  @override
  String get eventSledPush => 'Sled Push';

  @override
  String get eventRun3 => 'Run 3';

  @override
  String get eventSledPull => 'Sled Pull';

  @override
  String get eventRun4 => 'Run 4';

  @override
  String get eventBurpeeBroadJump => 'Burpee Broad Jump';

  @override
  String get eventRun5 => 'Run 5';

  @override
  String get eventRowing => 'Rowing';

  @override
  String get eventRun6 => 'Run 6';

  @override
  String get eventFarmersCarry => 'Farmer\'s Carry';

  @override
  String get eventRun7 => 'Run 7';

  @override
  String get eventSandbagLunges => 'Sandbag Lunges';

  @override
  String get eventRun8 => 'Run 8';

  @override
  String get eventWallBalls => 'Wall Balls';
}
