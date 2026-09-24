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
