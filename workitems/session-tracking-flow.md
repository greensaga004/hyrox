# Work Item: Session tracking flow

Roadmap item #3 - FULL track - branch `feature/session-tracking-flow`

---

## Spec

### Business Goal

Deliver the first end-to-end HYROX session experience in manual mode so an
athlete can run the full fixed 16-event sequence with correct per-event timing
and session totals. This turns the existing timer engine into usable training
flow and de-risks later persistence, background, and analytics work.

### User Story

As a HYROX athlete, I want a session screen that guides me through all 16 fixed
events with explicit controls for workout, pause, resume, and rest, so I can
record accurate event splits (workout, pause, pause count, rest) and complete a
full session in order.

### MVP

A production-usable manual session flow exists in `features/session` that:

- Runs the official fixed HYROX event order (16 items), non-editable.
- Uses the timer engine from `core/timer` as the timing source of truth.
- Supports manual controls per event:
  - Start Workout
  - Pause
  - Resume
  - Complete Workout
  - Start Rest
  - Complete Rest
- Tracks and displays per-event workout time, pause time, pause count, and rest
  time.
- Accumulates and displays session totals for workout, pause, pause count, rest,
  and session total.
- Advances to the next event only when rest is completed manually.
- Completes the session after event 16 rest is completed.

### Scope Definition

In scope:

- Session domain model(s) for fixed event sequence and runtime progress under
  `lib/features/session/domain/`.
- Application/controller logic under `lib/features/session/application/` to
  orchestrate event lifecycle using `TimerEngine` transitions.
- Session screen UI under `lib/features/session/presentation/` replacing the
  placeholder route target.
- UI state and controls for manual-mode transitions only.
- Event-level and session-level calculations based on timer snapshots.
- Unit tests for session-flow logic and guardrails.
- Widget tests for primary manual controls and event progression rendering.

Out of scope (deferred to roadmap items #4+):

- Auto transition mode and transition delay settings (item #4).
- Persistence/recovery via Hive resume-discard flows (item #5).
- Foreground/background service integration and actionable notifications
  (item #6).
- Voice alerts (item #7).
- Statistics screen/charts, history/comparison, settings expansion, and export
  (items #8-#11).

### Acceptance Criteria

- [x] Session flow enforces the official fixed 16-event HYROX order and does
      not allow user reordering.
- [x] Manual controls work end to end for each event:
      start workout -> pause/resume (repeatable) -> complete workout ->
      start rest -> complete rest -> next event.
- [x] Per-event values are tracked correctly: workout time, pause time,
      pause count, rest time, and derived total event time
      (`workout + pause`).
- [x] Session totals are displayed and update correctly:
      total workout, total pause, total pause count, total rest,
      total event time, total session time.
- [x] Completing workout does not auto-start next event (manual mode only).
- [x] Completing rest advances exactly one event; after the 16th event rest,
      session enters completed state.
- [x] Session timing logic remains outside widgets; presentation layer only
      renders state from application/domain logic.
- [x] Unit tests cover state transitions, multi-pause scenarios, event
      progression boundaries, and session completion behavior.
- [x] Widget tests validate key control visibility/enabled states and
      progression UI updates.
- [x] `flutter analyze` and `flutter test` pass after integration.

---

## Tasks

### Development Order

1. Define session domain constants and models for 16 fixed events and event
   progress snapshots.
2. Implement session application controller/notifier that orchestrates
   `TimerEngine` transitions for manual mode.
3. Replace placeholder session screen with manual-flow UI and bind controls to
   controller actions.
4. Add computed summaries (per-event and session totals) and event progression
   indicators.
5. Add unit tests for controller transition flow and guardrails.
6. Add widget tests for control states and progression rendering.
7. Run `flutter analyze` and `flutter test`; fix regressions.

### Core / Logic Tasks

- [x] C1. Add fixed HYROX event definitions in
  `lib/features/session/domain/` with immutable event metadata and order.
- [x] C2. Add session runtime domain models for current event index, event
  split data (workout/pause/pauseCount/rest/totalEvent), and session totals.
- [x] C3. Implement session flow controller in
  `lib/features/session/application/` using Riverpod state management,
  wrapping `TimerEngine` lifecycle calls:
  startWorkout, startPause, resumeWorkout, completeWorkout,
  startRest, completeRest.
- [x] C4. Implement transition guardrails with explicit behavior for invalid
  commands by phase (for example, pause before workout start).
- [x] C5. Implement event advancement rules:
  complete rest advances one event; last event completion sets session
  completed state.
- [x] C6. Implement session aggregate calculations:
  total workout, total pause, total pause count, total rest,
  total event time, total session time.

### UI / Interface Tasks

- [x] U1. Replace `HomePlaceholderScreen` route target with a session screen
  in `lib/features/session/presentation/screens/`.
- [x] U2. Render current event name, progress (event x/16), and active
  timers/metrics for workout, pause, pause count, and rest.
- [x] U3. Render manual action buttons with phase-aware enable/disable/visibility
  logic for Start Workout, Pause, Resume, Complete Workout,
  Start Rest, Complete Rest.
- [x] U4. Render per-event summary for completed events and running session
  totals section.
- [x] U5. Keep widgets presentation-focused by consuming provider state only;
  no timer business logic inside widgets.

### Data / Storage Tasks

- [x] D1. Keep all runtime state in plain Dart immutable structures
  (Duration/DateTime/int/String/bool) to remain persistence-ready.
- [x] D2. Define clear state fields that item #5 can persist without changing
  session semantics (current event index, phase, per-event splits, totals).
- [x] D3. Do not add Hive writes in this item; ensure application layer APIs
  can be extended later for persistence hooks.

### Test Tasks

- [x] T1. Add controller unit tests for happy-path event lifecycle in manual
  mode (single event and multi-event progression).
- [x] T2. Add unit tests for repeated pause/resume cycles and pause-count
  accumulation at event level.
- [x] T3. Add unit tests for invalid transitions and boundary behavior at
  first and last events.
- [x] T4. Add unit tests for session total calculations against accumulated
  event splits.
- [x] T5. Add widget tests to verify phase-appropriate button states and event
  progression text/UI updates.
- [x] T6. Run `flutter analyze` and `flutter test` to keep suite green.

### Task Independence Notes

- C1 and C2 can start immediately and unblock C3-C6.
- C3 depends on timer engine contracts in `lib/core/timer/timer_engine.dart`.
- C4 and C5 depend on C3.
- C6 depends on C2 and C3.
- U1 can begin with mocked state, but U2-U4 depend on C3-C6.
- D1-D3 should be validated alongside C2-C6 implementation.
- T1-T4 depend on C3-C6; T5 depends on U1-U4; T6 is final verification.