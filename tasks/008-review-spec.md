# Task 008: Review-Spec Command — Core Implementation

## Objective

Add the `playbook review-spec` command that sends SPEC.md + TASKS.md to three LLM models via OpenRouter for independent adversarial review.

## Context

Tasks 001-007 complete. playbook-cli v0.1.0 has 4 commands (init, task new, status, relay), 38 tests. This adds a 5th command.

## Spec Reference

This is a NEW feature. Full specification follows.

## Design

### Command: `playbook review-spec`

**Behavior:**
1. Detect project root via find_project_root()
2. Read SPEC.md and TASKS.md from project root
3. Load review config: check for `.playbook-review.json` in project root, fall back to built-in defaults
4. For each model in the panel, send a POST to OpenRouter API with the adversarial review prompt
5. Write each response to `reviews/spec-review-{model-slug}.md`
6. Print summary to terminal: model name, issue count (count lines starting with `- ` or numbered items in the response), cost estimate

**Default model panel (built-in, no config file needed):**
```python
DEFAULT_MODELS = [
    {"id": "google/gemini-2.5-pro", "name": "Gemini 2.5 Pro", "slug": "gemini", "role": "Architect"},
    {"id": "deepseek/deepseek-chat", "name": "DeepSeek V3.2", "slug": "deepseek", "role": "Practitioner"},
    {"id": "qwen/qwen3-235b-a22b-instruct", "name": "Qwen3 235B", "slug": "qwen", "role": "Contrarian"},
]
```

**`.playbook-review.json` override format (optional):**
```json
{
    "openrouter_api_key_env": "OPENROUTER_API_KEY",
    "models": [
        {"id": "google/gemini-2.5-pro", "name": "Gemini 2.5 Pro", "slug": "gemini", "role": "Architect"}
    ]
}
```

**API key:** Read from `OPENROUTER_API_KEY` environment variable. Exit with error if not set.

**OpenRouter API call (per model):**
```
POST https://openrouter.ai/api/v1/chat/completions
Headers:
  Authorization: Bearer {api_key}
  Content-Type: application/json
  HTTP-Referer: https://github.com/ratpackcp7/playbook-cli
Body:
{
  "model": "{model_id}",
  "max_tokens": 4000,
  "messages": [
    {"role": "system", "content": "You are a critical technical reviewer..."},
    {"role": "user", "content": "{spec + tasks content}"}
  ]
}
```

**Adversarial review prompt (system message):**
```
You are a critical technical reviewer. You are reviewing a project specification and task breakdown that will be executed by an autonomous coding agent (Claude Code). The agent follows instructions literally and cannot ask clarifying questions.

Your job is to find every issue that would cause the agent to produce wrong code, make wrong assumptions, or get stuck. Be brutally critical. Focus on:

1. Gaps or ambiguities that would cause wrong assumptions
2. Missing acceptance criteria
3. Dependency ordering problems
4. Interface mismatches between tasks (function signatures, data formats)
5. Things that sound good in theory but will break in practice
6. Python packaging, config, or tooling gotchas

Do NOT be polite. List every issue you find. Number each issue. For each issue, state: what's wrong, why it matters, and how to fix it.
```

**User message:**
```
## PROJECT SPECIFICATION

{contents of SPEC.md}

## TASK BREAKDOWN

{contents of TASKS.md}
```

**Output file format (`reviews/spec-review-{slug}.md`):**
```
# Spec Review — {model_name} ({role})

**Model:** {model_id}
**Date:** {iso date}
**Input tokens:** ~{estimate}
**Estimated cost:** ${estimate}

---

{model response}
```

**Terminal summary (using Rich):**
```
Spec Review Complete

  Gemini 2.5 Pro (Architect)    — 12 issues  ~$0.03
  DeepSeek V3.2 (Practitioner)  —  8 issues  ~$0.002
  Qwen3 235B (Contrarian)       — 15 issues  ~$0.01

  Total estimated cost: ~$0.04
  Reviews written to reviews/
```

**Flags:**
- `--model <id>` — run only one specific model instead of the full panel (for testing/cost control)
- `--dry-run` — show what would be sent (prompt + model list) without making API calls

**Exit codes:**
- 0: success
- 1: not in a playbook project
- 2: OPENROUTER_API_KEY not set
- 3: SPEC.md or TASKS.md missing
- 4: API call failed (print error details)

## Deliverables

- [ ] Add `httpx>=0.27.0` to pyproject.toml dependencies
- [ ] Create `src/playbook/commands/review.py` — the review_spec_cmd Click command
- [ ] Create `src/playbook/reviewer.py` — OpenRouter API client, model panel config, prompt assembly, response parsing
- [ ] Update `src/playbook/cli.py` — add review-spec command registration
- [ ] `reviews/` directory created if it doesn't exist when writing output

## Operation Order

1. Update pyproject.toml (add httpx)
2. Run `pip install -e ".[dev]"` to install httpx
3. Create src/playbook/reviewer.py (API client + config)
4. Create src/playbook/commands/review.py (Click command)
5. Update cli.py (import + register)
6. Manual test with --dry-run if possible

## Acceptance Criteria

1. [ ] `pip install -e ".[dev]"` succeeds with httpx installed
2. [ ] `playbook --help` shows `review-spec` in command list
3. [ ] `playbook review-spec --help` shows --model and --dry-run flags
4. [ ] `playbook review-spec --dry-run` prints the prompt and model list without making API calls
5. [ ] The adversarial prompt matches the spec exactly (copy it verbatim)
6. [ ] Default model panel has all 3 models with correct OpenRouter IDs
7. [ ] reviewer.py handles API errors gracefully (timeout, rate limit, bad key) with descriptive error messages

## Notes

- Use httpx (not requests) — it's modern, async-capable (we use sync for now), and lighter.
- Cost estimation: count words in the prompt, estimate ~1.3 tokens per word for input. For output, assume 2500 tokens. Use the model's published rates.
- The response from OpenRouter is OpenAI-compatible: `response["choices"][0]["message"]["content"]`
- Do NOT make real API calls during this task. Just build the code. Testing with real calls happens in Task 009.
- Issue counting heuristic: count lines matching `^\d+\.` or `^- ` in the model's response. This is approximate and that's fine.
