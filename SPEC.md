# Project Specification — Playbook CLI

## Problem Statement

Managing the project-playbook workflow manually — creating task files, tracking status, assembling relay prompts — involves repetitive file operations and copy-paste that should be automated. The Playbook CLI is a command-line tool that automates the mechanical parts of the playbook workflow so the human can focus on architecture and review.

## Tech Stack

| Layer | Choice | Rationale |
|---|---|---|
| Language | Python 3.12+ | Already on acerserver, agent has venv support |
| CLI framework | Click 8.x | Industry standard for multi-command CLIs, clean arg parsing, auto-generated help |
| Template engine | None — string formatting | Templates are simple markdown, Jinja is overkill |
| Database | None | All state lives in markdown files in the project repo |
| Deployment | pip install -e ".[dev]" (editable) | Installed once from the playbook-cli repo, available system-wide in venv |
| Testing | pytest | Standard, agent knows it well |
| Key packages | click>=8.1, rich>=13.0 (terminal formatting) |

## File Tree

```
playbook-cli/
├── README.md
├── pyproject.toml
├── .gitignore
├── src/
│   └── playbook/
│       ├── __init__.py          # __version__ = "0.1.0", nothing else
│       ├── cli.py               # Click group + command registration via add_command()
│       ├── commands/
│       │   ├── __init__.py      # empty
│       │   ├── init.py          # playbook init <name>
│       │   ├── task.py          # playbook task new "<title>" (task is a Click group)
│       │   ├── status.py        # playbook status
│       │   └── relay.py         # playbook relay <NNN>
│       ├── config.py            # Project detection, path resolution
│       ├── parser.py            # TASKS.md parser (read-only: parse_tasks)
│       └── templates.py         # Embedded markdown templates (literal strings)
└── tests/
    ├── __init__.py              # empty
    ├── conftest.py              # Shared fixtures: tmp_project, sample TASKS.md
    ├── test_init.py
    ├── test_task.py
    ├── test_status.py
    ├── test_relay.py
    └── test_parser.py
```

**Note:** No `requirements.txt`. All dependencies are declared in `pyproject.toml`. The `[dev]` extra includes pytest.

## CLI Architecture

### Command Registration Pattern

`cli.py` defines a Click group and registers all commands using `cli.add_command()`:

```python
import click
from playbook.commands.init import init_cmd
from playbook.commands.task import task_group
from playbook.commands.status import status_cmd
from playbook.commands.relay import relay_cmd

@click.group()
@click.version_option()
def cli():
    """Project Playbook CLI — plan, task, execute, verify."""
    pass

cli.add_command(init_cmd, "init")
cli.add_command(task_group, "task")
cli.add_command(status_cmd, "status")
cli.add_command(relay_cmd, "relay")
```

### Subcommand Structure

- `playbook init <name>` — top-level command
- `playbook task new "<title>"` — `task` is a `@click.group()`, `new` is a command under it
- `playbook status` — top-level command
- `playbook relay <NNN>` — top-level command

This means `commands/task.py` exports `task_group` (a Click group), not a plain command.

## Command Specifications

### playbook init <name>

**Purpose:** Create a new project from the playbook template.

**Behavior:**
1. Create directory `./<name>/` (fail if exists)
2. Write all template files from `templates.py` — see § Template Files for the complete list
3. Create `tasks/` and `reviews/` subdirectories
4. Initialize git repo (`git init -b main`) unless `--no-git`
5. Stage and commit all files (`Initial playbook from template`) unless `--no-git`
6. Print success message with next steps

**Arguments:**
- `name` (required, positional) — project directory name

**Flags:**
- `--no-git` — skip git init/commit

**Exit codes:**
- 0: success
- 1: directory already exists
- 2: git init failed

### playbook task new <title>

**Purpose:** Create the next numbered task file.

