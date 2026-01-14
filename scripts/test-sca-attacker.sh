#!/bin/bash
#
# Test: sca-attacker structure
#
# TC-01: sca-attacker.md exists with package.json dependencies detection
# TC-02: YAML frontmatter (name, description, allowed-tools) exists
# TC-03: Detection Targets table (package.json, composer.json, etc.) exists
# TC-04: OSV API integration section exists
# TC-05: Output format (JSON schema with package/version/ecosystem) exists
# TC-06: Version Resolution Strategy exists
# TC-07: Fallback Strategy exists
# TC-08: CWE/OWASP mapping exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/sca-attacker.md"

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
echo "sca-attacker Structure Test"
echo "================================"
echo ""

# TC-01: sca-attacker.md exists
if [ -f "$AGENT_FILE" ]; then
    # Check for package.json dependencies detection
    has_package_json=$(grep -ci "package.json" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_dependencies=$(grep -ci "dependencies" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_package_json" -gt 0 ] && [ "$has_dependencies" -gt 0 ]; then
        test_case "TC-01" "sca-attacker.md exists with package.json dependencies detection" 0
    else
        test_case "TC-01" "sca-attacker.md exists with package.json dependencies detection" 1
    fi
else
    test_case "TC-01" "sca-attacker.md exists with package.json dependencies detection" 1
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

# TC-03: Detection Targets table (package.json, composer.json, etc.) exists
if [ -f "$AGENT_FILE" ]; then
    has_package_json=$(grep -ci "package.json" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_composer_json=$(grep -ci "composer.json" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_requirements=$(grep -ci "requirements.txt" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_gemfile=$(grep -ci "Gemfile" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_go_mod=$(grep -ci "go.mod" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_package_json" -gt 0 ] && [ "$has_composer_json" -gt 0 ] && [ "$has_requirements" -gt 0 ] && [ "$has_gemfile" -gt 0 ] && [ "$has_go_mod" -gt 0 ]; then
        test_case "TC-03" "Detection Targets table exists" 0
    else
        test_case "TC-03" "Detection Targets table exists" 1
    fi
else
    test_case "TC-03" "Detection Targets table exists" 1
fi

# TC-04: OSV API integration section exists
if [ -f "$AGENT_FILE" ]; then
    has_osv=$(grep -ci "OSV" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_api=$(grep -ci "api.osv.dev" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_querybatch=$(grep -ci "querybatch" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_osv" -gt 0 ] && [ "$has_api" -gt 0 ] && [ "$has_querybatch" -gt 0 ]; then
        test_case "TC-04" "OSV API integration section exists" 0
    else
        test_case "TC-04" "OSV API integration section exists" 1
    fi
else
    test_case "TC-04" "OSV API integration section exists" 1
fi

# TC-05: Output format (JSON schema with package/version/ecosystem) exists
if [ -f "$AGENT_FILE" ]; then
    has_json_block=$(grep -c '```json' "$AGENT_FILE" 2>/dev/null || echo 0)
    has_package=$(grep -c '"package"' "$AGENT_FILE" 2>/dev/null || echo 0)
    has_version=$(grep -c '"version"' "$AGENT_FILE" 2>/dev/null || echo 0)
    has_ecosystem=$(grep -c '"ecosystem"' "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_json_block" -gt 0 ] && [ "$has_package" -gt 0 ] && [ "$has_version" -gt 0 ] && [ "$has_ecosystem" -gt 0 ]; then
        test_case "TC-05" "Output format (JSON schema) exists" 0
    else
        test_case "TC-05" "Output format (JSON schema) exists" 1
    fi
else
    test_case "TC-05" "Output format (JSON schema) exists" 1
fi

# TC-06: Version Resolution Strategy exists
if [ -f "$AGENT_FILE" ]; then
    has_version_strategy=$(grep -ci "Version.*Resolution\|Resolution.*Strategy" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_caret=$(grep -c '\^' "$AGENT_FILE" 2>/dev/null || echo 0)
    has_tilde=$(grep -c '~' "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_version_strategy" -gt 0 ] && [ "$has_caret" -gt 0 ]; then
        test_case "TC-06" "Version Resolution Strategy exists" 0
    else
        test_case "TC-06" "Version Resolution Strategy exists" 1
    fi
else
    test_case "TC-06" "Version Resolution Strategy exists" 1
fi

# TC-07: Fallback Strategy exists
if [ -f "$AGENT_FILE" ]; then
    has_fallback=$(grep -ci "Fallback\|timeout\|retry" "$AGENT_FILE" 2>/dev/null || echo 0)

    if [ "$has_fallback" -gt 0 ]; then
        test_case "TC-07" "Fallback Strategy exists" 0
    else
        test_case "TC-07" "Fallback Strategy exists" 1
    fi
else
    test_case "TC-07" "Fallback Strategy exists" 1
fi

# TC-08: CWE/OWASP mapping exists
if [ -f "$AGENT_FILE" ]; then
    has_cwe=$(grep -ci "CWE-1395\|CWE" "$AGENT_FILE" 2>/dev/null || echo 0)
    has_owasp=$(grep -ci "OWASP\|A06:2021" "$AGENT_FILE" 2>/dev/null || echo 0)

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
