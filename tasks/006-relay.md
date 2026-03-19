# Task 006: Relay Command

## Objective

Build the `playbook relay <NNN>` command that assembles a complete relay prompt from project files and prints it to stdout.

## Context

Tasks 001-005 complete. CLI has `init`, `task`, and `status` commands. All core modules (config, parser, templates) are working.

## Spec Reference

- § Command Specifications — playbook relay (behavior, arguments, flags, exit codes)
- § Relay Prompt Format (exact template)

## Deliverables

- [ ] `src/playbook/commands/relay.py` — Click command `relay_cmd`:
  - Takes `task_number` as positional argument (string — user may pass "3" or "003")
  - Takes `--copy` as boolean flag (default False)
  - Calls `find_project_root()` (exit 1 if not found)
  - Reads AGENT_CONTEXT.md — exit 3 with message if missing
  - Reads SPEC.md — exit 3 with message if missing
  - Finds task file: zero-pad task_number to 3 digits, glob `tasks/{padded}*.md` in tasks dir. Exit 2 if no match found.
  - Assembles prompt using exact format from SPEC.md § Relay Prompt Format:
    - `=== AGENT CONTEXT ===` section
    - `=== PROJECT SPEC ===` section
    - `=== CURRENT TASK ===` section
    - `=== INSTRUCTIONS ===` section with the standard instructions block
  - If `--copy`: attempt `subprocess.run(["xclip", "-selection", "clipboard"], input=prompt)`. If xclip not found (FileNotFoundError), fall back to printing to stdout and print warning to stderr: `"Warning: xclip not found, printing to stdout instead"`
  - If not `--copy`: print prompt to stdout
  - Always print to stderr: `"--- {word_count} words, {char_count} chars ---"`

- [ ] Update `src/playbook/cli.py` — add relay import and registration:
  ```python
  from playbook.commands.relay import relay_cmd
  cli.add_command(relay_cmd, "relay")
  ```

- [ ] `tests/test_relay.py` — tests using tmp_project fixture:
  1. `playbook relay 001` — stdout contains all three section headers ("=== AGENT CONTEXT ===", "=== PROJECT SPEC ===", "=== CURRENT TASK ===", "=== INSTRUCTIONS ===")
  2. `playbook relay 001` — stdout contains the content of AGENT_CONTEXT.md from the fixture
  3. `playbook relay 001` — stdout contains the content of the task file (001-example.md)
  4. `playbook relay 1` (no zero-padding) — works the same as `playbook relay 001`
  5. `playbook relay 999` (nonexistent task) — exits with code 2
  6. Relay in a project with SPEC.md deleted — exits with code 3
  7. Relay in a project with AGENT_CONTEXT.md deleted — exits with code 3
  8. `playbook relay 001 --copy` on a system without xclip — falls back to stdout output (no crash), warning on stderr
  9. Word count and char count appear on stderr (not stdout — verify by checking CliRunner output separation or by checking the prompt doesn't contain the count line)

## Acceptance Criteria

1. [ ] `playbook relay 001` prints a well-formed prompt with all 4 sections
2. [ ] The prompt contains actual file content, not placeholders
3. [ ] Zero-padding normalization works (both "1" and "001" find the same task)
4. [ ] `--copy` without xclip degrades to stdout + stderr warning (no crash, no traceback)
5. [ ] `pytest tests/test_relay.py -v` — all tests pass
6. [ ] `playbook --help` shows `relay` in command list

## Notes

- The relay prompt is printed to stdout so it can be piped: `playbook relay 003 | pbcopy` or similar. The word/char count goes to stderr so it doesn't pollute the pipe.
- For CliRunner testing, stderr and stdout can be separated in Click tests. If that's difficult, at minimum verify the section headers and content are present in the combined output.
- Exit codes must be distinct: 1=not in project, 2=task not found, 3=missing spec files. Use `sys.exit()` or `raise SystemExit()` for non-1 exit codes since click.ClickException always exits 1.
