#!/bin/bash
# Test script for ssrf-attacker agent
# Issue #12: ssrf-attacker implementation

AGENT_FILE="plugins/redteam-core/agents/ssrf-attacker.md"
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
echo "Testing ssrf-attacker agent"
echo "=========================================="
echo ""

# TC-01: ssrf-attacker.mdが存在する
if [ -f "$AGENT_FILE" ]; then
    pass "TC-01: ssrf-attacker.md exists"
else
    fail "TC-01: ssrf-attacker.md does not exist"
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

# TC-03: Detection Targetsに3タイプが定義
if [ -f "$AGENT_FILE" ]; then
    TYPE_COUNT=$(grep -cE "^\| (ssrf|blind-ssrf|partial-ssrf) \|" "$AGENT_FILE" | head -1)
    if [ "$TYPE_COUNT" -ge 3 ]; then
        pass "TC-03: Detection Targets has 3 types (found $TYPE_COUNT)"
    else
        fail "TC-03: Detection Targets should have 3 types (found $TYPE_COUNT)"
    fi
else
    fail "TC-03: Cannot check - file does not exist"
fi

# TC-04: PHP SSRF検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "file_get_contents|curl_setopt|CURLOPT_URL" "$AGENT_FILE"; then
        pass "TC-04: PHP SSRF detection pattern exists"
    else
        fail "TC-04: PHP SSRF detection pattern not found"
    fi
else
    fail "TC-04: Cannot check - file does not exist"
fi

# TC-05: Python SSRF検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "requests\.|urllib|httpx" "$AGENT_FILE"; then
        pass "TC-05: Python SSRF detection pattern exists"
    else
        fail "TC-05: Python SSRF detection pattern not found"
    fi
else
    fail "TC-05: Cannot check - file does not exist"
fi

# TC-06: Node.js SSRF検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "axios|fetch|http\.request|got" "$AGENT_FILE"; then
        pass "TC-06: Node.js SSRF detection pattern exists"
    else
        fail "TC-06: Node.js SSRF detection pattern not found"
    fi
else
    fail "TC-06: Cannot check - file does not exist"
fi

# TC-07: Java SSRF検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "HttpURLConnection|RestTemplate|new\s+URL" "$AGENT_FILE"; then
        pass "TC-07: Java SSRF detection pattern exists"
    else
        fail "TC-07: Java SSRF detection pattern not found"
    fi
else
    fail "TC-07: Cannot check - file does not exist"
fi

# TC-08: Cloud Metadata検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "169\.254\.169\.254|metadata\.google|metadata\.azure" "$AGENT_FILE"; then
        pass "TC-08: Cloud Metadata detection pattern exists"
    else
        fail "TC-08: Cloud Metadata detection pattern not found"
    fi
else
    fail "TC-08: Cannot check - file does not exist"
fi

# TC-09: CWE-918 Mappingが存在
if [ -f "$AGENT_FILE" ]; then
    CWE_COUNT=$(grep -c "CWE-918" "$AGENT_FILE" | head -1)
    if [ "$CWE_COUNT" -ge 1 ]; then
        pass "TC-09: CWE-918 Mapping exists (found $CWE_COUNT)"
    else
        fail "TC-09: CWE-918 Mapping not found"
    fi
else
    fail "TC-09: Cannot check - file does not exist"
fi

# TC-10: Severity Criteriaが定義
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "Severity|critical|high|medium" "$AGENT_FILE"; then
        pass "TC-10: Severity Criteria is defined"
    else
        fail "TC-10: Severity Criteria not found"
    fi
else
    fail "TC-10: Cannot check - file does not exist"
fi

# TC-11: Vulnerability ID Prefix（SSRF-XXX）が定義
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "SSRF-[0-9]+" "$AGENT_FILE"; then
        pass "TC-11: Vulnerability ID Prefix (SSRF-XXX) is defined"
    else
        fail "TC-11: Vulnerability ID Prefix (SSRF-XXX) not found"
    fi
else
    fail "TC-11: Cannot check - file does not exist"
fi

# TC-12: Known Limitationsセクションが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -q "Known Limitations" "$AGENT_FILE"; then
        pass "TC-12: Known Limitations section exists"
    else
        fail "TC-12: Known Limitations section not found"
    fi
else
    fail "TC-12: Cannot check - file does not exist"
fi

echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

exit $FAILED
