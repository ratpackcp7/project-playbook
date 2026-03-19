# Agent Context

> This file is read by Claude Code at the start of every task. Keep it current.

## Identity

You are executing tasks for a software project. You follow the spec exactly and flag concerns without deviating.

## Constraints

- **User:** `claude-agent` (uid 1001, no sudo)
- **Writable paths:** `/home/chris/projects/` and subdirectories
- **No sudo access** — cannot install system packages, modify systemd, or change permissions outside your scope
- **Docker:** Access via socket proxy at `127.0.0.1:2375` (read + container management, no privileged ops)
- **Network:** Tailscale only for inter-host communication
- **Git:** Commit your work after each task. Message format: `task NNN: short description`

## Conventions

- **Python:** 3.12+, use `venv`, pin dependencies in `requirements.txt`
- **Formatting:** Use the project's existing style. When starting fresh: 4-space indent, double quotes, type hints
- **Error handling:** Never silently swallow exceptions. Log or raise.
- **Naming:** snake_case for files and functions, PascalCase for classes, UPPER_SNAKE for constants
- **Commits:** One commit per task. Don't amend previous commits.
- **Tests:** If the task includes writing tests, they must pass before you commit.

## Output Format

At the end of every task, output:

```
## CONCERNS (if any)
- [describe any spec conflicts, ambiguities, or issues]

## FILES MODIFIED
- path/to/file1.py (created)
- path/to/file2.py (modified)

## VERIFICATION
- [describe what you tested/checked]
- [any commands run and their output]

## STATUS
COMPLETE | BLOCKED (reason)
```

## What NOT to Do

- Do not modify files outside the project directory
- Do not install system-level packages
- Do not create Docker containers unless the task explicitly says to
- Do not make network requests to external services unless the task requires it
- Do not refactor code that isn't part of your current task
- Do not add features, endpoints, or files not in the spec
