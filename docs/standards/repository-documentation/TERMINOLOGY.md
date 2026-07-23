# Repository Documentation — Canonical Terminology

Part of the [CP7 Reusable Repository Documentation Standard](STANDARD.md).

One word, one meaning. When these terms appear in any CP7 repository's docs,
they mean exactly what is written here. Ambiguity is the drift this standard
exists to prevent.

## Terms

| Term | Definition |
|---|---|
| **Current truth** | The state of the system *right now*. A doc describing current truth must match reality; if it describes something retired or planned, it is not current truth. |
| **Canonical / source of truth (SoT)** | The single file that authoritatively defines a thing. Exactly one SoT per topic. Everything else references it; nothing restates it. `AGENTS.md` is the canonical agent-instruction SoT. |
| **Backlog / roadmap** | Vetted, intended future work. Lives in `ROADMAP.md` (or a project-approved equivalent). Not a scratch list of every idea — items are triaged and worth doing. |
| **Active / in flight** | Work a human or agent is doing *now* or will resume imminently. Tracked in `HANDOFF.md`. When work stops, its active entry is closed out, not left to rot. |
| **Specification (SPEC)** | A written, reviewable definition of a discrete piece of work: objective, constraints, requirements, tests, gates. Has a `Status:` line. Moves through a lifecycle (active → completed/archive). |
| **Report** | The record of what an executed SPEC actually did: files changed, tests run, results, remaining risks. Written once, at closeout. Immutable afterward. |
| **Completed** | A SPEC whose work shipped and was verified. Moved to the completed location; its `Status:` says so. Not deleted — kept as a record. |
| **Changelog / released change** | A dated, human-facing entry describing a change that actually shipped or released. `CHANGELOG.md`. Not a diary of in-progress work — only completed/released changes. |
| **Decision / ADR** | An Architecture Decision Record: a durable note explaining *why* a non-obvious choice was made, its tradeoffs, and how to reverse it. Lives in `docs/decisions/`. |
| **Archive / historical** | A record kept for history but no longer current truth. Explicitly labeled as historical. Readers must not act on it as current guidance. |
| **Adapter** | A thin, harness-specific file (e.g. `CLAUDE.md`, `.cursor/rules/*.mdc`, `GEMINI.md`) that points a particular tool at the canonical `AGENTS.md`. It carries only genuine harness behavior — never a copy of shared policy. |
| **Generated document** | A file produced by a script from another source. Marked "do not edit by hand." Regenerated, never hand-maintained. |
| **Tombstone / redirect stub** | A small placeholder left where a file used to live, pointing to its new home (or stating it was retired). Prevents dead links and "where did it go?" confusion. |

## Prohibited names

These names (and similar uncontrolled variants) are **forbidden** — they signal
drift and have no defined meaning in the lifecycle:

- `FINAL_NOTES.md`, `LATEST_PLAN.md`, `NEW_HANDOFF.md`
- `FINAL_*.md`, `*_FINAL.md`, `LATEST_*.md`, `NEW_*.md`, `*_NEW.md`
- `*-old.md`, `*_old.md`, `*.md.bak`, `*copy*.md`

If you need a plan, it is a `SPEC` or a `ROADMAP` entry. If you need to preserve
history, it goes to the archive with an explicit historical label. There is no
"final" or "latest" or "new" document — there is the canonical one.

`repo-doc-check` enforces this list (configurable per project via
`forbidden_filenames`). `TODO.md` is *discouraged* in favor of a vetted
`ROADMAP.md`, but not forbidden by default — a project may keep it by
configuration if it is genuinely maintained.
