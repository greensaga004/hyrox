# PROJECT OVERVIEW

> Use this file for a **whole new codebase**.
> Fill it in once at project start to define the architecture, final target, and roadmap.
> Each roadmap item is later implemented on its own branch using `status.md`.

## Init Status

Status: DEFINED

> TEMPLATE = not yet defined; DEFINED = initialization complete.
> Set to DEFINED only after Final Target, Architecture, and Roadmap are filled in.
> This marker is the single source of truth for "is project.md defined?".

---

## Project

Project Name: HYROX Training Tracker & Analytics

Repository: TBD  (optional — leave empty for local-only; if using GitHub, create an empty repo and `git clone` before copying this template in)

Owner: TBD

Project Type: Mobile App (Android)

Target Platforms: Android

Tech Stack:

- Language(s): Dart
- Framework / UI: Flutter 3.35+, Material 3 (dark mode support)
- Data / Storage: Hive, hive_flutter (local, offline-first)
- Backend / Services: None (fully local); device services — local notifications, TTS, foreground/background task
- Build / Packaging: Flutter Android build (APK / App Bundle)
- Infrastructure / Distribution: TBD  (optional — CI/CD only if publishing)

Key Packages:

- State: flutter_riverpod
- Routing: go_router
- Charts: fl_chart
- Notifications: flutter_local_notifications
- Voice: flutter_tts
- Background: flutter_foreground_task (or flutter_background_service)
- Export: csv, pdf, excel, share_plus
- Localization: flutter_localizations, intl (ARB files)
- App info: package_info_plus

---

## Delivery Policy

> Decided once, after this file is defined. Governs how work branches land.

- Main Branch Protected: yes
- Pull Request Required: yes
- CI Required: yes
- Merge Method: squash  (one clean commit per work-item branch)

If Pull Request Required is **no** (local-only), work branches may merge directly and CI is optional.

---

## Branch Naming

Pattern: `<type>/<short-name>`  (base branch: main or master)

Types:

- feature/ — new functionality
- fix/ — bug fix
- chore/ — tooling, deps, refactor, config
- docs/ — documentation only

Each branch carries one `status.md` and one work item from the Roadmap, regardless of type.

---

## Repository Layout

```
docs/
  project.md            (this file — whole-project overview, read once)
  status.md             (per-task workflow, one copy per branch)
  workitems/<name>.md   (FULL track: SPEC + TASK output merged in one file)
<source>/               (application/source code)
```

---

## Final Target

Vision:

A production-ready Android app that lets HYROX athletes accurately time and analyze a full 16-station HYROX race — tracking active workout time, in-event pauses, pause counts, and between-event rest — with timing that stays correct while the screen is off, the phone is locked, or the app is backgrounded.

Problem Statement:

HYROX training demands precise, per-station timing that separates active work from pauses and rest. Generic stopwatches can't model the fixed 16-event structure, lose accuracy in the background, and give no post-session analytics. Athletes need a purpose-built tracker that records every split and turns it into actionable performance insight.

Success Definition (Done means):

- An athlete can run a complete HYROX session across all 16 fixed events, tracking workout time, pause time, pause count, and rest time per event.
- Timing stays accurate with the screen off, phone locked, or app backgrounded (timestamp-based, not Timer-only).
- Manual and auto-transition modes both work end to end.
- Sessions persist and recover after app restart, crash, or device reboot (Resume / Discard prompt).
- Statistics and analytics are computed correctly (totals, fastest/slowest/most-interrupted events, run analysis, fatigue index) and visualized with charts.
- History of completed sessions is browsable and comparable.
- UI is localized (Traditional Chinese zh_TW + English), following device language with English fallback; language is user-switchable without restart.
- Sessions export to CSV, JSON, Excel, and PDF and can be shared.
- Notifications and voice alerts fire on key session events.
- Follows Clean Architecture, is null-safe with immutable models, and passes static analysis and tests.

Out of Scope:

- iOS, web, and desktop platforms (Android only for v1).
- Cloud sync, accounts, or any backend service.
- Editing or reordering the fixed 16-event sequence.
- Multi-athlete / social / leaderboard features.
- Languages beyond zh_TW and English in v1.

---

## Architecture

High-Level Overview:

