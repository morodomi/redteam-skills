#!/bin/bash
#
# Test: e2e-ssti SSTI E2E test template (Issue #35)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_FILE="$PROJECT_ROOT/plugins/redteam-core/skills/generate-e2e/templates/ssti.spec.ts.tmpl"

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
echo "e2e-ssti SSTI E2E Template Test"
echo "========================================"
echo ""

# TC-01: Jinja2ペイロード
echo "--- TC-01: Jinja2 payload pattern ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_jinja=$(grep -ci "jinja\|{{7\*7}}" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$has_jinja" -gt 0 ] 2>/dev/null; then
        test_case "TC-01" "Jinja2 payload pattern exists" 0
    else
        test_case "TC-01" "Jinja2 payload pattern exists" 1
    fi
else
    test_case "TC-01" "Jinja2 payload pattern exists" 1
fi

# TC-02: Blade/Twigペイロード
echo ""
echo "--- TC-02: Blade/Twig payload pattern ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_blade=$(grep -ci "blade\|twig" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$has_blade" -gt 0 ] 2>/dev/null; then
        test_case "TC-02" "Blade/Twig payload pattern exists" 0
    else
        test_case "TC-02" "Blade/Twig payload pattern exists" 1
    fi
else
    test_case "TC-02" "Blade/Twig payload pattern exists" 1
fi

# TC-03: Playwright import文
echo ""
echo "--- TC-03: Playwright import ---"
if [ -f "$TEMPLATE_FILE" ]; then
    has_playwright=$(grep -c "@playwright/test" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$has_playwright" -gt 0 ] 2>/dev/null; then
        test_case "TC-03" "Playwright import exists" 0
    else
        test_case "TC-03" "Playwright import exists" 1
    fi
else
    test_case "TC-03" "Playwright import exists" 1
fi

# TC-04: 複数ペイロード対応
echo ""
echo "--- TC-04: Multiple payloads ---"
if [ -f "$TEMPLATE_FILE" ]; then
    payload_count=$(grep -c "payload" "$TEMPLATE_FILE" 2>/dev/null | head -1 || echo 0)
    if [ "$payload_count" -ge 5 ] 2>/dev/null; then
        test_case "TC-04" "Multiple payloads supported" 0
    else
        test_case "TC-04" "Multiple payloads supported" 1
    fi
else
    test_case "TC-04" "Multiple payloads supported" 1
fi

# TC-05: 構文エラーなし
echo ""
echo "--- TC-05: No syntax errors ---"
if [ -f "$TEMPLATE_FILE" ]; then
    open_parens=$(grep -o "(" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    close_parens=$(grep -o ")" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    open_braces=$(grep -o "{" "$TEMPLATE_FILE" | wc -l | tr -d ' ')
    close_braces=$(grep -o "}" "$TEMPLATE_FILE" | wc -l | tr -d ' ')

    if [ "$open_parens" -eq "$close_parens" ] && [ "$open_braces" -eq "$close_braces" ]; then
        test_case "TC-05" "No syntax errors (balanced braces)" 0
    else
        test_case "TC-05" "No syntax errors (balanced braces)" 1
    fi
else
    test_case "TC-05" "No syntax errors (balanced braces)" 1
fi

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
