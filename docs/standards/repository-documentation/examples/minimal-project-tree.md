# Example — The Smallest Compliant Repository

The standard scales down. A tiny script or CLI repo needs almost nothing.

## Minimal passing tree

```text
my-tool/
├── README.md          # what it is, how to run
└── AGENTS.md          # canonical agent instructions
```

No `.repo-doc.json` is needed — the defaults require only `README.md` +
`AGENTS.md`, allow the absence of `HANDOFF.md`, and expect no specs and no
adapters.

```bash
$ scripts/repo-doc-check --root my-tool
repo-doc-check (read-only) root=/.../my-tool
config: built-in defaults
----
OK: required file present: README.md
OK: required file present: AGENTS.md
OK: path/link references checked: 2      # however many in-repo refs the docs contain
OK: HANDOFF.md absent (no active work — allowed)
OK: docs/INDEX.md absent (optional)
OK: no harness adapters present (allowed)
OK: no forbidden/uncontrolled filenames
----
result: PASS (0 warning(s))
```

## Growing into more structure

Add pieces only when the project actually needs them:

```text
my-service/
├── README.md
├── AGENTS.md
├── CLAUDE.md                 # thin adapter → symlink to AGENTS.md
├── ROADMAP.md                # once there is a real backlog
├── HANDOFF.md                # only while work is in flight
├── .repo-doc.json            # enable specs, require docs/INDEX.md, tune budgets
└── docs/
    ├── INDEX.md
    ├── OPERATIONS.md         # project-specific safety rules (the canon for them)
    ├── decisions/
    │   └── ADR-2026-07-22-example.md
    └── specs/
        ├── active/
        │   └── first-feature.md      # has a Status: line
        ├── completed/
        └── archive/
```

A matching `.repo-doc.json` for that service:

```json
{
  "required_files": ["README.md", "AGENTS.md", "docs/INDEX.md"],
  "index": { "required": true, "must_reference": ["AGENTS.md"] },
  "handoff": { "required": false, "warn_lines": 200, "fail_lines": 400 },
  "specs": { "enabled": true },
  "adapters": { "candidates": ["CLAUDE.md", ".cursor/rules/*.mdc"] }
}
```

Everything above the required baseline is opt-in. **Never** create an empty file
just to match this tree.
