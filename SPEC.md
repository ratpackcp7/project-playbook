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
| Deployment | pip install -e . (editable) | Installed once from the playbook-cli repo, available system-wide in venv |
| Testing | pytest | Standard, agent knows it well |
| Key packages | click>=8.1, rich>=13.0 (terminal formatting) |

## File Tree

```
playbook-cli/
├── README.md
├── pyproject.toml
├── requirements.txt
├── .gitignore
├── src/
│   └── playbook/
│       ├── __init__.py
│       ├── cli.py              # Click group + command definitions
│       ├── commands/
│       │   ├── __init__.py
│       │   ├── init.py         # playbook init <name>
│       │   ├── task.py         # playbook task new "<title>"
│       │   ├── status.py       # playbook status
│       │   └── relay.py        # playbook relay <NNN>
│       ├── config.py           # Project detection, path resolution
│       ├── parser.py           # TASKS.md parser (read/write status)
│       └── templates.py        # Embedded markdown templates
└── tests/
    ├── __init__.py
    ├── conftest.py             # Fixtures: temp project dirs, sample files
    ├── test_init.py
    ├── test_task.py
    ├── test_status.py
    ├── test_relay.py
    └── test_parser.py
```

## Command Specifications

### playbook init <name>

**Purpose:** Create a new project from the playbook template.

**Behavior:**
1. Create directory `./<name>/` (fail if exists)
2. Write all template files: README.md, PLAYBOOK.md, SPEC.md, TASKS.md, AGENT_CONTEXT.md, .gitignore, tasks/_TEMPLATE.md, tasks/001-example.md, reviews/001-example.md
3. Initialize git repo (`git init -b main`)
4. Stage and commit all files (`Initial playbook from template`)
5. Print success message with next steps

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
2. Scan `tasks/` for highest-numbered .md file (ignore _TEMPLATE.md)
3. Compute next number (zero-padded to 3 digits)
4. Slugify title for filename: `tasks/NNN-slug.md`
5. Copy _TEMPLATE.md content, replace `NNN` with actual number and `[Title]` with provided title
6. Append row to TASKS.md table: `| NNN | Title | [ ] | — | |`
7. Print path to created file

**Arguments:**
- `title` (required, positional) — human-readable task title

**Exit codes:**
- 0: success
- 1: not in a playbook project (PLAYBOOK.md not found)
- 2: _TEMPLATE.md missing

**Slugify rules:** lowercase, spaces to hyphens, strip non-alphanumeric except hyphens, max 50 chars.

### playbook status

**Purpose:** Show the current task queue with status indicators.

**Behavior:**
1. Detect project root
2. Parse TASKS.md table rows
3. Display formatted output using Rich:
   - Project name (from directory name)
   - Each task with color-coded status: green=done, yellow=in-progress, red=failed, dim=not started, strikethrough=skipped
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
6. Assemble prompt in this exact format:

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

7. Print assembled prompt to stdout
8. Print character/word count to stderr (so it doesn't pollute the prompt if piped)

**Arguments:**
- `NNN` (required, positional) — task number (with or without zero-padding)

**Flags:**
- `--copy` — copy prompt to clipboard (xclip/xsel if available) instead of printing

**Exit codes:**
- 0: success
- 1: not in a playbook project
- 2: task file not found
- 3: SPEC.md or AGENT_CONTEXT.md missing

## Data Models

No database. All state is in markdown files.

### TASKS.md Table Format (parsed by parser.py)

```
| # | Task | Status | Depends On | Notes |
|---|---|---|---|---|
| 001 | Scaffold | `[ ]` | — | File structure, deps, config |
```

Parser must handle:
- Status values: `[ ]`, `[>]`, `[✓]`, `[!]`, `[~]`
- Backtick-wrapped status codes
- Pipe-delimited columns with variable whitespace
- Header row and separator row (skip both)
- Empty rows (skip)

### Task Filename Format

Pattern: `NNN-slug.md` where NNN is zero-padded 3-digit number.
Match regex: `^(\d{3})-(.+)\.md$`
Ignore: `_TEMPLATE.md`

## External Dependencies

| Package | Version | Purpose |
|---|---|---|
| click | >=8.1.0 | CLI framework |
| rich | >=13.0.0 | Terminal formatting and colors |

No external services. No network calls. No API keys.

## Environment

No environment variables required. No config files. No ports.

The CLI detects its project context by walking up from the current working directory looking for `PLAYBOOK.md`. This is the project root marker.

## Constraints

- **No network access needed** — purely local file operations
- **No database** — state lives in markdown
- **Agent can't test clipboard** — `--copy` flag on relay is best-effort, don't block on it
- **Agent must create the venv** — `python -m venv venv && source venv/bin/activate && pip install -e ".[dev]"`
- **pyproject.toml handles install** — use setuptools with `[project.scripts]` for the `playbook` entry point

## Design Decisions Log

1. **Click over argparse** — argparse requires manual subcommand wiring and help formatting. Click handles this declaratively. Every serious Python CLI uses Click.
2. **Rich over plain print** — status display with color-coding is the whole point of the status command. Rich is lightweight and the agent knows it well.
3. **No auto-relay in v1** — coupling to claude_code_relay.sh adds failure modes we haven't mapped. Print the prompt, let the human decide how to dispatch. Add --send in v2.
4. **Embedded templates over reading from template repo** — the CLI should be self-contained. Copying _TEMPLATE.md content into templates.py means init works without network access or a reference repo.
5. **Project detection by walking up** — matches how git works (find .git). User can be in any subdirectory and commands still work. PLAYBOOK.md is the sentinel file.
6. **No config file for the CLI itself** — zero configuration. Everything is inferred from the project directory structure. Less to break, less to document.
