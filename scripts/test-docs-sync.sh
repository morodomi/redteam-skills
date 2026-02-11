#!/bin/bash
#
# Test: Documentation sync (README.ja.md + CLAUDE.md)
#
# TC-01: README.ja.md has at least 2 badges
# TC-02: README.ja.md has Quick Start section
# TC-03: README.ja.md has 18+ agents listed
# TC-04: README.ja.md contains v4.2.0
# TC-05: CLAUDE.md has 18+ agents listed
# TC-06: CLAUDE.md contains v4.2.0
# TC-07: README.ja.md is 300 lines or less
# TC-08: No broken relative links in README.ja.md / CLAUDE.md

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
README_JA="$PROJECT_ROOT/README.ja.md"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

PASSED=0
FAILED=0

test_case() {
    local tc_id="$1"
    local description="$2"
    local result="$3"

    if [ "$result" = "0" ]; then
        echo "  PASS $tc_id: $description"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL $tc_id: $description"
        FAILED=$((FAILED + 1))
    fi
}

echo "================================"
echo "Docs Sync Test"
echo "================================"
echo ""

# TC-01: README.ja.md has at least 2 badges
echo "--- README.ja.md ---"
badge_count=$(grep -c 'img.shields.io\|badge' "$README_JA" 2>/dev/null)
if [ "$badge_count" -ge 2 ]; then
    test_case "TC-01" "README.ja.md has 2+ badges (found: $badge_count)" 0
else
    test_case "TC-01" "README.ja.md has 2+ badges (found: ${badge_count:-0})" 1
fi

# TC-02: README.ja.md has Quick Start section
if grep -qi 'クイックスタート\|Quick Start' "$README_JA" 2>/dev/null; then
    test_case "TC-02" "README.ja.md has Quick Start section" 0
else
    test_case "TC-02" "README.ja.md has Quick Start section" 1
fi

# TC-03: README.ja.md has 18+ agents
agent_count_ja=$(grep -c '\-attacker\|\-agent\|\-verifier\|\-filter\|\-crawler\|\-scenario' "$README_JA" 2>/dev/null)
if [ "$agent_count_ja" -ge 18 ]; then
    test_case "TC-03" "README.ja.md has 18+ agents (found: $agent_count_ja)" 0
else
    test_case "TC-03" "README.ja.md has 18+ agents (found: ${agent_count_ja:-0})" 1
fi

# TC-04: README.ja.md contains v4.2.0
if grep -q 'v4\.2\.0\|4\.2\.0' "$README_JA" 2>/dev/null; then
    test_case "TC-04" "README.ja.md contains v4.2.0" 0
else
    test_case "TC-04" "README.ja.md contains v4.2.0" 1
fi

# TC-05: CLAUDE.md has 18+ agents
echo ""
echo "--- CLAUDE.md ---"
agent_count_claude=$(grep -c '\-attacker\|\-agent\|\-verifier\|\-filter\|\-crawler\|\-scenario' "$CLAUDE_MD" 2>/dev/null)
if [ "$agent_count_claude" -ge 18 ]; then
    test_case "TC-05" "CLAUDE.md has 18+ agents (found: $agent_count_claude)" 0
else
    test_case "TC-05" "CLAUDE.md has 18+ agents (found: ${agent_count_claude:-0})" 1
fi

# TC-06: CLAUDE.md contains v4.2.0
if grep -q 'v4\.2\.0\|4\.2\.0' "$CLAUDE_MD" 2>/dev/null; then
    test_case "TC-06" "CLAUDE.md contains v4.2.0" 0
else
    test_case "TC-06" "CLAUDE.md contains v4.2.0" 1
fi

# TC-07: README.ja.md is 300 lines or less
echo ""
echo "--- Size ---"
line_count=$(wc -l < "$README_JA" | tr -d ' ')
if [ "$line_count" -le 300 ]; then
    test_case "TC-07" "README.ja.md is 300 lines or less (actual: $line_count)" 0
else
    test_case "TC-07" "README.ja.md is 300 lines or less (actual: $line_count)" 1
fi

# TC-08: No broken relative links in README.ja.md / CLAUDE.md
echo ""
echo "--- Links ---"
broken_links=0
for file in "$README_JA" "$CLAUDE_MD"; do
    while IFS= read -r link; do
        filepath="$PROJECT_ROOT/$link"
        if [ ! -e "$filepath" ]; then
            broken_links=$((broken_links + 1))
        fi
    done < <(grep -oE '\]\([^)]*\)' "$file" | grep -v 'http' | sed 's/\](\(.*\))/\1/' | sed 's/#.*//')
done
if [ "$broken_links" -eq 0 ]; then
    test_case "TC-08" "No broken relative links" 0
else
    test_case "TC-08" "No broken relative links ($broken_links broken)" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
