# HYROX Training Tracker

Android-first Flutter app for timing and analyzing HYROX training sessions with a fixed 16-event flow.

## Overview

This project is building a production-ready HYROX tracker focused on:

- Accurate event timing (workout, pause, and rest)
- Reliable behavior when screen is off, phone is locked, or app is backgrounded
- Session history and performance analytics
- Exportable training reports
- Bilingual UI (English and Traditional Chinese)

The official HYROX event sequence is fixed and not user-editable.

## Current Status

Scaffold and foundations are complete.

Implemented now:

- Flutter app bootstrap with Riverpod root
- Material 3 light/dark themes
- GoRouter with initial route
- Hive initialization bootstrap
- ARB-based localization wiring (`en`, `zh`, `zh_TW`)
- Locale resolution with English fallback
- Basic widget and localization tests

Planned next:

- Timestamp-based timer engine in `core/timer`
- Full 16-event session workflow (manual + auto transition)
- Background execution, notifications, and voice alerts
- Statistics, history, and export

## Tech Stack

- Flutter 3.35+
- Dart SDK: `^3.13.1`
- State management: `flutter_riverpod`
- Routing: `go_router`
- Local storage: `hive`, `hive_flutter`
- Localization: `flutter_localizations`, `intl`

## Architecture

Clean Architecture with feature-based organization:

Presentation -> Application -> Domain -> Data

Top-level layout:

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
    session/
    statistics/
    history/
    settings/
  l10n/
  main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK installed and available on PATH
- Android SDK and emulator/device for Android runs

Check setup:

```bash
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
```

### Run App

```bash
flutter run
```

### Quality Checks

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Localization

- ARB files are stored in `lib/l10n/`
- Current locales: `en`, `zh`, `zh_TW`
- Locale resolution prefers exact match and falls back to English when unsupported

## Core Domain Rules

- Event order is immutable (16 official HYROX events)
- Event total time = workout time + pause time
- Session total time = workout total + pause total + rest total
- Timer calculations will use timestamps (`DateTime.now().difference(...)`) as source of truth

## Roadmap Snapshot

1. Project scaffold and foundations
2. Timer engine
3. Session tracking flow
4. Auto transition mode
5. Persistence and recovery
6. Background execution and notifications
7. Voice alerts
8. Statistics and analytics
9. History and comparison
10. Settings
11. Export and share

## Workflow

This repository tracks work per branch/work item:

- Global plan and roadmap: `project.md`
- Active work item progress: `status.md`
- Detailed FULL-track specs/tasks: `workitems/`

Recommended branch naming:

- `feature/<name>`
- `fix/<name>`
- `chore/<name>`
- `docs/<name>`
