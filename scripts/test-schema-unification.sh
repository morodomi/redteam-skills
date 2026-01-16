#!/bin/bash
# Test script for schema unification
# Issue #47

PASSED=0
FAILED=0

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

run_test() {
    local test_name="$1"
    local test_cmd="$2"

    if eval "$test_cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}: $test_name"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC}: $test_name"
        ((FAILED++))
    fi
}

# Negative test (should NOT match)
run_negative_test() {
    local test_name="$1"
    local test_cmd="$2"

    if eval "$test_cmd" > /dev/null 2>&1; then
        echo -e "${RED}FAIL${NC}: $test_name"
        ((FAILED++))
    else
        echo -e "${GREEN}PASS${NC}: $test_name"
        ((PASSED++))
    fi
}

echo "================================================"
echo "Testing: Schema Unification (Issue #47)"
echo "================================================"
echo ""

# security-scan
echo "## security-scan"
run_test "TC-01: security-scan SKILL.mdに\`summary\`がある" \
    "grep -q '\"summary\"' plugins/redteam-core/skills/security-scan/SKILL.md"

run_test "TC-02: security-scan SKILL.mdに\`vulnerabilities\`配列がある" \
    "grep -q '\"vulnerabilities\": \[' plugins/redteam-core/skills/security-scan/SKILL.md"

run_negative_test "TC-03: security-scan SKILL.mdに\`details\`が存在しない" \
    "grep -q '\"details\"' plugins/redteam-core/skills/security-scan/SKILL.md"

run_test "TC-04: security-scan reference.mdに\`summary\`がある" \
    "grep -q '\"summary\"' plugins/redteam-core/skills/security-scan/reference.md"

echo ""

# attack-report
echo "## attack-report"
run_test "TC-05: attack-report SKILL.mdに\`vulnerabilities\`配列がある" \
    "grep -q '\"vulnerabilities\"' plugins/redteam-core/skills/attack-report/SKILL.md"

run_negative_test "TC-06: attack-report SKILL.mdに\`details\`が存在しない" \
    "grep -q '\"details\"' plugins/redteam-core/skills/attack-report/SKILL.md"

echo ""

# generate-e2e
echo "## generate-e2e"
run_test "TC-07: generate-e2e SKILL.mdに\`vulnerabilities\`配列がある" \
    "grep -q '\"vulnerabilities\"' plugins/redteam-core/skills/generate-e2e/SKILL.md"

run_negative_test "TC-08: generate-e2e SKILL.mdに\`details\`が存在しない" \
    "grep -q '\"details\"' plugins/redteam-core/skills/generate-e2e/SKILL.md"

echo ""

# dynamic-verifier
echo "## dynamic-verifier"
run_negative_test "TC-09: dynamic-verifier.mdに\`details\`が存在しない" \
    "grep -q '\"details\"' plugins/redteam-core/agents/dynamic-verifier.md"

echo ""

# README
echo "## README"
run_test "TC-10: README.mdに\`summary\`がある" \
    "grep -q '\"summary\"' README.md"

run_negative_test "TC-11: README.mdに\`details\`が存在しない" \
    "grep -q '\"details\"' README.md"

echo ""
echo "================================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================================"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
