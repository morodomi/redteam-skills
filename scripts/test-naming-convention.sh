#!/bin/bash
# Test script for naming convention unification
# Issue #48

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
echo "Testing: Naming Convention Unification (Issue #48)"
echo "================================================"
echo ""

# false-positive-filter
echo "## false-positive-filter"
run_negative_test "TC-01: false-positive-filterに\`sqli\`が存在しない" \
    "grep -q 'sqli:' plugins/redteam-core/agents/false-positive-filter.md"

run_test "TC-02: false-positive-filterに\`sql-injection\`が存在する" \
    "grep -q 'sql-injection:' plugins/redteam-core/agents/false-positive-filter.md"

echo ""

# security-scan reference
echo "## security-scan reference"
run_test "TC-03: reference.mdに命名規則セクションがある" \
    "grep -q '## Naming Convention\|### Naming Convention' plugins/redteam-core/skills/security-scan/reference.md"

run_test "TC-04: reference.mdに\`vulnerability_class\`フォーマット定義がある" \
    "grep -q 'vulnerability_class.*format\|vulnerability_class.*lowercase' plugins/redteam-core/skills/security-scan/reference.md"

run_test "TC-05: reference.mdに許可された略称リストがある" \
    "grep -q 'xss.*ssrf.*csrf\|ssrf.*csrf.*xxe' plugins/redteam-core/skills/security-scan/reference.md"

echo ""

# 整合性チェック
echo "## 整合性チェック"
run_negative_test "TC-06: 全エージェントで\`sqli:\`が使用されていない" \
    "grep -r 'sqli:' plugins/redteam-core/agents/*.md | grep -v 'wp-sqli'"

run_test "TC-07: injection-attackerが\`sql-injection\`を出力する" \
    "grep -q '\"vulnerability_class\": \"sql-injection\"' plugins/redteam-core/agents/injection-attacker.md"

echo ""
echo "================================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================================"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
