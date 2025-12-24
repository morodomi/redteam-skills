#!/bin/bash
# Test script for crypto-attacker agent
# Issue #10: OWASP 2025 Coverage - Phase 1

AGENT_FILE="plugins/redteam-core/agents/crypto-attacker.md"
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
echo "Testing crypto-attacker agent"
echo "=========================================="
echo ""

# TC-01: crypto-attacker.mdが存在する
if [ -f "$AGENT_FILE" ]; then
    pass "TC-01: crypto-attacker.md exists"
else
    fail "TC-01: crypto-attacker.md does not exist"
fi

# TC-02: YAMLフロントマターにname, description, allowed-toolsが定義されている
if [ -f "$AGENT_FILE" ]; then
    if grep -q "^name:" "$AGENT_FILE" && \
       grep -q "^description:" "$AGENT_FILE" && \
       grep -q "^allowed-tools:" "$AGENT_FILE"; then
        pass "TC-02: YAML frontmatter has name, description, allowed-tools"
    else
        fail "TC-02: YAML frontmatter missing required fields"
    fi
else
    fail "TC-02: Cannot check - file does not exist"
fi

# TC-03: Detection Targetsに5タイプが定義されている
if [ -f "$AGENT_FILE" ]; then
    TYPE_COUNT=$(grep -E "^\| (debug-enabled|weak-hash|weak-crypto|default-credentials|insecure-cors) \|" "$AGENT_FILE" | wc -l | tr -d ' ')
    if [ "$TYPE_COUNT" -ge 5 ]; then
        pass "TC-03: Detection Targets has 5 types (found $TYPE_COUNT)"
    else
        fail "TC-03: Detection Targets should have 5 types (found $TYPE_COUNT)"
    fi
else
    fail "TC-03: Cannot check - file does not exist"
fi

# TC-04: debug-enabled検出パターンが存在する
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "DEBUG|APP_DEBUG|debug.*true" "$AGENT_FILE"; then
        pass "TC-04: debug-enabled detection pattern exists"
    else
        fail "TC-04: debug-enabled detection pattern not found"
    fi
else
    fail "TC-04: Cannot check - file does not exist"
fi

# TC-05: weak-hash検出パターン（md5, sha1）が存在する
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "md5|sha1" "$AGENT_FILE"; then
        pass "TC-05: weak-hash detection patterns (md5, sha1) exist"
    else
        fail "TC-05: weak-hash detection patterns not found"
    fi
else
    fail "TC-05: Cannot check - file does not exist"
fi

# TC-06: weak-crypto検出パターン（DES, RC4, ECB）が存在する
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "DES|RC4|ECB" "$AGENT_FILE"; then
        pass "TC-06: weak-crypto detection patterns (DES, RC4, ECB) exist"
    else
        fail "TC-06: weak-crypto detection patterns not found"
    fi
else
    fail "TC-06: Cannot check - file does not exist"
fi

# TC-07: CWE Mappingセクションが存在する
if [ -f "$AGENT_FILE" ]; then
    if grep -q "CWE" "$AGENT_FILE" && grep -qE "CWE-[0-9]+" "$AGENT_FILE"; then
        pass "TC-07: CWE Mapping section exists"
    else
        fail "TC-07: CWE Mapping section not found"
    fi
else
    fail "TC-07: Cannot check - file does not exist"
fi

# TC-08: Severity Criteriaが定義されている
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "Severity|critical|high|medium|low" "$AGENT_FILE"; then
        pass "TC-08: Severity Criteria is defined"
    else
        fail "TC-08: Severity Criteria not found"
    fi
else
    fail "TC-08: Cannot check - file does not exist"
fi

echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

exit $FAILED
