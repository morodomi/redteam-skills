#!/bin/bash
#
# Test: attack-report skill structure
#
# TC-01: skills/attack-report/ directory exists
# TC-02: SKILL.md exists
# TC-03: YAML frontmatter (name, description) exists
# TC-04: Report structure (Summary, Vulnerabilities, Recommendations) is defined
# TC-05: Input format (security-scan JSON) is documented
# TC-06: Output format (Markdown) exists
# TC-07: reference.md exists
# TC-08: Usage instructions exist

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/plugins/redteam-core/skills/attack-report"
SKILL_FILE="$SKILL_DIR/SKILL.md"
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
echo "attack-report Skill Structure Test"
echo "================================"
echo ""

# TC-01: skills/attack-report/ directory exists
if [ -d "$SKILL_DIR" ]; then
    test_case "TC-01" "skills/attack-report/ directory exists" 0
else
    test_case "TC-01" "skills/attack-report/ directory exists" 1
fi

# TC-02: SKILL.md exists
if [ -f "$SKILL_FILE" ]; then
    test_case "TC-02" "SKILL.md exists" 0
else
    test_case "TC-02" "SKILL.md exists" 1
fi

# TC-03: YAML frontmatter (name, description) exists
if [ -f "$SKILL_FILE" ]; then
    has_frontmatter=$(head -1 "$SKILL_FILE" | grep -c "^---$")
    has_name=$(grep -c "^name:" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_description=$(grep -c "^description:" "$SKILL_FILE" 2>/dev/null || echo 0)

    if [ "$has_frontmatter" -gt 0 ] && [ "$has_name" -gt 0 ] && [ "$has_description" -gt 0 ]; then
        test_case "TC-03" "YAML frontmatter (name, description) exists" 0
    else
        test_case "TC-03" "YAML frontmatter (name, description) exists" 1
    fi
else
    test_case "TC-03" "YAML frontmatter (name, description) exists" 1
fi

# TC-04: Report structure (Summary, Vulnerabilities, Recommendations) is defined
if [ -f "$SKILL_FILE" ]; then
    has_summary=$(grep -ci "summary" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_vulns=$(grep -ci "vulnerabilities" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_recommend=$(grep -ci "recommend" "$SKILL_FILE" 2>/dev/null || echo 0)

    if [ "$has_summary" -gt 0 ] && [ "$has_vulns" -gt 0 ] && [ "$has_recommend" -gt 0 ]; then
        test_case "TC-04" "Report structure (Summary, Vulnerabilities, Recommendations) is defined" 0
    else
        test_case "TC-04" "Report structure (Summary, Vulnerabilities, Recommendations) is defined" 1
    fi
else
    test_case "TC-04" "Report structure (Summary, Vulnerabilities, Recommendations) is defined" 1
fi

# TC-05: Input format (security-scan JSON) is documented
if [ -f "$SKILL_FILE" ]; then
    has_input=$(grep -ci "input" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_security_scan=$(grep -ci "security-scan" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_json=$(grep -ci "json" "$SKILL_FILE" 2>/dev/null || echo 0)

    if [ "$has_input" -gt 0 ] && [ "$has_security_scan" -gt 0 ] && [ "$has_json" -gt 0 ]; then
        test_case "TC-05" "Input format (security-scan JSON) is documented" 0
    else
        test_case "TC-05" "Input format (security-scan JSON) is documented" 1
    fi
else
    test_case "TC-05" "Input format (security-scan JSON) is documented" 1
fi

# TC-06: Output format (Markdown) exists
if [ -f "$SKILL_FILE" ]; then
    has_output=$(grep -ci "output" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_markdown=$(grep -ci "markdown" "$SKILL_FILE" 2>/dev/null || echo 0)

    if [ "$has_output" -gt 0 ] && [ "$has_markdown" -gt 0 ]; then
        test_case "TC-06" "Output format (Markdown) exists" 0
    else
        test_case "TC-06" "Output format (Markdown) exists" 1
    fi
else
    test_case "TC-06" "Output format (Markdown) exists" 1
fi

# TC-07: reference.md exists
if [ -f "$REFERENCE_FILE" ]; then
    test_case "TC-07" "reference.md exists" 0
else
    test_case "TC-07" "reference.md exists" 1
fi

# TC-08: Usage instructions exist
if [ -f "$SKILL_FILE" ]; then
    has_usage=$(grep -ci "usage\|使用" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_command=$(grep -c "/attack-report" "$SKILL_FILE" 2>/dev/null || echo 0)

    if [ "$has_usage" -gt 0 ] || [ "$has_command" -gt 0 ]; then
        test_case "TC-08" "Usage instructions exist" 0
    else
        test_case "TC-08" "Usage instructions exist" 1
    fi
else
    test_case "TC-08" "Usage instructions exist" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
