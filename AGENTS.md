# AGENTS.md — Project Playbook

## Purpose

Template repository for planning and executing software projects using a human-architect + AI-agent workflow.

Defines the spec → task → build → verify methodology used across cp7 projects. The `playbook-cli` tool consumes this template to scaffold new projects with the standard file structure and conventions.

## Key Facts

- This is a **TEMPLATE repo** — not a running service, no port, no deployment
- Defines the spec → task → build → verify workflow used across cp7 projects
- Used by `playbook-cli` to scaffold new projects
- This repo is read-only for agents — do not modify the template without discussing with Chris
- One commit per task

## Architecture

```
project-playbook/
├── SPEC.md          # Full feature specification methodology
├── TASKS.md         # Task list with status tracking
├── PLAYBOOK.md      # Workflow rules and conventions (phases, gates, failure protocol)
├── AGENT_CONTEXT.md # What the AI agent needs to know (constraints, conventions, output format)
├── AGENTS.md        # This file — project orientation for agents
├── HANDOFF.md       # Current work status and next steps
├── README.md        # Human-facing project overview
├── tasks/           # Individual task files (T001.md, T002.md, ...)
│   ├── _TEMPLATE.md # Copy this for each new task
│   └── 001-example.md
├── reviews/         # Review outputs
├── docs/
│   └── decisions/   # ADR directory (ADR-template.md, README.md)
└── src/             # Source code (empty initially, populated by playbook-cli)
```

Key files:
- `SPEC.md` — Defines the architecture, data models, API contracts, file tree for new projects
- `PLAYBOOK.md` — The process: Phase 1 (Architecture), Phase 2 (Task Breakdown), Phase 3 (Execute), Phase 4 (Verify), plus Failure Protocol
- `AGENT_CONTEXT.md` — Constraints (no sudo, Docker socket proxy, writable paths), conventions (Python 3.12+, venv, formatting), output format
- `tasks/_TEMPLATE.md` — Template for creating new task files
- `TASKS.md` — Tracks task queue with status indicators (`[ ]`, `[>]`, `[✓]`, `[!]`, `[~]`)

What the template generates for new projects:
```
project-name/
├── SPEC.md          # Full feature specification
├── TASKS.md         # Task list with status tracking
├── PLAYBOOK.md      # Workflow rules and conventions
├── AGENT_CONTEXT.md # What the AI agent needs to know
├── AGENTS.md        # File inventory for agent reference
├── tasks/           # Individual task files
├── reviews/         # Review outputs
└── src/             # Source code (empty initially)
```

## Agents and Crons

None.

## Gotchas

None.

## Active Work

See `HANDOFF.md` for current work status and next steps.

## Decisions

See `docs/decisions/`. No ADRs exist yet.

## Before You Start
- Read `SPEC.md` for the full playbook methodology and conventions
- Read `AGENT_CONTEXT.md` for coding conventions the agent should follow

## How `playbook-cli` uses this template

The `playbook init` command copies this template, replaces placeholder names, and initializes the `tasks/` directory. The resulting project follows the methodology defined in `SPEC.md`.

## Workflow

1. **Human** writes `SPEC.md` (full feature spec)
2. **Agent** generates `TASKS.md` from the spec
3. **Human** reviews and approves tasks
4. **Agent** executes tasks one at a time, updating status
5. **Human** reviews completed work
6. **Agent** runs `playbook verify` to confirm spec compliance

<!-- CP7-AGENT-STANDARDS:START -->

## CP7 Agent Standard

Before behavior changes, read `/home/chris/cp7-bridge/docs/agent-standards/AGENT-OPERATING-STANDARD.md`, this project's README/HANDOFF, and `docs/decisions/`.

Create or update an ADR for changes to ports, bind addresses, tunnels, Docker Compose, volumes, healthchecks, systemd, timers, persistent data paths, MCP tools, auth, allowlists, writable roots, or unusual config.

Every change report must include what changed, why, verification, rollback, and touched files/services.

Verifier:

```bash
/home/chris/cp7-bridge/scripts/verify_agent_standards.sh
```

<!-- CP7-AGENT-STANDARDS:END -->
