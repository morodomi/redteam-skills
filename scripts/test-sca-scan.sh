#!/bin/bash
#
# Test: sca-scan integration in security-scan
#
# TC-01: security-scan SKILL.mdにsca-attackerが記載されている
# TC-02: SCAN Phaseにsca-attackerが追加されている
# TC-03: Agent Integrationテーブルにsca-attackerがある
# TC-04: --no-sca オプションがOptionsに記載されている
# TC-05: Output FormatにSCAセクションがある
# TC-06: 既存のattacker（injection/xss/crypto/error）が残っている
# TC-07: 既存のオプション（--dynamic等）が残っている
# TC-08: Usage例にSCA関連の説明がある

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_FILE="$PROJECT_ROOT/plugins/redteam-core/skills/security-scan/SKILL.md"

PASSED=0
FAILED=0

# Test helper
test_case() {
    local tc_id="$1"
    local description="$2"
    local result="$3"

    if [ "$result" = "0" ]; then
        echo "✓ $tc_id: $description"
        ((PASSED++))
    else
        echo "✗ $tc_id: $description"
        ((FAILED++))
    fi
}

echo "================================"
echo "sca-scan Integration Test"
echo "================================"
echo ""

# TC-01: security-scan SKILL.mdにsca-attackerが記載されている
if [ -f "$SKILL_FILE" ] && grep -q "sca-attacker" "$SKILL_FILE" 2>/dev/null; then
    test_case "TC-01" "security-scan SKILL.mdにsca-attackerが記載されている" 0
else
    test_case "TC-01" "security-scan SKILL.mdにsca-attackerが記載されている" 1
fi

# TC-02: SCAN Phaseにsca-attackerが追加されている
if [ -f "$SKILL_FILE" ] && grep -A 10 "SCAN Phase" "$SKILL_FILE" 2>/dev/null | grep -q "sca-attacker"; then
    test_case "TC-02" "SCAN Phaseにsca-attackerが追加されている" 0
else
    test_case "TC-02" "SCAN Phaseにsca-attackerが追加されている" 1
fi

# TC-03: Agent Integrationテーブルにsca-attackerがある
if [ -f "$SKILL_FILE" ] && grep -A 20 "Agent Integration" "$SKILL_FILE" 2>/dev/null | grep -q "sca-attacker"; then
    test_case "TC-03" "Agent Integrationテーブルにsca-attackerがある" 0
else
    test_case "TC-03" "Agent Integrationテーブルにsca-attackerがある" 1
fi

# TC-04: --no-sca オプションがOptionsに記載されている
if [ -f "$SKILL_FILE" ] && grep -q "\-\-no-sca" "$SKILL_FILE" 2>/dev/null; then
    test_case "TC-04" "--no-sca オプションがOptionsに記載されている" 0
else
    test_case "TC-04" "--no-sca オプションがOptionsに記載されている" 1
fi

# TC-05: Output FormatにSCAセクションがある
if [ -f "$SKILL_FILE" ] && grep -q '"sca"' "$SKILL_FILE" 2>/dev/null; then
    test_case "TC-05" "Output FormatにSCAセクションがある" 0
else
    test_case "TC-05" "Output FormatにSCAセクションがある" 1
fi

# TC-06: 既存のattacker（injection/xss/crypto/error）が残っている
if [ -f "$SKILL_FILE" ]; then
    has_all=true
    grep -q "injection-attacker" "$SKILL_FILE" 2>/dev/null || has_all=false
    grep -q "xss-attacker" "$SKILL_FILE" 2>/dev/null || has_all=false
    grep -q "crypto-attacker" "$SKILL_FILE" 2>/dev/null || has_all=false
    grep -q "error-attacker" "$SKILL_FILE" 2>/dev/null || has_all=false

    if [ "$has_all" = "true" ]; then
        test_case "TC-06" "既存のattacker（injection/xss/crypto/error）が残っている" 0
    else
        test_case "TC-06" "既存のattacker（injection/xss/crypto/error）が残っている" 1
    fi
else
    test_case "TC-06" "既存のattacker（injection/xss/crypto/error）が残っている" 1
fi

# TC-07: 既存のオプション（--dynamic等）が残っている
if [ -f "$SKILL_FILE" ]; then
    has_opts=true
    grep -q "\-\-dynamic" "$SKILL_FILE" 2>/dev/null || has_opts=false
    grep -q "\-\-target" "$SKILL_FILE" 2>/dev/null || has_opts=false

    if [ "$has_opts" = "true" ]; then
        test_case "TC-07" "既存のオプション（--dynamic等）が残っている" 0
    else
        test_case "TC-07" "既存のオプション（--dynamic等）が残っている" 1
    fi
else
    test_case "TC-07" "既存のオプション（--dynamic等）が残っている" 1
fi

# TC-08: Usage例にSCA関連の説明がある
if [ -f "$SKILL_FILE" ] && grep -qE "no-sca|sca-attacker" "$SKILL_FILE" 2>/dev/null; then
    test_case "TC-08" "Usage例にSCA関連の説明がある" 0
else
    test_case "TC-08" "Usage例にSCA関連の説明がある" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
