# Task Queue

## Status Key

- `[ ]` — Not started
- `[>]` — In progress (relayed to agent)
- `[✓]` — Completed and verified
- `[!]` — Failed / needs revision
- `[~]` — Skipped (no longer needed)

## Tasks

| # | Task | Status | Depends On | Notes |
|---|---|---|---|---|
| 001 | Scaffold + Minimal CLI | `[✓]` | — | pyproject.toml, src/ layout, venv, playbook --help works |
| 002 | Config + Parser | `[✓]` | 001 | find_project_root, parse_tasks, conftest fixtures |
| 003 | Init Command + Templates | `[✓]` | 002 | templates.py from project-playbook repo, init command |
| 004 | Task New Command | `[✓]` | 003 | task group, new subcommand, slugify, append_task_row |
| 005 | Status Command | `[✓]` | 004 | Rich formatted output, color-coded statuses |
| 006 | Relay Command | `[✓]` | 002 | Assemble prompt from project files, print to stdout |
| 007 | Smoke Test + README | `[ ]` | 006 | End-to-end bash test, project documentation |
