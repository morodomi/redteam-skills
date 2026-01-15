#!/bin/bash
#
# Test: attack-scenario agent
#
# TC-01: frontmatterにname: attack-scenarioがある
# TC-02: frontmatterにallowed-toolsがある
# TC-03: Input Formatセクションがある
# TC-04: Chain Analysisセクションがある
# TC-05: Chain Patternテーブルに6パターンがある
# TC-06: Chain Detection Logicセクションがある
# TC-07: Output Formatにscenariosがある
# TC-08: Output Formatにstepsがある
# TC-09: Output Formatにimpactがある
# TC-10: Impact Categoriesセクションがある
# TC-11: business_impactフィールドがある
# TC-12: Integration with security-scanセクションがある

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/attack-scenario.md"

PASSED=0
FAILED=0

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
echo "attack-scenario Agent Test"
echo "================================"
echo ""

# TC-01: frontmatterにname: attack-scenarioがある
if [ -f "$AGENT_FILE" ] && grep -q "name: attack-scenario" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-01" "frontmatterにname: attack-scenarioがある" 0
else
    test_case "TC-01" "frontmatterにname: attack-scenarioがある" 1
fi

# TC-02: frontmatterにallowed-toolsがある
if [ -f "$AGENT_FILE" ] && grep -q "allowed-tools:" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-02" "frontmatterにallowed-toolsがある" 0
else
    test_case "TC-02" "frontmatterにallowed-toolsがある" 1
fi

# TC-03: Input Formatセクションがある
if [ -f "$AGENT_FILE" ] && grep -q "Input Format" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-03" "Input Formatセクションがある" 0
else
    test_case "TC-03" "Input Formatセクションがある" 1
fi

# TC-04: Chain Analysisセクションがある
if [ -f "$AGENT_FILE" ] && grep -q "Chain Analysis" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-04" "Chain Analysisセクションがある" 0
else
    test_case "TC-04" "Chain Analysisセクションがある" 1
fi

# TC-05: Chain Patternテーブルに6パターンがある
if [ -f "$AGENT_FILE" ]; then
    pattern_count=$(grep -E "^\| (Data Breach|Account Takeover|RCE|SSRF Chain|Privilege Escalation|Lateral Movement) \|" "$AGENT_FILE" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$pattern_count" -ge 6 ]; then
        test_case "TC-05" "Chain Patternテーブルに6パターンがある" 0
    else
        test_case "TC-05" "Chain Patternテーブルに6パターンがある" 1
    fi
else
    test_case "TC-05" "Chain Patternテーブルに6パターンがある" 1
fi

# TC-06: Chain Detection Logicセクションがある
if [ -f "$AGENT_FILE" ] && grep -q "Chain Detection Logic" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-06" "Chain Detection Logicセクションがある" 0
else
    test_case "TC-06" "Chain Detection Logicセクションがある" 1
fi

# TC-07: Output Formatにscenariosがある
if [ -f "$AGENT_FILE" ] && grep -q '"scenarios"' "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-07" "Output Formatにscenariosがある" 0
else
    test_case "TC-07" "Output Formatにscenariosがある" 1
fi

# TC-08: Output Formatにstepsがある
if [ -f "$AGENT_FILE" ] && grep -q '"steps"' "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-08" "Output Formatにstepsがある" 0
else
    test_case "TC-08" "Output Formatにstepsがある" 1
fi

# TC-09: Output Formatにimpactがある
if [ -f "$AGENT_FILE" ] && grep -q '"impact"' "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-09" "Output Formatにimpactがある" 0
else
    test_case "TC-09" "Output Formatにimpactがある" 1
fi

# TC-10: Impact Categoriesセクションがある
if [ -f "$AGENT_FILE" ] && grep -q "Impact Categories" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-10" "Impact Categoriesセクションがある" 0
else
    test_case "TC-10" "Impact Categoriesセクションがある" 1
fi

# TC-11: business_impactフィールドがある
if [ -f "$AGENT_FILE" ] && grep -q "business_impact" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-11" "business_impactフィールドがある" 0
else
    test_case "TC-11" "business_impactフィールドがある" 1
fi

# TC-12: Integration with security-scanセクションがある
if [ -f "$AGENT_FILE" ] && grep -q "Integration" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-12" "Integration with security-scanセクションがある" 0
else
    test_case "TC-12" "Integration with security-scanセクションがある" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
