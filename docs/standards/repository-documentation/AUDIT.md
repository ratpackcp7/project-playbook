# Read-Only Audit & Checker Configuration

Part of the [CP7 Reusable Repository Documentation Standard](STANDARD.md).

This document covers the two tools and how to configure them. Both are
**read-only** and require **no network** and **no third-party packages**.

## `repo-doc-check` — deterministic gate

```bash
# from the repo you want to check (uses git toplevel automatically):
scripts/repo-doc-check

# or explicitly:
scripts/repo-doc-check --root /path/to/repo --config /path/to/.repo-doc.json

# discover what it does:
scripts/repo-doc-check --help
scripts/repo-doc-check --list-checks
scripts/repo-doc-check --print-config     # effective config after defaults merge
```

Exit code: **0 = PASS**, **1 = FAIL**, **2 = usage/config error**. Output ends
with exactly `result: PASS (...)` or `result: FAIL (...)`. Warnings never fail
the run.

### Configuration schema (`.repo-doc.json`)

Every key is optional. With no file present, built-in defaults apply — a small
repo needs no config. Deep-merged over the defaults, so you only override what
differs. Run `--print-config` to see the effective result.

```jsonc
{
  // Files that MUST exist. Default: ["README.md", "AGENTS.md"].
  "required_files": ["README.md", "AGENTS.md", "docs/INDEX.md"],

  // The one canonical agent-instruction file every adapter must point at.
  "canonical_agents_file": "AGENTS.md",

  // Active-work tracker size budget. required:false => absence is OK.
  "handoff": {
    "file": "HANDOFF.md",
    "required": false,
    "warn_lines": 200,
    "fail_lines": 400
  },

  // Documentation index. must_reference: substrings that must appear in it.
  "index": {
    "file": "docs/INDEX.md",
    "required": false,
    "must_reference": ["AGENTS.md"]
  },

  // SPEC lifecycle. Leave disabled if the project uses no specs.
  "specs": {
    "enabled": false,
    "active_dir": "docs/specs/active",
    "completed_dir": "docs/specs/completed",
    "archive_dir": "docs/specs/archive",
    "status_scan_lines": 45
  },

  // Thin harness adapters (globs allowed). Any present must reference the
  // canonical file. require_at_least_one:false => zero adapters is valid.
  "adapters": {
    "candidates": [".cursor/rules/*.mdc", "GEMINI.md", "CLAUDE.md", ".codex/AGENTS.md"],
    "require_at_least_one": false
  },

  // Relative-link / path-reference check (in-repo scope only, no network).
  "link_check": {
    "enabled": true,
    "scan": ["AGENTS.md", "README.md", "docs/INDEX.md", "ROADMAP.md"],
    "allowlist": ["path/that/exists/only/at/runtime"]
  },

  // Uncontrolled filenames to reject (globs, matched on basename, case-insensitive).
  "forbidden_filenames": ["FINAL_NOTES.md", "LATEST_PLAN.md", "NEW_HANDOFF.md", "FINAL_*.md"],

  // Project-specific stale terms to flag inside scanned docs.
  "forbidden_terms": ["retired-service-name", ":OLD_PORT"],

  // Directories never scanned.
  "ignore_dirs": [".git", "node_modules", "venv", ".venv", "dist", "build"]
}
```

### Small vs complex projects

- **Small script/CLI repo:** no `.repo-doc.json` at all. The defaults require
  only `README.md` + `AGENTS.md`, allow no HANDOFF, and expect no specs.
- **Complex multi-service repo:** enable `specs`, require `docs/INDEX.md`, add
  the project's real harness adapters, tighten the HANDOFF budget, and list
  project-specific `forbidden_terms` (e.g. a retired port or service name).

Prefer **configuration over editing the script**. The same generic
`repo-doc-check` serves every project; per-project behavior comes from
`.repo-doc.json`.

## `repo-doc-audit` — read-only inventory + semantic prompt

```bash
scripts/repo-doc-audit --root /path/to/repo > audit-<project>-<date>.md
scripts/repo-doc-audit --help
```

It writes Markdown to stdout (write the report **outside** the repo, or into a
task branch you will review — never committed as a stray file). It has two parts:

1. **Deterministic inventory (facts):** every Markdown file, canonical files
   present/absent, harness adapters, SPEC lifecycle state, and the full
   `repo-doc-check` output.
2. **Semantic audit prompt (judgment):** the questions the tools cannot answer —
   source-of-truth conflicts, link/reference *intent* tracing, stale-vs-current
   classification, dangerous operational instructions, per-file disposition
   recommendations, and unknown human decisions.

> **The tool never claims to have resolved a semantic question.** Part 2 must be
> answered by an agent or human. Do not treat a clean `repo-doc-check` as proof
> the documentation is *correct* — only that it is structurally valid.

## What the deterministic tools deliberately do NOT do

- Decide which of two conflicting docs is canonical.
- Judge whether prose is stale, misleading, or dangerous.
- Follow links to external hosts or validate their contents.
- Modify, move, or delete anything.

Those are semantic-audit and human-decision responsibilities, by design (see
[MAINTENANCE.md](MAINTENANCE.md) for cadence).
