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
