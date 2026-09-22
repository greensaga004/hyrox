# PROJECT OVERVIEW

> Use this file for a **whole new codebase**.
> Fill it in once at project start to define the architecture, final target, and roadmap.
> Each roadmap item is later implemented on its own branch using `status.md`.

## Init Status

Status: TEMPLATE

> TEMPLATE = not yet defined; DEFINED = initialization complete.
> Set to DEFINED only after Final Target, Architecture, and Roadmap are filled in.
> This marker is the single source of truth for "is project.md defined?".

---

## Project

Project Name: TBD

Repository: TBD  (optional — leave empty for local-only; if using GitHub, create an empty repo and `git clone` before copying this template in)

Owner: TBD

Project Type: TBD  (e.g. Web App / Desktop App (Windows/macOS/Linux) / Mobile App (Android/iOS) / CLI Tool / Library/SDK / Backend Service / Embedded)

Target Platforms: TBD

Tech Stack:

- Language(s): TBD
- Framework / UI: TBD
- Data / Storage: TBD
- Backend / Services: TBD
- Build / Packaging: TBD
- Infrastructure / Distribution: TBD  (optional — CI/CD only if publishing to GitHub or similar)

---

## Delivery Policy

> Decided once, after this file is defined. Governs how work branches land.

- Main Branch Protected: TBD  (yes / no)
- Pull Request Required: TBD  (yes / no — if main is protected, yes)
- CI Required: TBD  (yes if Pull Request Required; must pass before merge)
- Merge Method: TBD  (e.g. squash / merge / rebase)

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

TBD

Problem Statement:

TBD

Success Definition (Done means):

- TBD

Out of Scope:

- TBD

---

## Architecture

High-Level Overview:

TBD

Components:

| Component | Responsibility | Tech |
| --- | --- | --- |
| TBD | TBD | TBD |

Data Flow:

TBD

Key Decisions:

- TBD

Constraints / Non-Functional Requirements:

- Performance: TBD
- Security: TBD
- Scalability: TBD

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
| 1 | TBD | TBD | TBD | FULL | - | TODO |
| 2 | TBD | TBD | TBD | LIGHT | 1 | TODO |
| 3 | TBD | TBD | TBD | LIGHT | - | TODO |

Definition of Done: one line describing a distinct user-visible outcome; no two rows should share it.
Track values: FULL (full pipeline) / LIGHT (skip SPEC + TASK)
Status values: TODO / IN PROGRESS / DONE / BLOCKED

---

## Milestones

- [ ] M1: TBD
- [ ] M2: TBD
- [ ] M3: TBD

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
