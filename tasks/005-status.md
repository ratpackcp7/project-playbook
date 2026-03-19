# Task 005: Status Command

## Objective

Build the `playbook status` command that displays a color-coded task queue from TASKS.md.

## Context

Tasks 001-004 complete. CLI has `init` and `task` commands working. config.py, parser.py (with parse_tasks and append_task_row), and templates.py are complete.

## Spec Reference

- § Command Specifications — playbook status (color mapping, summary line)

## Deliverables

- [ ] `src/playbook/commands/status.py` — Click command `status_cmd`:
  - Calls `find_project_root()` (exit 1 if not found)
  - Calls `parse_tasks()` on TASKS.md
  - Uses Rich Console to display:
    - Header: project name (directory name of project root) in bold
    - Each task as a line: `  NNN  Title ................. STATUS_LABEL`
    - Status colors and labels:
      - `[ ]` → dim white, "TODO"
      - `[>]` → yellow, "IN PROGRESS"
      - `[✓]` → green, "DONE"
      - `[!]` → red, "FAILED"
      - `[~]` → dim + strikethrough, "SKIPPED"
    - Summary: "X/Y tasks complete" where complete = status `[✓]`
  - Exit 1 if not in project, exit 2 if TASKS.md can't be parsed (catch parse exceptions)

- [ ] Update `src/playbook/cli.py` — add status import and registration:
  ```python
  from playbook.commands.status import status_cmd
  cli.add_command(status_cmd, "status")
  ```

- [ ] `tests/test_status.py` — tests using tmp_project fixture:
  1. Status with 1 task (from default fixture) — output contains task number and name, shows "0/1 tasks complete"
  2. Status with 3 tasks (mixed: `[ ]`, `[✓]`, `[!]`) — shows "1/3 tasks complete", each status label appears correctly
  3. Status with 0 tasks (empty TASKS.md, just header) — shows "0/0 tasks complete", no crash
  4. Status outside a playbook project — exits with code 1
  5. Status output contains the project directory name as header

Use `click.testing.CliRunner` for command tests. For Rich output testing, use `rich.console.Console(file=io.StringIO())` or capture CliRunner output and check for status label text (e.g., "TODO", "DONE") rather than ANSI codes.

## Acceptance Criteria

1. [ ] `playbook status` in a project with tasks shows formatted output with task names and status labels
2. [ ] Summary line correctly counts only `[✓]` status as complete
3. [ ] `pytest tests/test_status.py -v` — all tests pass
4. [ ] `playbook --help` shows `status` in command list

## Notes

- Do NOT try to test ANSI color codes directly. Test for the presence of status label text ("TODO", "DONE", etc.) in the captured output.
- Rich's Console can write to a StringIO for testing: `Console(file=stringio, force_terminal=False)`. Use `force_terminal=False` to get plain text without ANSI codes in tests.
