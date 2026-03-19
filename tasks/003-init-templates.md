# Task 003: Init Command + Templates

## Objective

Build templates.py with all embedded markdown content and the `playbook init` command that writes those templates to a new project directory.

## Context

Tasks 001-002 complete. File structure, venv, config.py, and parser.py are working. cli.py has the Click group but no commands registered.

## Spec Reference

- § Command Specifications — playbook init
- § Template Files (list of 9 files and their canonical source)
- § CLI Architecture — Command Registration Pattern

## Deliverables

- [ ] `src/playbook/templates.py` — Python module containing a dict `TEMPLATES` mapping relative file paths to their string content. The content for each file MUST be read from the existing project-playbook repo at `/home/chris/projects/project-playbook/` and embedded as literal Python strings. Files to embed:
  - `README.md`
  - `PLAYBOOK.md`
  - `SPEC.md` (the blank template version from the repo, NOT the CLI spec)
  - `TASKS.md`
  - `AGENT_CONTEXT.md`
  - `.gitignore`
  - `tasks/_TEMPLATE.md`
  - `tasks/001-example.md`
  - `reviews/001-example.md`

- [ ] `src/playbook/commands/init.py` — Click command `init_cmd`:
  - Takes `name` as positional argument
  - Takes `--no-git` as boolean flag (default False)
  - Creates `./<name>/` directory (fail with exit code 1 if exists)
  - Writes all 9 template files from TEMPLATES dict
  - Creates `tasks/` and `reviews/` subdirectories (if not created by template writes)
  - If not `--no-git`: runs `git init -b main`, `git add -A`, `git commit -m "Initial playbook from template"` via subprocess. Exit code 2 if git fails.
  - Prints success message with rich: project name, file count, and hint to "Edit SPEC.md to get started"

- [ ] Update `src/playbook/cli.py` — uncomment/add the init import and registration:
  ```python
  from playbook.commands.init import init_cmd
  cli.add_command(init_cmd, "init")
  ```

- [ ] `tests/test_init.py` — tests:
  1. `playbook init test-project` creates directory with all 9 files in correct locations
  2. TASKS.md content in created project matches the template (spot-check: contains `| # | Task |` header)
  3. `_TEMPLATE.md` in created project contains the `NNN` placeholder
  4. `.git/` directory exists in created project (git was initialized)
  5. `playbook init test-project` when `test-project/` already exists — exits with code 1, prints error
  6. `playbook init test-project --no-git` creates project without `.git/` directory
  7. Created project is a valid playbook project: `find_project_root()` works from inside it

## Acceptance Criteria

1. [ ] `playbook init demo-project` creates a project with all 9 files
2. [ ] The content of every created file matches its source in `/home/chris/projects/project-playbook/`
3. [ ] `cd demo-project && playbook status` doesn't crash (TASKS.md is valid for the parser)
4. [ ] `pytest tests/test_init.py -v` — all tests pass
5. [ ] `playbook --help` shows the `init` command in the command list

## Notes

- Read the template files from `/home/chris/projects/project-playbook/` to get the EXACT content. Do not invent or paraphrase the markdown content.
- Use `subprocess.run` for git commands, not os.system.
- For Click test runner, use `click.testing.CliRunner` in tests.
