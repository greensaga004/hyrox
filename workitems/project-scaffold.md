# Work Item: Project scaffold & foundations

Roadmap item #1 — FULL track — branch `feature/project-scaffold`

---

## Spec

### Business Goal

Establish a clean, production-ready Flutter Android foundation so all subsequent
HYROX features (timer, session flow, analytics, history, settings, export) can be
built on a consistent architecture without rework. This item delivers no
user-facing HYROX behavior yet — it de-risks everything that follows.

### User Story

As a developer building the HYROX Training Tracker, I want a correctly structured,
dependency-wired Flutter app that boots to a placeholder screen, so that I can add
each feature into a predictable clean-architecture layout with state management,
routing, storage, theming, and localization already working.

### MVP

The app builds and launches on Android, showing a localized placeholder home
screen, with the following foundations in place:

- Clean-architecture folder structure: `lib/app/` (router, theme, localization,
  constants), `lib/core/` (timer, analytics, notifications, background, tts,
  export, storage, utils, extensions — created as empty placeholders), and
  `lib/features/` (session, statistics, history, settings — each with
  presentation/application/domain/data placeholders).
- `flutter_riverpod` installed and a `ProviderScope` wrapping the app.
- `go_router` configured with a single route (`/`) to a placeholder home screen.
- `hive` + `hive_flutter` installed and initialized at startup (`Hive.initFlutter()`),
  with a `core/storage` bootstrap ready for later boxes.
- Material 3 theme with light + dark schemes, following the system theme mode.
- Localization via `flutter_localizations` + `intl` with ARB files
  `lib/l10n/app_en.arb` and `lib/l10n/app_zh_TW.arb`; locale resolution follows
  the device language and falls back to English for unsupported locales.
- The placeholder home screen renders at least one string pulled from the ARB
  files (proving localization is wired).

### Scope Definition

In scope:

- `pubspec.yaml` dependencies for this foundation only: flutter_riverpod,
  go_router, hive, hive_flutter, flutter_localizations, intl.
- App entry (`main.dart`), `ProviderScope`, `MaterialApp.router`.
- Folder skeleton with `.gitkeep` (or a minimal placeholder file) where a
  directory would otherwise be empty.
- Theme, router, and localization wiring under `lib/app/`.
- Hive initialization in `core/storage`.
- l10n configuration (`l10n.yaml`) and generated localizations delegate.

Out of scope (deferred to their own roadmap items):

- Any timer logic (item 2), session/event flow (item 3), persistence models &
  recovery (item 5), notifications/background (item 6), TTS (item 7), analytics
  & charts (item 8), history (item 9), full settings screen (item 10), export
  (item 11).
- Adding fl_chart, notifications, background, tts, export, package_info_plus
  packages — pulled in by the items that need them.
- Hive TypeAdapters / model boxes (arrive with the models in item 5).

### Acceptance Criteria

- [x] `flutter analyze` passes with no errors.
- [x] `flutter build apk --debug` (or `flutter run`) succeeds on Android.
- [x] App launches to a placeholder home screen routed via go_router.
- [x] The home screen displays a string sourced from the ARB localization files.
- [x] Switching device language between English and Traditional Chinese changes
      the displayed string; an unsupported locale falls back to English.
- [x] Light/dark theme follows the system setting (Material 3).
- [x] `Hive.initFlutter()` runs at startup without error.
- [x] The folder structure matches the architecture defined in `project.md`.

---

## Tasks

### Development Order

1. Create Flutter app skeleton and folder layout.
2. Add dependencies and localization config.
3. Wire app bootstrap (ProviderScope, Hive init, MaterialApp.router).
4. Implement router + placeholder home screen.
5. Implement theme + localization delegates/resolution.
6. Add minimal tests for app boot, routing, and localization rendering.
7. Run analyze/build/test and fix issues.

### Core / Logic Tasks

- [x] C1. Create `lib/` structure matching architecture (`app/`, `core/`, `features/`), including placeholder files for empty dirs.
- [x] C2. Add and verify foundation packages in `pubspec.yaml`: flutter_riverpod, go_router, hive, hive_flutter, flutter_localizations, intl.
- [x] C3. Implement startup bootstrap in `main.dart` with `ProviderScope` and async init path for Hive.
- [x] C4. Add `core/storage` bootstrap helper (single init entrypoint) that wraps `Hive.initFlutter()`.

### UI / Interface Tasks

- [x] U1. Configure `MaterialApp.router` with go_router and default `/` route.
- [x] U2. Create placeholder home screen with localized title/body text pulled from generated l10n strings.
- [x] U3. Add Material 3 light/dark theme configuration that follows system theme mode.
- [x] U4. Keep layout simple and touch-friendly for future gym usage expansion.

### Data / Storage Tasks

- [x] D1. Ensure Hive initialization executes once before app shell is rendered.
- [x] D2. Prepare `core/storage` placeholders for future boxes/repositories (no adapters yet).
- [x] D3. Confirm no runtime Hive init errors during app launch.

### Test Tasks

- [x] T1. Add/adjust widget test to verify app boots and renders placeholder route.
- [x] T2. Add/adjust test asserting at least one localized string is displayed from ARB-backed l10n.
- [x] T3. Run `flutter analyze`, unit/widget tests, and debug build to satisfy acceptance criteria.

### Task Independence Notes

- C2 can begin immediately after C1.
- U1/U2/U3 depend on C2/C3.
- D1/D3 depend on C3/C4.
- T1/T2 depend on U2 and localization wiring.
- T3 is final verification for this item before moving to IMPLEMENTATION complete.
