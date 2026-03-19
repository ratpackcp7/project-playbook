# Task NNN: [Title]

## Objective

_One sentence: what this task produces._

## Context

_What already exists before this task runs. Reference prior tasks if relevant._

## Spec Reference

_Point to the relevant sections of SPEC.md_

## Deliverables

_Exact files to create or modify:_

- [ ] `path/to/file.py` — description of what it contains
- [ ] `path/to/other.py` — description

## Acceptance Criteria

_How to verify this task is done correctly:_

1. [ ] Criterion 1 (e.g., "Server starts without errors on port 8000")
2. [ ] Criterion 2 (e.g., "GET /api/health returns 200")
3. [ ] Criterion 3

## Operation Order

_Specify the order of operations. Front-load cheap/critical work (imports, wiring) before expensive work (implementation, tests)._

1. [ ] Step 1
2. [ ] Step 2
3. [ ] Step 3

## Verify

```bash
# Commands to verify this task was completed correctly
# These should be runnable by the dispatcher or a verification tool
cd /path/to/project && source venv/bin/activate
pytest tests/test_thing.py -v
```

## Notes

_Any additional context, edge cases, or warnings._
