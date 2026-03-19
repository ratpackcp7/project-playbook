# Task 002: Config + Parser

## Objective

Build the project-detection utility and the TASKS.md read-only parser, with shared test fixtures.

## Context

Task 001 completed: file structure exists, venv works, `playbook --help` runs. No commands registered yet.

## Spec Reference

- § Environment — project detection by walking up looking for PLAYBOOK.md
- § Data Models — TASKS.md Table Format, parser rules, parse_tasks() return format

## Deliverables

- [ ] `src/playbook/config.py` — two functions:
  - `find_project_root(start_path: Path = None) -> Path` — walks up from start_path (default: cwd) looking for a directory containing PLAYBOOK.md. Returns the Path to that directory. Raises `click.ClickException("Not a playbook project (PLAYBOOK.md not found)")` if it hits filesystem root without finding one.
  - `get_project_paths(root: Path) -> dict` — returns dict with keys: "root", "spec", "agent_context", "tasks_md", "tasks_dir", "reviews_dir" pointing to the expected file/dir paths.

- [ ] `src/playbook/parser.py` — one function:
  - `parse_tasks(tasks_md_path: Path) -> list[dict]` — reads TASKS.md, skips header row (starts with `| #`), skips separator row (contains `|---|`), skips empty rows. For each data row: splits on `|`, strips whitespace from each cell, strips backticks from the status cell. Returns list of dicts with keys: "number", "task", "status", "depends_on", "notes". Status values in returned dicts do NOT include backticks.

- [ ] `tests/conftest.py` — shared fixtures:
  - `tmp_project(tmp_path)` — creates a valid playbook project structure in a temp dir: PLAYBOOK.md (can be minimal, just needs to exist), SPEC.md, AGENT_CONTEXT.md, TASKS.md (with valid header + separator + one example row: `| 001 | Example | \x60[ ]\x60 | — | test |`), tasks/ dir with _TEMPLATE.md (use content from SPEC.md § Template Files description), reviews/ dir. Returns the Path to the temp project root.

- [ ] `tests/test_parser.py` — tests for parse_tasks:
  1. Parse TASKS.md with 1 row — returns list with 1 dict, correct keys/values, status has no backticks
  2. Parse TASKS.md with 3 rows with mixed statuses (`[ ]`, `[✓]`, `[!]`) — returns 3 dicts with correct statuses
  3. Parse TASKS.md with 0 data rows (just header + separator) — returns empty list
  4. Parse TASKS.md with extra whitespace in cells — values are stripped clean
  5. Parse TASKS.md with empty rows between data rows — empty rows are skipped

- [ ] `tests/test_config.py` (new file) — tests for config:
  1. `find_project_root` from project root — returns that directory
  2. `find_project_root` from a subdirectory (e.g., tasks/) — returns parent project root
  3. `find_project_root` from a directory with no PLAYBOOK.md anywhere above — raises ClickException
  4. `get_project_paths` — returns dict with all expected keys, all paths are relative to root

## Acceptance Criteria

1. [ ] `pytest tests/test_parser.py tests/test_config.py -v` — all tests pass
2. [ ] `parse_tasks` correctly strips backticks from status values
3. [ ] `find_project_root` works from subdirectories (not just project root)
4. [ ] `find_project_root` raises ClickException (not generic Exception) when not in a project

## Notes

- parser.py is READ-ONLY in this task. It only parses. The "append row" functionality will be built in Task 004 alongside the command that uses it.
- Use `click.ClickException` for user-facing errors so Click handles the error display and exit code.
- The test file is test_config.py (not test_init.py) to avoid confusion with the init command tests in Task 003.
