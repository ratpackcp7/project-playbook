# Task 009: Review-Spec Tests + Live Verification

## Objective

Write tests for the review-spec command and verify it works with real OpenRouter API calls.

## Context

Task 008 complete. review-spec command built with reviewer.py (API client) and commands/review.py (Click command). httpx installed. No real API calls made yet.

## Deliverables

- [ ] `tests/test_review.py` — tests using tmp_project fixture:
  1. `playbook review-spec --dry-run` — exits 0, output contains all 3 model names, output contains "DRY RUN" indicator, output contains SPEC.md content
  2. `playbook review-spec` outside a playbook project — exits with code 1
  3. `playbook review-spec` with no OPENROUTER_API_KEY env var — exits with code 2, error message mentions the env var
  4. `playbook review-spec` with SPEC.md deleted — exits with code 3
  5. `playbook review-spec --model google/gemini-2.5-pro --dry-run` — only shows 1 model, not all 3
  6. Mock test: patch httpx.Client.post to return a fake OpenRouter response, verify review file is written to reviews/spec-review-{slug}.md with correct format
  7. Mock test: patch httpx.Client.post to raise httpx.ConnectError, verify graceful error handling (exit 4, descriptive message)

For mocking, use `unittest.mock.patch` on the httpx post method. Fake response format:
```python
{"choices": [{"message": {"content": "1. Issue one\n2. Issue two\n3. Issue three"}}], "usage": {"prompt_tokens": 3000, "completion_tokens": 500}}
```

- [ ] `pytest -v` — full test suite passes (all previous + new tests)

## Live Verification (manual, after tests pass)

Run a real review against the playbook-cli's own SPEC.md with ONE model to verify end-to-end:
```bash
cd /home/chris/projects/playbook-cli
source venv/bin/activate
export OPENROUTER_API_KEY=$(grep OPENROUTER /home/chris/.openclaw/.env | cut -d= -f2)
playbook review-spec --model deepseek/deepseek-chat
```

DeepSeek is cheapest (~$0.002). Verify:
- reviews/spec-review-deepseek.md is created
- File contains the model's critical review
- Terminal shows issue count and cost estimate

## Acceptance Criteria

1. [ ] `pytest tests/test_review.py -v` — all tests pass
2. [ ] `pytest -v` — full suite passes (no regressions)
3. [ ] Live test with DeepSeek produces a real review file
4. [ ] Cost of live test reported

## Notes

- Only use ONE model for the live test to keep costs minimal (DeepSeek ~$0.002)
- The OpenRouter API key is in /home/chris/.openclaw/.env as OPENROUTER_API_KEY or similar. Check the file for the exact variable name.
- If the key var name is different (e.g., OPENROUTER_KEY), adapt accordingly.
