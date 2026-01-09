#!/bin/bash
#
# Test: expect.poll() pattern improvement (Issue #29)
#
# TC-01: [正常系] expect.pollパターンが存在
# TC-02: [正常系] waitForTimeoutが削除されている
# TC-03: [正常系] timeout: 3000 設定
# TC-04: [正常系] intervals設定
# TC-05: [境界値] 両テストケースに適用
# TC-06: [異常系] 構文エラーなし

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_FILE="$PROJECT_ROOT/plugins/redteam-core/skills/generate-e2e/templates/ssrf.spec.ts.tmpl"

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
echo "expect.poll() Pattern Improvement Test"
echo "========================================"
echo ""

# TC-01: expect.pollパターンが存在
echo "--- TC-01: expect.poll pattern exists ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_expect_poll=$(grep -c "expect\.poll" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    has_expect_poll=${has_expect_poll:-0}

    if [ "$has_expect_poll" -gt 0 ] 2>/dev/null; then
        test_case "TC-01" "expect.poll pattern exists" 0
    else
        test_case "TC-01" "expect.poll pattern exists" 1
    fi
else
    test_case "TC-01" "expect.poll pattern exists" 1
fi

# TC-02: waitForTimeoutが削除されている
echo ""
echo "--- TC-02: waitForTimeout is removed ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_wait_for_timeout=$(grep -c "waitForTimeout" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    has_wait_for_timeout=${has_wait_for_timeout:-0}

    if [ "$has_wait_for_timeout" -eq 0 ] 2>/dev/null; then
        test_case "TC-02" "waitForTimeout is removed" 0
    else
        test_case "TC-02" "waitForTimeout is removed" 1
    fi
else
    test_case "TC-02" "waitForTimeout is removed" 1
fi

# TC-03: timeout: 3000 設定
echo ""
echo "--- TC-03: timeout: 3000 setting ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_timeout=$(grep -cE "timeout:[[:space:]]*3000" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    has_timeout=${has_timeout:-0}

    if [ "$has_timeout" -gt 0 ] 2>/dev/null; then
        test_case "TC-03" "timeout: 3000 setting exists" 0
    else
        test_case "TC-03" "timeout: 3000 setting exists" 1
    fi
else
    test_case "TC-03" "timeout: 3000 setting exists" 1
fi

# TC-04: intervals設定
echo ""
echo "--- TC-04: intervals setting ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_intervals=$(grep -c "intervals" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    has_intervals=${has_intervals:-0}

    if [ "$has_intervals" -gt 0 ] 2>/dev/null; then
        test_case "TC-04" "intervals setting exists" 0
    else
        test_case "TC-04" "intervals setting exists" 1
    fi
else
    test_case "TC-04" "intervals setting exists" 1
fi

# TC-05: 両テストケースに適用
echo ""
echo "--- TC-05: Applied to both test cases ---"
if [ -f "$TEMPLATE_FILE" ]; then
    expect_poll_count=$(grep -c "expect\.poll" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    expect_poll_count=${expect_poll_count:-0}

    if [ "$expect_poll_count" -ge 2 ] 2>/dev/null; then
        test_case "TC-05" "expect.poll applied to both test cases" 0
    else
        test_case "TC-05" "expect.poll applied to both test cases" 1
    fi
else
    test_case "TC-05" "expect.poll applied to both test cases" 1
fi

# TC-06: 構文エラーなし（基本的なTypeScript構文チェック）
echo ""
echo "--- TC-06: No syntax errors ---"
if [ -f "$TEMPLATE_FILE" ]; then
    # Check balanced braces/parentheses as basic syntax check
    open_parens=$(grep -o "(" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    close_parens=$(grep -o ")" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    open_braces=$(grep -o "{" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    close_braces=$(grep -o "}" "$TEMPLATE_FILE" | wc -l | tr -d ' ')

    if [ "$open_parens" -eq "$close_parens" ] && [ "$open_braces" -eq "$close_braces" ]; then
        test_case "TC-06" "No syntax errors (balanced braces)" 0
    else
        test_case "TC-06" "No syntax errors (balanced braces)" 1
    fi
else
    test_case "TC-06" "No syntax errors (balanced braces)" 1
fi

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
