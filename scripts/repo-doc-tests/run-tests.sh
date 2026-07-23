#!/usr/bin/env bash
# run-tests.sh — fixture tests for repo-doc-check / repo-doc-audit.
#
# Read-only: runs the tools against fixture repos under ./fixtures and asserts
# the expected PASS/FAIL result. No network, no mutation, no dependencies
# beyond bash + python3. Exits 0 when all cases pass, 1 otherwise.
set -euo pipefail

HERE="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
SCRIPTS="$(cd "$HERE/.." && pwd)"
CHECK="$SCRIPTS/repo-doc-check"
AUDIT="$SCRIPTS/repo-doc-audit"
FIX="$HERE/fixtures"

pass=0
fail=0

# assert_result <fixture> <expected-exit> <label>
assert_result() {
  local fx="$1" want="$2" label="$3" rc=0
  python3 "$CHECK" --root "$FIX/$fx" >/dev/null 2>&1 || rc=$?
  if [[ "$rc" -eq "$want" ]]; then
    echo "PASS: $label ($fx -> exit $rc)"
    pass=$((pass + 1))
  else
    echo "FAIL: $label ($fx -> exit $rc, wanted $want)"
    echo "----- full output -----"
    python3 "$CHECK" --root "$FIX/$fx" || true
    echo "-----------------------"
    fail=$((fail + 1))
  fi
}

echo "== repo-doc-check --help =="
python3 "$CHECK" --help >/dev/null && echo "PASS: check --help" && pass=$((pass + 1)) \
  || { echo "FAIL: check --help"; fail=$((fail + 1)); }

echo "== repo-doc-audit --help =="
python3 "$AUDIT" --help >/dev/null && echo "PASS: audit --help" && pass=$((pass + 1)) \
  || { echo "FAIL: audit --help"; fail=$((fail + 1)); }

echo "== fixture cases =="
assert_result valid-minimal        0 "valid minimal project passes"
assert_result missing-canonical    1 "missing canonical AGENTS.md fails"
assert_result broken-link          1 "broken relative link fails"
assert_result missing-spec-status  1 "active SPEC without Status: fails"
assert_result oversized-handoff    1 "oversized HANDOFF fails when configured"
assert_result thin-adapter         0 "thin adapter referencing AGENTS.md passes"
assert_result bad-adapter          1 "adapter not referencing AGENTS.md fails"
assert_result forbidden-name       1 "uncontrolled filename fails"

echo "== repo-doc-audit smoke (read-only, no mutation) =="
before="$(find "$FIX/valid-minimal" -type f | sort | xargs sha256sum 2>/dev/null | sha256sum)"
python3 "$AUDIT" --root "$FIX/valid-minimal" >/dev/null
after="$(find "$FIX/valid-minimal" -type f | sort | xargs sha256sum 2>/dev/null | sha256sum)"
if [[ "$before" == "$after" ]]; then
  echo "PASS: audit made no changes to the fixture"
  pass=$((pass + 1))
else
  echo "FAIL: audit modified the fixture"
  fail=$((fail + 1))
fi

echo "----"
echo "result: $pass passed, $fail failed"
[[ "$fail" -eq 0 ]] || exit 1
echo "result: PASS"
