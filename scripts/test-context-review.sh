#!/bin/bash
# Test script for context-review skill
# Tests SKILL.md and reference.md structure

PASSED=0
FAILED=0

SKILL_FILE="plugins/redteam-core/skills/context-review/SKILL.md"
REF_FILE="plugins/redteam-core/skills/context-review/reference.md"

pass() {
    echo "PASS: $1"
    ((PASSED++))
}

fail() {
    echo "FAIL: $1"
    ((FAILED++))
}

echo "=== Skill Structure Tests ==="

# TC-01: skills/context-review/SKILL.mdが存在する
if [ -f "$SKILL_FILE" ]; then
    pass "TC-01: SKILL.mdが存在する"
else
    fail "TC-01: SKILL.mdが存在しない"
fi

# TC-02: frontmatterにname, descriptionがある
if [ -f "$SKILL_FILE" ]; then
    if grep -q '^name:' "$SKILL_FILE" && grep -q '^description:' "$SKILL_FILE"; then
        pass "TC-02: frontmatterにname, descriptionがある"
    else
        fail "TC-02: frontmatterにname, descriptionがない"
    fi
else
    fail "TC-02: SKILL.mdが存在しないためスキップ"
fi

# TC-03: Usageセクションが存在する
if [ -f "$SKILL_FILE" ] && grep -q '## Usage' "$SKILL_FILE"; then
    pass "TC-03: Usageセクションが存在する"
else
    fail "TC-03: Usageセクションが存在しない"
fi

echo ""
echo "=== Workflow Section Tests ==="

# TC-04: Workflowセクションが存在する
if [ -f "$SKILL_FILE" ] && grep -q '## Workflow' "$SKILL_FILE"; then
    pass "TC-04: Workflowセクションが存在する"
else
    fail "TC-04: Workflowセクションが存在しない"
fi

# TC-05: ANALYZE Phaseが定義されている
if [ -f "$SKILL_FILE" ] && grep -qi 'ANALYZE' "$SKILL_FILE"; then
    pass "TC-05: ANALYZE Phaseが定義されている"
else
    fail "TC-05: ANALYZE Phaseが定義されていない"
fi

# TC-06: QUESTION Phaseが定義されている
if [ -f "$SKILL_FILE" ] && grep -qi 'QUESTION' "$SKILL_FILE"; then
    pass "TC-06: QUESTION Phaseが定義されている"
else
    fail "TC-06: QUESTION Phaseが定義されていない"
fi

# TC-07: RESOLVE Phaseが定義されている
if [ -f "$SKILL_FILE" ] && grep -qi 'RESOLVE' "$SKILL_FILE"; then
    pass "TC-07: RESOLVE Phaseが定義されている"
else
    fail "TC-07: RESOLVE Phaseが定義されていない"
fi

echo ""
echo "=== Question Categories Tests ==="

# TC-08: Question Categoriesセクションが存在する
if [ -f "$SKILL_FILE" ] && grep -qi 'Question.*Categor' "$SKILL_FILE"; then
    pass "TC-08: Question Categoriesセクションが存在する"
else
    fail "TC-08: Question Categoriesセクションが存在しない"
fi

# TC-09: auth-intentカテゴリが定義されている
if [ -f "$SKILL_FILE" ] && grep -q 'auth-intent' "$SKILL_FILE"; then
    pass "TC-09: auth-intentカテゴリが定義されている"
else
    fail "TC-09: auth-intentカテゴリが定義されていない"
fi

# TC-10: error-handlingカテゴリが定義されている
if [ -f "$SKILL_FILE" ] && grep -q 'error-handling' "$SKILL_FILE"; then
    pass "TC-10: error-handlingカテゴリが定義されている"
else
    fail "TC-10: error-handlingカテゴリが定義されていない"
fi

# TC-11: data-exposureカテゴリが定義されている
if [ -f "$SKILL_FILE" ] && grep -q 'data-exposure' "$SKILL_FILE"; then
    pass "TC-11: data-exposureカテゴリが定義されている"
else
    fail "TC-11: data-exposureカテゴリが定義されていない"
fi

# TC-12: business-logicカテゴリが定義されている
if [ -f "$SKILL_FILE" ] && grep -q 'business-logic' "$SKILL_FILE"; then
    pass "TC-12: business-logicカテゴリが定義されている"
else
    fail "TC-12: business-logicカテゴリが定義されていない"
fi

echo ""
echo "=== Output Format Tests ==="

# TC-13: Output Formatセクションが存在する
if [ -f "$SKILL_FILE" ] && grep -q '## Output Format' "$SKILL_FILE"; then
    pass "TC-13: Output Formatセクションが存在する"
else
    fail "TC-13: Output Formatセクションが存在しない"
fi

# TC-14: resolution値(excluded/confirmed/needs_review)が定義されている
if [ -f "$SKILL_FILE" ]; then
    if grep -q 'excluded' "$SKILL_FILE" && grep -q 'confirmed' "$SKILL_FILE" && grep -q 'needs_review' "$SKILL_FILE"; then
        pass "TC-14: resolution値が定義されている"
    else
        fail "TC-14: resolution値が不完全"
    fi
else
    fail "TC-14: SKILL.mdが存在しないためスキップ"
fi

echo ""
echo "=== Reference Tests ==="

# TC-15: reference.mdが存在する
if [ -f "$REF_FILE" ]; then
    pass "TC-15: reference.mdが存在する"
else
    fail "TC-15: reference.mdが存在しない"
fi

# TC-16: 質問テンプレートが定義されている
if [ -f "$REF_FILE" ] && grep -qi 'template' "$REF_FILE"; then
    pass "TC-16: 質問テンプレートが定義されている"
else
    fail "TC-16: 質問テンプレートが定義されていない"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
