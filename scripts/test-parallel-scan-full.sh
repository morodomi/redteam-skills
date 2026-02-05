#!/bin/bash
#
# Test: Parallel Scan Full (13 agents)
#
# TC-01: --full-scan option documented in SKILL.md
# TC-02: Core Agents (5) listed in reference.md
# TC-03: Extended Agents (8) listed in reference.md
# TC-04: Total 13 agents documented
# TC-05: Core vs Extended categorization exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/plugins/redteam-core/skills/security-scan"
SKILL_MD="$SKILL_DIR/SKILL.md"
REFERENCE_MD="$SKILL_DIR/reference.md"

PASSED=0
FAILED=0

# Test helper
test_case() {
    local tc_id="$1"
    local description="$2"
    local result="$3"

    if [ "$result" = "0" ]; then
        echo "PASS $tc_id: $description"
        ((PASSED++))
    else
        echo "FAIL $tc_id: $description"
        ((FAILED++))
    fi
}

echo "================================"
echo "Parallel Scan Full Test"
echo "================================"
echo ""

# TC-01: --full-scan option documented in SKILL.md
if grep -q "\-\-full-scan" "$SKILL_MD" 2>/dev/null; then
    test_case "TC-01" "--full-scan option documented in SKILL.md" 0
else
    test_case "TC-01" "--full-scan option documented in SKILL.md" 1
fi

# TC-02: Core Agents (5) listed in reference.md
# Core: injection-attacker, xss-attacker, crypto-attacker, error-attacker, sca-attacker
CORE_COUNT=0
for agent in "injection-attacker" "xss-attacker" "crypto-attacker" "error-attacker" "sca-attacker"; do
    if grep -q "$agent" "$REFERENCE_MD" 2>/dev/null; then
        ((CORE_COUNT++))
    fi
done
if [ "$CORE_COUNT" -eq 5 ]; then
    test_case "TC-02" "Core Agents (5) listed in reference.md" 0
else
    test_case "TC-02" "Core Agents (5) listed in reference.md (found: $CORE_COUNT)" 1
fi

# TC-03: Extended Agents (8) listed in reference.md
# Extended: auth, api, file, ssrf, csrf, ssti, xxe, wordpress
EXTENDED_COUNT=0
for agent in "auth-attacker" "api-attacker" "file-attacker" "ssrf-attacker" "csrf-attacker" "ssti-attacker" "xxe-attacker" "wordpress-attacker"; do
    if grep -q "$agent" "$REFERENCE_MD" 2>/dev/null; then
        ((EXTENDED_COUNT++))
    fi
done
if [ "$EXTENDED_COUNT" -eq 8 ]; then
    test_case "TC-03" "Extended Agents (8) listed in reference.md" 0
else
    test_case "TC-03" "Extended Agents (8) listed in reference.md (found: $EXTENDED_COUNT)" 1
fi

# TC-04: Total 13 agents documented
TOTAL=$((CORE_COUNT + EXTENDED_COUNT))
if [ "$TOTAL" -eq 13 ]; then
    test_case "TC-04" "Total 13 agents documented" 0
else
    test_case "TC-04" "Total 13 agents documented (found: $TOTAL)" 1
fi

# TC-05: Core vs Extended categorization exists
if grep -q "Core Agent\|Core agent\|core agent" "$REFERENCE_MD" 2>/dev/null && \
   grep -q "Extended Agent\|Extended agent\|extended agent" "$REFERENCE_MD" 2>/dev/null; then
    test_case "TC-05" "Core vs Extended categorization exists" 0
else
    test_case "TC-05" "Core vs Extended categorization exists" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