**Behavior:**
1. Detect project root (walk up from cwd looking for PLAYBOOK.md)
2. Scan `tasks/` for highest-numbered .md file (ignore `_TEMPLATE.md`)
3. Compute next number (zero-padded to 3 digits). If no numbered files exist, start at 001.
4. Slugify title for filename: `tasks/NNN-slug.md`
5. Read `_TEMPLATE.md` content, replace `NNN` with actual number and `[Title]` with provided title
6. Write the new task file
7. Append row to TASKS.md table: `| NNN | Title | \x60[ ]\x60 | — | |` (status MUST be backtick-wrapped)
8. Print path to created file

**Arguments:**
- `title` (required, positional) — human-readable task title

**Exit codes:**
- 0: success
- 1: not in a playbook project (PLAYBOOK.md not found)
- 2: _TEMPLATE.md missing

**Slugify rules:** lowercase, spaces to hyphens, strip non-alphanumeric except hyphens, collapse multiple hyphens, strip leading/trailing hyphens, max 50 chars.

### playbook status

**Purpose:** Show the current task queue with status indicators.

**Behavior:**
1. Detect project root
2. Parse TASKS.md table rows
3. Display formatted output using Rich:
   - Project name (from directory name)
   - Each task with color-coded status:
     - `[ ]` → dim white, label "TODO"
     - `[>]` → yellow, label "IN PROGRESS"
     - `[✓]` → green, label "DONE"
     - `[!]` → red, label "FAILED"
     - `[~]` → dim + strikethrough, label "SKIPPED"
   - Summary line: "3/7 tasks complete"

**Exit codes:**
- 0: success
- 1: not in a playbook project
- 2: TASKS.md parse error

### playbook relay <NNN>

**Purpose:** Assemble a complete relay prompt for a specific task.

**Behavior:**
1. Detect project root
2. Read AGENT_CONTEXT.md (full contents)
3. Read SPEC.md (full contents)
4. Find task file matching NNN in `tasks/` directory
5. Read task file (full contents)
6. Assemble prompt (see § Relay Prompt Format)
7. Print assembled prompt to stdout
8. Print character count and word count to stderr

**Arguments:**
- `NNN` (required, positional) — task number (with or without zero-padding, e.g., "3" or "003")

**Flags:**
- `--copy` — attempt to copy prompt to clipboard using `xclip -selection clipboard`. If xclip is not available, fall back to printing to stdout and print a warning to stderr: "Warning: xclip not found, printing to stdout instead"

**Exit codes:**
- 0: success
- 1: not in a playbook project
- 2: task file not found
- 3: SPEC.md or AGENT_CONTEXT.md missing

### Relay Prompt Format

```
=== AGENT CONTEXT ===

{contents of AGENT_CONTEXT.md}

=== PROJECT SPEC ===

{contents of SPEC.md}

=== CURRENT TASK ===

{contents of tasks/NNN-*.md}

=== INSTRUCTIONS ===

Execute the task above. Follow the spec exactly.

If you encounter a conflict, ambiguity, or something that seems wrong:
1. Document the concern at the top of your output
2. Complete the task as spec'd anyway
3. Do not improvise alternatives unless the spec is impossible to follow

When done, provide your output in this format:

## CONCERNS (if any)
- [describe any spec conflicts, ambiguities, or issues]

## FILES MODIFIED
- path/to/file.py (created/modified)

## VERIFICATION
- [what you tested and results]

## STATUS
COMPLETE | BLOCKED (reason)
```

## Data Models

No database. All state is in markdown files.

### TASKS.md Table Format (parsed by parser.py)

```
| # | Task | Status | Depends On | Notes |
|---|---|---|---|---|
| 001 | Scaffold | `[ ]` | — | File structure, deps, config |
```

**Parser rules:**
- Skip the header row (first row starting with `| #`)
- Skip the separator row (contains `|---|`)
- Skip empty rows
- Status values are always backtick-wrapped: `[ ]`, `[>]`, `[✓]`, `[!]`, `[~]`
- Parser must strip backticks when reading, all writers must add backticks when writing
- Columns are pipe-delimited with variable whitespace (strip each cell)

**parse_tasks() return format:**
```python
[
    {"number": "001", "task": "Scaffold", "status": "[ ]", "depends_on": "—", "notes": "File structure, deps, config"},
    ...
]
```

