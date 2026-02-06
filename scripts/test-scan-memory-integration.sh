#!/bin/bash
#
# Test: Scan Memory Integration feature
#
# TC-01: SKILL.md is 100 lines or less
# TC-02: reference.md contains "Memory Integration" section
# TC-03: Existing workflow (RECON->SCAN->REPORT->AUTO TRANSITION) preserved
# TC-04: SKILL.md workflow contains LEARN Phase
# TC-05: recon-agent.md contains "Check past scan context" step
# TC-06: reference.md Memory Convention has Project / Known False Positive Patterns / Scan History
# TC-07: Plugin structure test passes
# TC-08: Output Schema has no breaking changes (schema_version, vulnerabilities fields present)
# TC-09: recon-agent.md contains fallback behavior for missing auto memory
# TC-10: SKILL.md Options table contains --no-memory
# TC-11: reference.md contains Memory Data Exclusion section

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="$PROJECT_ROOT/plugins/redteam-core"
SKILL_DIR="$PLUGIN_DIR/skills/security-scan"
SKILL_MD="$SKILL_DIR/SKILL.md"
REFERENCE_MD="$SKILL_DIR/reference.md"
RECON_MD="$PLUGIN_DIR/agents/recon-agent.md"

PASSED=0
FAILED=0

# Test helper
test_case() {
    local tc_id="$1"
    local description="$2"
    local result="$3"

    if [ "$result" = "0" ]; then
        echo "PASS $tc_id: $description"
        ((PASSED++))
    else
        echo "FAIL $tc_id: $description"
        ((FAILED++))
    fi
}

echo "================================"
echo "Scan Memory Integration Test"
echo "================================"
echo ""

# TC-01: SKILL.md is 100 lines or less
if [ -f "$SKILL_MD" ]; then
    line_count=$(wc -l < "$SKILL_MD" | tr -d ' ')
    if [ "$line_count" -le 100 ]; then
        test_case "TC-01" "SKILL.md is 100 lines or less ($line_count lines)" 0
    else
        test_case "TC-01" "SKILL.md is 100 lines or less ($line_count lines)" 1
    fi
else
    test_case "TC-01" "SKILL.md is 100 lines or less (file not found)" 1
fi

# TC-02: reference.md contains "Memory Integration" section
if grep -q "## Memory Integration\|### Memory Integration" "$REFERENCE_MD" 2>/dev/null; then
    test_case "TC-02" "reference.md contains Memory Integration section" 0
else
    test_case "TC-02" "reference.md contains Memory Integration section" 1
fi

# TC-03: Existing workflow preserved (RECON, SCAN, REPORT, AUTO TRANSITION)
existing_ok=true
for keyword in "RECON" "SCAN" "REPORT" "AUTO TRANSITION"; do
    if ! grep -q "$keyword" "$SKILL_MD" 2>/dev/null; then
        existing_ok=false
        break
    fi
done
if [ "$existing_ok" = true ]; then
    test_case "TC-03" "Existing workflow (RECON/SCAN/REPORT/AUTO TRANSITION) preserved" 0
else
    test_case "TC-03" "Existing workflow (RECON/SCAN/REPORT/AUTO TRANSITION) preserved" 1
fi

# TC-04: SKILL.md workflow contains LEARN Phase
if grep -q "LEARN" "$SKILL_MD" 2>/dev/null; then
    test_case "TC-04" "SKILL.md workflow contains LEARN Phase" 0
else
    test_case "TC-04" "SKILL.md workflow contains LEARN Phase" 1
fi

# TC-05: recon-agent.md contains "Check past scan context" step
if grep -qi "past scan context\|check.*memory\|check.*past.*context" "$RECON_MD" 2>/dev/null; then
    test_case "TC-05" "recon-agent.md contains Check past scan context step" 0
else
    test_case "TC-05" "recon-agent.md contains Check past scan context step" 1
fi

# TC-06: reference.md Memory Convention has required subsections
mc_ok=true
for subsection in "### Project" "### Known False Positive Patterns" "### Scan History"; do
    if ! grep -q "$subsection" "$REFERENCE_MD" 2>/dev/null; then
        mc_ok=false
        break
    fi
done
if [ "$mc_ok" = true ]; then
    test_case "TC-06" "Memory Convention has Project/Known FP Patterns/Scan History" 0
else
    test_case "TC-06" "Memory Convention has Project/Known FP Patterns/Scan History" 1
fi

# TC-07: Plugin structure test passes
if bash "$SCRIPT_DIR/test-plugins-structure.sh" > /dev/null 2>&1; then
    test_case "TC-07" "Plugin structure test passes" 0
else
    test_case "TC-07" "Plugin structure test passes" 1
fi

# TC-08: Output Schema has no breaking changes
schema_ok=true
for field in "schema_version" "vulnerabilities" "metadata" "summary"; do
    if ! grep -q "$field" "$REFERENCE_MD" 2>/dev/null; then
        schema_ok=false
        break
    fi
done
if [ "$schema_ok" = true ]; then
    test_case "TC-08" "Output Schema has no breaking changes" 0
else
    test_case "TC-08" "Output Schema has no breaking changes" 1
fi

# TC-09: recon-agent.md contains fallback behavior for missing auto memory
if grep -qi "fallback\|skip\|not found\|no.*memory\|no.*context" "$RECON_MD" 2>/dev/null; then
    test_case "TC-09" "recon-agent.md contains fallback for missing auto memory" 0
else
    test_case "TC-09" "recon-agent.md contains fallback for missing auto memory" 1
fi

# TC-10: SKILL.md Options table contains --no-memory
if grep -q "\-\-no-memory" "$SKILL_MD" 2>/dev/null; then
    test_case "TC-10" "SKILL.md Options table contains --no-memory" 0
else
    test_case "TC-10" "SKILL.md Options table contains --no-memory" 1
fi

# TC-11: reference.md contains Memory Data Exclusion section
if grep -qi "Memory Data Exclusion\|Data Exclusion\|保存禁止" "$REFERENCE_MD" 2>/dev/null; then
    test_case "TC-11" "reference.md contains Memory Data Exclusion section" 0
else
    test_case "TC-11" "reference.md contains Memory Data Exclusion section" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
