# Project Workflow Template

A lightweight, stage-based workflow for building software one work item at a time.
Two files drive everything:

| File | Scope | When |
| --- | --- | --- |
| `project.md` | Whole codebase | Filled once at project start (or scanned from an existing repo) |
| `status.md` | One work item | Copied per branch; walks a Track — FULL (INIT → SPEC → TASK → IMPLEMENTATION → VERIFICATION) or LIGHT (INIT → IMPLEMENTATION → VERIFICATION) |

Works for any project type: web, desktop (Windows/macOS/Linux), mobile (Android/iOS), CLI, library, backend, or embedded.

---

## Current Scaffold Status

Roadmap item 1 (Project scaffold & foundations) is implemented on branch
feature/project-scaffold.

- Flutter Android project scaffold exists in this repository.
- Clean-architecture folders are in place under lib/app, lib/core, and lib/features.
- Riverpod, go_router, Hive bootstrap, Material 3 theme, and en/zh localization are wired.

Validation commands used:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

---

## Two flows

### 1. Whole new project

1. Create the project, then fill in `project.md`: Final Target, Architecture, Roadmap (give each roadmap item a one-line Definition of Done).
2. `project.md` is read **once** to initialize; after that it is ignored during branch work and only revisited on `report` from `main`/`master`, or when you ask to modify it.

### 2. Existing project (e.g. OpenBMC, Linux kernel)

1. Copy the template in, then run `init` — it scans the codebase (languages, frameworks, structure, build files) and drafts the empty fields for your confirmation.
2. Fill Final Target and Roadmap yourself (a scan can't invent those).

---

## Is `project.md` defined?

`project.md` carries an **Init Status** marker (`TEMPLATE` or `DEFINED`), so the check is a one-liner:

```bash
if [ -f docs/project.md ] && grep -q '^Status: DEFINED' docs/project.md; then
  echo "defined"
else
  echo "not defined"
fi
```

---

## Per work item (single branch)

1. Create a branch: `<type>/<short-name>` (type = `feature` / `fix` / `chore` / `docs`).
2. Copy `status.md` into `docs/` and run `goto init` to reset it.
3. Pick a **Track**: FULL for large/risky items (full SPEC + TASK pipeline), LIGHT for small/clear ones (skips SPEC + TASK).
4. Progress through the stages with `goto next stage`.
5. Deliver: `open pr` (if your Delivery Policy requires a PR — always confirmed before opening), then merge, then `finish`.

---

## Where to put the files

- Small/new project: `docs/`
- Large existing repo (kernel, OpenBMC): a dedicated folder like `.workflow/` to avoid clashing with the project's own `docs/` or `Documentation/`. Add it to `.gitignore` if you don't intend to upstream it.

On the FULL track, SPEC and TASK outputs land together in `docs/workitems/<name>.md`. The LIGHT track skips both — status.md holds the whole trail.

---

## Using this repo

This is a **template repository** — click **Use this template** (or copy `project.md` + `status.md`) into your project on a new branch.
See each file's own **Commands** and **AI Instructions** sections for the full command set.
