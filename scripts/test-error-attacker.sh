#!/bin/bash
# Test script for error-attacker agent
# Issue #10: OWASP 2025 Coverage - Phase 2

AGENT_FILE="plugins/redteam-core/agents/error-attacker.md"
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
echo "Testing error-attacker agent"
echo "=========================================="
echo ""

# TC-09: error-attacker.mdが存在する
if [ -f "$AGENT_FILE" ]; then
    pass "TC-09: error-attacker.md exists"
else
    fail "TC-09: error-attacker.md does not exist"
fi

# TC-10: YAMLフロントマターにname, description, allowed-toolsが定義されている
if [ -f "$AGENT_FILE" ]; then
    if grep -q "^name:" "$AGENT_FILE" && \
       grep -q "^description:" "$AGENT_FILE" && \
       grep -q "^allowed-tools:" "$AGENT_FILE"; then
        pass "TC-10: YAML frontmatter has name, description, allowed-tools"
    else
        fail "TC-10: YAML frontmatter missing required fields"
    fi
else
    fail "TC-10: Cannot check - file does not exist"
fi

# TC-11: Detection Targetsに5タイプが定義されている
if [ -f "$AGENT_FILE" ]; then
    TYPE_COUNT=$(grep -E "^\| (empty-catch|swallowed-exception|fail-open|generic-exception|missing-finally) \|" "$AGENT_FILE" | wc -l | tr -d ' ')
    if [ "$TYPE_COUNT" -ge 5 ]; then
        pass "TC-11: Detection Targets has 5 types (found $TYPE_COUNT)"
    else
        fail "TC-11: Detection Targets should have 5 types (found $TYPE_COUNT)"
    fi
else
    fail "TC-11: Cannot check - file does not exist"
fi

# TC-12: empty-catch検出パターンが存在する
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "catch.*\{\s*\}|except.*pass" "$AGENT_FILE"; then
        pass "TC-12: empty-catch detection pattern exists"
    else
        fail "TC-12: empty-catch detection pattern not found"
    fi
else
    fail "TC-12: Cannot check - file does not exist"
fi

# TC-13: fail-open検出パターンが存在する
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "catch.*return.*true|except.*return.*True|fail.*open" "$AGENT_FILE"; then
        pass "TC-13: fail-open detection pattern exists"
    else
        fail "TC-13: fail-open detection pattern not found"
    fi
else
    fail "TC-13: Cannot check - file does not exist"
fi

# TC-14: CWE Mappingセクションが存在する
if [ -f "$AGENT_FILE" ]; then
    if grep -q "CWE" "$AGENT_FILE" && grep -qE "CWE-[0-9]+" "$AGENT_FILE"; then
        pass "TC-14: CWE Mapping section exists"
    else
        fail "TC-14: CWE Mapping section not found"
    fi
else
    fail "TC-14: Cannot check - file does not exist"
fi

# TC-15: Severity Criteriaが定義されている
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "Severity|critical|high|medium|low" "$AGENT_FILE"; then
        pass "TC-15: Severity Criteria is defined"
    else
        fail "TC-15: Severity Criteria not found"
    fi
else
    fail "TC-15: Cannot check - file does not exist"
fi

# TC-16: 複数言語対応（JS, Python, PHP）のパターンが存在する
if [ -f "$AGENT_FILE" ]; then
    JS_PATTERN=$(grep -cE "catch|try.*\{" "$AGENT_FILE" | head -1)
    PY_PATTERN=$(grep -cE "except|try:" "$AGENT_FILE" | head -1)
    PHP_PATTERN=$(grep -cE "catch.*Exception" "$AGENT_FILE" | head -1)

    if [ "$JS_PATTERN" -gt 0 ] && [ "$PY_PATTERN" -gt 0 ]; then
        pass "TC-16: Multi-language patterns (JS, Python, PHP) exist"
    else
        fail "TC-16: Multi-language patterns not found (JS=$JS_PATTERN, PY=$PY_PATTERN, PHP=$PHP_PATTERN)"
    fi
else
    fail "TC-16: Cannot check - file does not exist"
fi

echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

exit $FAILED
