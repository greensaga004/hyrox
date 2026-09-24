import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HYROX Training Tracker'**
  String get appTitle;

  /// No description provided for @foundationReady.
  ///
  /// In en, this message translates to:
  /// **'Foundation scaffold is ready.'**
  String get foundationReady;

  /// No description provided for @placeholderDescription.
  ///
  /// In en, this message translates to:
  /// **'Core architecture, routing, localization, and storage bootstrap are wired.'**
  String get placeholderDescription;

  /// No description provided for @currentEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Event'**
  String get currentEventLabel;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @workoutTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout Time'**
  String get workoutTimeLabel;

  /// No description provided for @pauseTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause Time'**
  String get pauseTimeLabel;

  /// No description provided for @pauseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause Count'**
  String get pauseCountLabel;

  /// No description provided for @restTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get restTimeLabel;

  /// No description provided for @totalEventTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Event Total'**
  String get totalEventTimeLabel;

  /// No description provided for @sessionTotalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Session Totals'**
  String get sessionTotalsLabel;

  /// No description provided for @totalWorkoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout Total'**
  String get totalWorkoutLabel;

  /// No description provided for @totalPauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause Total'**
  String get totalPauseLabel;

  /// No description provided for @totalPauseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause Count Total'**
  String get totalPauseCountLabel;

  /// No description provided for @totalRestLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest Total'**
  String get totalRestLabel;

  /// No description provided for @totalSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Session Total'**
  String get totalSessionLabel;

  /// No description provided for @completedEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed Events'**
  String get completedEventsLabel;

  /// No description provided for @sessionCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Complete'**
  String get sessionCompletedTitle;

  /// No description provided for @voiceWorkoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get voiceWorkoutComplete;

  /// No description provided for @voicePauseStarted.
  ///
  /// In en, this message translates to:
  /// **'Pause started'**
  String get voicePauseStarted;

  /// No description provided for @voicePauseEnded.
  ///
  /// In en, this message translates to:
  /// **'Pause ended'**
  String get voicePauseEnded;

  /// No description provided for @voiceStartRest.
  ///
  /// In en, this message translates to:
  /// **'Start rest'**
  String get voiceStartRest;

  /// No description provided for @voiceRestComplete.
  ///
  /// In en, this message translates to:
  /// **'Rest complete'**
  String get voiceRestComplete;

  /// No description provided for @voiceSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get voiceSessionComplete;

  /// No description provided for @voiceStartEvent.
  ///
  /// In en, this message translates to:
  /// **'Start {eventName}'**
  String voiceStartEvent(Object eventName);

  /// No description provided for @startWorkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkoutButton;

  /// No description provided for @pauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseButton;

  /// No description provided for @resumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeButton;

  /// No description provided for @completeWorkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Workout'**
  String get completeWorkoutButton;

  /// No description provided for @startRestButton.
  ///
  /// In en, this message translates to:
  /// **'Start Rest'**
  String get startRestButton;

  /// No description provided for @completeRestButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Rest'**
  String get completeRestButton;

  /// No description provided for @autoTransitionSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Transition'**
  String get autoTransitionSettingsTitle;

  /// No description provided for @autoTransitionEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable Auto Transition'**
  String get autoTransitionEnabledLabel;

  /// No description provided for @transitionDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Transition Delay'**
  String get transitionDelayLabel;

  /// No description provided for @defaultRestDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Rest Duration'**
  String get defaultRestDurationLabel;

  /// No description provided for @secondsLabel.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get secondsLabel;

  /// No description provided for @autoTransitionPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Auto Action'**
  String get autoTransitionPendingLabel;

  /// No description provided for @autoTransitionActionStartRest.
  ///
  /// In en, this message translates to:
  /// **'Start Rest'**
  String get autoTransitionActionStartRest;

  /// No description provided for @autoTransitionActionStartNextWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Next Event'**
  String get autoTransitionActionStartNextWorkout;

  /// No description provided for @recoveryPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume Previous Session?'**
  String get recoveryPromptTitle;

  /// No description provided for @recoveryPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'An unfinished session was found. Resume it or discard and start a new session.'**
  String get recoveryPromptMessage;

  /// No description provided for @recoveryResumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get recoveryResumeButton;

  /// No description provided for @recoveryDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get recoveryDiscardButton;

  /// No description provided for @viewSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get viewSettingsTooltip;

  /// No description provided for @viewStatisticsTooltip.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get viewStatisticsTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSectionTitle;

  /// No description provided for @languageTraditionalChineseLabel.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get languageTraditionalChineseLabel;

  /// No description provided for @languageEnglishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishLabel;

  /// No description provided for @settingsAppInfoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Information'**
  String get settingsAppInfoSectionTitle;

  /// No description provided for @settingsAppNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Application Name'**
  String get settingsAppNameLabel;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersionLabel;

  /// No description provided for @settingsBuildNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get settingsBuildNumberLabel;

  /// No description provided for @settingsFutureSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Future Settings'**
  String get settingsFutureSectionTitle;

  /// No description provided for @settingsFutureAutoTransition.
  ///
  /// In en, this message translates to:
  /// **'Auto Transition'**
  String get settingsFutureAutoTransition;

  /// No description provided for @settingsFutureVoiceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Voice Alerts'**
  String get settingsFutureVoiceAlerts;

  /// No description provided for @settingsFutureNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingsFutureNotificationSettings;

  /// No description provided for @settingsFutureDefaultRestDuration.
  ///
  /// In en, this message translates to:
  /// **'Default Rest Duration'**
  String get settingsFutureDefaultRestDuration;

  /// No description provided for @settingsFutureTargetFinishTime.
  ///
  /// In en, this message translates to:
  /// **'Target Finish Time'**
  String get settingsFutureTargetFinishTime;

  /// No description provided for @settingsComingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get settingsComingSoonLabel;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics & Analytics'**
  String get statisticsTitle;

  /// No description provided for @statisticsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics unavailable'**
  String get statisticsUnavailableTitle;

  /// No description provided for @statisticsUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete a session to unlock statistics.'**
  String get statisticsUnavailableMessage;

  /// No description provided for @eventHighlightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Highlights'**
  String get eventHighlightsTitle;

  /// No description provided for @runAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Run Analysis'**
  String get runAnalysisTitle;

  /// No description provided for @fastestEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Fastest Event'**
  String get fastestEventLabel;

  /// No description provided for @slowestEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Slowest Event'**
  String get slowestEventLabel;

  /// No description provided for @mostInterruptedEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Most Interrupted Event'**
  String get mostInterruptedEventLabel;

  /// No description provided for @longestPauseEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest Pause Event'**
  String get longestPauseEventLabel;

  /// No description provided for @fastestRunLabel.
  ///
  /// In en, this message translates to:
  /// **'Fastest Run'**
  String get fastestRunLabel;

  /// No description provided for @slowestRunLabel.
  ///
  /// In en, this message translates to:
  /// **'Slowest Run'**
  String get slowestRunLabel;

  /// No description provided for @averageRunTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Run Time'**
  String get averageRunTimeLabel;

  /// No description provided for @fatigueIndexLabel.
  ///
  /// In en, this message translates to:
  /// **'Fatigue Index'**
  String get fatigueIndexLabel;

  /// No description provided for @fatigueIndexFormulaLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Last 4 - Average First 4'**
  String get fatigueIndexFormulaLabel;

  /// No description provided for @averagePauseTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Pause Time'**
  String get averagePauseTimeLabel;

  /// No description provided for @averageRestTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Rest Time'**
  String get averageRestTimeLabel;

  /// No description provided for @workoutDurationChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Duration by Event'**
  String get workoutDurationChartTitle;

  /// No description provided for @pauseDurationChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause Duration by Event'**
  String get pauseDurationChartTitle;

  /// No description provided for @restDurationChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest Duration by Event'**
  String get restDurationChartTitle;

  /// No description provided for @cumulativeTimeChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cumulative Time by Event'**
  String get cumulativeTimeChartTitle;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Session Tracking'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Background tracking controls for active HYROX sessions.'**
  String get notificationChannelDescription;

  /// No description provided for @eventRun1.
  ///
  /// In en, this message translates to:
  /// **'Run 1'**
  String get eventRun1;

  /// No description provided for @eventSkiErg.
  ///
  /// In en, this message translates to:
  /// **'SkiErg'**
  String get eventSkiErg;

  /// No description provided for @eventRun2.
  ///
  /// In en, this message translates to:
  /// **'Run 2'**
  String get eventRun2;

  /// No description provided for @eventSledPush.
  ///
  /// In en, this message translates to:
  /// **'Sled Push'**
  String get eventSledPush;

  /// No description provided for @eventRun3.
  ///
  /// In en, this message translates to:
  /// **'Run 3'**
  String get eventRun3;

  /// No description provided for @eventSledPull.
  ///
  /// In en, this message translates to:
  /// **'Sled Pull'**
  String get eventSledPull;

  /// No description provided for @eventRun4.
  ///
  /// In en, this message translates to:
  /// **'Run 4'**
  String get eventRun4;

  /// No description provided for @eventBurpeeBroadJump.
  ///
  /// In en, this message translates to:
  /// **'Burpee Broad Jump'**
  String get eventBurpeeBroadJump;

  /// No description provided for @eventRun5.
  ///
  /// In en, this message translates to:
  /// **'Run 5'**
  String get eventRun5;

  /// No description provided for @eventRowing.
  ///
  /// In en, this message translates to:
  /// **'Rowing'**
  String get eventRowing;

  /// No description provided for @eventRun6.
  ///
  /// In en, this message translates to:
  /// **'Run 6'**
  String get eventRun6;

  /// No description provided for @eventFarmersCarry.
  ///
  /// In en, this message translates to:
  /// **'Farmer\'s Carry'**
  String get eventFarmersCarry;

  /// No description provided for @eventRun7.
  ///
  /// In en, this message translates to:
  /// **'Run 7'**
  String get eventRun7;

  /// No description provided for @eventSandbagLunges.
  ///
  /// In en, this message translates to:
  /// **'Sandbag Lunges'**
  String get eventSandbagLunges;

  /// No description provided for @eventRun8.
  ///
  /// In en, this message translates to:
  /// **'Run 8'**
  String get eventRun8;

  /// No description provided for @eventWallBalls.
  ///
  /// In en, this message translates to:
  /// **'Wall Balls'**
  String get eventWallBalls;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
