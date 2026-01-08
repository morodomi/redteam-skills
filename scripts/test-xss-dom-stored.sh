#!/bin/bash
#
# Test: xss-attacker DOM/Stored XSS detection (Issue #28)
#
# TC-01: [正常系] DOM XSS innerHTML検出
# TC-02: [正常系] DOM XSS document.write検出
# TC-03: [正常系] DOM XSS jQuery.html()検出
# TC-04: [正常系] Stored XSS Laravel検出
# TC-05: [正常系] Stored XSS Django検出
# TC-06: [正常系] Stored XSS Express検出
# TC-07: [境界値] 安全なパターン（エスケープ済み）除外
# TC-08: [エッジケース] 複数タイプ混在
# TC-09: [異常系] 対象ファイルなし

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/xss-attacker.md"

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
echo "xss-attacker DOM/Stored XSS Test"
echo "================================"
echo ""

# TC-01: DOM XSS innerHTML検出
echo "--- TC-01: DOM XSS innerHTML Detection ---"
if [ -f "$AGENT_FILE" ]; then
    # Check for innerHTML pattern in DOM XSS section
    has_dom_section=$(grep -ci "DOM XSS" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_dom_section=${has_dom_section:-0}
    has_innerhtml=$(grep -c "innerHTML" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_innerhtml=${has_innerhtml:-0}

    if [ "$has_dom_section" -gt 0 ] && [ "$has_innerhtml" -gt 0 ]; then
        test_case "TC-01" "DOM XSS innerHTML detection pattern exists" 0
    else
        test_case "TC-01" "DOM XSS innerHTML detection pattern exists" 1
    fi
else
    test_case "TC-01" "DOM XSS innerHTML detection pattern exists" 1
fi

# TC-02: DOM XSS document.write検出
echo ""
echo "--- TC-02: DOM XSS document.write Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_docwrite=$(grep -c "document\.write" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_docwrite=${has_docwrite:-0}

    if [ "$has_docwrite" -gt 0 ]; then
        test_case "TC-02" "DOM XSS document.write detection pattern exists" 0
    else
        test_case "TC-02" "DOM XSS document.write detection pattern exists" 1
    fi
else
    test_case "TC-02" "DOM XSS document.write detection pattern exists" 1
fi

# TC-03: DOM XSS jQuery.html()検出
echo ""
echo "--- TC-03: DOM XSS jQuery.html() Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_jquery_html=$(grep -c "\.html(" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_jquery_html=${has_jquery_html:-0}
    has_jquery_section=$(grep -ci "jquery" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_jquery_section=${has_jquery_section:-0}

    if [ "$has_jquery_html" -gt 0 ] || [ "$has_jquery_section" -gt 0 ]; then
        test_case "TC-03" "DOM XSS jQuery.html() detection pattern exists" 0
    else
        test_case "TC-03" "DOM XSS jQuery.html() detection pattern exists" 1
    fi
else
    test_case "TC-03" "DOM XSS jQuery.html() detection pattern exists" 1
fi

# TC-04: Stored XSS Laravel検出
echo ""
echo "--- TC-04: Stored XSS Laravel Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_stored_section=$(grep -ci "stored" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_stored_section=${has_stored_section:-0}
    has_laravel=$(grep -ci "laravel" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_laravel=${has_laravel:-0}

    if [ "$has_stored_section" -gt 0 ] && [ "$has_laravel" -gt 0 ]; then
        test_case "TC-04" "Stored XSS Laravel detection pattern exists" 0
    else
        test_case "TC-04" "Stored XSS Laravel detection pattern exists" 1
    fi
else
    test_case "TC-04" "Stored XSS Laravel detection pattern exists" 1
fi

# TC-05: Stored XSS Django検出
echo ""
echo "--- TC-05: Stored XSS Django Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_stored=$(grep -ci "stored" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_stored=${has_stored:-0}
    has_django=$(grep -ci "django" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_django=${has_django:-0}

    if [ "$has_stored" -gt 0 ] && [ "$has_django" -gt 0 ]; then
        test_case "TC-05" "Stored XSS Django detection pattern exists" 0
    else
        test_case "TC-05" "Stored XSS Django detection pattern exists" 1
    fi
else
    test_case "TC-05" "Stored XSS Django detection pattern exists" 1
fi

# TC-06: Stored XSS Express検出
echo ""
echo "--- TC-06: Stored XSS Express Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_stored=$(grep -ci "stored" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_stored=${has_stored:-0}
    has_express=$(grep -ci "express" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_express=${has_express:-0}

    if [ "$has_stored" -gt 0 ] && [ "$has_express" -gt 0 ]; then
        test_case "TC-06" "Stored XSS Express detection pattern exists" 0
    else
        test_case "TC-06" "Stored XSS Express detection pattern exists" 1
    fi
else
    test_case "TC-06" "Stored XSS Express detection pattern exists" 1
fi

# TC-07: 安全なパターン（エスケープ済み）除外
echo ""
echo "--- TC-07: Safe Pattern Documentation ---"
if [ -f "$AGENT_FILE" ]; then
    has_safe=$(grep -ci "safe" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_safe=${has_safe:-0}
    has_sanitiz=$(grep -ci "sanitiz" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_sanitiz=${has_sanitiz:-0}

    if [ "$has_safe" -gt 0 ] || [ "$has_sanitiz" -gt 0 ]; then
        test_case "TC-07" "Safe pattern/sanitization documentation exists" 0
    else
        test_case "TC-07" "Safe pattern/sanitization documentation exists" 1
    fi
else
    test_case "TC-07" "Safe pattern/sanitization documentation exists" 1
fi

# TC-08: 複数タイプ混在（type: reflected | dom | stored）
echo ""
echo "--- TC-08: Multiple XSS Types Support ---"
if [ -f "$AGENT_FILE" ]; then
    has_reflected=$(grep -c '"reflected"' "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_reflected=${has_reflected:-0}
    has_dom_type=$(grep -c '"dom"' "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_dom_type=${has_dom_type:-0}
    has_stored_type=$(grep -c '"stored"' "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_stored_type=${has_stored_type:-0}

    if [ "$has_reflected" -gt 0 ] && [ "$has_dom_type" -gt 0 ] && [ "$has_stored_type" -gt 0 ]; then
        test_case "TC-08" "Multiple XSS types (reflected, dom, stored) in output format" 0
    else
        test_case "TC-08" "Multiple XSS types (reflected, dom, stored) in output format" 1
    fi
else
    test_case "TC-08" "Multiple XSS types (reflected, dom, stored) in output format" 1
fi

# TC-09: 対象ファイルなし
echo ""
echo "--- TC-09: Agent File Exists ---"
if [ -f "$AGENT_FILE" ]; then
    test_case "TC-09" "xss-attacker.md exists" 0
else
    test_case "TC-09" "xss-attacker.md exists" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
