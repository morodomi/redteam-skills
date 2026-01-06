#!/bin/bash
#
# Test: e2e-auth Auth Bypass E2E test template
#
# TC-01: [正常系] unauthenticated-access検出結果からテスト生成
# TC-02: [正常系] privilege-escalation検出結果からテスト生成
# TC-03: [正常系] session-fixation検出結果からテスト生成
# TC-04: [正常系] idor検出結果からテスト生成
# TC-05: [境界値] Auth脆弱性0件時の処理
# TC-06: [エッジケース] 複数認証タイプ混在
# TC-07: [異常系] 不正なAuthタイプ指定時のエラー

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/plugins/redteam-core/skills/generate-e2e"
TEMPLATE_DIR="$SKILL_DIR/templates"
AUTH_TMPL="$TEMPLATE_DIR/auth.spec.ts.tmpl"
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
echo "e2e-auth Template Test"
echo "================================"
echo ""

# TC-01: Unauthenticated Access Template
echo "--- TC-01: Unauthenticated Access Template ---"

# TC-01a: auth.spec.ts.tmpl exists
if [ -f "$AUTH_TMPL" ]; then
    test_case "TC-01a" "auth.spec.ts.tmpl exists" 0
else
    test_case "TC-01a" "auth.spec.ts.tmpl exists" 1
fi

