#!/bin/bash
#
# Test: README.md structure and content quality
#
# TC-01: At least 2 badges exist (license, version)
# TC-02: Quick Start section exists
# TC-03: At least 18 agents listed
# TC-04: v4.2.0 in Version History
# TC-05: 6 languages in Supported Languages
# TC-06: README.md is 300 lines or less
# TC-07: No broken markdown links (relative files)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
README="$PROJECT_ROOT/README.md"

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
echo "README Structure Test"
echo "================================"
echo ""

# TC-01: At least 2 badges (shields.io or img.shields.io URLs)
echo "--- Badges ---"
badge_count=$(grep -c 'img.shields.io\|badge' "$README" 2>/dev/null)
if [ "$badge_count" -ge 2 ]; then
    test_case "TC-01" "At least 2 badges exist (found: $badge_count)" 0
else
    test_case "TC-01" "At least 2 badges exist (found: ${badge_count:-0})" 1
fi

# TC-02: Quick Start section exists
echo ""
echo "--- Structure ---"
if grep -qi '## Quick Start\|## Getting Started' "$README" 2>/dev/null; then
    test_case "TC-02" "Quick Start section exists" 0
else
    test_case "TC-02" "Quick Start section exists" 1
fi

# TC-03: At least 18 agents listed
echo ""
echo "--- Content ---"
agent_count=$(grep -c '\-attacker\|\-agent\|\-verifier\|\-filter\|\-crawler\|\-scenario' "$README" 2>/dev/null)
if [ "$agent_count" -ge 18 ]; then
    test_case "TC-03" "At least 18 agents listed (found: $agent_count)" 0
else
    test_case "TC-03" "At least 18 agents listed (found: ${agent_count:-0})" 1
fi

# TC-04: v4.2.0 in Version History
if grep -q 'v4\.2\.0\|4\.2\.0' "$README" 2>/dev/null; then
    test_case "TC-04" "v4.2.0 in Version History" 0
else
    test_case "TC-04" "v4.2.0 in Version History" 1
fi

# TC-05: 6 languages in Supported Languages
lang_count=0
for lang in PHP Python JavaScript TypeScript Go Java; do
    if grep -qi "$lang" "$README" 2>/dev/null; then
        lang_count=$((lang_count + 1))
    fi
done
if [ "$lang_count" -ge 6 ]; then
    test_case "TC-05" "6 languages listed (found: $lang_count)" 0
else
    test_case "TC-05" "6 languages listed (found: $lang_count)" 1
fi

# TC-06: README.md is 300 lines or less
echo ""
echo "--- Size ---"
line_count=$(wc -l < "$README" | tr -d ' ')
if [ "$line_count" -le 300 ]; then
    test_case "TC-06" "README.md is 300 lines or less (actual: $line_count)" 0
else
    test_case "TC-06" "README.md is 300 lines or less (actual: $line_count)" 1
fi

# TC-07: No broken relative markdown links
echo ""
echo "--- Links ---"
broken_links=0
while IFS= read -r link; do
    filepath="$PROJECT_ROOT/$link"
    if [ ! -e "$filepath" ]; then
        broken_links=$((broken_links + 1))
    fi
done < <(grep -oE '\]\([^)]*\)' "$README" | grep -v 'http' | sed 's/\](\(.*\))/\1/' | sed 's/#.*//')
if [ "$broken_links" -eq 0 ]; then
    test_case "TC-07" "No broken relative links" 0
else
    test_case "TC-07" "No broken relative links ($broken_links broken)" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
