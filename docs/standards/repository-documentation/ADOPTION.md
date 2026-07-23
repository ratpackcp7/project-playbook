# Adoption Procedure

Part of the [CP7 Reusable Repository Documentation Standard](STANDARD.md).

Adopt the standard **one project at a time**. Empower is the reference
implementation — study how it applied the pattern, but never blind-copy its
paths, ports, services, or data rules into another repo.

## Principles

- **Read before write.** Every adoption starts with a read-only audit and a set
  of human decisions. No repository is mass-rewritten sight-unseen.
- **Reconcile with reality.** The docs must match the project's *actual*
  topology (services, deploy model, worktrees — or the absence of them). A
  project with no database/frontend/service/worktree manager must not inherit
  rules that assume them.
- **One task branch/worktree per adoption.** Same discipline as any other
  change: isolated worktree, focused commit, review.

## Stages

### 1. Read-only audit
Run `repo-doc-audit --root <project> > audit-<project>-<date>.md` (write it
outside the repo). Run `repo-doc-check` for the deterministic baseline. Answer
the semantic prompt (source-of-truth conflicts, stale docs, dangerous
instructions, per-file disposition). **No file changes in this stage.**

### 2. Reconcile actual topology
Confirm what the project really is: language, run/deploy model, whether it uses
specs, whether it has harness adapters, what its real production-safety rules
are. Note anything the generic baseline should *not* impose here.

### 3. Approve terminology & human decisions
Take the unknown-decision list from stage 1 to Chris: which file is canonical
for each fact, what to retire, any terminology renames, whether the project
tracks specs/roadmap. Record the answers.

### 4. Create a project-specific implementation SPEC
Write a SPEC (use [templates/SPEC.template.md](templates/SPEC.template.md)) that
lists the exact, reviewed changes: canonical `AGENTS.md`, thin adapters,
`docs/INDEX.md`, HANDOFF trim, roadmap, spec lifecycle if used, and a tuned
`.repo-doc.json`. The SPEC is the reviewable plan — not an open-ended "clean up
the docs."

### 5. Migrate in a task branch/worktree
Execute the SPEC in an isolated worktree. Move history to archive with
tombstones; never delete load-bearing records. Keep the diff focused on docs.

### 6. Add project-appropriate checks
Commit a `.repo-doc.json` tuned to the project. Verify `repo-doc-check` passes.
Add fixtures only if the project needs project-specific rules.

### 7. Review / merge / deploy *only if relevant*
Open a PR if review adds value; otherwise follow the project's normal ship path.
Documentation changes rarely need a deploy — do not trigger one unless the
project genuinely couples docs to runtime.

### 8. Post-merge verification & cleanup
Re-run `repo-doc-check` on the merged result. Remove the task worktree. Confirm
no runtime/service/data state changed.

## Guardrails

- **Never** migrate more than one project per task.
- **Never** skip the stage-1 audit or the stage-3 human decisions.
- **Never** import Empower-specific commands, ports, or paths into a generic
  project's `AGENTS.md`.
- If adopting would require modifying another project or any runtime state to
  make the kit "work," **stop and report** — the kit must be adoptable without
  touching production.

See [MAINTENANCE.md](MAINTENANCE.md) for keeping a project compliant afterward,
and [PROJECT-INVENTORY.md](PROJECT-INVENTORY.md) for the recommended order.
