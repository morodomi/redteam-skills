#!/bin/bash
#
# Test: security-scan skill structure
#
# TC-01: skills/security-scan/ directory exists
# TC-02: SKILL.md exists
# TC-03: YAML frontmatter (name, description) exists
# TC-04: Workflow (RECON/SCAN/REPORT) is defined
# TC-05: Agent integration (recon-agent, injection-attacker, xss-attacker) is documented
# TC-06: Output format (JSON schema) exists
# TC-07: reference.md exists
# TC-08: Usage instructions exist

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/plugins/redteam-core/skills/security-scan"
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
echo "security-scan Skill Structure Test"
echo "================================"
echo ""

# TC-01: skills/security-scan/ directory exists
if [ -d "$SKILL_DIR" ]; then
    test_case "TC-01" "skills/security-scan/ directory exists" 0
else
    test_case "TC-01" "skills/security-scan/ directory exists" 1
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

# TC-04: Workflow (RECON/SCAN/REPORT) is defined
if [ -f "$SKILL_FILE" ]; then
    has_recon=$(grep -ci "recon" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_scan=$(grep -ci "scan" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_report=$(grep -ci "report" "$SKILL_FILE" 2>/dev/null || echo 0)

    if [ "$has_recon" -gt 0 ] && [ "$has_scan" -gt 0 ] && [ "$has_report" -gt 0 ]; then
        test_case "TC-04" "Workflow (RECON/SCAN/REPORT) is defined" 0
    else
        test_case "TC-04" "Workflow (RECON/SCAN/REPORT) is defined" 1
    fi
else
    test_case "TC-04" "Workflow (RECON/SCAN/REPORT) is defined" 1
fi

# TC-05: Agent integration (recon-agent, injection-attacker, xss-attacker) is documented
# Check in SKILL.md or reference.md (Progressive Disclosure)
has_recon_agent=$(grep -ci "recon-agent" "$SKILL_FILE" "$REFERENCE_FILE" 2>/dev/null | grep -v ":0$" | wc -l)
has_injection=$(grep -ci "injection-attacker" "$SKILL_FILE" "$REFERENCE_FILE" 2>/dev/null | grep -v ":0$" | wc -l)
has_xss=$(grep -ci "xss-attacker" "$SKILL_FILE" "$REFERENCE_FILE" 2>/dev/null | grep -v ":0$" | wc -l)

if [ "$has_recon_agent" -gt 0 ] && [ "$has_injection" -gt 0 ] && [ "$has_xss" -gt 0 ]; then
    test_case "TC-05" "Agent integration (recon-agent, injection-attacker, xss-attacker) is documented" 0
else
    test_case "TC-05" "Agent integration (recon-agent, injection-attacker, xss-attacker) is documented" 1
fi

# TC-06: Output format (JSON schema) exists
# Check in SKILL.md or reference.md (Progressive Disclosure)
has_json_block=$(grep -c '```json' "$SKILL_FILE" "$REFERENCE_FILE" 2>/dev/null | grep -v ":0$" | wc -l)
has_vulnerabilities=$(grep -c '"vulnerabilities"' "$SKILL_FILE" "$REFERENCE_FILE" 2>/dev/null | grep -v ":0$" | wc -l)

if [ "$has_json_block" -gt 0 ] && [ "$has_vulnerabilities" -gt 0 ]; then
    test_case "TC-06" "Output format (JSON schema) exists" 0
else
    test_case "TC-06" "Output format (JSON schema) exists" 1
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
    has_command=$(grep -c "/security-scan" "$SKILL_FILE" 2>/dev/null || echo 0)

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