Clean Architecture with a feature-based structure. Layers flow Presentation → Application → Domain → Data. Cross-cutting engines (timer, analytics, notifications, background, TTS, export, storage) live in `core/`. Features (session, statistics, history, settings) each own their presentation/application/domain/data slices. State is managed with Riverpod; navigation with go_router; persistence with Hive.

Components:

| Component | Responsibility | Tech |
| --- | --- | --- |
| Session feature | Run the 16-event flow: workout/pause/rest, manual + auto transition | Riverpod, go_router |
| Timer engine (`core/timer`) | Timestamp-based, background-accurate timing; never in UI widgets | Dart, DateTime diffs |
| Analytics service (`core/analytics`) | Session totals, fastest/slowest/most-interrupted, run analysis, fatigue index | Dart |
| Storage (`core/storage`) | Persist current session, splits, statistics, settings; recovery | Hive, hive_flutter |
| Background (`core/background`) | Keep timing alive when screen off / locked / backgrounded | flutter_foreground_task |
| Notifications (`core/notifications`) | Event notifications with Pause/Resume/Complete actions | flutter_local_notifications |
| TTS (`core/tts`) | Voice alerts on key events | flutter_tts |
| Export (`core/export`) | CSV / JSON / Excel / PDF export + share | csv, pdf, excel, share_plus |
| Statistics feature | Summary, tables, charts | fl_chart |
| History feature | List, detail, comparison of past sessions | Hive |
| Settings feature | Language switch, app info, future placeholders | package_info_plus, intl |
| Localization (`app/localization`) | ARB-based en + zh_TW strings, device-language default | flutter_localizations, intl |

Data Flow:

UI (Presentation) dispatches intents to Application (Riverpod controllers) → Domain services/models (timer engine, analytics, immutable models) → Data (Hive repositories). Timer state is derived from stored timestamps (`DateTime.now().difference(...)`) so it survives backgrounding; the background service and notifications observe session state changes; completed sessions flow into statistics, history, and export.

Key Decisions:

- Timestamp-based timing is the source of truth; `Timer.periodic` only drives UI refresh, never elapsed calculation.
- Timer logic lives in `core/timer`, never inside widgets.
- Offline-first, no backend; Hive is the only persistence.
- Immutable domain models + Repository pattern + Riverpod DI.
- Fixed, immutable 16-event HYROX sequence.
- `Total Event Time = Workout Time + Pause Time`; `Total Session Time = Total Workout + Total Pause + Total Rest`.

Constraints / Non-Functional Requirements:

- Performance: Timing accurate to the second across screen-off / locked / backgrounded states; smooth 60fps UI.
- Security: Local-only data, no network, no PII leaving the device.
- Scalability: Handle a growing history of sessions without UI degradation.
- Usability: Material 3, dark mode, min 60dp touch targets, one-hand gym use.
- Quality: Null safety, static analysis clean, unit + widget tests for timer/analytics/screens.

---

## Roadmap / Todo List

> Each item becomes a work branch. On start, copy `status.md` into `docs/`,
> set the work item, choose a Track (FULL for risky/unknown items, LIGHT for
> small/clear ones), reset items to TBD, and begin at the INIT stage.
>
> Slicing rules to avoid redundant work:
> - Define each item by a distinct, user-visible outcome, captured in its one-line Definition of Done.
> - Before starting an item, check overlap: if an earlier item already forces this work, fold them together or keep the earlier one deliberately minimal.
> - If two rows share Definition-of-Done language, merge or re-scope them.
> - For vertical slices, mark any pulled-in work in the roadmap immediately, or defer it with an explicit stub — never leave silent overlap.

