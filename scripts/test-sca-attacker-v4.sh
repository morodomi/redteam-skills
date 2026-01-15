#!/bin/bash
#
# Test: sca-attacker v4.0 improvements
#
# TC-01: Response Formatセクションに詳細JSON構造がある
# TC-02: vulnsオブジェクトのフィールド（id, summary, severity, affected）が記載
# TC-03: severityの構造（type, score）が記載
# TC-04: Fallback StrategyにExponential backoffが記載
# TC-05: リトライ回数が3回と記載
# TC-06: リトライ間隔が2s, 4s, 8sと記載
# TC-07: 既存のtimeout 10sが維持
# TC-08: 既存のapi-unavailableフォールバックが維持

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/sca-attacker.md"

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
echo "sca-attacker v4.0 Test"
echo "================================"
echo ""

# TC-01: Response Formatセクションに詳細JSON構造がある
if [ -f "$AGENT_FILE" ] && grep -q '"results"' "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-01" "Response Formatセクションに詳細JSON構造がある" 0
else
    test_case "TC-01" "Response Formatセクションに詳細JSON構造がある" 1
fi

# TC-02: vulnsオブジェクトのフィールド（id, summary, severity, affected）が記載
if [ -f "$AGENT_FILE" ]; then
    has_all=true
    grep -q '"id"' "$AGENT_FILE" 2>/dev/null || has_all=false
    grep -q '"summary"' "$AGENT_FILE" 2>/dev/null || has_all=false
    grep -q '"severity"' "$AGENT_FILE" 2>/dev/null || has_all=false
    grep -q '"affected"' "$AGENT_FILE" 2>/dev/null || has_all=false

    if [ "$has_all" = "true" ]; then
        test_case "TC-02" "vulnsオブジェクトのフィールド（id, summary, severity, affected）が記載" 0
    else
        test_case "TC-02" "vulnsオブジェクトのフィールド（id, summary, severity, affected）が記載" 1
    fi
else
    test_case "TC-02" "vulnsオブジェクトのフィールド（id, summary, severity, affected）が記載" 1
fi

# TC-03: severityの構造（type, score）が記載
if [ -f "$AGENT_FILE" ] && grep -q '"type".*"score"' "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-03" "severityの構造（type, score）が記載" 0
else
    test_case "TC-03" "severityの構造（type, score）が記載" 1
fi

# TC-04: Fallback StrategyにExponential backoffが記載
if [ -f "$AGENT_FILE" ] && grep -qi "exponential backoff" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-04" "Fallback StrategyにExponential backoffが記載" 0
else
    test_case "TC-04" "Fallback StrategyにExponential backoffが記載" 1
fi

# TC-05: リトライ回数が3回と記載
if [ -f "$AGENT_FILE" ] && grep -qE "3.*retry|retry.*3|3回" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-05" "リトライ回数が3回と記載" 0
else
    test_case "TC-05" "リトライ回数が3回と記載" 1
fi

# TC-06: リトライ間隔が2s, 4s, 8sと記載
if [ -f "$AGENT_FILE" ] && grep -qE "2s.*4s.*8s|2s,.*4s,.*8s" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-06" "リトライ間隔が2s, 4s, 8sと記載" 0
else
    test_case "TC-06" "リトライ間隔が2s, 4s, 8sと記載" 1
fi

# TC-07: 既存のtimeout 10sが維持
if [ -f "$AGENT_FILE" ] && grep -q "timeout.*10s\|10s.*timeout" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-07" "既存のtimeout 10sが維持" 0
else
    test_case "TC-07" "既存のtimeout 10sが維持" 1
fi

# TC-08: 既存のapi-unavailableフォールバックが維持
if [ -f "$AGENT_FILE" ] && grep -q "api-unavailable" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-08" "既存のapi-unavailableフォールバックが維持" 0
else
    test_case "TC-08" "既存のapi-unavailableフォールバックが維持" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
