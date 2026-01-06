#!/bin/bash
#
# Test: e2e-xss XSS E2E test template
#
# TC-01: [正常系] Reflected XSS検出結果からテスト生成
# TC-02: [正常系] DOM XSS検出結果からテスト生成
# TC-03: [正常系] Stored XSS検出結果からテスト生成
# TC-04: [正常系] 複数ペイロードでのテスト生成
# TC-05: [境界値] XSS脆弱性0件時の処理
# TC-06: [エッジケース] 特殊文字を含むエンドポイント
# TC-07: [異常系] 不正なXSSタイプ指定時のエラー

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/plugins/redteam-core/skills/generate-e2e"
TEMPLATE_DIR="$SKILL_DIR/templates"
XSS_TMPL="$TEMPLATE_DIR/xss.spec.ts.tmpl"
REFERENCE_FILE="$SKILL_DIR/reference.md"

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
echo "e2e-xss Template Test"
echo "================================"
echo ""

# TC-01: Reflected XSS Template
echo "--- TC-01: Reflected XSS Template ---"

# TC-01a: xss.spec.ts.tmpl exists
if [ -f "$XSS_TMPL" ]; then
    test_case "TC-01a" "xss.spec.ts.tmpl exists" 0
else
    test_case "TC-01a" "xss.spec.ts.tmpl exists" 1
fi