| # | Work Item | Definition of Done | Priority | Track | Depends On | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Project scaffold & foundations | A Flutter Android app boots with the clean-architecture folders, Riverpod, go_router, Hive init, Material 3 theme (dark mode), and en/zh_TW localization wired to a placeholder home screen | High | FULL | - | DONE |
| 2 | Timer engine | A `core/timer` engine computes workout/pause/rest durations from timestamps and stays accurate when backgrounded, covered by unit tests | High | FULL | 1 | DONE |
| 3 | Session tracking flow | Session screen runs all 16 fixed events with Start/Pause/Resume/Complete/Rest, tracking workout time, pause time, pause count, and rest time (manual mode) | High | FULL | 2 | DONE |
| 4 | Auto transition mode | Completing a workout auto-starts rest and the next event using the configurable transition delay and default rest duration | Medium | LIGHT | 3 | DONE |
| 5 | Persistence & recovery | Active session and splits persist to Hive and restore after restart/crash/reboot via a Resume / Discard prompt | High | FULL | 3 | DONE |
| 6 | Background execution & notifications | Timing survives screen-off/locked/backgrounded via foreground task, with notifications (and Pause/Resume/Complete actions) on key events | High | FULL | 5 | DONE |
| 7 | Voice alerts | Key session events trigger spoken TTS cues (e.g. "Workout Complete", "Start SkiErg") | Low | LIGHT | 3 | DONE |
| 8 | Statistics & analytics | Statistics screen shows session totals, fastest/slowest/most-interrupted/longest-pause events, run analysis, fatigue index, and charts | Medium | FULL | 3 | TODO |
| 9 | History & comparison | History screen lists completed sessions with detail view and session comparison | Medium | LIGHT | 5 | TODO |
| 10 | Settings | Settings screen switches language (persisted, no restart), shows app name/version/build, and lists future placeholders | Medium | LIGHT | 1 | TODO |
| 11 | Export & share | A completed session exports to CSV, JSON, Excel, and PDF and can be shared | Low | LIGHT | 8 | TODO |

Definition of Done: one line describing a distinct user-visible outcome; no two rows should share it.
Track values: FULL (full pipeline) / LIGHT (skip SPEC + TASK)
Status values: TODO / IN PROGRESS / DONE / BLOCKED

---

## Milestones

- [x] M1: Foundations & timing — scaffold + timer engine accurate in background (items 1–2)
- [x] M2: Core tracking — full 16-event session flow with persistence & recovery (items 3–5)
- [x] M3: Background & alerts — foreground timing, notifications, voice cues (items 6–7)
- [ ] M4: Insight & settings — statistics/charts, history, settings (items 8–10)
- [ ] M5: Production polish — export/share, tests green, static analysis clean (item 11 + hardening)

---

## AI Instructions

Read this file **once** to initialize the project (architecture, final target, roadmap).
After initialization, do **not** read or update it again during work on a branch — use `status.md` on the work branch instead.
Re-read this file only when: (a) the user explicitly asks to modify it, or (b) the user says `report` while on the `main` (or `master`) branch.

Detecting whether the project is defined:

- If `docs/project.md` is missing → not defined; initialize first.
- If it exists but `Init Status` is `TEMPLATE` → not defined; finish initialization.
- If `Init Status` is `DEFINED` → already defined; do not re-initialize.

Initializing (`init`):

- If `Init Status` is already `DEFINED`, do nothing unless the user asks to modify.
- For an existing codebase: scan the repo (languages, frameworks, structure, build files) and draft the empty fields — Project Type, Target Platforms, Tech Stack, Architecture summary.
- For an empty project: interview the user to fill the same fields.
- Always present the drafted values for confirmation; set `Status: DEFINED` only after the user approves.
- Never invent Final Target or Roadmap from a scan — those come from the user.

Rules:

1. Define architecture and final target before writing any code.
2. Keep the roadmap as the single source of truth for what to build next.
3. Prefer MVP solutions and avoid over-engineering.
4. Suggest architecture changes only when absolutely necessary; record them under Key Decisions.
5. Give every roadmap item a one-line Definition of Done describing a distinct, user-visible outcome; no two items should share it.
6. Before starting a work item, run an overlap check against earlier/related items — if an earlier item already forces this work, fold them together or keep the earlier one deliberately minimal instead of duplicating.
7. When a vertical slice pulls in adjacent work, record it in the roadmap immediately or defer it with an explicit stub; never leave silent overlap.
8. Do not start a work item until it exists in the Roadmap.
9. When starting a work item, hand off to `status.md` (per-task workflow) on a new branch.
10. During work branches, ignore this file; it is only revisited when the user asks to modify it, or via `report` on main/master.

---

## Commands

init   (scan the codebase to draft empty fields — or interview if empty project — confirm, then set Init Status = DEFINED)

show final target

show architecture

show roadmap

add roadmap item   (add a row with a one-line Definition of Done; check it doesn't overlap an existing item)

start <type>/<name> [full|light]   (copy status.md to docs/, reset to INIT stage, set the Track; type = feature/fix/chore/docs; Track defaults to the Roadmap row, else FULL)

report   (only on main/master: re-read this file and summarize roadmap progress)
