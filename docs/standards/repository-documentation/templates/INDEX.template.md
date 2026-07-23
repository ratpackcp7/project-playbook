# Documentation Index

The map of this repo's documentation. If a doc exists and matters, it is listed
here. New Markdown files must be added here (or exempted in `.repo-doc.json`).

## Sources of truth

| Topic | Canonical file |
|---|---|
| Agent instructions | `AGENTS.md` |
| Human overview | `README.md` |
| Active work | `HANDOFF.md` (only while work is in flight) |
| Backlog | `ROADMAP.md` |
| <topic> | `<file>` |

## Directory map

- `docs/decisions/` — ADRs (why non-obvious choices exist).
- `docs/specs/active/` — in-flight specifications (each has a `Status:`).
- `docs/specs/completed/` — shipped specifications.
- `docs/specs/archive/` — historical / superseded (labeled historical).
- `<dir>` — <purpose>.

## Archive policy

Anything no longer current truth moves to an archive location and is explicitly
labeled historical, or is left as a tombstone stub pointing to its replacement.
Nothing load-bearing is deleted outright.
