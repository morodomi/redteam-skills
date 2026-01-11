#!/bin/bash
#
# Test: Report quality improvements (Issue #38)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_FILE="$PROJECT_ROOT/plugins/redteam-core/skills/attack-report/SKILL.md"
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
echo "Report Quality Improvements Test"
echo "========================================"
echo ""

# TC-01: Executive Summary section in SKILL.md
echo "--- TC-01: Executive Summary in SKILL.md ---"
has_exec=$(grep -ci "executive summary" "$SKILL_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_exec" -gt 0 ] 2>/dev/null; then
    test_case "TC-01" "Executive Summary section exists" 0
else
    test_case "TC-01" "Executive Summary section exists" 1
fi

# TC-02: Risk assessment guidance in SKILL.md
echo ""
echo "--- TC-02: Risk assessment in SKILL.md ---"
has_risk=$(grep -ci "リスク評価" "$SKILL_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_risk" -gt 0 ] 2>/dev/null; then
    test_case "TC-02" "Risk assessment guidance exists" 0
else
    test_case "TC-02" "Risk assessment guidance exists" 1
fi

# TC-03: Priority Top 3 in SKILL.md
echo ""
echo "--- TC-03: Priority Top 3 in SKILL.md ---"
has_top3=$(grep -ci "優先対応" "$SKILL_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_top3" -gt 0 ] 2>/dev/null; then
    test_case "TC-03" "Priority Top 3 template exists" 0
else
    test_case "TC-03" "Priority Top 3 template exists" 1
fi

# TC-04: Remediation Templates in reference.md
echo ""
echo "--- TC-04: Remediation Templates in reference.md ---"
has_remediation=$(grep -ci "Remediation Template" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_remediation" -gt 0 ] 2>/dev/null; then
    test_case "TC-04" "Remediation Templates section exists" 0
else
    test_case "TC-04" "Remediation Templates section exists" 1
fi

# TC-05: Laravel Remediation in reference.md
echo ""
echo "--- TC-05: Laravel Remediation in reference.md ---"
has_laravel=$(grep -c "Laravel" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_laravel" -gt 0 ] 2>/dev/null; then
    test_case "TC-05" "Laravel remediation exists" 0
else
    test_case "TC-05" "Laravel remediation exists" 1
fi

# TC-06: Django Remediation in reference.md
echo ""
echo "--- TC-06: Django Remediation in reference.md ---"
has_django=$(grep -c "Django" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_django" -gt 0 ] 2>/dev/null; then
    test_case "TC-06" "Django remediation exists" 0
else
    test_case "TC-06" "Django remediation exists" 1
fi

# TC-07: Express Remediation in reference.md
echo ""
echo "--- TC-07: Express Remediation in reference.md ---"
has_express=$(grep -c "Express" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_express" -gt 0 ] 2>/dev/null; then
    test_case "TC-07" "Express remediation exists" 0
else
    test_case "TC-07" "Express remediation exists" 1
fi

# TC-08: Glossary in reference.md
echo ""
echo "--- TC-08: Glossary in reference.md ---"
has_glossary=$(grep -ci "glossary\|用語集" "$REFERENCE_FILE" 2>/dev/null | head -1 || echo 0)
if [ "$has_glossary" -gt 0 ] 2>/dev/null; then
    test_case "TC-08" "Glossary section exists" 0
else
    test_case "TC-08" "Glossary section exists" 1
fi

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
