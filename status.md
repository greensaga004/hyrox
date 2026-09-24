# PROJECT STATUS

> Use this file for a **single work item** (feature, fix, chore, docs) on its own branch.
> Copy into `docs/`, fill in the Current Work Item, reset the checklist to unchecked, and start at the INIT stage.
> For whole-codebase architecture, target, and roadmap, see `project.md`.

## Project

See `project.md` for Project Name, Repository, and Tech Stack.
(For a standalone task with no `project.md`, fill those in here instead.)

---

## Current Work Item

Work Item Name: Settings

Description: Settings screen switches language (persisted, no restart), shows app name/version/build, and lists future placeholders. Roadmap item #10 (LIGHT track, depends on item #1).

---

## Track

LIGHT

Tracks:

- FULL - INIT -> SPEC -> TASK -> IMPLEMENTATION -> VERIFICATION. Use for large/risky items with real unknowns.
- LIGHT - INIT -> IMPLEMENTATION -> VERIFICATION (skips the SPEC and TASK docs). Use for small, clear items.

Choose LIGHT when scope and design are obvious; FULL when there are unknowns worth writing down.

---

## Current Stage

VERIFICATION

Available Stages (depends on Track):

- INIT
- SPEC            (FULL track only)
- TASK            (FULL track only)
- IMPLEMENTATION
- VERIFICATION

---

## Stage Definitions

### INIT

Goal:

Set up this task's context before any requirements work.

Output:

Filled header of this file (Project + Current Work Item).

Allowed:

- Confirm Branch
- Set Work Item Name / Description
- Inherit Tech Stack from project.md
- Agree Task Boundary / Scope Line
- Confirm the item's one-line Definition of Done and check it doesn't overlap an earlier item

Not Allowed:

- Requirements / MVP Definition
- Task Planning
- Source Code

Exit Criteria:

- Branch created
- Work Item Name + Description filled
- Tech Stack confirmed
- Scope boundary agreed
- Definition of Done confirmed and overlap with earlier items checked

---

### SPEC

Goal:

Define requirements and MVP.  (FULL track only - skipped on LIGHT.)

Output:

docs/workitems/<name>.md - "Spec" section

Allowed:

- Business Goal
- User Story
- MVP
- Scope Definition
- Acceptance Criteria

Not Allowed:

- Source Code
- Detailed Task Planning
- Implementation Discussion

Exit Criteria:

- MVP is clearly defined
- Scope is agreed
- Success criteria exist

---

### TASK

Goal:

Break the work item into implementable tasks.  (FULL track only - skipped on LIGHT.)

Output:

docs/workitems/<name>.md - "Tasks" section (same file as SPEC)

Allowed:

- Task Breakdown
- Dependencies
- Priorities
- Development Order

Not Allowed:

- Source Code

Exit Criteria:

- Tasks are small and actionable
- Each task can be completed independently

---

### IMPLEMENTATION

Goal:

Build the work item.

Output:

Source Code

Allowed:

- Data / Storage Changes
- Core / Logic Code
- UI / Interface Code
- Tests

Not Allowed:

- New Scope Changes

Exit Criteria:

- All tasks completed
- Code committed
- Tests added

---

### VERIFICATION

Goal:

Confirm implementation matches specification.

Output:

Verification Result

Allowed:

- Testing
- Code Review
- Spec Coverage Check
- Bug Fixes

Exit Criteria:

- Implementation matches Spec
- Tests pass
- CI passes (required if Delivery Policy in project.md sets CI Required = yes)
- No critical issues remain

---

## Delivery (after VERIFICATION)

> Not a stage. Runs once VERIFICATION is done.

Flow (only if project.md Delivery Policy sets Pull Request Required = yes):

1. `open pr` - confirm, then push branch and open a PR to main.
2. Wait for CI green + review approval.
3. Merge the PR.
4. `finish` — switch to main, update `project.md` progress (Roadmap row status and any completed Milestone checkbox), then delete the branch.

