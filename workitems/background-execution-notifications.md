# Work Item: Background execution & notifications

Roadmap item #6 - FULL track - branch `feature/background-execution-notifications`

---

## Definition of Done

Timing survives screen-off/locked/background via foreground task, with notifications and Pause/Resume/Complete actions on key events.

---

## Scope Boundary

In scope:

- Keep session timing and progression correct while app lifecycle changes (screen off, lock, background, return to foreground).
- Add Android foreground service integration for active session tracking.
- Publish an ongoing notification while a session is active.
- Add actionable notification buttons for Pause, Resume, and Complete Workout.
- Handle notification actions in the application layer by calling existing `SessionController` commands.
- Keep timestamp-based timing as source of truth; notification/service is orchestration only.
- Add tests that validate lifecycle + notification action integration behavior.

Out of scope:

- Resume/Discard persistence flow changes (already delivered in item #5).
- Voice alerts and spoken cues (item #7).
- New analytics/history/export features (items #8, #9, #11).
- iOS background behavior (Android-only target for v1).

---

## Spec

### Business Goal

Ensure HYROX athletes can keep an active training session reliable when the app
is no longer foregrounded, without losing control over the current event flow.
The app must continue to track time accurately and offer quick control actions
from a persistent notification while Android keeps the process alive.

### User Story

As a HYROX athlete training with my phone in my pocket or with the screen
locked, I want session timing to remain accurate and notification controls to be
available, so I can pause/resume/complete workouts without reopening the app.

### MVP

A production-usable background-execution slice exists for Android:

- When a session becomes active (workout/pause/rest), a foreground task starts.
- A persistent notification is shown while the session is active.
- Notification action buttons are available and correctly mapped:
  - Pause -> `SessionController.startPause()` when allowed.
  - Resume -> `SessionController.resumeWorkout()` when allowed.
  - Complete Workout -> `SessionController.completeWorkout()` when allowed.
- Action handling respects current phase guardrails (invalid actions are ignored
  safely and never corrupt state).
- Returning from background reflects correct elapsed durations based on existing
  timestamp-based `TimerEngine` logic.
- Foreground task/ongoing notification stop when session is fully completed or
  discarded/reset.

### Scope Definition

In scope:

- Add background runner abstraction in `lib/core/background/` that wraps
  foreground task plugin initialization/start/stop and lifecycle hooks.
- Add notification abstraction in `lib/core/notifications/` for channel setup,
  ongoing session notification updates, and action callback wiring.
- Connect session lifecycle state changes to background/notification start-stop
  policy in `lib/features/session/application/` (or dedicated coordinator).
- Add an action dispatcher that translates notification intents to controller
  methods with phase checks.
- Add/update Android manifest/service configuration required by the chosen
  plugin and target SDK behavior.
- Localize any new user-facing notification strings in ARB files.
- Add tests for lifecycle transitions and action dispatch behavior.

Out of scope:

- Replacing timestamp-based timing with ticker-based elapsed tracking.
- Reworking session domain models unrelated to background/notification needs.
- Implementing TTS voice alert content (item #7).
- Expanding settings UI beyond what is strictly needed to support this item.

### Acceptance Criteria

- [x] With an active session, locking the screen and returning later shows
      elapsed workout/pause/rest values consistent with timestamp-based
      calculations (no reset/drift from lifecycle change).
- [x] Foreground service starts when session becomes active and stops when no
      active session remains (completed or discarded).
- [x] An ongoing notification is visible during active tracking and includes
      action buttons for Pause, Resume, and Complete Workout.
- [x] Tapping notification actions triggers the same domain-safe transitions as
      in-app controls; invalid actions for the current phase are ignored safely.
- [x] Notification/action handling never bypasses `SessionController` guardrails
      and does not introduce widget-level business logic.
- [x] New notification labels/messages are localized in English and zh_TW.
- [x] Unit/integration tests cover: foreground start/stop policy, action
      dispatch mapping, invalid-action handling, and lifecycle timing
      continuity.
- [x] `flutter analyze` and `flutter test` pass after integration.

---

## Tasks

### Development Order

1. Define plugin integration boundaries (background runner + notifications)
   and platform wiring needed on Android.
2. Implement core background/notification services and provider wiring.
3. Integrate lifecycle orchestration with session state transitions.
4. Implement notification action dispatch to controller commands.
5. Add localization strings for notification content/actions.
6. Add unit/integration tests for lifecycle continuity and action handling.
7. Run `flutter analyze` and `flutter test`; fix regressions.

### Core / Logic Tasks

- [x] C1. Add a background execution service in
  `lib/core/background/` with APIs for initialize/start/stop and active-state
  idempotency guards.
- [x] C2. Add a notification service in `lib/core/notifications/` for channel
  setup, ongoing session notification updates, and action registration.
- [x] C3. Add Riverpod providers for background/notification services and
  inject them into session orchestration.
- [x] C4. Extend `SessionController` integration points (or add a dedicated
  coordinator) so active phases trigger service start/update/stop policy.
- [x] C5. Add notification action dispatcher mapping action IDs to
  `startPause`, `resumeWorkout`, and `completeWorkout` with phase-safe checks.
- [x] C6. Ensure all action handling is side-effect safe and ignores invalid
  transitions without throwing uncaught runtime errors.

### UI / Interface Tasks

- [x] U1. No new primary screen is required; keep session-screen behavior
  unchanged except reflecting state updates triggered externally.
- [x] U2. Add minimal user-facing feedback only when needed (for example,
  ignore-invalid-action behavior remains non-disruptive).
- [x] U3. Keep widget layer presentation-only; do not move orchestration logic
  into screens/widgets.

### Data / Storage Tasks

- [x] D1. Reuse existing session recovery persistence; do not introduce a new
  parallel timing source.
- [x] D2. Ensure background/notification lifecycle decisions derive only from
  `SessionViewState` (single source of truth).
- [x] D3. Add constants for notification IDs/channel/action IDs in
  deterministic locations to keep platform wiring maintainable.

### Test Tasks

- [x] T1. Add unit tests for lifecycle policy:
  start service on active session, stop service on completed/discarded session.
- [x] T2. Add unit tests for notification action mapping and guardrails:
  valid action in valid phase executes; invalid phase is ignored safely.
- [x] T3. Add tests for timing continuity when simulating lifecycle changes
  (screen off/background/foreground) using timestamp-based snapshots.
- [x] T4. Add tests for localization presence of new notification labels in
  `app_en.arb` and `app_zh_TW.arb`.
- [x] T5. Run `flutter analyze` and `flutter test` as final quality gates.

### Task Independence Notes

- C1 and C2 can start in parallel, then converge in C3.
- C4 depends on C1-C3 and existing session state transitions.
- C5 and C6 depend on C2-C4.
- U1-U3 run alongside C4-C6 and should remain minimal.
- D1 and D2 are guardrails validated continuously during C4-C6.
- D3 should be done early with C2 to avoid magic values.
- T1-T3 depend on C4-C6; T4 depends on localization edits; T5 is final gate.
