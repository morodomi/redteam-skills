#!/bin/bash

# Test script for Issue #20: Command Injection対応追加
# Expected: All tests FAIL in RED phase (except TC-00)

PASS=0
FAIL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    ((PASS++))
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    ((FAIL++))
}

INJECTION_MD="plugins/redteam-core/agents/injection-attacker.md"
REPORT_REF="plugins/redteam-core/skills/attack-report/reference.md"

echo "=========================================="
echo "Testing Command Injection Implementation"
echo "=========================================="

# TC-00: Test script exists (meta test)
if [[ -f "scripts/test-command-injection.sh" ]]; then
    pass "TC-00: test-command-injection.sh exists"
else
    fail "TC-00: test-command-injection.sh exists"
fi

# TC-01: Detection Targets has command-injection
if grep -A 10 "Detection Targets" "$INJECTION_MD" 2>/dev/null | grep -qi "command"; then
    pass "TC-01: Detection Targets has command-injection"
else
    fail "TC-01: Detection Targets has command-injection"
fi

# TC-02: Dangerous Patterns has exec pattern
if grep -A 50 "Command Injection" "$INJECTION_MD" 2>/dev/null | grep -q "exec"; then
    pass "TC-02: Dangerous Patterns has exec pattern"
else
    fail "TC-02: Dangerous Patterns has exec pattern"
fi

# TC-03: Dangerous Patterns has shell_exec pattern
if grep -A 50 "Command Injection" "$INJECTION_MD" 2>/dev/null | grep -qi "shell_exec"; then
    pass "TC-03: Dangerous Patterns has shell_exec pattern"
else
    fail "TC-03: Dangerous Patterns has shell_exec pattern"
fi

# TC-04: Dangerous Patterns has system pattern
if grep -A 50 "Command Injection" "$INJECTION_MD" 2>/dev/null | grep -q "system"; then
    pass "TC-04: Dangerous Patterns has system pattern"
else
    fail "TC-04: Dangerous Patterns has system pattern"
fi

# TC-05: Safe Patterns section exists
if grep -q "Safe Patterns" "$INJECTION_MD" 2>/dev/null; then
    pass "TC-05: Safe Patterns section exists"
else
    fail "TC-05: Safe Patterns section exists"
fi

# TC-06: CWE/OWASP Mapping has CWE-78
if grep -q "CWE-78" "$INJECTION_MD" 2>/dev/null; then
    pass "TC-06: CWE/OWASP Mapping has CWE-78"
else
    fail "TC-06: CWE/OWASP Mapping has CWE-78"
fi

# TC-07: OWASP reference is A05:2025
if grep -q "A05:2025" "$INJECTION_MD" 2>/dev/null; then
    pass "TC-07: OWASP reference is A05:2025"
else
    fail "TC-07: OWASP reference is A05:2025"
fi

# TC-08: CVSS table has command-injection
if grep -E "^\| command-injection " "$REPORT_REF" 2>/dev/null | grep -q "CVSS"; then
    pass "TC-08: CVSS table has command-injection"
else
    fail "TC-08: CVSS table has command-injection"
fi

# TC-09: CWE/OWASP table has command-injection (CWE-78)
if grep -E "^\| command-injection " "$REPORT_REF" 2>/dev/null | grep -q "CWE-78"; then
    pass "TC-09: CWE/OWASP table has command-injection (CWE-78)"
else
    fail "TC-09: CWE/OWASP table has command-injection (CWE-78)"
fi

# TC-10: Output example has CMD-xxx format ID
if grep -q "CMD-" "$INJECTION_MD" 2>/dev/null; then
    pass "TC-10: Output example has CMD-xxx format ID"
else
    fail "TC-10: Output example has CMD-xxx format ID"
fi

echo ""
echo "=========================================="
echo "Results: $PASS passed, $FAIL failed"
echo "=========================================="

# Exit with failure if any test failed
if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
