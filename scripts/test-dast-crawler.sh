#!/bin/bash
#
# Test: dast-crawler agent
#
# TC-01: frontmatterにname: dast-crawlerがある
# TC-02: frontmatterにallowed-toolsがある
# TC-03: Detection Targetsセクションがある
# TC-04: Playwright MCP Integrationセクションがある
# TC-05: Crawl Strategyセクションがある
# TC-06: Output Formatにdiscovered_urlsがある
# TC-07: Output Formatにformsがある
# TC-08: Safety Measuresセクションがある

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/dast-crawler.md"

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
echo "dast-crawler Agent Test"
echo "================================"
echo ""

# TC-01: frontmatterにname: dast-crawlerがある
if [ -f "$AGENT_FILE" ] && grep -q "name: dast-crawler" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-01" "frontmatterにname: dast-crawlerがある" 0
else
    test_case "TC-01" "frontmatterにname: dast-crawlerがある" 1
fi

# TC-02: frontmatterにallowed-toolsがある
if [ -f "$AGENT_FILE" ] && grep -q "allowed-tools:" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-02" "frontmatterにallowed-toolsがある" 0
else
    test_case "TC-02" "frontmatterにallowed-toolsがある" 1
fi

# TC-03: Detection Targetsセクションがある
if [ -f "$AGENT_FILE" ] && grep -q "## Detection Targets" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-03" "Detection Targetsセクションがある" 0
else
    test_case "TC-03" "Detection Targetsセクションがある" 1
fi

# TC-04: Playwright MCP Integrationセクションがある
if [ -f "$AGENT_FILE" ] && grep -qi "playwright" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-04" "Playwright MCP Integrationセクションがある" 0
else
    test_case "TC-04" "Playwright MCP Integrationセクションがある" 1
fi

# TC-05: Crawl Strategyセクションがある
if [ -f "$AGENT_FILE" ] && grep -q "Crawl Strategy" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-05" "Crawl Strategyセクションがある" 0
else
    test_case "TC-05" "Crawl Strategyセクションがある" 1
fi

# TC-06: Output Formatにdiscovered_urlsがある
if [ -f "$AGENT_FILE" ] && grep -q "discovered_urls" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-06" "Output Formatにdiscovered_urlsがある" 0
else
    test_case "TC-06" "Output Formatにdiscovered_urlsがある" 1
fi

# TC-07: Output Formatにformsがある
if [ -f "$AGENT_FILE" ] && grep -q '"forms"' "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-07" "Output Formatにformsがある" 0
else
    test_case "TC-07" "Output Formatにformsがある" 1
fi

# TC-08: Safety Measuresセクションがある
if [ -f "$AGENT_FILE" ] && grep -q "Safety Measures" "$AGENT_FILE" 2>/dev/null; then
    test_case "TC-08" "Safety Measuresセクションがある" 0
else
    test_case "TC-08" "Safety Measuresセクションがある" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
