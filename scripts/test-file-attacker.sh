#!/bin/bash
# Test script for file-attacker agent
# Issue #11: file-attacker implementation

AGENT_FILE="plugins/redteam-core/agents/file-attacker.md"
PASSED=0
FAILED=0

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    ((FAILED++))
}

echo "=========================================="
echo "Testing file-attacker agent"
echo "=========================================="
echo ""

# TC-01: file-attacker.mdが存在する
if [ -f "$AGENT_FILE" ]; then
    pass "TC-01: file-attacker.md exists"
else
    fail "TC-01: file-attacker.md does not exist"
fi

# TC-02: YAMLフロントマターにname, description, allowed-toolsが定義
if [ -f "$AGENT_FILE" ]; then
    if grep -q "^name:" "$AGENT_FILE" && \
       grep -q "^description:" "$AGENT_FILE" && \
       grep -q "^allowed-tools:" "$AGENT_FILE"; then
        pass "TC-02: YAML frontmatter has name, description, allowed-tools"
    else
        fail "TC-02: YAML frontmatter missing required fields"
    fi
else
    fail "TC-02: Cannot check - file does not exist"
fi

# TC-03: Detection Targetsに4タイプが定義
if [ -f "$AGENT_FILE" ]; then
    TYPE_COUNT=$(grep -cE "^\| (path-traversal|arbitrary-file-upload|lfi|unrestricted-file-access) \|" "$AGENT_FILE" | head -1)
    if [ "$TYPE_COUNT" -ge 4 ]; then
        pass "TC-03: Detection Targets has 4 types (found $TYPE_COUNT)"
    else
        fail "TC-03: Detection Targets should have 4 types (found $TYPE_COUNT)"
    fi
else
    fail "TC-03: Cannot check - file does not exist"
fi

# TC-04: path-traversal検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "file_get_contents|fopen|readfile|\\.\\./|path.traversal" "$AGENT_FILE"; then
        pass "TC-04: path-traversal detection pattern exists"
    else
        fail "TC-04: path-traversal detection pattern not found"
    fi
else
    fail "TC-04: Cannot check - file does not exist"
fi

# TC-05: arbitrary-file-upload検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "move_uploaded_file|\\\$_FILES|upload|multer" "$AGENT_FILE"; then
        pass "TC-05: arbitrary-file-upload detection pattern exists"
    else
        fail "TC-05: arbitrary-file-upload detection pattern not found"
    fi
else
    fail "TC-05: Cannot check - file does not exist"
fi

# TC-06: lfi検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "include.*\\\$_|require.*\\\$_|include_once|require_once" "$AGENT_FILE"; then
        pass "TC-06: lfi detection pattern exists"
    else
        fail "TC-06: lfi detection pattern not found"
    fi
else
    fail "TC-06: Cannot check - file does not exist"
fi

# TC-07: unrestricted-file-access検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "X-Sendfile|X-Accel-Redirect|send_file|sendFile" "$AGENT_FILE"; then
        pass "TC-07: unrestricted-file-access detection pattern exists"
    else
        fail "TC-07: unrestricted-file-access detection pattern not found"
    fi
else
    fail "TC-07: Cannot check - file does not exist"
fi

# TC-08: CWE Mappingセクションが存在（4件）
if [ -f "$AGENT_FILE" ]; then
    CWE_COUNT=$(grep -cE "CWE-(22|434|98|552)" "$AGENT_FILE" | head -1)
    if [ "$CWE_COUNT" -ge 4 ]; then
        pass "TC-08: CWE Mapping has 4 entries (found $CWE_COUNT)"
    else
        fail "TC-08: CWE Mapping should have 4 entries (found $CWE_COUNT)"
    fi
else
    fail "TC-08: Cannot check - file does not exist"
fi

# TC-09: Severity Criteriaが定義
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "Severity|critical|high|medium" "$AGENT_FILE"; then
        pass "TC-09: Severity Criteria is defined"
    else
        fail "TC-09: Severity Criteria not found"
    fi
else
    fail "TC-09: Cannot check - file does not exist"
fi

# TC-10: Vulnerability ID Prefix（FILE-XXX）が定義
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "FILE-[0-9]+" "$AGENT_FILE"; then
        pass "TC-10: Vulnerability ID Prefix (FILE-XXX) is defined"
    else
        fail "TC-10: Vulnerability ID Prefix (FILE-XXX) not found"
    fi
else
    fail "TC-10: Cannot check - file does not exist"
fi

echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

exit $FAILED
