# Work Item: Auto transition mode

Roadmap item #4 - LIGHT track - branch `feature/auto-transition-mode`

---

## Definition of Done

Completing a workout auto-starts rest and then auto-starts the next event using configurable transition delay and default rest duration.

---

## Scope

In scope:

- Add auto transition behavior to session flow after workout completion.
- Add configuration for:
  - enable/disable auto transition (default enabled)
  - transition delay (0s, 3s, 5s, 10s)
  - default rest duration
- Keep manual controls available and valid when auto transition is disabled.
- Add/extend tests for auto transition timing and event progression.

Out of scope:

- Hive persistence for settings/session recovery.
- Notification/TTS/background integrations.

---

## Implementation Notes

- Start from current manual flow in `lib/features/session`.
- Keep timing logic in application/domain layers, not widgets.
- Keep implementation minimal and compatible with later persistence item.
