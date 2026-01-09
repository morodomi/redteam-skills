#!/bin/bash
#
# Test: CVSS Mapping completeness (Issue #37)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REFERENCE_FILE="$PROJECT_ROOT/plugins/redteam-core/skills/attack-report/reference.md"

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
echo "CVSS Mapping Completeness Test"
echo "========================================"
echo ""

# TC-01: ssti CVSS mapping
echo "--- TC-01: ssti CVSS mapping ---"
has_ssti=$(grep -c "| ssti |" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_ssti" -gt 0 ] 2>/dev/null; then
    test_case "TC-01" "ssti CVSS mapping exists" 0
else
    test_case "TC-01" "ssti CVSS mapping exists" 1
fi

# TC-02: xxe CVSS mapping
echo ""
echo "--- TC-02: xxe CVSS mapping ---"
has_xxe=$(grep -c "| xxe |" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_xxe" -gt 0 ] 2>/dev/null; then
    test_case "TC-02" "xxe CVSS mapping exists" 0
else
    test_case "TC-02" "xxe CVSS mapping exists" 1
fi

# TC-03: object-injection CVSS mapping
echo ""
echo "--- TC-03: object-injection CVSS mapping ---"
has_obj=$(grep -c "| object-injection |" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_obj" -gt 0 ] 2>/dev/null; then
    test_case "TC-03" "object-injection CVSS mapping exists" 0
else
    test_case "TC-03" "object-injection CVSS mapping exists" 1
fi

# TC-04: ssti-attacker in Agent to Type Mapping
echo ""
echo "--- TC-04: ssti-attacker Agent mapping ---"
has_ssti_agent=$(grep -c "ssti-attacker" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_ssti_agent" -gt 0 ] 2>/dev/null; then
    test_case "TC-04" "ssti-attacker in Agent mapping" 0
else
    test_case "TC-04" "ssti-attacker in Agent mapping" 1
fi

# TC-05: xxe-attacker in Agent to Type Mapping
echo ""
echo "--- TC-05: xxe-attacker Agent mapping ---"
has_xxe_agent=$(grep -c "xxe-attacker" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_xxe_agent" -gt 0 ] 2>/dev/null; then
    test_case "TC-05" "xxe-attacker in Agent mapping" 0
else
    test_case "TC-05" "xxe-attacker in Agent mapping" 1
fi

# TC-06: wordpress-attacker in Agent to Type Mapping
echo ""
echo "--- TC-06: wordpress-attacker Agent mapping ---"
has_wp_agent=$(grep -c "wordpress-attacker" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_wp_agent" -gt 0 ] 2>/dev/null; then
    test_case "TC-06" "wordpress-attacker in Agent mapping" 0
else
    test_case "TC-06" "wordpress-attacker in Agent mapping" 1
fi

# TC-07: ssti in CWE/OWASP Mapping
echo ""
echo "--- TC-07: ssti CWE/OWASP mapping ---"
has_ssti_cwe=$(grep -c "| ssti | CWE-" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_ssti_cwe" -gt 0 ] 2>/dev/null; then
    test_case "TC-07" "ssti CWE/OWASP mapping exists" 0
else
    test_case "TC-07" "ssti CWE/OWASP mapping exists" 1
fi

# TC-08: xxe in CWE/OWASP Mapping
echo ""
echo "--- TC-08: xxe CWE/OWASP mapping ---"
has_xxe_cwe=$(grep -c "| xxe | CWE-" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_xxe_cwe" -gt 0 ] 2>/dev/null; then
    test_case "TC-08" "xxe CWE/OWASP mapping exists" 0
else
    test_case "TC-08" "xxe CWE/OWASP mapping exists" 1
fi

# TC-09: object-injection in CWE/OWASP Mapping
echo ""
echo "--- TC-09: object-injection CWE/OWASP mapping ---"
has_obj_cwe=$(grep -c "| object-injection | CWE-" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_obj_cwe" -gt 0 ] 2>/dev/null; then
    test_case "TC-09" "object-injection CWE/OWASP mapping exists" 0
else
    test_case "TC-09" "object-injection CWE/OWASP mapping exists" 1
fi

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
