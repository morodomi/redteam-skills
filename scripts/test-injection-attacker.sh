#!/bin/bash
#
# Test: injection-attacker structure
#
# TC-01: injection-attacker.md exists
# TC-02: YAML frontmatter (name, description, allowed-tools) exists
# TC-03: Detection targets section (Union/Error/Boolean) exists
# TC-04: Framework detection pattern table exists
# TC-05: Dangerous patterns (Grep patterns) are defined
# TC-06: Output format (JSON schema) exists
# TC-07: Severity criteria exist
# TC-08: CWE/OWASP mapping exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/injection-attacker.md"

PASSED=0
FAILED=0

# Test helper
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
echo "injection-attacker Structure Test"
echo "================================"
echo ""

# TC-01: injection-attacker.md exists
if [ -f "$AGENT_FILE" ]; then
    test_case "TC-01" "injection-attacker.md exists" 0
else
    test_case "TC-01" "injection-attacker.md exists" 1
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

# TC-03: Detection targets section (Union/Error/Boolean) exists
if [ -f "$AGENT_FILE" ]; then
    has_union=$(grep -ci "union" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_error=$(grep -ci "error" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_boolean=$(grep -ci "boolean\|blind" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_union" -gt 0 ] && [ "$has_error" -gt 0 ] && [ "$has_boolean" -gt 0 ]; then
        test_case "TC-03" "Detection targets section (Union/Error/Boolean) exists" 0
    else
        test_case "TC-03" "Detection targets section (Union/Error/Boolean) exists" 1
    fi
else
    test_case "TC-03" "Detection targets section (Union/Error/Boolean) exists" 1
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
    has_db_raw=$(grep -ci "DB::raw\|whereRaw\|execute\|query" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_patterns" -gt 0 ] && [ "$has_db_raw" -gt 0 ]; then
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
    has_severity=$(grep -c '"severity"' "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_json_block" -gt 0 ] && [ "$has_vulnerabilities" -gt 0 ] && [ "$has_severity" -gt 0 ]; then
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
    has_cwe=$(grep -ci "CWE-89\|CWE" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_owasp=$(grep -ci "OWASP\|A03:2021" "$AGENT_FILE" 2>/dev/null || echo 0)

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
