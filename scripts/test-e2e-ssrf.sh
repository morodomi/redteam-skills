#!/bin/bash
#
# Test: e2e-ssrf SSRF E2E test template
#
# TC-01: [正常系] ssrf検出結果からテスト生成
# TC-02: [正常系] blind-ssrf検出結果からテスト生成
# TC-03: [正常系] partial-ssrf検出結果からテスト生成
# TC-04: [正常系] コールバックサーバー起動/停止
# TC-05: [境界値] SSRF脆弱性0件時の処理
# TC-06: [エッジケース] 複数SSRF脆弱性
# TC-07: [異常系] コールバックタイムアウト

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/plugins/redteam-core/skills/generate-e2e"
TEMPLATE_DIR="$SKILL_DIR/templates"
SSRF_TMPL="$TEMPLATE_DIR/ssrf.spec.ts.tmpl"
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
echo "e2e-ssrf Template Test"
echo "================================"
echo ""

# TC-01: SSRF Template Basics
echo "--- TC-01: SSRF Template Basics ---"

# TC-01a: ssrf.spec.ts.tmpl exists
if [ -f "$SSRF_TMPL" ]; then
    test_case "TC-01a" "ssrf.spec.ts.tmpl exists" 0
else
    test_case "TC-01a" "ssrf.spec.ts.tmpl exists" 1
fi

