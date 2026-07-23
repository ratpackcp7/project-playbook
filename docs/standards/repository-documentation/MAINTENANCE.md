# Maintenance Procedure

Part of the [CP7 Reusable Repository Documentation Standard](STANDARD.md).

How documentation cleanliness persists after a project adopts the standard, and
how the shared standard itself evolves.

## Keeping a project clean

1. **Docs check in closeout gates.** Add `repo-doc-check` to the project's
   pre-push / closeout gate (alongside its tests). A failing docs check blocks
   the same way a failing test does.
2. **Optional CI integration.** Projects with CI may run `repo-doc-check` on push
   and PR. It is read-only and needs no secrets or network. Keep it a *separate*
   step so a docs failure is legible. (This is optional — not every repo has or
   wants CI.)
3. **Index-or-exempt for new Markdown.** A new doc must be added to
   `docs/INDEX.md` (or explicitly exempted in `.repo-doc.json`). Unindexed docs
   are how drift starts.
4. **Active-work budgets.** Respect the `HANDOFF.md` size budget; archive closed
   sessions when it warns. Re-confirm or archive stale active SPECs (> 30 days
   idle).
5. **Periodic semantic audit.** `repo-doc-check` catches structure, not meaning.
   Run `repo-doc-audit` and answer its semantic prompt on a cadence — suggested
   **quarterly**, or before a major refactor / handoff to a new maintainer.

## Owning changes to the standard

- **Owner:** Chris. The standard is hosted in `project-playbook`
  (`docs/standards/repository-documentation/`) and changes go through that
  repo's normal review.
- **Scope discipline:** the standard governs documentation only. Runtime/agent
  gating changes belong in ACP; workflow-process changes belong in
  `project-playbook`'s `PLAYBOOK.md`. Do not absorb those concerns here.

## Versioning & changelog

- The standard is **semver-versioned** in `STANDARD.md` (currently `1.0.0`).
- **PATCH** — wording, examples, non-behavioral checker fixes.
- **MINOR** — new optional checks, new templates, new config keys with safe
  defaults (existing repos keep passing).
- **MAJOR** — a change that can make a previously-passing repo fail (e.g. a new
  required file, a stricter default). Requires migration notes.
- Record every change in the host repo's `CHANGELOG.md` under a
  `repository-documentation-standard` heading, with the version bump.

## Migration notes (when terminology or defaults change)

When a change could break adopted projects:

1. State the change and the version in `CHANGELOG.md`.
2. Provide the exact `.repo-doc.json` override that restores prior behavior, so a
   project can adopt the new version on its own schedule.
3. Never silently tighten a default — a MINOR release must keep existing repos
   green; only a MAJOR may require action, and only with migration notes.

## Drift-prevention summary

| Mechanism | Catches |
|---|---|
| `repo-doc-check` in closeout gate | structural drift (missing files, broken links, bad adapters, oversized HANDOFF, forbidden names) |
| Index-or-exempt rule | orphaned new docs |
| Active-work budgets | HANDOFF bloat, zombie SPECs |
| Quarterly `repo-doc-audit` | semantic drift (conflicts, stale prose, dangerous instructions) |
| Semver + changelog + migration notes | the standard drifting from its adopters |
