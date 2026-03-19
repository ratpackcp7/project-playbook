# Task 007: Smoke Test + README

## Objective

Create an end-to-end smoke test script that proves the full playbook workflow, and write the project README with install and usage docs.

## Context

Tasks 001-006 complete. All four commands (init, task new, status, relay) are working and tested individually.

## Spec Reference

- § Command Specifications (all four commands)
- § File Tree (README.md location)

## Deliverables

- [ ] `smoke_test.sh` (in project root) — bash script with `set -euo pipefail` that runs the full workflow:
  ```
  1. Create a temp directory and cd into it
  2. Run: playbook init smoke-test-project
  3. Verify: smoke-test-project/ exists and contains PLAYBOOK.md, SPEC.md, TASKS.md, AGENT_CONTEXT.md
  4. cd smoke-test-project
  5. Run: playbook status
  6. Verify: output contains "Example" (the default task name) and "tasks complete"
  7. Run: playbook task new "Build the database"
  8. Verify: tasks/002-build-the-database.md exists
  9. Run: playbook status
  10. Verify: output contains "Build the database" and "0/2 tasks complete"
  11. Run: playbook relay 001
  12. Verify: output contains "=== AGENT CONTEXT ===" and "=== PROJECT SPEC ===" and "=== CURRENT TASK ==="
  13. Run: playbook relay 002
  14. Verify: output contains "Build the database"
  15. Run: playbook relay 999 (expect failure)
  16. Verify: exit code is non-zero
  17. Clean up temp directory
  18. Print "SMOKE TEST PASSED"
  ```
  Each verification step should print what it's checking. Use grep or test for assertions. If any step fails, `set -e` will abort and print which step failed.

- [ ] `README.md` — project documentation:
  - Project name and one-line description
  - Install instructions (clone, venv, pip install -e ".[dev]")
  - Usage section with example for each command:
    - `playbook init my-project`
    - `playbook task new "Build the API"`
    - `playbook status`
    - `playbook relay 003`
    - `playbook relay 003 --copy`
  - Development section: how to run tests (`pytest`), how to run smoke test (`bash smoke_test.sh`)
  - Brief explanation of the playbook workflow (link to PLAYBOOK.md in generated projects)
  - Note that this is a CLI tool, not a web service — no ports, no database, no config

- [ ] Run the smoke test and verify it passes
- [ ] Run `pytest` and verify all tests pass (full test suite, not just new tests)

## Acceptance Criteria

1. [ ] `bash smoke_test.sh` exits 0 and prints "SMOKE TEST PASSED"
2. [ ] `pytest -v` — ALL tests across all test files pass (full regression)
3. [ ] README.md exists with install instructions and usage examples for all 4 commands
4. [ ] README.md install instructions actually work if followed step by step

## Notes

- The smoke test is a bash script, NOT a pytest test. It tests the CLI as a user would use it — from the command line, not through Python imports.
- Make smoke_test.sh executable: `chmod +x smoke_test.sh`
- The smoke test should use `mktemp -d` for the temp directory and trap cleanup on exit.
- This is the last task. After this, commit everything and the project is ready for real use.