# TC-01b: template imports @playwright/test
if [ -f "$SSRF_TMPL" ]; then
    has_import=$(grep -c "@playwright/test" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_import" -gt 0 ]; then
        test_case "TC-01b" "template imports @playwright/test" 0
    else
        test_case "TC-01b" "template imports @playwright/test" 1
    fi
else
    test_case "TC-01b" "template imports @playwright/test" 1
fi

# TC-01c: template imports createServer from http
if [ -f "$SSRF_TMPL" ]; then
    has_http=$(grep -c "createServer" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_http" -gt 0 ]; then
        test_case "TC-01c" "template imports createServer from http" 0
    else
        test_case "TC-01c" "template imports createServer from http" 1
    fi
else
    test_case "TC-01c" "template imports createServer from http" 1
fi

# TC-01d: template has SSRF test pattern
if [ -f "$SSRF_TMPL" ]; then
    has_ssrf=$(grep -ci "ssrf\|callback\|server-side" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_ssrf" -gt 0 ]; then
        test_case "TC-01d" "template has SSRF test pattern" 0
    else
        test_case "TC-01d" "template has SSRF test pattern" 1
    fi
else
    test_case "TC-01d" "template has SSRF test pattern" 1
fi

echo ""
echo "--- TC-02: Blind SSRF Support ---"

# TC-02a: template supports callback verification
if [ -f "$SSRF_TMPL" ]; then
    has_callback=$(grep -ci "callback\|received" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_callback" -gt 0 ]; then
        test_case "TC-02a" "template supports callback verification" 0
    else
        test_case "TC-02a" "template supports callback verification" 1
    fi
else
    test_case "TC-02a" "template supports callback verification" 1
fi

# TC-02b: template has localhost callback URL
if [ -f "$SSRF_TMPL" ]; then
    has_localhost=$(grep -ci "localhost\|127\.0\.0\.1" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_localhost" -gt 0 ]; then
        test_case "TC-02b" "template has localhost callback URL" 0
    else
        test_case "TC-02b" "template has localhost callback URL" 1
    fi
else
    test_case "TC-02b" "template has localhost callback URL" 1
fi

echo ""
echo "--- TC-03: Partial SSRF Support ---"

# TC-03a: template has form submission pattern
if [ -f "$SSRF_TMPL" ]; then
    has_form=$(grep -c "page.fill\|page.click" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_form" -gt 0 ]; then
        test_case "TC-03a" "template has form submission pattern" 0
    else
        test_case "TC-03a" "template has form submission pattern" 1
    fi
else
    test_case "TC-03a" "template has form submission pattern" 1
fi

echo ""
echo "--- TC-04: Callback Server Lifecycle ---"

# TC-04a: template has beforeAll hook
if [ -f "$SSRF_TMPL" ]; then
    has_before=$(grep -c "test.beforeAll\|beforeAll" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_before" -gt 0 ]; then
        test_case "TC-04a" "template has beforeAll hook" 0
    else
        test_case "TC-04a" "template has beforeAll hook" 1
    fi
else
    test_case "TC-04a" "template has beforeAll hook" 1
fi

# TC-04b: template has afterAll hook
if [ -f "$SSRF_TMPL" ]; then
    has_after=$(grep -c "test.afterAll\|afterAll" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_after" -gt 0 ]; then
        test_case "TC-04b" "template has afterAll hook" 0
    else
        test_case "TC-04b" "template has afterAll hook" 1
    fi
else
    test_case "TC-04b" "template has afterAll hook" 1
fi

# TC-04c: template binds to 127.0.0.1
if [ -f "$SSRF_TMPL" ]; then
    has_bind=$(grep -c "127.0.0.1" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_bind" -gt 0 ]; then
        test_case "TC-04c" "template binds to 127.0.0.1" 0
    else
        test_case "TC-04c" "template binds to 127.0.0.1" 1
    fi
else
    test_case "TC-04c" "template binds to 127.0.0.1" 1
fi

# TC-04d: template has server.close cleanup
if [ -f "$SSRF_TMPL" ]; then
    has_close=$(grep -c "server.close\|\.close(" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_close" -gt 0 ]; then
        test_case "TC-04d" "template has server.close cleanup" 0
    else
        test_case "TC-04d" "template has server.close cleanup" 1
    fi
else
    test_case "TC-04d" "template has server.close cleanup" 1
fi

echo ""
echo "--- TC-05: Empty Vulnerabilities ---"

# TC-05a: reference.md documents SSRF empty case
if [ -f "$REFERENCE_FILE" ]; then
    has_empty=$(grep -ci "ssrf.*0\|ssrf.*empty\|empty.*ssrf" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
    has_empty=${has_empty:-0}
    if [ "$has_empty" -gt 0 ]; then
        test_case "TC-05a" "reference.md documents SSRF empty case" 0
    else
        test_case "TC-05a" "reference.md documents SSRF empty case" 1
    fi
else
    test_case "TC-05a" "reference.md documents SSRF empty case" 1
fi

echo ""
echo "--- TC-06: Multiple SSRF Vulnerabilities ---"

# TC-06a: template has test.describe structure
if [ -f "$SSRF_TMPL" ]; then
    has_describe=$(grep -c "test.describe" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_describe" -gt 0 ]; then
        test_case "TC-06a" "template has test.describe structure" 0
    else
        test_case "TC-06a" "template has test.describe structure" 1
    fi
else
    test_case "TC-06a" "template has test.describe structure" 1
fi

# TC-06b: template has receivedPaths array
if [ -f "$SSRF_TMPL" ]; then
    has_paths=$(grep -c "receivedPaths" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_paths" -gt 0 ]; then
        test_case "TC-06b" "template has receivedPaths array" 0
    else
        test_case "TC-06b" "template has receivedPaths array" 1
    fi
else
    test_case "TC-06b" "template has receivedPaths array" 1
fi

echo ""
echo "--- TC-07: Timeout Handling ---"

# TC-07a: template has waitForTimeout
if [ -f "$SSRF_TMPL" ]; then
    has_timeout=$(grep -c "waitForTimeout" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_timeout" -gt 0 ]; then
        test_case "TC-07a" "template has waitForTimeout" 0
    else
        test_case "TC-07a" "template has waitForTimeout" 1
    fi
else
    test_case "TC-07a" "template has waitForTimeout" 1
fi

# TC-07b: template has PURPOSE/WARNING comment
if [ -f "$SSRF_TMPL" ]; then
    has_purpose=$(grep -ci "purpose\|warning" "$SSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_purpose" -gt 0 ]; then
        test_case "TC-07b" "template has PURPOSE/WARNING comment" 0
    else
        test_case "TC-07b" "template has PURPOSE/WARNING comment" 1
    fi
else
    test_case "TC-07b" "template has PURPOSE/WARNING comment" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
