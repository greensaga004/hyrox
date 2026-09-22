# HYROX Training Tracker & Analytics

## Project Overview

Build a production-ready Android application using Flutter for HYROX training tracking and analytics.

The application allows athletes to:

- Track HYROX workouts
- Track intra-event pauses
- Track pause count
- Track between-event rest periods
- Analyze performance data
- Review historical sessions
- Export training reports
- Continue timing accurately in the background

Target Platform:

```text
Android
```

Target Flutter Version:

```text
Flutter 3.35+
```

---

# Technology Stack

## Framework

```yaml
flutter
```

## State Management

```yaml
flutter_riverpod
```

## Local Storage

```yaml
hive
hive_flutter
```

## Routing

```yaml
go_router
```

## Charts

```yaml
fl_chart
```

## Notifications

```yaml
flutter_local_notifications
```

## Text To Speech

```yaml
flutter_tts
```

## Background Execution

```yaml
flutter_foreground_task
```

or

```yaml
flutter_background_service
```

## Export

```yaml
csv
pdf
excel
share_plus
```

## Localization

```yaml
flutter_localizations
intl
```

## App Information

```yaml
package_info_plus
```

---

# Architecture

Use Clean Architecture.

```text
Presentation Layer
      ↓
Application Layer
      ↓
Domain Layer
      ↓
Data Layer
```

---

# Folder Structure

```text
lib/

├── app/
│   ├── router/
│   ├── theme/
│   ├── localization/
│   └── constants/
│
├── core/
│   ├── timer/
│   ├── analytics/
│   ├── notifications/
│   ├── background/
│   ├── tts/
│   ├── export/
│   ├── storage/
│   ├── utils/
│   └── extensions/
│
├── features/
│
│   ├── session/
│   │   ├── presentation/
│   │   ├── application/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── statistics/
│   │   ├── presentation/
│   │   ├── application/
│   │   ├── domain/
│   │   └── data/
│   │
│   ├── history/
│   │   ├── presentation/
│   │   ├── application/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── settings/
│       ├── presentation/
│       ├── application/
│       ├── domain/
│       └── data/
│
└── main.dart
```

---

# Official HYROX Events

The event order is fixed and immutable.

```text
1. Run 1 (1 km)
2. SkiErg (1000 m)
3. Run 2 (1 km)
4. Sled Push (50 m)
5. Run 3 (1 km)
6. Sled Pull (50 m)
7. Run 4 (1 km)
8. Burpee Broad Jump (80 m)
9. Run 5 (1 km)
10. Rowing (1000 m)
11. Run 6 (1 km)
12. Farmer's Carry (200 m)
13. Run 7 (1 km)
14. Sandbag Lunges (100 m)
15. Run 8 (1 km)
16. Wall Balls (100 reps)
```

Users shall not modify the sequence.

---

# Core Definitions

## Workout Time

Actual active exercise time.

Does not include pause duration.

Example:

```text
Workout Time
05:00
```

---

## Pause Time

Time paused during a specific event.

Example:

```text
Workout

Pause

Workout

Pause

Workout
```

Pause duration must be accumulated separately.

---

## Pause Count

Every completed pause increases count by one.

Example:

```text
Pause #1

Pause #2

Pause #3
```

Result:

```text
Pause Count = 3
```

---

## Rest Time

Time between two events.

Example:

```text
Run 1 Complete

Rest

Start SkiErg
```

---

## Total Event Time

Formula:

```text
Workout Time + Pause Time
```

---

# Domain Models

## SessionState

Use enum.

```dart
enum SessionState {
  idle,
  workoutRunning,
  eventPaused,
  restRunning,
  completed,
}
```

---

## HyroxEvent

```dart
class HyroxEvent {
  String id;

  String name;

  Duration workoutTime;

  Duration pauseTime;

  int pauseCount;

  Duration restTime;

  Duration totalEventTime;

  bool completed;
}
```

---

## SplitRecord

```dart
class SplitRecord {
  String eventName;

  Duration workoutTime;

  Duration pauseTime;

  int pauseCount;

  Duration restTime;

  Duration totalEventTime;

  Duration cumulativeTime;

  DateTime startTimestamp;

  DateTime finishTimestamp;
}
```

---

## HyroxSession

