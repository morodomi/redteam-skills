#!/bin/bash
#
# Test: attack-report-v2 (CVSS 4.0 extension)
#
# TC-01: reference.md has CVSS 4.0 Vector Mapping section
# TC-02: reference.md has CWE/OWASP Mapping section
# TC-03: reference.md has link templates
# TC-04: SKILL.md output format includes CVSS score
# TC-05: SKILL.md output format includes References section
# TC-06: SKILL.md has CVSS sorting explanation
# TC-07: Main vulnerability types (SQLi, XSS, Auth, API) have CVSS mappings
# TC-08: CWE/OWASP links are in correct format

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_FILE="$PROJECT_ROOT/plugins/redteam-core/skills/attack-report/SKILL.md"
REF_FILE="$PROJECT_ROOT/plugins/redteam-core/skills/attack-report/reference.md"

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
echo "attack-report-v2 Structure Test"
echo "================================"
echo ""

# TC-01: reference.md has CVSS 4.0 Vector Mapping section
if [ -f "$REF_FILE" ]; then
    has_cvss_section=$(grep -ci "CVSS.*4\.0.*Vector.*Mapping\|Vector.*Mapping" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_cvss_prefix=$(grep -c "CVSS:4.0" "$REF_FILE" 2>/dev/null | head -1 || echo 0)

    if [ "$has_cvss_section" -gt 0 ] && [ "$has_cvss_prefix" -gt 0 ]; then
        test_case "TC-01" "reference.md has CVSS 4.0 Vector Mapping section" 0
    else
        test_case "TC-01" "reference.md has CVSS 4.0 Vector Mapping section" 1
    fi
else
    test_case "TC-01" "reference.md has CVSS 4.0 Vector Mapping section" 1
fi

# TC-02: reference.md has CWE/OWASP Mapping section
if [ -f "$REF_FILE" ]; then
    has_cwe_section=$(grep -ciE "CWE.*OWASP.*Mapping|CWE/OWASP" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_cwe=$(grep -c "CWE-" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_owasp=$(grep -cE "A0[1-9]:2021|API[1-9]:2023" "$REF_FILE" 2>/dev/null | head -1 || echo 0)

    if [ "$has_cwe_section" -gt 0 ] && [ "$has_cwe" -gt 0 ] && [ "$has_owasp" -gt 0 ]; then
        test_case "TC-02" "reference.md has CWE/OWASP Mapping section" 0
    else
        test_case "TC-02" "reference.md has CWE/OWASP Mapping section" 1
    fi
else
    test_case "TC-02" "reference.md has CWE/OWASP Mapping section" 1
fi

# TC-03: reference.md has link templates
if [ -f "$REF_FILE" ]; then
    has_cwe_link=$(grep -c "cwe.mitre.org" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_owasp_link=$(grep -c "owasp.org/Top10/2021" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_api_link=$(grep -c "owasp.org/API-Security" "$REF_FILE" 2>/dev/null | head -1 || echo 0)

    if [ "$has_cwe_link" -gt 0 ] && [ "$has_owasp_link" -gt 0 ] && [ "$has_api_link" -gt 0 ]; then
        test_case "TC-03" "reference.md has link templates" 0
    else
        test_case "TC-03" "reference.md has link templates" 1
    fi
else
    test_case "TC-03" "reference.md has link templates" 1
fi

# TC-04: SKILL.md output format includes CVSS score
if [ -f "$SKILL_FILE" ]; then
    has_cvss_output=$(grep -ciE "CVSS.*4\.0|CVSS:4.0" "$SKILL_FILE" 2>/dev/null | head -1 || echo 0)

    if [ "$has_cvss_output" -gt 0 ]; then
        test_case "TC-04" "SKILL.md output format includes CVSS score" 0
    else
        test_case "TC-04" "SKILL.md output format includes CVSS score" 1
    fi
else
    test_case "TC-04" "SKILL.md output format includes CVSS score" 1
fi

# TC-05: SKILL.md output format includes References section
if [ -f "$SKILL_FILE" ]; then
    has_references=$(grep -cE "\*\*References\*\*|## References" "$SKILL_FILE" 2>/dev/null | head -1 || echo 0)
    has_cwe_ref=$(grep -c "CWE-[0-9]" "$SKILL_FILE" 2>/dev/null | head -1 || echo 0)

    if [ "$has_references" -gt 0 ] && [ "$has_cwe_ref" -gt 0 ]; then
        test_case "TC-05" "SKILL.md output format includes References section" 0
    else
        test_case "TC-05" "SKILL.md output format includes References section" 1
    fi
else
    test_case "TC-05" "SKILL.md output format includes References section" 1
fi

# TC-06: SKILL.md has CVSS sorting explanation
if [ -f "$SKILL_FILE" ]; then
    has_sort=$(grep -ciE "sort|順|priority|優先" "$SKILL_FILE" 2>/dev/null | head -1 || echo 0)

    if [ "$has_sort" -gt 0 ]; then
        test_case "TC-06" "SKILL.md has CVSS sorting explanation" 0
    else
        test_case "TC-06" "SKILL.md has CVSS sorting explanation" 1
    fi
else
    test_case "TC-06" "SKILL.md has CVSS sorting explanation" 1
fi

# TC-07: Main vulnerability types (SQLi, XSS, Auth, API) have CVSS mappings
if [ -f "$REF_FILE" ]; then
    has_sqli=$(grep -ciE "sql-injection.*CVSS|sql.*injection.*AV:" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_xss=$(grep -ciE "xss.*CVSS|xss.*AV:" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_auth=$(grep -ciE "hardcoded|missing-auth|broken-access" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_api=$(grep -ciE "mass-assignment|bola|rate-limiting" "$REF_FILE" 2>/dev/null | head -1 || echo 0)

    if [ "$has_sqli" -gt 0 ] && [ "$has_xss" -gt 0 ] && [ "$has_auth" -gt 0 ] && [ "$has_api" -gt 0 ]; then
        test_case "TC-07" "Main vulnerability types (SQLi, XSS, Auth, API) have CVSS mappings" 0
    else
        test_case "TC-07" "Main vulnerability types (SQLi, XSS, Auth, API) have CVSS mappings" 1
    fi
else
    test_case "TC-07" "Main vulnerability types (SQLi, XSS, Auth, API) have CVSS mappings" 1
fi

# TC-08: CWE/OWASP links are in correct format
if [ -f "$REF_FILE" ]; then
    # Check for correct URL formats
    has_cwe_format=$(grep -cE "https://cwe.mitre.org/data/definitions/[0-9]+\.html" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_owasp_format=$(grep -cE "https://owasp.org/Top10/2021/A[0-9]+_2021" "$REF_FILE" 2>/dev/null | head -1 || echo 0)
    has_api_format=$(grep -c "https://owasp.org/API-Security/editions/2023" "$REF_FILE" 2>/dev/null | head -1 || echo 0)

    if [ "$has_cwe_format" -gt 0 ] && [ "$has_owasp_format" -gt 0 ] && [ "$has_api_format" -gt 0 ]; then
        test_case "TC-08" "CWE/OWASP links are in correct format" 0
    else
        test_case "TC-08" "CWE/OWASP links are in correct format" 1
    fi
else
    test_case "TC-08" "CWE/OWASP links are in correct format" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
