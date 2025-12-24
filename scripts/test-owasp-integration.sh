#!/bin/bash
# Test script for OWASP 2025 Integration (Phase 3)
# Issue #10: security-scan / attack-report integration

SECURITY_SCAN_SKILL="plugins/redteam-core/skills/security-scan/SKILL.md"
SECURITY_SCAN_REF="plugins/redteam-core/skills/security-scan/reference.md"
ATTACK_REPORT_REF="plugins/redteam-core/skills/attack-report/reference.md"

PASSED=0
FAILED=0

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    ((FAILED++))
}

echo "=========================================="
echo "Testing OWASP 2025 Integration"
echo "=========================================="
echo ""

# TC-17: security-scan SKILL.mdにcrypto-attacker統合
if grep -q "crypto-attacker" "$SECURITY_SCAN_SKILL"; then
    pass "TC-17: security-scan SKILL.md has crypto-attacker"
else
    fail "TC-17: security-scan SKILL.md missing crypto-attacker"
fi

# TC-18: security-scan SKILL.mdにerror-attacker統合
if grep -q "error-attacker" "$SECURITY_SCAN_SKILL"; then
    pass "TC-18: security-scan SKILL.md has error-attacker"
else
    fail "TC-18: security-scan SKILL.md missing error-attacker"
fi

# TC-19: security-scan reference.mdに新エージェント追加
if grep -q "crypto-attacker" "$SECURITY_SCAN_REF" && grep -q "error-attacker" "$SECURITY_SCAN_REF"; then
    pass "TC-19: security-scan reference.md has new agents"
else
    fail "TC-19: security-scan reference.md missing new agents"
fi

# TC-20: attack-report reference.mdに新CVSSマッピング追加（10件）
CVSS_COUNT=$(grep -cE "debug-enabled|weak-hash|weak-crypto|default-credentials|insecure-cors|empty-catch|swallowed-exception|fail-open|generic-exception|missing-finally" "$ATTACK_REPORT_REF" | head -1)
if [ "$CVSS_COUNT" -ge 10 ]; then
    pass "TC-20: attack-report has new CVSS mappings (found $CVSS_COUNT)"
else
    fail "TC-20: attack-report missing CVSS mappings (found $CVSS_COUNT, expected 10+)"
fi

# TC-21: attack-report reference.mdに新CWEマッピング追加（10件）
CWE_COUNT=$(grep -cE "CWE-489|CWE-328|CWE-327|CWE-1392|CWE-942|CWE-390|CWE-391|CWE-636|CWE-396|CWE-404" "$ATTACK_REPORT_REF" | head -1)
if [ "$CWE_COUNT" -ge 10 ]; then
    pass "TC-21: attack-report has new CWE mappings (found $CWE_COUNT)"
else
    fail "TC-21: attack-report missing CWE mappings (found $CWE_COUNT, expected 10+)"
fi

# TC-22: attack-report reference.mdにAgent to Type Mapping追加
if grep -q "crypto-attacker" "$ATTACK_REPORT_REF" && grep -q "error-attacker" "$ATTACK_REPORT_REF"; then
    pass "TC-22: attack-report has Agent to Type Mapping"
else
    fail "TC-22: attack-report missing Agent to Type Mapping"
fi

echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

exit $FAILED