Status values in the returned dicts do NOT include backticks (stripped on read).

### Task Filename Format

Pattern: `NNN-slug.md` where NNN is zero-padded 3-digit number.
Match regex: `^(\d{3})-(.+)\.md$`
Ignore: `_TEMPLATE.md`

## Template Files

The `init` command creates these 9 files. The **canonical source** for template content is the `ratpackcp7/project-playbook` repository on GitHub. `templates.py` must embed the content of these files as Python string constants:

1. `README.md` — from project-playbook/README.md
2. `PLAYBOOK.md` — from project-playbook/PLAYBOOK.md
3. `SPEC.md` — from project-playbook/SPEC.md (the blank template version, NOT this CLI spec)
4. `TASKS.md` — from project-playbook/TASKS.md
5. `AGENT_CONTEXT.md` — from project-playbook/AGENT_CONTEXT.md
6. `.gitignore` — from project-playbook/.gitignore
7. `tasks/_TEMPLATE.md` — from project-playbook/tasks/_TEMPLATE.md
8. `tasks/001-example.md` — from project-playbook/tasks/001-example.md
9. `reviews/001-example.md` — from project-playbook/reviews/001-example.md

The agent executing the templates task MUST read these files from the project-playbook repo (located at `/home/chris/projects/project-playbook/`) and embed their exact content.

## External Dependencies

| Package | Version | Purpose |
|---|---|---|
| click | >=8.1.0 | CLI framework |
| rich | >=13.0.0 | Terminal formatting and colors |
| pytest | >=7.0.0 | Testing (dev dependency only) |

No external services. No network calls. No API keys.

## pyproject.toml Structure

```toml
[build-system]
requires = ["setuptools>=68.0"]
build-backend = "setuptools.backends._legacy:_Backend"

[project]
name = "playbook-cli"
version = "0.1.0"
description = "CLI tool for the project playbook workflow"
requires-python = ">=3.12"
dependencies = [
    "click>=8.1.0",
    "rich>=13.0.0",
]

[project.optional-dependencies]
dev = ["pytest>=7.0.0"]

[project.scripts]
playbook = "playbook.cli:cli"

[tool.setuptools.packages.find]
where = ["src"]
```

## Environment

No environment variables required. No config files. No ports.

The CLI detects its project context by walking up from the current working directory looking for `PLAYBOOK.md`. This is the project root marker.

## Constraints

- **No network access needed** — purely local file operations
- **No database** — state lives in markdown
- **Agent runs as claude-agent (uid 1001, no sudo)** on acerserver
- **xclip is NOT installed on the execution host** — `--copy` must degrade gracefully
- **The agent must create the venv** — `python -m venv venv && source venv/bin/activate && pip install -e ".[dev]"`
- **pyproject.toml handles everything** — no requirements.txt
- **Template source repo** is at `/home/chris/projects/project-playbook/` on acerserver

## Design Decisions Log

1. **Click over argparse** — argparse requires manual subcommand wiring and help formatting. Click handles this declaratively.
2. **Rich over plain print** — status display with color-coding is the whole point of the status command. Rich is lightweight.
3. **No auto-relay in v1** — coupling to claude_code_relay.sh adds failure modes we haven't mapped. Print the prompt, let the human decide how to dispatch. Add --send in v2.
4. **Embedded templates over reading from template repo at runtime** — the CLI should be self-contained. templates.py embeds the content so init works without the template repo being present.
5. **Project detection by walking up** — matches how git works. PLAYBOOK.md is the sentinel file.
6. **No config file** — zero configuration. Everything is inferred from directory structure.
7. **`task` as Click group** — enables `playbook task new` now and future subcommands (`playbook task done 003`, `playbook task list`) without restructuring.
8. **No requirements.txt** — pyproject.toml is the single source of truth for dependencies. requirements.txt would be redundant and could drift.
9. **parse_tasks strips backticks, all writers add backticks** — single normalization point. Parser always returns clean status strings, writers always format for markdown.
10. **conftest.py provides shared fixtures** — tmp_project fixture creates a temp directory with valid playbook structure for all command tests to use.