# TC-01b: template imports @playwright/test
if [ -f "$AUTH_TMPL" ]; then
    has_import=$(grep -c "@playwright/test" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_import" -gt 0 ]; then
        test_case "TC-01b" "template imports @playwright/test" 0
    else
        test_case "TC-01b" "template imports @playwright/test" 1
    fi
else
    test_case "TC-01b" "template imports @playwright/test" 1
fi

# TC-01c: template has unauthenticated access pattern
if [ -f "$AUTH_TMPL" ]; then
    has_unauth=$(grep -ci "unauthenticated\|without.*auth\|no.*auth" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_unauth" -gt 0 ]; then
        test_case "TC-01c" "template has unauthenticated access pattern" 0
    else
        test_case "TC-01c" "template has unauthenticated access pattern" 1
    fi
else
    test_case "TC-01c" "template has unauthenticated access pattern" 1
fi

# TC-01d: template checks 401/403 status
if [ -f "$AUTH_TMPL" ]; then
    has_status=$(grep -c "status()" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_status" -gt 0 ]; then
        test_case "TC-01d" "template checks response status" 0
    else
        test_case "TC-01d" "template checks response status" 1
    fi
else
    test_case "TC-01d" "template checks response status" 1
fi

echo ""
echo "--- TC-02: Privilege Escalation Template ---"

# TC-02a: template has privilege escalation pattern
if [ -f "$AUTH_TMPL" ]; then
    has_priv=$(grep -ci "privilege\|escalation\|admin\|regular.*user" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_priv" -gt 0 ]; then
        test_case "TC-02a" "template has privilege escalation pattern" 0
    else
        test_case "TC-02a" "template has privilege escalation pattern" 1
    fi
else
    test_case "TC-02a" "template has privilege escalation pattern" 1
fi

# TC-02b: template has authentication flow for regular user
if [ -f "$AUTH_TMPL" ]; then
    has_auth=$(grep -ci "login\|auth\|password" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_auth" -gt 0 ]; then
        test_case "TC-02b" "template has authentication flow" 0
    else
        test_case "TC-02b" "template has authentication flow" 1
    fi
else
    test_case "TC-02b" "template has authentication flow" 1
fi

echo ""
echo "--- TC-03: Session Fixation Template ---"

# TC-03a: template has session fixation pattern
if [ -f "$AUTH_TMPL" ]; then
    has_session=$(grep -ci "session.*fixation\|session.*id\|cookie.*before\|cookie.*after" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_session" -gt 0 ]; then
        test_case "TC-03a" "template has session fixation pattern" 0
    else
        test_case "TC-03a" "template has session fixation pattern" 1
    fi
else
    test_case "TC-03a" "template has session fixation pattern" 1
fi

# TC-03b: template compares session before/after login
if [ -f "$AUTH_TMPL" ]; then
    has_compare=$(grep -ci "before\|after" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_compare" -gt 0 ]; then
        test_case "TC-03b" "template compares session before/after" 0
    else
        test_case "TC-03b" "template compares session before/after" 1
    fi
else
    test_case "TC-03b" "template compares session before/after" 1
fi

echo ""
echo "--- TC-04: IDOR Template ---"

# TC-04a: template has IDOR pattern
if [ -f "$AUTH_TMPL" ]; then
    has_idor=$(grep -ci "idor\|other.*user\|user.*id\|resource" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_idor" -gt 0 ]; then
        test_case "TC-04a" "template has IDOR pattern" 0
    else
        test_case "TC-04a" "template has IDOR pattern" 1
    fi
else
    test_case "TC-04a" "template has IDOR pattern" 1
fi

# TC-04b: template uses request API for IDOR
if [ -f "$AUTH_TMPL" ]; then
    has_request=$(grep -c "request\.\(get\|post\|put\|delete\)" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_request" -gt 0 ]; then
        test_case "TC-04b" "template uses request API" 0
    else
        test_case "TC-04b" "template uses request API" 1
    fi
else
    test_case "TC-04b" "template uses request API" 1
fi

echo ""
echo "--- TC-05: Empty Vulnerabilities ---"

# TC-05a: reference.md documents Auth empty case
if [ -f "$REFERENCE_FILE" ]; then
    has_empty=$(grep -ci "auth.*0\|no.*auth\|empty" "$REFERENCE_FILE" 2>/dev/null || echo 0)
    if [ "$has_empty" -gt 0 ]; then
        test_case "TC-05a" "reference.md documents Auth empty case" 0
    else
        test_case "TC-05a" "reference.md documents Auth empty case" 1
    fi
else
    test_case "TC-05a" "reference.md documents Auth empty case" 1
fi

echo ""
echo "--- TC-06: Multiple Auth Types ---"

# TC-06a: template has test.describe structure
if [ -f "$AUTH_TMPL" ]; then
    has_describe=$(grep -c "test.describe" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$has_describe" -gt 0 ]; then
        test_case "TC-06a" "template has test.describe structure" 0
    else
        test_case "TC-06a" "template has test.describe structure" 1
    fi
else
    test_case "TC-06a" "template has test.describe structure" 1
fi

# TC-06b: template has multiple test cases
if [ -f "$AUTH_TMPL" ]; then
    test_count=$(grep -c "test('" "$AUTH_TMPL" 2>/dev/null || echo 0)
    if [ "$test_count" -ge 4 ]; then
        test_case "TC-06b" "template has multiple test cases (>=4)" 0
    else
        test_case "TC-06b" "template has multiple test cases (>=4)" 1
    fi
else
    test_case "TC-06b" "template has multiple test cases (>=4)" 1
fi

echo ""
echo "--- TC-07: Error Handling ---"

# TC-07a: reference.md documents Auth types
if [ -f "$REFERENCE_FILE" ]; then
    has_auth_types=$(grep -ci "auth.*type\|unauthenticated\|privilege\|session\|idor" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
    has_auth_types=${has_auth_types:-0}
    if [ "$has_auth_types" -gt 0 ]; then
        test_case "TC-07a" "reference.md documents Auth types" 0
    else
        test_case "TC-07a" "reference.md documents Auth types" 1
    fi
else
    test_case "TC-07a" "reference.md documents Auth types" 1
fi

# TC-07b: template has PURPOSE comment
if [ -f "$AUTH_TMPL" ]; then
    has_purpose=$(grep -ci "purpose\|warning" "$AUTH_TMPL" 2>/dev/null || echo 0)
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
