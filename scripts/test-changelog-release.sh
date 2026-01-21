#!/bin/bash
# Test script for changelog-release cycle
# Tests CHANGELOG.md and docs/STATUS.md updates

PASSED=0
FAILED=0

pass() {
    echo "PASS: $1"
    ((PASSED++))
}

fail() {
    echo "FAIL: $1"
    ((FAILED++))
}

echo "=== CHANGELOG.md Tests ==="

# TC-01: v3.1.0に#48が記載されている
if grep -A 20 '## \[3.1.0\]' CHANGELOG.md | grep -q '#48'; then
    pass "TC-01: v3.1.0に#48が記載されている"
else
    fail "TC-01: v3.1.0に#48が記載されていない"
fi

# TC-02: v3.2.0セクションが存在する
if grep -q '## \[3.2.0\]' CHANGELOG.md; then
    pass "TC-02: v3.2.0セクションが存在する"
else
    fail "TC-02: v3.2.0セクションが存在しない"
fi

# TC-03: v3.2.0に#40, #41, #42, #43, #45, #46が記載
V32_SECTION=$(sed -n '/## \[3.2.0\]/,/## \[3.1.0\]/p' CHANGELOG.md 2>/dev/null || echo "")
MISSING=""
for issue in 40 41 42 43 45 46; do
    if ! echo "$V32_SECTION" | grep -q "#$issue"; then
        MISSING="$MISSING #$issue"
    fi
done
if [ -z "$MISSING" ]; then
    pass "TC-03: v3.2.0に#40, #41, #42, #43, #45, #46が記載"
else
    fail "TC-03: v3.2.0に以下が未記載:$MISSING"
fi

# TC-04: Roadmapにv4.1-v4.2が存在しない (v4.0はcontext-reviewerで使用)
ROADMAP_SECTION=$(sed -n '/## Roadmap/,$p' CHANGELOG.md)
if echo "$ROADMAP_SECTION" | grep -q 'v4\.[12]'; then
    fail "TC-04: Roadmapにv4.1-v4.2が残っている"
else
    pass "TC-04: Roadmapにv4.1-v4.2が存在しない"
fi

# TC-05: Roadmapにcontext-reviewer (#44)のみ残っている
if echo "$ROADMAP_SECTION" | grep -q 'context-reviewer.*#44'; then
    pass "TC-05: Roadmapにcontext-reviewer (#44)が残っている"
else
    fail "TC-05: Roadmapにcontext-reviewer (#44)が存在しない"
fi

echo ""
echo "=== docs/STATUS.md Tests ==="

# TC-06: Current Versionが3.2.0
if grep -q 'Current Version.*3.2.0' docs/STATUS.md; then
    pass "TC-06: Current Versionが3.2.0"
else
    fail "TC-06: Current Versionが3.2.0ではない"
fi

# TC-07: Last Updatedが2026-01-21
if grep -q 'Last Updated.*2026-01-21' docs/STATUS.md; then
    pass "TC-07: Last Updatedが2026-01-21"
else
    fail "TC-07: Last Updatedが2026-01-21ではない"
fi

# TC-08: v3.2セクションにsca-attackerがDone
if grep -A 10 'v3.2 - ' docs/STATUS.md | grep -q 'sca-attacker.*Done'; then
    pass "TC-08: v3.2 sca-attackerがDone"
else
    fail "TC-08: v3.2 sca-attackerがDoneではない"
fi

# TC-09: v3.2セクションにdast-crawlerがDone
if grep -A 10 'v3.2 - ' docs/STATUS.md | grep -q 'dast-crawler.*Done'; then
    pass "TC-09: v3.2 dast-crawlerがDone"
else
    fail "TC-09: v3.2 dast-crawlerがDoneではない"
fi

# TC-10: v3.2セクションにattack-scenarioがDone
if grep -A 10 'v3.2 - ' docs/STATUS.md | grep -q 'attack-scenario.*Done'; then
    pass "TC-10: v3.2 attack-scenarioがDone"
else
    fail "TC-10: v3.2 attack-scenarioがDoneではない"
fi

# TC-11: v3.2セクションにfalse-positive-filterがDone
if grep -A 10 'v3.2 - ' docs/STATUS.md | grep -q 'false-positive-filter.*Done'; then
    pass "TC-11: v3.2 false-positive-filterがDone"
else
    fail "TC-11: v3.2 false-positive-filterがDoneではない"
fi

# TC-12: v4.0 context-reviewerがPlanned
if grep -A 10 'v4.0 - ' docs/STATUS.md | grep -q 'context-reviewer.*Planned'; then
    pass "TC-12: v4.0 context-reviewerがPlanned"
else
    fail "TC-12: v4.0 context-reviewerがPlannedではない"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
