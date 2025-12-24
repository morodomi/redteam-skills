#!/bin/bash
#
# Test: api-attacker structure
#
# TC-01: api-attacker.md exists
# TC-02: YAML frontmatter (name, description, allowed-tools) exists
# TC-03: Detection targets section (Mass Assignment, BOLA, Rate Limiting) exists
# TC-04: Framework detection pattern table exists
# TC-05: Dangerous patterns (Grep patterns) are defined
# TC-06: Output format (JSON schema) exists
# TC-07: Severity criteria exist
# TC-08: CWE/OWASP mapping exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/api-attacker.md"

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
echo "api-attacker Structure Test"
echo "================================"
echo ""

# TC-01: api-attacker.md exists
if [ -f "$AGENT_FILE" ]; then
    test_case "TC-01" "api-attacker.md exists" 0
else
    test_case "TC-01" "api-attacker.md exists" 1
fi

# TC-02: YAML frontmatter (name, description, allowed-tools) exists
if [ -f "$AGENT_FILE" ]; then
    has_frontmatter=$(head -1 "$AGENT_FILE" | grep -c "^---$")
    has_name=$(grep -c "^name:" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_description=$(grep -c "^description:" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_allowed_tools=$(grep -c "^allowed-tools:" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_frontmatter" -gt 0 ] && [ "$has_name" -gt 0 ] && [ "$has_description" -gt 0 ] && [ "$has_allowed_tools" -gt 0 ]; then
        test_case "TC-02" "YAML frontmatter (name, description, allowed-tools) exists" 0
    else
        test_case "TC-02" "YAML frontmatter (name, description, allowed-tools) exists" 1
    fi
else
    test_case "TC-02" "YAML frontmatter (name, description, allowed-tools) exists" 1
fi

# TC-03: Detection targets section (Mass Assignment, BOLA, Rate Limiting) exists
if [ -f "$AGENT_FILE" ]; then
    has_mass=$(grep -ci "mass.*assignment" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_bola=$(grep -ci "bola\|object.*level.*auth" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_rate=$(grep -ci "rate.*limit" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_mass" -gt 0 ] && [ "$has_bola" -gt 0 ] && [ "$has_rate" -gt 0 ]; then
        test_case "TC-03" "Detection targets section (Mass Assignment, BOLA, Rate Limiting) exists" 0
    else
        test_case "TC-03" "Detection targets section (Mass Assignment, BOLA, Rate Limiting) exists" 1
    fi
else
    test_case "TC-03" "Detection targets section (Mass Assignment, BOLA, Rate Limiting) exists" 1
fi

# TC-04: Framework detection pattern table exists
if [ -f "$AGENT_FILE" ]; then
    has_laravel=$(grep -ci "laravel" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_django=$(grep -ci "django" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_flask=$(grep -ci "flask" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_express=$(grep -ci "express" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_laravel" -gt 0 ] && [ "$has_django" -gt 0 ] && [ "$has_flask" -gt 0 ] && [ "$has_express" -gt 0 ]; then
        test_case "TC-04" "Framework detection pattern table exists" 0
    else
        test_case "TC-04" "Framework detection pattern table exists" 1
    fi
else
    test_case "TC-04" "Framework detection pattern table exists" 1
fi

# TC-05: Dangerous patterns (Grep patterns) are defined
if [ -f "$AGENT_FILE" ]; then
    has_patterns=$(grep -c "patterns:" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_api_patterns=$(grep -ci "request->all\|find\|create" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_patterns" -gt 0 ] && [ "$has_api_patterns" -gt 0 ]; then
        test_case "TC-05" "Dangerous patterns (Grep patterns) are defined" 0
    else
        test_case "TC-05" "Dangerous patterns (Grep patterns) are defined" 1
    fi
else
    test_case "TC-05" "Dangerous patterns (Grep patterns) are defined" 1
fi

# TC-06: Output format (JSON schema) exists
if [ -f "$AGENT_FILE" ]; then
    has_json_block=$(grep -c '```json' "$AGENT_FILE" 2>/dev/null || echo 0)
    has_vulnerabilities=$(grep -c '"vulnerabilities"' "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_json_block" -gt 0 ] && [ "$has_vulnerabilities" -gt 0 ]; then
        test_case "TC-06" "Output format (JSON schema) exists" 0
    else
        test_case "TC-06" "Output format (JSON schema) exists" 1
    fi
else
    test_case "TC-06" "Output format (JSON schema) exists" 1
fi

# TC-07: Severity criteria exist
if [ -f "$AGENT_FILE" ]; then
    has_critical=$(grep -ci "critical" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_high=$(grep -ci "high" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_medium=$(grep -ci "medium" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_low=$(grep -ci "low" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_critical" -gt 0 ] && [ "$has_high" -gt 0 ] && [ "$has_medium" -gt 0 ] && [ "$has_low" -gt 0 ]; then
        test_case "TC-07" "Severity criteria exist" 0
    else
        test_case "TC-07" "Severity criteria exist" 1
    fi
else
    test_case "TC-07" "Severity criteria exist" 1
fi

# TC-08: CWE/OWASP mapping exists
if [ -f "$AGENT_FILE" ]; then
    has_cwe=$(grep -ci "CWE-915\|CWE-639\|CWE" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_owasp=$(grep -ci "OWASP\|API1\|API3" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_cwe" -gt 0 ] && [ "$has_owasp" -gt 0 ]; then
        test_case "TC-08" "CWE/OWASP mapping exists" 0
    else
        test_case "TC-08" "CWE/OWASP mapping exists" 1
    fi
else
    test_case "TC-08" "CWE/OWASP mapping exists" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
