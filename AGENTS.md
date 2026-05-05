# CLAUDE.md — Project Playbook

Template repository for planning and executing software projects using a human-architect + AI-agent workflow. Defines the spec → task → build → verify methodology.

## Before You Start
- Read `SPEC.md` for the full playbook methodology and conventions
- Read `AGENT_CONTEXT.md` for coding conventions the agent should follow

## Key Facts
- This is a **TEMPLATE repo** — not a running service, no port, no deployment
- Defines the spec → task → build → verify workflow used across cp7 projects
- Used by `playbook-cli` to scaffold new projects

## What the template generates

Directory structure for a new project:
```
project-name/
├── SPEC.md          # Full feature specification
├── TASKS.md         # Task list with status tracking
├── PLAYBOOK.md      # Workflow rules and conventions
├── AGENT_CONTEXT.md # What the AI agent needs to know
├── AGENTS.md        # File inventory for agent reference
├── tasks/           # Individual task files (T001.md, T002.md, ...)
├── reviews/         # Review outputs
└── src/             # Source code (empty initially)
```

## How `new-project.sh` uses it

The `playbook init` command (from `playbook-cli`) copies this template, replaces placeholder names, and initializes the `tasks/` directory. The resulting project follows the methodology defined in `SPEC.md`.

## Workflow

1. **Human** writes `SPEC.md` (full feature spec)
2. **Agent** generates `TASKS.md` from the spec
3. **Human** reviews and approves tasks
4. **Agent** executes tasks one at a time, updating status
5. **Human** reviews completed work
6. **Agent** runs `playbook verify` to confirm spec compliance

## Rules
- This repo is read-only for agents — do not modify the template without discussing with Chris
- One commit per task

## Active Work

See `HANDOFF.md` for current work status and next steps.

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
