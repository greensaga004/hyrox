# Work Item: Statistics & analytics

Roadmap item #8 - FULL track - branch `feature/statistics-analytics`

---

## Definition of Done

Statistics screen shows session totals, fastest/slowest/most-interrupted/longest-pause events, run analysis, fatigue index, and charts.

---

## Spec

### Business Goal

Turn completed session data into actionable performance insight so athletes can
identify pacing, interruption patterns, and fatigue trends without external
spreadsheets or manual calculations.

### User Story

As a HYROX athlete, I want a statistics screen that summarizes my completed
session with totals, event and run analysis, and charts, so I can understand
where I lost time and what to improve next session.

### MVP

A production-usable statistics view exists in `features/statistics` that:

- Reads one completed session from the existing session domain data.
- Calculates and displays session totals:
  - total workout time
  - total pause time
  - total pause count
  - total rest time
  - total event time
  - total session time
- Calculates and displays key event insights:
  - fastest event (lowest total event time)
  - slowest event (highest total event time)
  - most interrupted event (highest pause count)
  - longest pause event (highest pause time)
- Calculates and displays run analysis over Run 1..Run 8:
  - fastest run
  - slowest run
  - average run pace/time
- Calculates and displays fatigue index:
  - average last 4 events minus average first 4 events
- Renders charts for:
  - workout duration by event
  - pause duration by event
  - rest duration by event
  - cumulative time progression
- Uses localized labels and values compatible with existing en/zh_TW support.

### Scope Definition

In scope:

- Statistics domain models/value objects under `lib/features/statistics/domain/`.
- Analytics service logic under `lib/core/analytics/` for deterministic
  calculations from immutable session data.
- Statistics application providers/controllers under
  `lib/features/statistics/application/`.
- Statistics presentation screen/widgets under
  `lib/features/statistics/presentation/`.
- Route wiring to reach the statistics screen from existing app navigation.
- Unit tests for analytics/statistics calculations.
- Widget tests for rendering key sections and empty-data states.

Out of scope (deferred to roadmap items #9-#11):

- Multi-session history browsing and comparison.
- Export/share formats (CSV/JSON/Excel/PDF).
- Additional settings toggles beyond current placeholders.
- Cloud sync or backend analytics.

### Acceptance Criteria

- [x] Session totals are calculated exactly as defined by project formulas.
- [x] Fastest/slowest/most-interrupted/longest-pause event insights are shown
      and tie handling is deterministic.
- [x] Run analysis includes Run 1..Run 8 only and excludes non-run events.
- [x] Fatigue index is calculated as:
      average(total event time of events 13-16)
      minus
      average(total event time of events 1-4).
- [x] Chart data matches the same source values shown in textual summaries.
- [x] Empty/incomplete-session states render a clear localized message and do
      not crash.
- [x] Business logic stays outside widgets; UI consumes provider state only.
- [x] `flutter analyze` and `flutter test` pass after integration.

---

## Tasks

### Development Order

1. Define analytics input/output models and pure calculation contracts.
2. Implement core analytics service functions in `core/analytics`.
3. Add statistics feature application provider/controller to assemble
   presentation-ready view state.
4. Build statistics screen sections for totals, insights, run analysis,
   fatigue index, and charts.
5. Add route entry point and navigation affordance from existing flow.
6. Add unit tests for all calculations and widget tests for key states.
7. Run `flutter analyze` and `flutter test`; fix any regressions.

### Core / Logic Tasks

- [x] C1. Add analytics value objects and helper types in
  `lib/core/analytics/` for event metrics, run metrics, and fatigue index.
- [x] C2. Implement deterministic calculation functions for session totals,
  event highlights, run analysis, and fatigue index.
- [x] C3. Define tie-breaking rules (for example first-in-order event wins)
  and apply them consistently across highlight calculations.
- [x] C4. Add statistics-specific domain mappers in
  `lib/features/statistics/domain/` to adapt session records to analytics
  inputs.

### UI / Interface Tasks

- [x] U1. Add a statistics screen in
  `lib/features/statistics/presentation/screens/` with sections for:
  session totals, event highlights, run analysis, fatigue index, charts.
- [x] U2. Add chart widgets using `fl_chart` for workout/pause/rest/cumulative
  views, including axis labels and localized legends.
- [x] U3. Add empty/incomplete-session UI state with localized guidance.
- [x] U4. Wire route/navigation so users can open the statistics screen.

### Data / Storage Tasks

- [x] D1. Reuse existing completed-session data structures as the source of
  truth; do not introduce duplicate persistence for statistics.
- [x] D2. Ensure statistics calculations operate on immutable snapshots only.
- [x] D3. Keep extension points ready for later history multi-session analysis
  without changing single-session calculation semantics.

### Test Tasks

- [x] T1. Add unit tests for session totals formulas and edge cases
  (zero values, partial pauses, deterministic ties).
- [x] T2. Add unit tests for run analysis over Run 1..Run 8 filtering.
- [x] T3. Add unit tests for fatigue index calculation and expected sign.
- [x] T4. Add widget tests for statistics screen sections and empty states.
- [x] T5. Run `flutter analyze` and `flutter test` and keep both green.

### Task Independence Notes

- C1 and C2 unblock all remaining logic and should be completed first.
- C4 depends on existing session models and C1 contracts.
- U1 depends on C2-C4 output shape.
- U2 depends on U1 base layout and C2 values.
- U3 can be implemented in parallel with U1.
- U4 can be done once U1 is routable.
- T1-T3 depend on C2-C4; T4 depends on U1-U3; T5 is final verification.
