#!/bin/bash

# Test script for Issue #19: csrf-attacker CSRF検出エージェント
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

CSRF_MD="plugins/redteam-core/agents/csrf-attacker.md"
REPORT_REF="plugins/redteam-core/skills/attack-report/reference.md"

echo "=========================================="
echo "Testing CSRF Attacker Implementation"
echo "=========================================="

# TC-00: Test script exists (meta test)
if [[ -f "scripts/test-csrf-attacker.sh" ]]; then
    pass "TC-00: test-csrf-attacker.sh exists"
else
    fail "TC-00: test-csrf-attacker.sh exists"
fi

# TC-01: File exists
if [[ -f "$CSRF_MD" ]]; then
    pass "TC-01: csrf-attacker.md exists"
else
    fail "TC-01: csrf-attacker.md exists"
fi

# TC-02: YAML frontmatter (name, description, allowed-tools)
if grep -q "^name:" "$CSRF_MD" 2>/dev/null && \
   grep -q "^description:" "$CSRF_MD" 2>/dev/null && \
   grep -q "^allowed-tools:" "$CSRF_MD" 2>/dev/null; then
    pass "TC-02: YAML frontmatter exists"
else
    fail "TC-02: YAML frontmatter exists"
fi

# TC-03: Detection Targets section exists
if grep -q "## Detection Targets" "$CSRF_MD" 2>/dev/null; then
    pass "TC-03: Detection Targets section exists"
else
    fail "TC-03: Detection Targets section exists"
fi

# TC-04: csrf-token-missing pattern exists
if grep -qi "csrf-token-missing\|token.*missing" "$CSRF_MD" 2>/dev/null; then
    pass "TC-04: csrf-token-missing pattern exists"
else
    fail "TC-04: csrf-token-missing pattern exists"
fi

# TC-05: csrf-protection-disabled pattern exists
if grep -qi "csrf.*disabled\|protection.*disabled\|csrf_exempt\|skip.*verify" "$CSRF_MD" 2>/dev/null; then
    pass "TC-05: csrf-protection-disabled pattern exists"
else
    fail "TC-05: csrf-protection-disabled pattern exists"
fi

# TC-06: Framework Detection Patterns table exists
if grep -q "Framework Detection Patterns\|Framework.*Pattern" "$CSRF_MD" 2>/dev/null; then
    pass "TC-06: Framework Detection Patterns table exists"
else
    fail "TC-06: Framework Detection Patterns table exists"
fi

# TC-07: Dangerous Patterns section exists
if grep -q "## Dangerous Patterns\|Dangerous Patterns" "$CSRF_MD" 2>/dev/null; then
    pass "TC-07: Dangerous Patterns section exists"
else
    fail "TC-07: Dangerous Patterns section exists"
fi

# TC-08: Output Format section exists
if grep -q "## Output Format" "$CSRF_MD" 2>/dev/null; then
    pass "TC-08: Output Format section exists"
else
    fail "TC-08: Output Format section exists"
fi

# TC-09: CSRF-xxx format ID exists
if grep -q "CSRF-" "$CSRF_MD" 2>/dev/null; then
    pass "TC-09: CSRF-xxx format ID exists"
else
    fail "TC-09: CSRF-xxx format ID exists"
fi

# TC-10: CWE-352 reference exists
if grep -q "CWE-352" "$CSRF_MD" 2>/dev/null; then
    pass "TC-10: CWE-352 reference exists"
else
    fail "TC-10: CWE-352 reference exists"
fi

# TC-11: A01:2025 reference exists
if grep -q "A01:2025" "$CSRF_MD" 2>/dev/null; then
    pass "TC-11: A01:2025 reference exists"
else
    fail "TC-11: A01:2025 reference exists"
fi

# TC-12: CVSS table has csrf
if grep -E "^\| csrf " "$REPORT_REF" 2>/dev/null | grep -q "CVSS"; then
    pass "TC-12: CVSS table has csrf"
else
    fail "TC-12: CVSS table has csrf"
fi

# TC-13: Agent to Type Mapping has csrf-attacker
if grep -q "csrf-attacker" "$REPORT_REF" 2>/dev/null; then
    pass "TC-13: Agent to Type Mapping has csrf-attacker"
else
    fail "TC-13: Agent to Type Mapping has csrf-attacker"
fi

# TC-14: CWE/OWASP table has csrf (CWE-352)
if grep -E "^\| csrf " "$REPORT_REF" 2>/dev/null | grep -q "CWE-352"; then
    pass "TC-14: CWE/OWASP table has csrf (CWE-352)"
else
    fail "TC-14: CWE/OWASP table has csrf (CWE-352)"
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
