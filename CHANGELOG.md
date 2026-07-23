# Changelog

All notable changes to this project will be documented in this file.

## 2026-07-22 - repository-documentation-standard v1.0.0
**What:** Added the CP7 Reusable Repository Documentation Standard under
`docs/standards/repository-documentation/` (STANDARD, TERMINOLOGY, ADOPTION,
AUDIT, MAINTENANCE, PROJECT-INVENTORY, 8 templates, minimal-tree example) plus
`scripts/repo-doc-check`, `scripts/repo-doc-audit`, and fixture tests under
`scripts/repo-doc-tests/`. Generalized from the Empower documentation model.
**Why:** Give every CP7 repo a reusable, agent-agnostic documentation standard
with a deterministic read-only checker, without copying Empower-specific details.
**Verification:** `bash scripts/repo-doc-tests/run-tests.sh` (11/11 PASS);
`python3 -m py_compile` on both tools; `git diff --check`.
**Scope:** standard + tooling + inventory only — no other project migrated.
**Agent:** Claude Code (Opus 4.8)
**Standard version:** 1.0.0

## 2026-05-06 - Agent standards compliance
**What:** Added missing AGENTS.md sections (Purpose, Architecture, Agents and Crons, Gotchas, Decisions) and created CHANGELOG.md to comply with CP7 Agent Operating Standard v1.
**Why:** Project was missing required standard sections and had no change log.
**Verification:** Ran `/home/chris/cp7-bridge/scripts/verify_agent_standards.sh /home/chris/projects/project-playbook` and confirmed compliance.
**Agent:** Claude
