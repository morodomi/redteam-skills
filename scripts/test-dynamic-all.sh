#!/bin/bash
#
# Test: dynamic-verifier all verification types (Issue #36)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERIFIER_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/dynamic-verifier.md"

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
echo "dynamic-verifier All Types Test"
echo "========================================"
echo ""

# TC-01: SQLi検証
echo "--- TC-01: SQLi verification ---"
has_sqli=$(grep -c "SQLi" "$VERIFIER_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_sqli" -gt 0 ] 2>/dev/null; then
    test_case "TC-01" "SQLi verification exists" 0
else
    test_case "TC-01" "SQLi verification exists" 1
fi

# TC-02: XSS検証
echo ""
echo "--- TC-02: XSS verification ---"
has_xss=$(grep -c "XSS" "$VERIFIER_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_xss" -gt 0 ] 2>/dev/null; then
    test_case "TC-02" "XSS verification exists" 0
else
    test_case "TC-02" "XSS verification exists" 1
fi

# TC-03: Auth検証
echo ""
echo "--- TC-03: Auth verification ---"
has_auth=$(grep -c "Auth Verification" "$VERIFIER_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_auth" -gt 0 ] 2>/dev/null; then
    test_case "TC-03" "Auth verification exists" 0
else
    test_case "TC-03" "Auth verification exists" 1
fi

# TC-04: CSRF検証
echo ""
echo "--- TC-04: CSRF verification ---"
has_csrf=$(grep -c "CSRF Verification" "$VERIFIER_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_csrf" -gt 0 ] 2>/dev/null; then
    test_case "TC-04" "CSRF verification exists" 0
else
    test_case "TC-04" "CSRF verification exists" 1
fi

# TC-05: SSRF検証
echo ""
echo "--- TC-05: SSRF verification ---"
has_ssrf=$(grep -c "SSRF Verification" "$VERIFIER_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_ssrf" -gt 0 ] 2>/dev/null; then
    test_case "TC-05" "SSRF verification exists" 0
else
    test_case "TC-05" "SSRF verification exists" 1
fi

# TC-06: File検証
echo ""
echo "--- TC-06: File verification ---"
has_file=$(grep -c "File Verification" "$VERIFIER_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_file" -gt 0 ] 2>/dev/null; then
    test_case "TC-06" "File verification exists" 0
else
    test_case "TC-06" "File verification exists" 1
fi

# TC-07: Detection Target表に全タイプ
echo ""
echo "--- TC-07: All types in Detection Target ---"
has_all_flags=$(grep -c "enable-dynamic" "$VERIFIER_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_all_flags" -ge 5 ] 2>/dev/null; then
    test_case "TC-07" "All dynamic flags documented" 0
else
    test_case "TC-07" "All dynamic flags documented" 1
fi

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