If Pull Request Required = no, skip straight to `finish`.

---

## Current Checklist

> On the LIGHT track, skip the SPEC and TASK sections below.

### INIT

- [x] Branch Created
- [x] Work Item Name + Description
- [x] Tech Stack Confirmed
- [x] Scope Boundary Agreed
- [x] Definition of Done + Overlap Checked

### SPEC

- [ ] Business Goal
- [ ] User Story
- [ ] MVP Defined
- [ ] Scope Defined
- [ ] Acceptance Criteria

### TASK

- [ ] Core / Logic Tasks
- [ ] UI / Interface Tasks
- [ ] Data / Storage Tasks
- [ ] Test Tasks

### IMPLEMENTATION

- [x] Data / Storage Changes
- [x] Core / Logic Changes
- [x] UI / Interface Changes
- [x] Unit Tests
- [x] Docs/README updated

### VERIFICATION

- [x] Work Item Tested
- [x] Spec Coverage Verified
- [ ] CI Passed (required if project.md Delivery Policy sets CI Required = yes)

---

## Current Task

VERIFICATION in progress for roadmap item #10 on branch feature/settings.

Settings language persistence (no restart), app info display, and placeholders
are implemented and wired. Local checks passed: `flutter analyze` and
`flutter test`.

> Keep this to 3-4 lines. Detail belongs in docs/workitems/<name>.md, not here.

---

## Next Action

Update README notes for Settings and prepare PR details for CI execution.

---

## AI Instructions

Always read this file first.

Rules:

1. Follow the Current Stage and Track. On the LIGHT track, INIT hands off directly to IMPLEMENTATION - skip SPEC and TASK.
2. Confirm the Track during INIT: FULL for items with unknowns, LIGHT for small/clear items. Record it in the Track section.
3. Do not jump to later stages.
4. Prefer MVP solutions.
5. Avoid over-engineering.
6. Suggest architecture changes only when absolutely necessary.
7. Focus on completing the current stage before moving forward.
8. Commit at meaningful checkpoints, not every stage: once at SPEC-agreed (FULL track) and once at IMPLEMENTATION-done. Do not create a commit per stage.
9. Keep the Current Task section to 3-4 lines; put detail in docs/workitems/<name>.md.
10. On `goto init`, reset this file to its init state: set Track to FULL, Current Stage to INIT, set Work Item Name/Description/Current Task/Next Action to TBD, and uncheck every checklist item.
11. On `open pr`, always show the PR title and description and ask for explicit user confirmation; only open the PR after the user approves.
12. On `report` while on a work branch, summarize progress from this file only (current stage + checklist); do not read `project.md`.

Efficiency (keep credit/token spend low):

- Reuse the shell environment: configure PATH/toolchain once per terminal, or call the project's build script - don't re-emit long environment setup on every command.
- Batch build + test into one command instead of running configure -> build -> test as separate calls.
- Don't re-run builds or tests that already passed unless the code changed.
- Prefer fewer, larger file reads over many small ranged reads of the same file.
- Persist build/run/test commands and workflow conventions to repo memory once confirmed, so they aren't re-derived each session.

---

## Commands

report   (on a work branch: summarize this work item's progress from status.md only; do not read project.md)

set track full | light   (choose the pipeline: FULL = SPEC + TASK + IMPLEMENTATION + VERIFICATION, LIGHT = IMPLEMENTATION + VERIFICATION only)

goto init   (reset this file to init state: track=FULL, stage=INIT, header fields=TBD, all checkboxes unchecked)

goto spec   (FULL track only)

goto task   (FULL track only)

goto implementation

goto verification

goto next stage   (advances along the current Track; on LIGHT, INIT -> IMPLEMENTATION)

open pr   (after VERIFICATION done: push branch and open a PR to main; requires CI green if project.md sets CI Required = yes; must be confirmed by the user before the PR is actually opened)

finish   (switch to main, update project.md progress (Roadmap/Milestones), then delete the current branch)