# TC-01b: template imports @playwright/test
if [ -f "$XSS_TMPL" ]; then
    has_import=$(grep -c "@playwright/test" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_import" -gt 0 ]; then
        test_case "TC-01b" "template imports @playwright/test" 0
    else
        test_case "TC-01b" "template imports @playwright/test" 1
    fi
else
    test_case "TC-01b" "template imports @playwright/test" 1
fi

# TC-01c: template has Reflected XSS test pattern (URL param injection)
if [ -f "$XSS_TMPL" ]; then
    has_reflected=$(grep -ci "reflected\|page.goto.*\?" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_reflected" -gt 0 ]; then
        test_case "TC-01c" "template has Reflected XSS pattern" 0
    else
        test_case "TC-01c" "template has Reflected XSS pattern" 1
    fi
else
    test_case "TC-01c" "template has Reflected XSS pattern" 1
fi

# TC-01d: template has xssTriggered verification
if [ -f "$XSS_TMPL" ]; then
    has_triggered=$(grep -c "xssTriggered" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_triggered" -gt 0 ]; then
        test_case "TC-01d" "template has xssTriggered verification" 0
    else
        test_case "TC-01d" "template has xssTriggered verification" 1
    fi
else
    test_case "TC-01d" "template has xssTriggered verification" 1
fi

echo ""
echo "--- TC-02: DOM XSS Template ---"

# TC-02a: template has DOM XSS pattern (innerHTML, document.write, etc)
if [ -f "$XSS_TMPL" ]; then
    has_dom=$(grep -ci "dom\|innerhtml\|document.write" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_dom" -gt 0 ]; then
        test_case "TC-02a" "template has DOM XSS pattern" 0
    else
        test_case "TC-02a" "template has DOM XSS pattern" 1
    fi
else
    test_case "TC-02a" "template has DOM XSS pattern" 1
fi

# TC-02b: template uses page.evaluate for DOM check
if [ -f "$XSS_TMPL" ]; then
    has_evaluate=$(grep -c "page.evaluate" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_evaluate" -gt 0 ]; then
        test_case "TC-02b" "template uses page.evaluate" 0
    else
        test_case "TC-02b" "template uses page.evaluate" 1
    fi
else
    test_case "TC-02b" "template uses page.evaluate" 1
fi

echo ""
echo "--- TC-03: Stored XSS Template ---"

# TC-03a: template has Stored XSS pattern (submit then view)
if [ -f "$XSS_TMPL" ]; then
    has_stored=$(grep -ci "stored\|submit\|save" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_stored" -gt 0 ]; then
        test_case "TC-03a" "template has Stored XSS pattern" 0
    else
        test_case "TC-03a" "template has Stored XSS pattern" 1
    fi
else
    test_case "TC-03a" "template has Stored XSS pattern" 1
fi

echo ""
echo "--- TC-04: Payload Variations ---"

# TC-04a: template has XSS_PAYLOADS array
if [ -f "$XSS_TMPL" ]; then
    has_payloads=$(grep -c "XSS_PAYLOADS\|payloads" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_payloads" -gt 0 ]; then
        test_case "TC-04a" "template has XSS_PAYLOADS array" 0
    else
        test_case "TC-04a" "template has XSS_PAYLOADS array" 1
    fi
else
    test_case "TC-04a" "template has XSS_PAYLOADS array" 1
fi

# TC-04b: template has script tag payload
if [ -f "$XSS_TMPL" ]; then
    has_script=$(grep -c "<script>" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_script" -gt 0 ]; then
        test_case "TC-04b" "template has script tag payload" 0
    else
        test_case "TC-04b" "template has script tag payload" 1
    fi
else
    test_case "TC-04b" "template has script tag payload" 1
fi

# TC-04c: template has img onerror payload
if [ -f "$XSS_TMPL" ]; then
    has_img=$(grep -c "onerror" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_img" -gt 0 ]; then
        test_case "TC-04c" "template has img onerror payload" 0
    else
        test_case "TC-04c" "template has img onerror payload" 1
    fi
else
    test_case "TC-04c" "template has img onerror payload" 1
fi

# TC-04d: template has svg onload payload
if [ -f "$XSS_TMPL" ]; then
    has_svg=$(grep -c "svg.*onload\|onload.*svg" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_svg" -gt 0 ]; then
        test_case "TC-04d" "template has svg onload payload" 0
    else
        test_case "TC-04d" "template has svg onload payload" 1
    fi
else
    test_case "TC-04d" "template has svg onload payload" 1
fi

echo ""
echo "--- TC-05: Empty Vulnerabilities ---"

# TC-05a: reference.md documents XSS empty case
if [ -f "$REFERENCE_FILE" ]; then
    has_empty=$(grep -ci "xss.*0\|no.*xss\|empty" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
    has_empty=${has_empty:-0}
    if [ "$has_empty" -gt 0 ]; then
        test_case "TC-05a" "reference.md documents XSS empty case" 0
    else
        test_case "TC-05a" "reference.md documents XSS empty case" 1
    fi
else
    test_case "TC-05a" "reference.md documents XSS empty case" 1
fi

echo ""
echo "--- TC-06: Special Characters ---"

# TC-06a: template uses encodeURIComponent for URL params
if [ -f "$XSS_TMPL" ]; then
    has_encode=$(grep -c "encodeURIComponent" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_encode" -gt 0 ]; then
        test_case "TC-06a" "template uses encodeURIComponent" 0
    else
        test_case "TC-06a" "template uses encodeURIComponent" 1
    fi
else
    test_case "TC-06a" "template uses encodeURIComponent" 1
fi

echo ""
echo "--- TC-07: Error Handling ---"

# TC-07a: reference.md documents XSS type validation
if [ -f "$REFERENCE_FILE" ]; then
    has_xss_types=$(grep -ci "xss.*type\|reflected.*dom.*stored" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
    has_xss_types=${has_xss_types:-0}
    if [ "$has_xss_types" -gt 0 ]; then
        test_case "TC-07a" "reference.md documents XSS types" 0
    else
        test_case "TC-07a" "reference.md documents XSS types" 1
    fi
else
    test_case "TC-07a" "reference.md documents XSS types" 1
fi

# TC-07b: template has test.describe with XSS context
if [ -f "$XSS_TMPL" ]; then
    has_describe=$(grep -c "test.describe" "$XSS_TMPL" 2>/dev/null || echo 0)
    if [ "$has_describe" -gt 0 ]; then
        test_case "TC-07b" "template has test.describe structure" 0
    else
        test_case "TC-07b" "template has test.describe structure" 1
    fi
else
    test_case "TC-07b" "template has test.describe structure" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
