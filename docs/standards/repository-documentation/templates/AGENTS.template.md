# AGENTS.md — <Project Name>

> Canonical agent-instruction source for this repo. Every harness adapter points
> here; nothing restates this file. Keep it self-contained enough to orient a
> cold agent. Delete any section below that does not apply — do not keep empty
> headings.

## Purpose

<One paragraph: what this project is, who/what it serves, and its role in CP7.>

## Read first (startup order)

1. This file (`AGENTS.md`).
2. `README.md` — human overview / how to run.
3. `HANDOFF.md` — current active work (only exists while work is in flight).
4. `docs/INDEX.md` — where every doc lives (if present).
5. `<any project-specific must-read, e.g. docs/OPERATIONS.md>`.

## Key facts

- **Language / stack:** <...>
- **Run:** `<command>`
- **Test:** `<command>`
- **Build:** `<command, if any>`
- **Deploy model:** <none / manual / CI — describe, or delete if N/A>
- **Ports / URLs:** <or delete if N/A>

## Repo layout (conventions, not a full tree)

- `<path>` — <what lives here / the one rule about it>

## Safety rules (project-specific — this is the canon for them)

> State the project's real production-safety rules here (what must never be done
> without explicit human approval: restarts, live-data writes, migrations,
> deploys). These belong in the project canon, not in the shared standard.
> Delete this section for a project with no live/prod surface.

- <rule>

## Workflow

<How work is done here: branch/worktree convention (or "no worktrees — commit on
a branch"), test gate, ship path. Reference the ACP task levels and
project-playbook workflow rather than restating them.>

## Gotchas / lessons

- <non-obvious thing that has bitten someone>

---
*Documentation follows the CP7 Repository Documentation Standard
(`project-playbook/docs/standards/repository-documentation/STANDARD.md`). Run
`repo-doc-check` before closeout.*
