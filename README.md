# HYROX Training Tracker

Android-first Flutter app for timing HYROX training sessions with a fixed 16-event sequence.

## Overview

This project targets accurate, training-focused timing for HYROX sessions:

- Workout time (active work)
- Pause time and pause count (inside an event)
- Rest time (between events)
- Session totals across all events

The 16 official HYROX events are fixed and not user-editable.

## Current Capabilities

Implemented in the app now:

- Clean project scaffold with Riverpod, GoRouter, Hive bootstrap, and Material 3
- Timestamp-based timer engine in `lib/core/timer` (source of truth for elapsed time)
- Full manual session flow across all 16 events:
  - Start Workout
  - Pause / Resume
  - Complete Workout
  - Start Rest / Complete Rest
- Auto transition mode:
  - Auto start rest after workout completion
  - Auto start next event workout after rest completion
  - Transition delay options: `0s`, `3s`, `5s`, `10s`
  - Configurable default rest duration
  - Auto transition enabled by default
- Active session persistence and recovery:
  - Hive-backed recovery payload for in-progress session state
  - Resume/Discard prompt on app relaunch when recoverable state exists
  - Timestamp-consistent timing after restore
- Session UI with per-event metrics and running totals
- Localization wiring with ARB files and locale fallback behavior
- Unit and widget tests for timer/session flow and key UI states

Not yet implemented:

- Background task integration + actionable notifications
- Voice alerts (TTS)
- Statistics, history/comparison, and export

## Tech Stack (Current)

- Flutter 3.35+
- Dart SDK `^3.13.1`
- State management: `flutter_riverpod`
- Routing: `go_router`
- Local storage setup: `hive`, `hive_flutter`
- Localization: `flutter_localizations`, `intl`

## Architecture

Clean Architecture with feature-based organization:

Presentation -> Application -> Domain -> Data

```text
lib/
  app/
    localization/
    router/
    theme/
  core/
    analytics/
    background/
    export/
    notifications/
    storage/
    timer/
    tts/
  features/
    history/
    session/
    settings/
    statistics/
  l10n/
  main.dart
```

## HYROX Event Order

The event order is immutable:

1. Run 1
2. SkiErg
3. Run 2
4. Sled Push
5. Run 3
6. Sled Pull
7. Run 4
8. Burpee Broad Jump
9. Run 5
10. Rowing
11. Run 6
12. Farmer's Carry
13. Run 7
14. Sandbag Lunges
15. Run 8
16. Wall Balls

## Getting Started

### Prerequisites

- Flutter SDK on `PATH`
- Android SDK + emulator/device

Verify environment:

```bash
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Validate

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Localization

- ARB files: `lib/l10n/`
- Locales currently wired: `en`, `zh`, `zh_TW`
- Locale resolution falls back to English when unsupported

## Timing Rules

- Event total time = workout time + pause time
- Session total time = workout total + pause total + rest total
- Elapsed calculations are timestamp-based (`DateTime.now().difference(...)`)

## Roadmap Snapshot

Completed:

1. Project scaffold and foundations
2. Timer engine
3. Session tracking flow
4. Auto transition mode

Next:

5. Persistence and recovery
6. Background execution and notifications
7. Voice alerts
8. Statistics and analytics
9. History and comparison
10. Settings completion
11. Export and share

## Workflow Docs

- Whole-project roadmap: `project.md`
- Active work item tracking: `status.md`
- Work-item specs/tasks: `workitems/`
