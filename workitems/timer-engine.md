# Work Item: Timer engine

Roadmap item #2 - FULL track - branch `feature/timer-engine`

---

## Spec

### Business Goal

Establish a reliable timing core for HYROX sessions before building the full
session UI flow. This item creates the source-of-truth timer behavior used by
later features (session tracking, persistence/recovery, notifications,
background execution, and analytics), reducing rework and timing bugs.

### User Story

As a developer building the HYROX tracker, I want a dedicated timer engine that
tracks workout, pause, and rest durations from timestamps, so that elapsed time
stays accurate even if UI refreshes are delayed or the app is backgrounded.

### MVP

A production-usable timer engine exists in `core/timer` with unit-tested,
timestamp-based duration calculations for the three timing modes:

- Workout running
- Event paused
- Rest running

The engine must:

- Use timestamps plus accumulated durations as source of truth (not periodic
  timer ticks for elapsed time correctness).
- Support start, pause, resume, and complete-style transitions needed by the
  next session-flow item.
- Track pause count increments only when a pause period completes.
- Expose computed durations for workout, pause, rest, and derived total event
  time (`workout + pause`).
- Be independent of widgets and render loops so background/foreground changes do
  not corrupt elapsed calculations.

### Scope Definition

In scope:

- Timer domain model(s) and engine API under `lib/core/timer/`.
- Timestamp-based transition handling for workout, pause, and rest.
- Accumulation logic for multiple pause/resume cycles within an event.
- Deterministic unit tests that validate transitions and elapsed time math.
- Utilities or abstractions required only to make timing deterministic in tests
  (for example, injectable clock/time source).

Out of scope (deferred to later roadmap items):

- Full 16-event session orchestration and event progression UI (item 3).
- Auto transition settings and delay behavior (item 4).
- Hive persistence/recovery and reboot resume prompts (item 5).
- Foreground service integration and actionable notifications (item 6).
- Voice alerts, statistics views, history, and export (items 7-11).

### Acceptance Criteria

- [x] A timer engine is implemented under `lib/core/timer/` with no timing
	business logic in widgets.
- [x] Elapsed workout, pause, and rest durations are derived from
	`DateTime.now().difference(...)` style timestamp deltas plus accumulators,
	not from `Timer.periodic()` tick counts.
- [x] Pause count increases by exactly 1 for each completed pause interval and
	does not change while pause is still active.
- [x] Event total time is computed as `workout time + pause time` and excludes
	rest time.
- [x] Repeated pause/resume cycles correctly accumulate pause duration without
	double-counting or losing elapsed time.
- [x] Unit tests cover at least:
	start workout, start pause, resume workout, complete workout,
	start rest, complete rest, and multi-pause accumulation scenarios.
- [x] Unit tests are deterministic and do not rely on real wall-clock delays.
- [x] `flutter analyze` and `flutter test` pass after integration.

---

## Tasks

### Development Order

1. Define timer domain types and state transitions.
2. Implement clock abstraction for deterministic tests.
3. Implement timer engine calculations (workout, pause, rest, total event).
4. Add guardrails for invalid transition calls.
5. Add unit tests for all required transition and accumulation scenarios.
6. Integrate into app module exports/usages required for compilation.
7. Run analyze and tests; fix issues.

### Core / Logic Tasks

- [x] C1. Create timer domain types in `lib/core/timer/`:
	event timer phase/state, timer snapshot/read model, and command/intents
	used by the engine API.
- [x] C2. Define engine API that supports transition operations required by
	item #3 flow: start workout, start pause, resume workout,
	complete workout, start rest, complete rest.
- [x] C3. Implement timestamp-based duration math using active-start
	timestamps plus accumulated durations for workout/pause/rest.
- [x] C4. Implement derived values: total event time (`workout + pause`) and
	pause count behavior (increment only when a pause interval completes).
- [x] C5. Add invalid transition protection (for example: resume while not
	paused) with explicit, testable behavior.

### UI / Interface Tasks

- [x] U1. Keep timer engine presentation-agnostic (no Flutter widget
	dependencies in `core/timer`).
- [x] U2. Provide read-friendly snapshot/output methods so session UI/controllers
	can render timers without owning timing logic.

### Data / Storage Tasks

- [x] D1. Keep engine state serializable-ready by using plain Dart values
	(`DateTime`, `Duration`, primitives) to simplify later Hive persistence.
- [x] D2. Define clear handoff fields for later persistence item (active phase,
	active start timestamp(s), accumulated durations, pause count).

### Test Tasks

- [x] T1. Add deterministic unit tests using an injectable clock/time source
	(no real sleep/wall-clock waiting).
- [x] T2. Cover required transitions: start workout, start pause,
	resume workout, complete workout, start rest, complete rest.
- [x] T3. Cover multi-pause accumulation across repeated pause/resume cycles.
- [x] T4. Verify pause count increments exactly once per completed pause and not
	while pause is active.
- [x] T5. Verify total event time equals workout + pause and excludes rest.
- [x] T6. Run `flutter analyze` and `flutter test` and keep the suite green.

### Task Independence Notes

- C1 and C2 can start immediately.
- C3 and C4 depend on C1/C2.
- C5 depends on C2 and should be tested alongside T2.
- U1/U2 depend on C2-C4.
- D1/D2 depend on finalized engine state shape from C1-C4.
- T1 starts with C2; T2-T5 depend on C3-C5.
- T6 is final verification before moving to IMPLEMENTATION complete.