```dart
class HyroxSession {
  String id;

  DateTime startTime;

  DateTime? endTime;

  List<HyroxEvent> events;

  Duration totalWorkoutTime;

  Duration totalPauseTime;

  int totalPauseCount;

  Duration totalRestTime;

  Duration totalEventTime;

  Duration totalSessionTime;
}
```

---

# Timer Engine

Create a dedicated timer engine.

Location:

```text
core/timer
```

Timer logic must never be implemented inside UI widgets.

---

# Timing Requirements

The application must remain accurate when:

```text
Screen Off
```

```text
Phone Locked
```

```text
App In Background
```

---

## Timestamp-Based Calculation

Do not depend solely on:

```dart
Timer.periodic()
```

Store timestamps:

```dart
DateTime workoutStartedAt;

DateTime pauseStartedAt;

DateTime restStartedAt;
```

Calculate durations using:

```dart
DateTime.now().difference(...)
```

---

# Event Workflow

## Manual Mode

```text
Start Workout
↓
Pause / Resume
↓
Complete Workout
↓
Start Rest
↓
Complete Rest
↓
Next Event
```

---

## Auto Transition Mode

```text
Start Workout
↓
Complete Workout
↓
Rest Starts Automatically
↓
Rest Completes
↓
Next Event Starts Automatically
```

---

# Auto Transition Settings

Provide:

```text
Enable Auto Transition
```

Default:

```text
Enabled
```

---

## Transition Delay

Options:

```text
0 sec
3 sec
5 sec
10 sec
```

---

## Default Rest Duration

User configurable.

---

# Notifications

Use local notifications.

---

## Notification Events

```text
Workout Complete
```

```text
Pause Started
```

```text
Pause Ended
```

```text
Rest Complete
```

```text
Next Event Started
```

```text
Session Complete
```

---

## Notification Actions

Support:

```text
Pause
```

```text
Resume
```

```text
Complete Workout
```

---

# Voice Alerts

Use:

```yaml
flutter_tts
```

Examples:

```text
Workout Complete
```

```text
Start Rest
```

```text
Rest Complete
```

```text
Start SkiErg
```

---

# Local Persistence

Use:

```yaml
Hive
```

Persist:

```text
Current Session
Current Event
Workout Time
Pause Time
Pause Count
Rest Time
Statistics
Settings
```

---

# Recovery Requirements

## App Restart

Restore session automatically.

---

## App Crash

Recover active session.

---

## Device Reboot

On launch display:

```text
Resume Previous Session?
```

Options:

```text
Resume
Discard
```

---

# Localization

## Supported Languages

Version 1 supports:

```text
Traditional Chinese (zh_TW)
English (en)
```

---

## Default Behavior

Follow device language.

Rules:

```text
zh_TW -> Traditional Chinese
en -> English
```

Unsupported language:

```text
Fallback to English
```

---

## Localization Files

Use ARB files.

```text
lib/l10n/app_en.arb
lib/l10n/app_zh_TW.arb
```

---

## Localization Rules

All user-facing strings must be localized.

Examples:

```text
Workout Time
```

```text
Pause Time
```

```text
Pause Count
```

```text
Rest Time
```

```text
Session Summary
```

```text
Settings
```

---

# Analytics

Implement analytics service.

Location:

```text
core/analytics
```

---

## Session Totals

Calculate:

```text
Total Workout Time
```

```text
Total Pause Time
```

```text
Total Pause Count
```

```text
Total Rest Time
```

```text
Total Event Time
```

```text
Total Session Time
```

---

## Fastest Event

Based on:

```text
Lowest Total Event Time
```

---

## Slowest Event

Based on:

```text
Highest Total Event Time
```

---

## Most Interrupted Event

Based on:

```text
Highest Pause Count
```

---

## Longest Pause Event

Based on:

```text
Highest Pause Time
```

---

## Average Pause Time

Formula:

```text
Total Pause Time
/
Total Pause Count
```

---

## Average Rest Time

Formula:

```text
Total Rest Time
/
Completed Events
```

---

## Run Analysis

Analyze:

```text
Run 1
Run 2
Run 3
Run 4
Run 5
Run 6
Run 7
Run 8
```

Calculate:

```text
Fastest Run
```

