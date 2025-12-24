#!/bin/bash
#
# Test: recon-agent structure
#
# TC-01: recon-agent.md exists
# TC-02: YAML frontmatter (name, description, allowed-tools) exists
# TC-03: Detection targets section exists
# TC-04: Framework detection table exists (Laravel, Django, Flask, Express)
# TC-05: Scan scope (include/exclude) is defined
# TC-06: Sensitive data exclusion rules exist
# TC-07: Output format (JSON schema) exists
# TC-08: Attack priority criteria exist

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/recon-agent.md"

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
echo "recon-agent Structure Test"
echo "================================"
echo ""

# TC-01: recon-agent.md exists
if [ -f "$AGENT_FILE" ]; then
    test_case "TC-01" "recon-agent.md exists" 0
else
    test_case "TC-01" "recon-agent.md exists" 1
fi

# TC-02: YAML frontmatter (name, description, allowed-tools) exists
if [ -f "$AGENT_FILE" ]; then
    # Check for YAML frontmatter markers and required fields
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

# TC-03: Detection targets section exists
if [ -f "$AGENT_FILE" ]; then
    # Check for detection targets: endpoint, tech stack, attack priority
    has_endpoint=$(grep -ci "endpoint" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_tech_stack=$(grep -ci "tech.stack\|技術スタック" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_priority=$(grep -ci "priority\|優先" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_endpoint" -gt 0 ] && [ "$has_tech_stack" -gt 0 ] && [ "$has_priority" -gt 0 ]; then
        test_case "TC-03" "Detection targets section exists" 0
    else
        test_case "TC-03" "Detection targets section exists" 1
    fi
else
    test_case "TC-03" "Detection targets section exists" 1
fi

# TC-04: Framework detection table exists (Laravel, Django, Flask, Express)
if [ -f "$AGENT_FILE" ]; then
    has_laravel=$(grep -ci "laravel" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_django=$(grep -ci "django" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_flask=$(grep -ci "flask" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_express=$(grep -ci "express" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_laravel" -gt 0 ] && [ "$has_django" -gt 0 ] && [ "$has_flask" -gt 0 ] && [ "$has_express" -gt 0 ]; then
        test_case "TC-04" "Framework detection table exists (Laravel, Django, Flask, Express)" 0
    else
        test_case "TC-04" "Framework detection table exists (Laravel, Django, Flask, Express)" 1
    fi
else
    test_case "TC-04" "Framework detection table exists (Laravel, Django, Flask, Express)" 1
fi

# TC-05: Scan scope (include/exclude) is defined
if [ -f "$AGENT_FILE" ]; then
    has_include=$(grep -c "include:" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_exclude=$(grep -c "exclude:" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_include" -gt 0 ] && [ "$has_exclude" -gt 0 ]; then
        test_case "TC-05" "Scan scope (include/exclude) is defined" 0
    else
        test_case "TC-05" "Scan scope (include/exclude) is defined" 1
    fi
else
    test_case "TC-05" "Scan scope (include/exclude) is defined" 1
fi

# TC-06: Sensitive data exclusion rules exist
if [ -f "$AGENT_FILE" ]; then
    # Check for sensitive data keywords
    has_password=$(grep -ci "password\|secret\|key\|token" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_exclusion=$(grep -ci "除外\|exclusion\|収集しない\|do not collect" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_password" -gt 0 ] && [ "$has_exclusion" -gt 0 ]; then
        test_case "TC-06" "Sensitive data exclusion rules exist" 0
    else
        test_case "TC-06" "Sensitive data exclusion rules exist" 1
    fi
else
    test_case "TC-06" "Sensitive data exclusion rules exist" 1
fi

# TC-07: Output format (JSON schema) exists
if [ -f "$AGENT_FILE" ]; then
    # Check for JSON output format with key fields
    has_json_block=$(grep -c '```json' "$AGENT_FILE" 2>/dev/null || echo 0)
    has_metadata=$(grep -c '"metadata"' "$AGENT_FILE" 2>/dev/null || echo 0)
    has_endpoints=$(grep -c '"endpoints"' "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_json_block" -gt 0 ] && [ "$has_metadata" -gt 0 ] && [ "$has_endpoints" -gt 0 ]; then
        test_case "TC-07" "Output format (JSON schema) exists" 0
    else
        test_case "TC-07" "Output format (JSON schema) exists" 1
    fi
else
    test_case "TC-07" "Output format (JSON schema) exists" 1
fi

# TC-08: Attack priority criteria exist
if [ -f "$AGENT_FILE" ]; then
    has_critical=$(grep -ci "critical" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_high=$(grep -ci "high" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_medium=$(grep -ci "medium" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_low=$(grep -ci "low" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_critical" -gt 0 ] && [ "$has_high" -gt 0 ] && [ "$has_medium" -gt 0 ] && [ "$has_low" -gt 0 ]; then
        test_case "TC-08" "Attack priority criteria exist" 0
    else
        test_case "TC-08" "Attack priority criteria exist" 1
    fi
else
    test_case "TC-08" "Attack priority criteria exist" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
