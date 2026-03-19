# Task 004: Task New Command

## Objective

Build the `playbook task new "<title>"` command that auto-creates numbered task files and appends to TASKS.md.

## Context

Tasks 001-003 complete. CLI has the Click group with `init` registered. config.py and parser.py (read-only) are working. templates.py has all embedded content.

## Spec Reference

- § Command Specifications — playbook task new
- § CLI Architecture — `task` is a Click group, `new` is a subcommand
- § Data Models — TASKS.md Table Format (backtick-wrapped status), Task Filename Format, Slugify rules

## Deliverables

- [ ] `src/playbook/commands/task.py` — exports `task_group` (a `@click.group()`), with `new` as a subcommand:
  - `task_group` is a Click group with help text "Manage project tasks."
  - `new_cmd` takes `title` as positional argument
  - Calls `find_project_root()` to detect project (exit 1 if not found)
  - Scans `tasks/` dir for files matching `^(\d{3})-(.+)\.md$`, finds highest number, increments. If none found, starts at 001.
  - Slugifies title: lowercase, replace spaces with hyphens, strip non-alphanumeric except hyphens, collapse multiple hyphens, strip leading/trailing hyphens, truncate to 50 chars
  - Reads `tasks/_TEMPLATE.md`, replaces `NNN` with zero-padded number, replaces `[Title]` with the original title (not slugified)
  - Writes new file to `tasks/NNN-slug.md`
  - Appends row to TASKS.md: `| NNN | Title | \x60[ ]\x60 | — | |` — status MUST be backtick-wrapped
  - Prints path to created file

- [ ] Add `append_task_row(tasks_md_path: Path, number: str, title: str)` function to `src/playbook/parser.py`:
  - Opens TASKS.md, appends a new row at the end: `| {number} | {title} | \x60[ ]\x60 | — | |`
  - Ensures there's a newline before the new row if the file doesn't end with one
  - Status is ALWAYS backtick-wrapped

- [ ] Update `src/playbook/cli.py` — add task_group import and registration:
  ```python
  from playbook.commands.task import task_group
  cli.add_command(task_group, "task")
  ```

- [ ] `tests/test_task.py` — tests using tmp_project fixture:
  1. `playbook task new "Build the API"` in a project with 001-example.md — creates `tasks/002-build-the-api.md`, file contains "Task 002" and "Build the API"
  2. Created task file has the _TEMPLATE.md structure with NNN and [Title] replaced
  3. TASKS.md now has a new row with `002`, `Build the API`, and backtick-wrapped `[ ]` status
  4. `parse_tasks()` on the updated TASKS.md returns both the original and new row
  5. `playbook task new "First Task"` in a project with NO numbered files in tasks/ (only _TEMPLATE.md) — creates `tasks/001-first-task.md`
  6. Slugify edge cases: title with special chars `"Hello, World! (v2)"` → `hello-world-v2`, title with multiple spaces `"  too   many  spaces  "` → `too-many-spaces`
  7. Running from a subdirectory (e.g., `tasks/`) still works (find_project_root walks up)
  8. Running outside a playbook project — exits with code 1

## Acceptance Criteria

1. [ ] `playbook task new "My Task"` creates correctly numbered task file
2. [ ] TASKS.md row uses backtick-wrapped status: `\x60[ ]\x60` (not bare `[ ]`)
3. [ ] `playbook status` correctly displays the new task after creation (round-trip proof)
4. [ ] `pytest tests/test_task.py -v` — all tests pass
5. [ ] `playbook --help` shows `task` in command list, `playbook task --help` shows `new`

## Notes

- The `task` command is a Click GROUP, not a plain command. `new` is a subcommand. This is critical for the CLI to parse `playbook task new "title"` correctly.
- The slugify function should be a standalone helper (not buried in the command) so it's testable. Put it in commands/task.py or in a utils module.
- append_task_row goes in parser.py to keep all TASKS.md I/O in one module, even though parser.py was read-only in Task 002.
