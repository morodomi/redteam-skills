#!/bin/bash
#
# Test: Auto Phase Transition feature
#
# TC-01: SKILL.md contains Auto Transition section
# TC-02: --no-auto-report option documented in SKILL.md
# TC-03: --auto-e2e option documented in SKILL.md
# TC-04: reference.md contains Auto Transition workflow
# TC-05: Skill call pattern exists (Skill(redteam-core:attack-report))

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
echo "Auto Phase Transition Test"
echo "================================"
echo ""

# TC-01: SKILL.md contains Auto Transition section
if grep -q "Auto Transition\|AUTO TRANSITION" "$SKILL_MD" 2>/dev/null; then
    test_case "TC-01" "SKILL.md contains Auto Transition section" 0
else
    test_case "TC-01" "SKILL.md contains Auto Transition section" 1
fi

# TC-02: --no-auto-report option documented in SKILL.md
if grep -q "\-\-no-auto-report" "$SKILL_MD" 2>/dev/null; then
    test_case "TC-02" "--no-auto-report option documented in SKILL.md" 0
else
    test_case "TC-02" "--no-auto-report option documented in SKILL.md" 1
fi

# TC-03: --auto-e2e option documented in SKILL.md
if grep -q "\-\-auto-e2e" "$SKILL_MD" 2>/dev/null; then
    test_case "TC-03" "--auto-e2e option documented in SKILL.md" 0
else
    test_case "TC-03" "--auto-e2e option documented in SKILL.md" 1
fi

# TC-04: reference.md contains Auto Transition workflow
if grep -q "Auto Transition\|AUTO TRANSITION" "$REFERENCE_MD" 2>/dev/null; then
    test_case "TC-04" "reference.md contains Auto Transition workflow" 0
else
    test_case "TC-04" "reference.md contains Auto Transition workflow" 1
fi

# TC-05: Skill call pattern exists
if grep -q "Skill(redteam-core:attack-report)" "$SKILL_MD" 2>/dev/null || \
   grep -q "Skill(redteam-core:attack-report)" "$REFERENCE_MD" 2>/dev/null; then
    test_case "TC-05" "Skill call pattern exists (attack-report)" 0
else
    test_case "TC-05" "Skill call pattern exists (attack-report)" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
