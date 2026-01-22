#!/bin/bash
# Test script for docs structure (Issue #53)
# Usage: bash scripts/test-docs-structure.sh

DOCS_DIR="docs"
FAILED=0
PASSED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    ((FAILED++))
}

echo "========================================"
echo "Documentation Structure Tests"
echo "========================================"
echo ""

# TC-01: AGENT_GUIDE.md exists
echo "TC-01: AGENT_GUIDE.md exists"
if [ -f "$DOCS_DIR/AGENT_GUIDE.md" ]; then
    pass "AGENT_GUIDE.md exists"
else
    fail "AGENT_GUIDE.md not found"
fi

# TC-02: All 18 agents listed
echo "TC-02: 18 agents listed"
if [ -f "$DOCS_DIR/AGENT_GUIDE.md" ]; then
    AGENTS=(
        "recon-agent"
        "injection-attacker"
        "auth-attacker"
        "xss-attacker"
        "api-attacker"
        "file-attacker"
        "ssrf-attacker"
        "csrf-attacker"
        "ssti-attacker"
        "xxe-attacker"
        "wordpress-attacker"
        "crypto-attacker"
        "error-attacker"
        "dynamic-verifier"
        "sca-attacker"
        "dast-crawler"
        "false-positive-filter"
        "attack-scenario"
    )
    MISSING=0
    for agent in "${AGENTS[@]}"; do
        if ! grep -q "$agent" "$DOCS_DIR/AGENT_GUIDE.md"; then
            echo "  Missing: $agent"
            MISSING=1
        fi
    done
    if [ $MISSING -eq 0 ]; then
        pass "All 18 agents listed"
    else
        fail "Some agents missing"
    fi
else
    fail "AGENT_GUIDE.md not found"
fi

# TC-03: Framework matrix exists
echo "TC-03: Framework matrix exists"
if [ -f "$DOCS_DIR/AGENT_GUIDE.md" ]; then
    if grep -q "Laravel\|Django\|Express\|WordPress" "$DOCS_DIR/AGENT_GUIDE.md" && \
       grep -q "|.*|.*|" "$DOCS_DIR/AGENT_GUIDE.md"; then
        pass "Framework matrix found"
    else
        fail "Framework matrix not found"
    fi
else
    fail "AGENT_GUIDE.md not found"
fi

# TC-04: Each agent has description
echo "TC-04: Each agent has usage/detection info"
if [ -f "$DOCS_DIR/AGENT_GUIDE.md" ]; then
    # Check for description patterns (用途, 検出, detection, etc.)
    if grep -qE "(用途|検出|detection|Usage|Target)" "$DOCS_DIR/AGENT_GUIDE.md"; then
        pass "Agent descriptions found"
    else
        fail "Agent descriptions not found"
    fi
else
    fail "AGENT_GUIDE.md not found"
fi

# TC-05: WORKFLOW.md exists
echo "TC-05: WORKFLOW.md exists"
if [ -f "$DOCS_DIR/WORKFLOW.md" ]; then
    pass "WORKFLOW.md exists"
else
    fail "WORKFLOW.md not found"
fi

# TC-06: ASCII diagram exists
echo "TC-06: ASCII diagram exists"
if [ -f "$DOCS_DIR/WORKFLOW.md" ]; then
    if grep -qE "(\+---|\|.*\||─|→|↓|┌|└|├)" "$DOCS_DIR/WORKFLOW.md"; then
        pass "ASCII diagram found"
    else
        fail "ASCII diagram not found"
    fi
else
    fail "WORKFLOW.md not found"
fi

# TC-07: Phase descriptions (RECON→SCAN→ATTACK→REPORT)
echo "TC-07: Phase descriptions exist"
if [ -f "$DOCS_DIR/WORKFLOW.md" ]; then
    if grep -q "RECON" "$DOCS_DIR/WORKFLOW.md" && \
       grep -q "SCAN" "$DOCS_DIR/WORKFLOW.md" && \
       grep -q "ATTACK" "$DOCS_DIR/WORKFLOW.md" && \
       grep -q "REPORT" "$DOCS_DIR/WORKFLOW.md"; then
        pass "All phases documented"
    else
        fail "Some phases missing"
    fi
else
    fail "WORKFLOW.md not found"
fi

# TC-08: FAQ.md exists
echo "TC-08: FAQ.md exists"
if [ -f "$DOCS_DIR/FAQ.md" ]; then
    pass "FAQ.md exists"
else
    fail "FAQ.md not found"
fi

# TC-09: 15+ Q&A items
echo "TC-09: 15+ Q&A items"
if [ -f "$DOCS_DIR/FAQ.md" ]; then
    QA_COUNT=$(grep -cE "^## Q[0-9]+" "$DOCS_DIR/FAQ.md" 2>/dev/null || echo 0)
    if [ "$QA_COUNT" -ge 15 ]; then
        pass "Found $QA_COUNT Q&A items (>= 15)"
    else
        fail "Only $QA_COUNT Q&A items found (need >= 15)"
    fi
else
    fail "FAQ.md not found"
fi

# TC-10: Each answer has content
echo "TC-10: Each answer has content"
if [ -f "$DOCS_DIR/FAQ.md" ]; then
    # Check file has substantial content (more than just headers)
    CONTENT_LINES=$(grep -cvE "^(#|$)" "$DOCS_DIR/FAQ.md" 2>/dev/null || echo 0)
    if [ "$CONTENT_LINES" -ge 15 ]; then
        pass "Answers have content ($CONTENT_LINES lines)"
    else
        fail "Answers lack content ($CONTENT_LINES lines)"
    fi
else
    fail "FAQ.md not found"
fi

# TC-11: README has documentation section
echo "TC-11: README has documentation section"
if grep -qiE "(Documentation|ドキュメント)" "README.md"; then
    pass "Documentation section found"
else
    fail "Documentation section not found"
fi

# TC-12: README links to docs
echo "TC-12: README links to AGENT_GUIDE/WORKFLOW/FAQ"
LINKS_FOUND=0
if grep -q "AGENT_GUIDE" "README.md"; then ((LINKS_FOUND++)); fi
if grep -q "WORKFLOW" "README.md"; then ((LINKS_FOUND++)); fi
if grep -q "FAQ" "README.md"; then ((LINKS_FOUND++)); fi

if [ "$LINKS_FOUND" -eq 3 ]; then
    pass "All doc links found"
else
    fail "Only $LINKS_FOUND/3 doc links found"
fi

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