```text
Slowest Run
```

```text
Average Pace
```

---

## Fatigue Index

Formula:

```text
Average Last 4 Events
-
Average First 4 Events
```

---

# Screens

## Session Screen

### AppBar

Title:

```text
HYROX Training Tracker
```

Right Action:

```text
Settings Icon
```

Example:

```text
HYROX Training Tracker      ⚙️
```

---

### Content

Display:

```text
Current Event
```

```text
Workout Timer
```

```text
Pause Timer
```

```text
Pause Count
```

```text
Rest Timer
```

```text
Progress
```

```text
Workout Total
```

```text
Pause Total
```

```text
Rest Total
```

```text
Session Total
```

---

### Buttons

```text
Start Workout
```

```text
Pause
```

```text
Resume
```

```text
Complete Workout
```

```text
Start Rest
```

```text
Complete Rest
```

---

## Statistics Screen

Display:

```text
Session Summary
```

```text
Event Summary Table
```

```text
Fastest Event
```

```text
Slowest Event
```

```text
Most Interrupted Event
```

```text
Longest Pause Event
```

---

### Charts

```text
Workout Duration Chart
```

```text
Pause Duration Chart
```

```text
Rest Duration Chart
```

```text
Cumulative Time Chart
```

---

## History Screen

Display:

```text
Completed Sessions
```

```text
Session Details
```

```text
Session Comparison
```

---

## Settings Screen

### Section 1 - Language

Options:

```text
繁體中文
English
```

Requirements:

- Persist selected language
- Apply immediately
- No app restart required

Storage Key:

```text
selectedLanguage
```

---

### Section 2 - App Information

Display:

```text
Application Name
```

```text
Version
```

```text
Build Number
```

Use:

```yaml
package_info_plus
```

Example:

```text
HYROX Training Tracker

Version
1.0.0

Build
100
```

---

### Future Settings

Display placeholders for:

```text
Auto Transition
```

```text
Voice Alerts
```

```text
Notification Settings
```

```text
Default Rest Duration
```

```text
Target Finish Time
```

---

# Export Requirements

Support:

```text
CSV
```

```text
JSON
```

```text
Excel
```

```text
PDF
```

---

## Export Data

Per Event:

```text
Event Name
Workout Time
Pause Time
Pause Count
Rest Time
Total Event Time
```

Session Summary:

```text
Total Workout Time
Total Pause Time
Total Pause Count
Total Rest Time
Total Event Time
Total Session Time
```

---

# UI Guidelines

Use:

```text
Material 3
```

Support:

```text
Dark Mode
```

Minimum button height:

```text
60dp
```

Requirements:

```text
Large touch targets
```

```text
One-hand gym usage
```

```text
Simple navigation
```

---

# Code Quality Rules

Required:

```text
Null Safety
```

```text
Immutable Models
```

```text
Repository Pattern
```

```text
Dependency Injection
```

```text
Riverpod Providers
```

```text
Feature-Based Structure
```

Avoid:

```text
Business Logic In Widgets
```

```text
Global Mutable State
```

```text
Large Monolithic Classes
```

---

# Testing Requirements

Unit Tests:

```text
Timer Engine
Statistics Service
Analytics Service
Session Calculations
```

Widget Tests:

```text
Session Screen
Statistics Screen
Settings Screen
```

---

# Calculation Rules

## Event Level

```text
Total Event Time
=
Workout Time
+
Pause Time
```

---

## Session Level

```text
Total Workout Time
=
Σ Workout Time
```

```text
Total Pause Time
=
Σ Pause Time
```

```text
Total Pause Count
=
Σ Pause Count
```

```text
Total Rest Time
=
Σ Rest Time
```

```text
Total Event Time
=
Σ Total Event Time
```

```text
Total Session Time
=
Total Workout Time
+
Total Pause Time
+
Total Rest Time
```

---

# Definition Of Done

A feature is complete when:

✅ Builds successfully

✅ Passes static analysis

✅ Passes all tests

✅ Uses Riverpod

✅ Uses Hive

✅ Supports background timing

✅ Supports notifications

✅ Supports localization

✅ Supports settings page

✅ Displays app version

✅ Persists user language

✅ Calculates statistics correctly

✅ Follows clean architecture

✅ Production ready
