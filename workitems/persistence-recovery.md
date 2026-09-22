# Work Item: Persistence & recovery

Roadmap item #5 - FULL track - branch `feature/persistence-recovery`

---

## Definition of Done

Active session and splits persist to Hive and restore after restart/crash/reboot via a Resume / Discard prompt.

---

## Scope Boundary

In scope:

- Persist active session runtime state and per-event splits to Hive.
- Restore in-progress session state on app relaunch.
- Show resume/discard decision flow when recoverable state exists.
- Ensure restored timing remains timestamp-accurate.
- Add or update tests for persistence and recovery behavior.

Out of scope:

- Foreground/background service integration and actionable notifications (item #6).
- Voice alert integrations (item #7).
- Statistics/history/export enhancements.

---

## Spec

### Business Goal

Ensure athletes never lose an in-progress HYROX session when the app is closed,
restarted, crashes, or the device reboots. The app must restore recoverable
session state with correct timing semantics so training data remains trustworthy.

### User Story

As a HYROX athlete in the middle of training, I want the app to recover my
active session after reopening, so I can resume where I left off or discard the
stale session and start fresh.

### MVP

An in-progress session can be safely persisted and recovered end to end:

- Persist active session state to Hive whenever session state changes in ways
	that affect recovery (phase changes, event index changes, split updates,
	timer timestamp anchors, auto-transition schedule updates, settings changes).
- Store enough data to rebuild the current session without reordering events and
	without recomputing already-completed splits.
- On app startup, detect recoverable active session state.
- If recoverable state exists, show a Resume / Discard decision prompt before
	continuing normal session flow.
- Resume reconstructs session state and timer state so elapsed durations remain
	timestamp-accurate after downtime.
- Discard clears recovery data and opens a fresh session at event 1 in idle.
- Once a session reaches completed state, active recovery payload is cleared.

### Scope Definition

In scope:

- Add persistence models/mappers for active session runtime state in
	`lib/features/session/data/` using Hive-friendly primitive fields.
- Add an active-session repository in `lib/features/session/data/` with APIs to
	save, load, and clear the recovery payload.
- Extend session application flow so persistence hooks are triggered on
	meaningful state transitions.
- Add recovery bootstrap logic at app startup to determine whether resume
	prompting is required.
- Add Resume / Discard prompt UI and wiring.
- Add/extend unit and widget tests for repository serialization, recovery
	decision flow, and restored timing correctness.
- Localize new user-facing strings related to resume/discard.

Out of scope:

- Foreground/background service behavior and notification actions (item #6).
- Voice alerts (item #7).
- History list/comparison or completed-session archival schema (item #9).
- Statistics/export pipeline changes (items #8/#11).

### Acceptance Criteria

- [x] Active session recovery payload persists to Hive during session progress
			and includes: current event index, session flow state, per-event splits,
			timer snapshot fields/timestamp anchors, auto-transition settings/schedule,
			and a schema version.
- [x] On app launch, if a valid recovery payload exists and session is not
			completed, the user sees a localized Resume / Discard prompt.
- [x] Choosing Resume restores the session to the exact event/phase context and
			keeps timing consistent using timestamp-based calculations.
- [x] Choosing Discard removes recovery payload and starts a clean session
			(`currentEventIndex = 0`, idle phase, zeroed splits/totals).
- [x] If recovery payload is missing, malformed, or version-incompatible, the
			app fails safe by clearing it and starting a fresh session.
- [x] Completing the final event clears active recovery payload so relaunch does
			not prompt to resume a finished session.
- [x] Session recovery behavior is covered by tests:
			repository round-trip serialization, resume flow, discard flow, malformed
			payload handling, and timer continuity after restore.
- [x] `flutter analyze` and `flutter test` pass after integration.

---

## Tasks

### Development Order

1. Define recovery payload schema and Hive repository API for save/load/clear.
2. Implement session state <-> persistence mapping and reconstruction helpers.
3. Wire persistence hooks into session flow transitions and settings updates.
4. Add app-start recovery bootstrap and Resume/Discard prompt flow.
5. Add tests for repository round-trip, decision flow, invalid payload handling,
	 and resumed timer continuity.
6. Run static analysis and tests, then fix any regressions.

### Core / Logic Tasks

- [x] C1. Add immutable persistence DTOs for active session recovery in
	lib/features/session/data/ (schema version, event index, session state,
	splits, timer fields, auto-transition fields, timestamp metadata).
- [x] C2. Add mapper utilities between SessionViewState/TimerSnapshot and
	persistence DTOs, including safe parsing and validation.
- [x] C3. Extend session application layer with hydration/restore entry points
	and clear-state behavior for discard and completed sessions.
- [x] C4. Ensure resumed session timing uses stored timestamp anchors and
	DateTime differences rather than synthetic elapsed counters.
- [x] C5. Add fail-safe behavior for malformed or incompatible payloads:
	clear payload and fallback to fresh session.

### UI / Interface Tasks

- [x] U1. Add startup recovery prompt (Resume / Discard) before normal session
	flow when a valid recoverable payload exists.
- [x] U2. Connect prompt actions to application layer: Resume restores state,
	Discard clears payload and resets session to idle event 1.
- [x] U3. Add localized strings for recovery prompt title/body/buttons and any
	related error fallback messaging.
- [x] U4. Keep prompt logic thin in presentation layer; no persistence business
	logic inside widgets.

### Data / Storage Tasks

- [x] D1. Add active session Hive box/key constants and repository
	implementation for save/load/clear operations.
- [x] D2. Store only primitive/Hive-friendly values and deterministic field
	names for forward-compatible schema evolution.
- [x] D3. Ensure writes happen at meaningful transition points (not every UI
	tick) to avoid unnecessary churn while preserving recoverability.
- [x] D4. Clear active payload after terminal completion so finished sessions do
	not re-trigger resume prompts.

### Test Tasks

- [x] T1. Unit tests for repository serialization and deserialization round-trip
	of active session payload.
- [x] T2. Unit tests for recovery mapper validation (valid payload, malformed
	payload, incompatible version fallback).
- [x] T3. Controller/application tests for resume and discard behavior,
	including payload clear semantics.
- [x] T4. Deterministic timer continuity tests verifying resumed elapsed values
	remain correct after simulated downtime.
- [x] T5. Widget tests for startup Resume/Discard prompt visibility and action
	outcomes.
- [x] T6. Run flutter analyze and flutter test to keep suite green.

### Task Independence Notes

- C1, D1, and D2 can start immediately and unlock storage integration.
- C2 depends on finalized DTO shape from C1.
- C3 and C5 depend on C2 and repository behavior from D1.
- C4 depends on C3 and timer snapshot semantics already defined in core/timer.
- U1 and U2 depend on C3 plus D1; U3 can be done in parallel.
- T1 and T2 depend on C1/C2/D1; T3 and T4 depend on C3/C4; T5 depends on U1/U2.
- T6 is final gate before moving to IMPLEMENTATION done.
