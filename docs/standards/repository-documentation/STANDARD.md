# CP7 Reusable Repository Documentation Standard

**Version:** 1.0.0 · **Status:** Active · **Owner:** Chris (see [MAINTENANCE.md](MAINTENANCE.md))

A reusable, agent-agnostic standard for how a CP7 repository documents itself so
that any human or any agent/harness can orient quickly, find the one true source
for each fact, and avoid acting on stale or conflicting instructions.

This standard is the **generalized** form of the model proven in the Empower
repository (PRs #453–#460). Empower is the *reference implementation*, not a
template to copy — nothing Empower-specific (paths, ports, services, database
rules, product details) belongs in a generic project.

## What this is and is not

- **It governs documentation structure** — which docs exist, what each means,
  how work moves through them, and a read-only check that catches drift.
- **It does not govern agent runtime behavior.** Agent safety gates, task
  levels, routing, and worktree rules live in the Agent Control Plane (ACP,
  `agent-control-plane/source/rules/` → the rendered `CLAUDE.md`). This standard
  **references** that authority; it does not restate it. See
  [Separation of concerns](#separation-of-concerns).

## Read next

| Doc | Purpose |
|---|---|
| [TERMINOLOGY.md](TERMINOLOGY.md) | Exact meaning of every doc term; prohibited names |
| [ADOPTION.md](ADOPTION.md) | Staged, one-project-at-a-time rollout procedure |
| [AUDIT.md](AUDIT.md) | Read-only audit + full `repo-doc-check` config schema |
| [MAINTENANCE.md](MAINTENANCE.md) | How cleanliness persists; versioning of this standard |
| [PROJECT-INVENTORY.md](PROJECT-INVENTORY.md) | Current projects + recommended rollout waves |
| [templates/](templates/) | Concise, fill-in templates for every doc type |
| [examples/minimal-project-tree.md](examples/minimal-project-tree.md) | The smallest compliant repo |

Tools: [`scripts/repo-doc-check`](../../../scripts/repo-doc-check) (deterministic
gate) and [`scripts/repo-doc-audit`](../../../scripts/repo-doc-audit) (read-only
inventory + semantic audit prompt).

---

## 1. Universal rules (every repository)

These are the small, non-negotiable baseline. They fit a one-file script repo as
well as a multi-service app.

1. **One canonical agent-instruction file: `AGENTS.md`.** It is the source of
   truth for how to work in the repo. It is hand-authored and self-contained
   enough to orient a cold agent.
2. **A `README.md`** for humans — what the project is, how to run it.
3. **Every harness adapter is thin and points at `AGENTS.md`.** `CLAUDE.md`,
   `.cursor/rules/*.mdc`, `GEMINI.md`, `.codex/AGENTS.md`, etc. carry only
   genuine harness-specific behavior. Shared policy is never copied into them.
   The preferred `CLAUDE.md` form is a symlink to `AGENTS.md`.
4. **One meaning per term** — [TERMINOLOGY.md](TERMINOLOGY.md) governs. No
   uncontrolled `FINAL_*/LATEST_*/NEW_*` files.
5. **One SoT per fact.** If two files state the same rule, one is canonical and
   the other references it. Conflicts are drift.
6. **Active work is tracked and closed out.** While work is in flight it has a
   `HANDOFF.md` entry; when it stops, the entry is closed (shipped, archived, or
   abandoned) — not left dangling.
7. **History is labeled.** Anything no longer current truth is archived and
   explicitly marked historical, or left as a tombstone/redirect stub.
8. **Docs are checkable.** `repo-doc-check` runs clean (read-only, no network).

## 2. Required vs optional structure

**Required baseline** (small; suitable for most repositories):

| File / location | When required |
|---|---|
| `README.md` | always |
| `AGENTS.md` | always |
| `docs/INDEX.md` | when the repo has more than a handful of docs (recommended once `docs/` exists) |
| `HANDOFF.md` | **only while work is active** — absence is valid and correct when nothing is in flight |
| `ROADMAP.md` (or approved equivalent) | when the project tracks future work |
| `docs/specs/{active,completed,archive}/` | when the project uses specifications |

**Conditional / optional** — add only when the project actually needs it:

architecture docs, testing/gate docs, `docs/OPERATIONS.md`, deployment docs,
`docs/decisions/` ADRs, implementation reports, `CHANGELOG.md`, harness
adapters.

> **Do not create empty files to satisfy a template.** A missing optional doc is
> correct when there is nothing to say. The checker never requires an optional
> file to exist.

## 3. Agent / harness contract

- **One canonical instruction source** (`AGENTS.md`), consumed directly by every
  harness that supports it (Codex, OpenCode, and others read `AGENTS.md`
  natively — they need no adapter at all).
- **Thin adapters only for genuine harness behavior.** If a harness needs a file,
  it points at `AGENTS.md` and adds only what is specific to that harness.
- **No copied shared policy** across Claude / Cursor / Gemini / Codex / OpenCode
  / Bob-Hermes files. Duplication is the failure mode; a checker rule enforces
  that every adapter references the canonical file.
- **Clear startup / read-first order** stated at the top of `AGENTS.md`.
- **Project-specific production-safety rules live in the project's own canon**
  (`AGENTS.md` / `docs/OPERATIONS.md`) — never hard-coded into this generic
  standard, which knows nothing about any project's services or data.

## 4. Document lifecycle

Work moves in one direction; each stage has one home:

```text
ROADMAP / backlog            (vetted intent)
  → active SPEC              (docs/specs/active/, has Status:)
  → HANDOFF entry            (while actively worked)
  → implementation report    (what actually happened)
  → completed SPEC or archive (docs/specs/completed/ or archive/)
  → CHANGELOG                (only for completed / released changes)
```

**Closeout is mandatory.** When work stops, the active SPEC moves to
completed/archive, the `HANDOFF.md` entry is resolved, and (if released) a
`CHANGELOG.md` line is added. A relocated SPEC leaves a tombstone stub at its old
path.

**Stale-entry budgets** (defaults; tune per project in `.repo-doc.json`):

- `HANDOFF.md`: target ≤ 200 lines (warn), hard fail > 400. Over the warn
  budget → archive the oldest closed sessions.
- Active SPECs with no movement for > 30 days → re-confirm on the roadmap or move
  to archive.

## 5. Deterministic validation — `repo-doc-check`

A generic, configurable, **read-only** checker (see [AUDIT.md](AUDIT.md) for the
config schema). It performs only checks that are true/false by inspection:

required canonical files · broken relative Markdown links & path refs (in-repo
scope) · invalid lifecycle placement · missing `Status:` in active/completed
SPECs · `HANDOFF.md` size budget · missing index references · adapters that fail
to reference `AGENTS.md` · forbidden/uncontrolled filenames · configured stale
terms. It prints `OK/WARN/FAIL` lines and a final **`result: PASS`** or
**`result: FAIL`**, exiting non-zero on failure.

Guarantees: **no repository mutation · no network by default · no new
dependencies** (Python standard library only). Configuration scales from a
zero-config small repo to a complex multi-service one. Fixtures cover both
passing and failing cases (`scripts/repo-doc-tests/`).

## 6. Read-only semantic audit — `repo-doc-audit`

Deterministic checks cannot resolve *meaning*. `repo-doc-audit` produces a
read-only inventory (every doc, canonical files, adapters, SPEC lifecycle, and
the `repo-doc-check` result) **plus a semantic audit prompt** for the questions
that require judgment: source-of-truth conflicts, stale-vs-current
classification, dangerous operational instructions, per-file disposition, and
unknown human decisions.

> The audit is complete only after a human/agent answers the semantic prompt.
> **No regex or link check can certify semantic correctness.**

## 7. Adoption & maintenance

Rollout is staged and **one project at a time** — see [ADOPTION.md](ADOPTION.md).
Cleanliness is kept via closeout gates, optional CI, and periodic audits — see
[MAINTENANCE.md](MAINTENANCE.md).

---

## Separation of concerns

| Concern | Authority | This standard's role |
|---|---|---|
| Documentation structure, terminology, lifecycle, doc-check | **This standard** | defines it |
| Agent safety gates, task levels (L1–L3), routing, worktree rules, mobile-safe ops | **ACP** (`agent-control-plane/source/rules/`) | references it — never restates |
| Project workflow (spec → task → build → verify), task files, review gates | **project-playbook** `PLAYBOOK.md` | integrates with it; this kit lives here |
| Concrete project scaffolds (FastAPI/Flask) | **cp7-project-template** | orthogonal; a scaffolded project then adopts this standard |
| ADR format | **project-playbook** `docs/decisions/ADR-template.md` | this kit's [ADR template](templates/ADR.template.md) shares that section set |

This standard **integrates** existing CP7 governance; it does not duplicate it.
Where another repo already owns a rule, this standard points at it.
