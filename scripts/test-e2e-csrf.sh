#!/bin/bash
#
# Test: e2e-csrf CSRF E2E test template
#
# TC-01: [正常系] csrf-token-missing検出結果からテスト生成
# TC-02: [正常系] csrf-protection-disabled検出結果からテスト生成
# TC-03: [正常系] samesite-cookie-missing検出結果からテスト生成
# TC-04: [正常系] 認証付きエンドポイントのテスト生成
# TC-05: [境界値] CSRF脆弱性0件時の処理
# TC-06: [エッジケース] 複数HTTPメソッド対応
# TC-07: [異常系] 不正なCSRFタイプ指定時のエラー

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/plugins/redteam-core/skills/generate-e2e"
TEMPLATE_DIR="$SKILL_DIR/templates"
CSRF_TMPL="$TEMPLATE_DIR/csrf.spec.ts.tmpl"
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
echo "e2e-csrf Template Test"
echo "================================"
echo ""

# TC-01: csrf-token-missing Template
echo "--- TC-01: CSRF Token Missing Template ---"

# TC-01a: csrf.spec.ts.tmpl exists
if [ -f "$CSRF_TMPL" ]; then
    test_case "TC-01a" "csrf.spec.ts.tmpl exists" 0
else
    test_case "TC-01a" "csrf.spec.ts.tmpl exists" 1
fi

# TC-01b: template imports @playwright/test
if [ -f "$CSRF_TMPL" ]; then
    has_import=$(grep -c "@playwright/test" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_import" -gt 0 ]; then
        test_case "TC-01b" "template imports @playwright/test" 0
    else
        test_case "TC-01b" "template imports @playwright/test" 1
    fi
else
    test_case "TC-01b" "template imports @playwright/test" 1
fi

# TC-01c: template has CSRF token missing test pattern
if [ -f "$CSRF_TMPL" ]; then
    has_token_missing=$(grep -ci "token.*missing\|without.*csrf\|csrf.*token" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_token_missing" -gt 0 ]; then
        test_case "TC-01c" "template has CSRF token missing pattern" 0
    else
        test_case "TC-01c" "template has CSRF token missing pattern" 1
    fi
else
    test_case "TC-01c" "template has CSRF token missing pattern" 1
fi

# TC-01d: template uses request.post/put/delete
if [ -f "$CSRF_TMPL" ]; then
    has_request=$(grep -c "request\.\(post\|put\|delete\)" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_request" -gt 0 ]; then
        test_case "TC-01d" "template uses request.post/put/delete" 0
    else
        test_case "TC-01d" "template uses request.post/put/delete" 1
    fi
else
    test_case "TC-01d" "template uses request.post/put/delete" 1
fi

echo ""
echo "--- TC-02: CSRF Protection Disabled Template ---"

# TC-02a: template has protection disabled pattern
if [ -f "$CSRF_TMPL" ]; then
    has_disabled=$(grep -ci "protection.*disabled\|disabled\|exempt" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_disabled" -gt 0 ]; then
        test_case "TC-02a" "template has protection disabled pattern" 0
    else
        test_case "TC-02a" "template has protection disabled pattern" 1
    fi
else
    test_case "TC-02a" "template has protection disabled pattern" 1
fi

echo ""
echo "--- TC-03: SameSite Cookie Template ---"

# TC-03a: template has SameSite cookie check
if [ -f "$CSRF_TMPL" ]; then
    has_samesite=$(grep -ci "samesite\|cookie" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_samesite" -gt 0 ]; then
        test_case "TC-03a" "template has SameSite cookie check" 0
    else
        test_case "TC-03a" "template has SameSite cookie check" 1
    fi
else
    test_case "TC-03a" "template has SameSite cookie check" 1
fi

# TC-03b: template uses context.cookies() or storageState
if [ -f "$CSRF_TMPL" ]; then
    has_cookies=$(grep -ci "cookies\|storageState" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_cookies" -gt 0 ]; then
        test_case "TC-03b" "template uses cookies API" 0
    else
        test_case "TC-03b" "template uses cookies API" 1
    fi
else
    test_case "TC-03b" "template uses cookies API" 1
fi

echo ""
echo "--- TC-04: Authentication Support ---"

# TC-04a: template has authentication flow
if [ -f "$CSRF_TMPL" ]; then
    has_auth=$(grep -ci "login\|auth\|password" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_auth" -gt 0 ]; then
        test_case "TC-04a" "template has authentication flow" 0
    else
        test_case "TC-04a" "template has authentication flow" 1
    fi
else
    test_case "TC-04a" "template has authentication flow" 1
fi

# TC-04b: template has AUTH_EMAIL/AUTH_PASSWORD placeholders
if [ -f "$CSRF_TMPL" ]; then
    has_auth_vars=$(grep -c "AUTH_EMAIL\|AUTH_PASSWORD" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_auth_vars" -gt 0 ]; then
        test_case "TC-04b" "template has AUTH placeholders" 0
    else
        test_case "TC-04b" "template has AUTH placeholders" 1
    fi
else
    test_case "TC-04b" "template has AUTH placeholders" 1
fi

echo ""
echo "--- TC-05: Empty Vulnerabilities ---"

# TC-05a: reference.md documents CSRF empty case
if [ -f "$REFERENCE_FILE" ]; then
    has_empty=$(grep -ci "csrf.*0\|no.*csrf\|empty" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
    has_empty=${has_empty:-0}
    if [ "$has_empty" -gt 0 ]; then
        test_case "TC-05a" "reference.md documents CSRF empty case" 0
    else
        test_case "TC-05a" "reference.md documents CSRF empty case" 1
    fi
else
    test_case "TC-05a" "reference.md documents CSRF empty case" 1
fi

echo ""
echo "--- TC-06: Multiple HTTP Methods ---"

# TC-06a: template supports POST method
if [ -f "$CSRF_TMPL" ]; then
    has_post=$(grep -ci "post" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_post" -gt 0 ]; then
        test_case "TC-06a" "template supports POST method" 0
    else
        test_case "TC-06a" "template supports POST method" 1
    fi
else
    test_case "TC-06a" "template supports POST method" 1
fi

# TC-06b: template supports PUT/DELETE methods
if [ -f "$CSRF_TMPL" ]; then
    has_put_delete=$(grep -ci "put\|delete" "$CSRF_TMPL" 2>/dev/null || echo 0)
    if [ "$has_put_delete" -gt 0 ]; then
        test_case "TC-06b" "template supports PUT/DELETE methods" 0
    else
        test_case "TC-06b" "template supports PUT/DELETE methods" 1
    fi
else
    test_case "TC-06b" "template supports PUT/DELETE methods" 1
fi

echo ""
echo "--- TC-07: Error Handling ---"

# TC-07a: reference.md documents CSRF types
if [ -f "$REFERENCE_FILE" ]; then
    has_csrf_types=$(grep -ci "csrf.*type\|token.*missing\|samesite" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
    has_csrf_types=${has_csrf_types:-0}
    if [ "$has_csrf_types" -gt 0 ]; then
        test_case "TC-07a" "reference.md documents CSRF types" 0
    else
        test_case "TC-07a" "reference.md documents CSRF types" 1
    fi
else
    test_case "TC-07a" "reference.md documents CSRF types" 1
fi

# TC-07b: template has test.describe structure
if [ -f "$CSRF_TMPL" ]; then
    has_describe=$(grep -c "test.describe" "$CSRF_TMPL" 2>/dev/null || echo 0)
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
