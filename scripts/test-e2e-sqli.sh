#!/bin/bash
#
# Test: e2e-sqli SQLi E2E test template (Issue #34)
#
# TC-01: [正常系] Error-based SQLiテストパターン存在
# TC-02: [正常系] Union-based SQLiテストパターン存在
# TC-03: [正常系] Boolean-blind SQLiテストパターン存在
# TC-04: [正常系] Time-blind SQLiテストパターン存在
# TC-05: [正常系] Playwright import文
# TC-06: [境界値] 複数ペイロード対応
# TC-07: [異常系] 構文エラーなし

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_FILE="$PROJECT_ROOT/plugins/redteam-core/skills/generate-e2e/templates/sqli.spec.ts.tmpl"

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

echo "========================================"
echo "e2e-sqli SQLi E2E Template Test"
echo "========================================"
echo ""

# TC-01: Error-based SQLiテストパターン
echo "--- TC-01: Error-based SQLi pattern ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_error_based=$(grep -c "error" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$has_error_based" -gt 0 ] 2>/dev/null; then
        test_case "TC-01" "Error-based SQLi pattern exists" 0
    else
        test_case "TC-01" "Error-based SQLi pattern exists" 1
    fi
else
    test_case "TC-01" "Error-based SQLi pattern exists" 1
fi

# TC-02: Union-based SQLiテストパターン
echo ""
echo "--- TC-02: Union-based SQLi pattern ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_union=$(grep -ci "union" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$has_union" -gt 0 ] 2>/dev/null; then
        test_case "TC-02" "Union-based SQLi pattern exists" 0
    else
        test_case "TC-02" "Union-based SQLi pattern exists" 1
    fi
else
    test_case "TC-02" "Union-based SQLi pattern exists" 1
fi

# TC-03: Boolean-blind SQLiテストパターン
echo ""
echo "--- TC-03: Boolean-blind SQLi pattern ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_boolean=$(grep -c "AND 1=1\|boolean\|blind" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$has_boolean" -gt 0 ] 2>/dev/null; then
        test_case "TC-03" "Boolean-blind SQLi pattern exists" 0
    else
        test_case "TC-03" "Boolean-blind SQLi pattern exists" 1
    fi
else
    test_case "TC-03" "Boolean-blind SQLi pattern exists" 1
fi

# TC-04: Time-blind SQLiテストパターン
echo ""
echo "--- TC-04: Time-blind SQLi pattern ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_time=$(grep -ci "time\|delay\|sleep\|waitfor" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$has_time" -gt 0 ] 2>/dev/null; then
        test_case "TC-04" "Time-blind SQLi pattern exists" 0
    else
        test_case "TC-04" "Time-blind SQLi pattern exists" 1
    fi
else
    test_case "TC-04" "Time-blind SQLi pattern exists" 1
fi

# TC-05: Playwright import文
echo ""
echo "--- TC-05: Playwright import ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_playwright=$(grep -c "@playwright/test" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$has_playwright" -gt 0 ] 2>/dev/null; then
        test_case "TC-05" "Playwright import exists" 0
    else
        test_case "TC-05" "Playwright import exists" 1
    fi
else
    test_case "TC-05" "Playwright import exists" 1
fi

# TC-06: 複数ペイロード対応
echo ""
echo "--- TC-06: Multiple payloads ---"
if [ -f "$TEMPLATE_FILE" ]; then
    payload_count=$(grep -c "payload\|Payload\|PAYLOAD" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$payload_count" -ge 2 ] 2>/dev/null; then
        test_case "TC-06" "Multiple payloads supported" 0
    else
        test_case "TC-06" "Multiple payloads supported" 1
    fi
else
    test_case "TC-06" "Multiple payloads supported" 1
fi

# TC-07: 構文エラーなし
echo ""
echo "--- TC-07: No syntax errors ---"
if [ -f "$TEMPLATE_FILE" ]; then
    open_parens=$(grep -o "(" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    close_parens=$(grep -o ")" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    open_braces=$(grep -o "{" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    close_braces=$(grep -o "}" "$TEMPLATE_FILE" | wc -l | tr -d ' ')

    if [ "$open_parens" -eq "$close_parens" ] && [ "$open_braces" -eq "$close_braces" ]; then
        test_case "TC-07" "No syntax errors (balanced braces)" 0
    else
        test_case "TC-07" "No syntax errors (balanced braces)" 1
    fi
else
    test_case "TC-07" "No syntax errors (balanced braces)" 1
fi

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
