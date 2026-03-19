# Task 001: Scaffold + Minimal CLI

## Objective

Create the project file structure, pyproject.toml, venv, and a minimal Click CLI so that `playbook --help` works.

## Context

Starting from an empty project. This is the foundation everything else builds on.

## Spec Reference

- § File Tree (full directory layout)
- § Tech Stack
- § pyproject.toml Structure (use this exactly)
- § CLI Architecture — Command Registration Pattern

## Deliverables

- [ ] `pyproject.toml` — copy the exact structure from SPEC.md § pyproject.toml Structure
- [ ] `.gitignore` — Python standard: __pycache__, *.pyc, .env, venv/, .venv/, *.egg-info/, dist/, build/, .pytest_cache/
- [ ] `src/playbook/__init__.py` — contains only `__version__ = "0.1.0"`
- [ ] `src/playbook/cli.py` — Click group with `@click.version_option()`, no commands registered yet (just the group and the `if __name__` block). Use the exact pattern from SPEC.md § CLI Architecture but with placeholder imports commented out.
- [ ] `src/playbook/commands/__init__.py` — empty file
- [ ] `src/playbook/config.py` — empty file with docstring: `"""Project detection and path resolution."""`
- [ ] `src/playbook/parser.py` — empty file with docstring: `"""TASKS.md parser."""`
- [ ] `src/playbook/templates.py` — empty file with docstring: `"""Embedded markdown templates."""`
- [ ] `tests/__init__.py` — empty file
- [ ] `tests/conftest.py` — empty file with docstring: `"""Shared test fixtures."""`
- [ ] Virtual environment created at `venv/`, dependencies installed

## Acceptance Criteria

1. [ ] All files from § File Tree exist (empty placeholder files for modules not yet implemented)
2. [ ] `python -m venv venv && source venv/bin/activate && pip install -e ".[dev]"` succeeds with no errors
3. [ ] `playbook --help` prints Click help text including the group docstring "Project Playbook CLI"
4. [ ] `playbook --version` prints "0.1.0"
5. [ ] `python -c "from playbook import __version__; print(__version__)"` prints "0.1.0"
6. [ ] `pytest` runs and exits 0 (no tests to collect yet is fine, no errors)

## Notes

- The pyproject.toml `[project.scripts]` entry point must be `playbook = "playbook.cli:cli"` — this is the most common failure point with src/ layout.
- Do NOT create requirements.txt. pyproject.toml is the single source of truth.
- Comment out the command imports in cli.py (they don't exist yet). Add a comment: `# Commands registered in tasks 003-006`
