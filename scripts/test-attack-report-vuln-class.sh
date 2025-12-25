#!/bin/bash

# Test script for Issue #21: attack-report vulnerability_class活用
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

REPORT_REF="plugins/redteam-core/skills/attack-report/reference.md"

echo "=========================================="
echo "Testing attack-report vulnerability_class"
echo "=========================================="

# TC-00: Test script exists (meta test)
if [[ -f "scripts/test-attack-report-vuln-class.sh" ]]; then
    pass "TC-00: test-attack-report-vuln-class.sh exists"
else
    fail "TC-00: test-attack-report-vuln-class.sh exists"
fi

# TC-01: Input Schema has schema_version field
if grep -A 20 "Input Schema" "$REPORT_REF" 2>/dev/null | grep -q "schema_version"; then
    pass "TC-01: Input Schema has schema_version field"
else
    fail "TC-01: Input Schema has schema_version field"
fi

# TC-02: Input Schema has vulnerability_class field
if grep -A 40 "Input Schema" "$REPORT_REF" 2>/dev/null | grep -q "vulnerability_class"; then
    pass "TC-02: Input Schema has vulnerability_class field"
else
    fail "TC-02: Input Schema has vulnerability_class field"
fi

# TC-03: Input Schema has cwe_id field
if grep -A 40 "Input Schema" "$REPORT_REF" 2>/dev/null | grep -q "cwe_id"; then
    pass "TC-03: Input Schema has cwe_id field"
else
    fail "TC-03: Input Schema has cwe_id field"
fi

# TC-04: CVSS table has ssrf entry
if grep -E "^\| ssrf " "$REPORT_REF" 2>/dev/null | grep -q "CVSS"; then
    pass "TC-04: CVSS table has ssrf entry"
else
    fail "TC-04: CVSS table has ssrf entry"
fi

# TC-05: CVSS table has path-traversal entry
if grep -E "^\| path-traversal " "$REPORT_REF" 2>/dev/null | grep -q "CVSS"; then
    pass "TC-05: CVSS table has path-traversal entry"
else
    fail "TC-05: CVSS table has path-traversal entry"
fi

# TC-06: CVSS table has lfi entry
if grep -E "^\| lfi " "$REPORT_REF" 2>/dev/null | grep -q "CVSS"; then
    pass "TC-06: CVSS table has lfi entry"
else
    fail "TC-06: CVSS table has lfi entry"
fi

# TC-07: CVSS table has arbitrary-file-upload entry
if grep -E "^\| arbitrary-file-upload " "$REPORT_REF" 2>/dev/null | grep -q "CVSS"; then
    pass "TC-07: CVSS table has arbitrary-file-upload entry"
else
    fail "TC-07: CVSS table has arbitrary-file-upload entry"
fi

# TC-08: CWE/OWASP table has ssrf (CWE-918)
if grep -E "^\| ssrf " "$REPORT_REF" 2>/dev/null | grep -q "CWE-918"; then
    pass "TC-08: CWE/OWASP table has ssrf (CWE-918)"
else
    fail "TC-08: CWE/OWASP table has ssrf (CWE-918)"
fi

# TC-09: CWE/OWASP table has path-traversal (CWE-22)
if grep -E "^\| path-traversal " "$REPORT_REF" 2>/dev/null | grep -q "CWE-22"; then
    pass "TC-09: CWE/OWASP table has path-traversal (CWE-22)"
else
    fail "TC-09: CWE/OWASP table has path-traversal (CWE-22)"
fi

# TC-10: Agent to Type Mapping is maintained
if grep -q "Agent to Type Mapping" "$REPORT_REF" 2>/dev/null; then
    pass "TC-10: Agent to Type Mapping is maintained"
else
    fail "TC-10: Agent to Type Mapping is maintained"
fi

# TC-11: file-attacker default type is defined
if grep -A 10 "Agent to Type Mapping" "$REPORT_REF" 2>/dev/null | grep -q "file-attacker"; then
    pass "TC-11: file-attacker default type is defined"
else
    fail "TC-11: file-attacker default type is defined"
fi

# TC-12: ssrf-attacker default type is defined
if grep -A 15 "Agent to Type Mapping" "$REPORT_REF" 2>/dev/null | grep -q "ssrf-attacker"; then
    pass "TC-12: ssrf-attacker default type is defined"
else
    fail "TC-12: ssrf-attacker default type is defined"
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
