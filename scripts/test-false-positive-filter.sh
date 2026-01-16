#!/bin/bash
# Test script for false-positive-filter agent
# Issue #45

AGENT_FILE="plugins/redteam-core/agents/false-positive-filter.md"
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

echo "================================================"
echo "Testing: false-positive-filter agent"
echo "================================================"
echo ""

# Check if agent file exists
if [ ! -f "$AGENT_FILE" ]; then
    echo -e "${RED}Agent file not found: $AGENT_FILE${NC}"
    echo "All tests will fail."
    echo ""
fi

# エージェント構造
echo "## エージェント構造"
run_test "TC-01: frontmatterにname: false-positive-filterがある" \
    "grep -q '^name: false-positive-filter' '$AGENT_FILE'"

run_test "TC-02: frontmatterにallowed-toolsがある" \
    "grep -q '^allowed-tools:' '$AGENT_FILE'"

run_test "TC-03: Input Formatセクションがある" \
    "grep -q '## Input Format\|### Input Format\|#### Input Format' '$AGENT_FILE'"

echo ""

# Filter Rules
echo "## Filter Rules"
run_test "TC-04: Pattern-Based Filtersセクションがある" \
    "grep -q 'Pattern-Based Filters' '$AGENT_FILE'"

run_test "TC-05: Context-Based Filtersセクションがある" \
    "grep -q 'Context-Based Filters' '$AGENT_FILE'"

run_test "TC-06: Sanitization Patterns by Languageセクションがある" \
    "grep -q 'Sanitization Patterns' '$AGENT_FILE'"

echo ""

# Output Format
echo "## Output Format"
run_test "TC-07: Output Formatにfiltered_vulnerabilitiesがある" \
    "grep -q 'filtered_vulnerabilities' '$AGENT_FILE'"

run_test "TC-08: Output Formatにfalse_positivesがある" \
    "grep -q 'false_positives' '$AGENT_FILE'"

run_test "TC-09: Output Formatにsummaryがある" \
    "grep -q '\"summary\"' '$AGENT_FILE'"

run_test "TC-10: false_positivesにreasonフィールドがある" \
    "grep -q '\"reason\"' '$AGENT_FILE'"

run_test "TC-11: false_positivesにconfidenceフィールドがある" \
    "grep -q '\"confidence\"' '$AGENT_FILE'"

echo ""

# Confidence Scoring
echo "## Confidence Scoring"
run_test "TC-12: Confidence Scoringセクションがある" \
    "grep -q 'Confidence Scoring' '$AGENT_FILE'"

echo ""

# Filter Types
echo "## Filter Types"
run_test "TC-13: Filter Typesセクションに4タイプがある" \
    "grep -q '| pattern |' '$AGENT_FILE' && grep -q '| path |' '$AGENT_FILE' && grep -q '| context |' '$AGENT_FILE' && grep -q '| comment |' '$AGENT_FILE'"

echo ""

# Audit Trail
echo "## Audit Trail"
run_test "TC-14: Audit Trailセクションがある" \
    "grep -q 'Audit Trail' '$AGENT_FILE'"

echo ""

# @security-ignore
echo "## @security-ignore"
run_test "TC-15: @security-ignore Formatセクションがある" \
    "grep -q '@security-ignore Format' '$AGENT_FILE'"

run_test "TC-16: reason/reviewer属性が必須と記載されている" \
    "grep -q 'reason.*Yes\|reason.*必須' '$AGENT_FILE' && grep -q 'reviewer.*Yes\|reviewer.*必須' '$AGENT_FILE'"

echo ""

# Integration
echo "## Integration"
run_test "TC-17: Integration with security-scanセクションがある" \
    "grep -q 'Integration with security-scan\|Integration' '$AGENT_FILE'"

echo ""
echo "================================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================================"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
