#!/bin/bash
# Test script for dynamic-testing feature
# Issue #13: dynamic-testing implementation

AGENT_FILE="plugins/redteam-core/agents/dynamic-verifier.md"
SKILL_FILE="plugins/redteam-core/skills/security-scan/SKILL.md"
REF_FILE="plugins/redteam-core/skills/security-scan/reference.md"
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
echo "Testing dynamic-testing feature"
echo "=========================================="
echo ""

# TC-01: dynamic-verifier.md が存在する
if [ -f "$AGENT_FILE" ]; then
    pass "TC-01: dynamic-verifier.md exists"
else
    fail "TC-01: dynamic-verifier.md does not exist"
fi

# TC-02: dynamic-verifier に Bash ツールが許可されている
if [ -f "$AGENT_FILE" ]; then
    if grep -q "allowed-tools:.*Bash" "$AGENT_FILE"; then
        pass "TC-02: dynamic-verifier has Bash in allowed-tools"
    else
        fail "TC-02: dynamic-verifier does not have Bash in allowed-tools"
    fi
else
    fail "TC-02: Cannot check - file does not exist"
fi

# TC-03: security-scan SKILL.md に --dynamic オプションが記載
if [ -f "$SKILL_FILE" ]; then
    if grep -q "\-\-dynamic" "$SKILL_FILE"; then
        pass "TC-03: SKILL.md has --dynamic option"
    else
        fail "TC-03: SKILL.md does not have --dynamic option"
    fi
else
    fail "TC-03: Cannot check - SKILL.md does not exist"
fi

# TC-04: security-scan SKILL.md に --target オプションが記載
if [ -f "$SKILL_FILE" ]; then
    if grep -q "\-\-target" "$SKILL_FILE"; then
        pass "TC-04: SKILL.md has --target option"
    else
        fail "TC-04: SKILL.md does not have --target option"
    fi
else
    fail "TC-04: Cannot check - SKILL.md does not exist"
fi

# TC-05: security-scan reference.md に [VERIFY] ステップが記載
if [ -f "$REF_FILE" ]; then
    if grep -q "VERIFY" "$REF_FILE"; then
        pass "TC-05: reference.md has VERIFY step"
    else
        fail "TC-05: reference.md does not have VERIFY step"
    fi
else
    fail "TC-05: Cannot check - reference.md does not exist"
fi

# TC-06: dynamic-verifier に SQLi 検証パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "SQL syntax|mysql_fetch|ORA-|pg_query" "$AGENT_FILE"; then
        pass "TC-06: dynamic-verifier has SQLi detection patterns"
    else
        fail "TC-06: dynamic-verifier does not have SQLi detection patterns"
    fi
else
    fail "TC-06: Cannot check - file does not exist"
fi

# TC-07: dynamic-verifier に非破壊ペイロード定義が存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "error_based|1' OR '1'='1" "$AGENT_FILE"; then
        pass "TC-07: dynamic-verifier has non-destructive payload definition"
    else
        fail "TC-07: dynamic-verifier does not have non-destructive payload definition"
    fi
else
    fail "TC-07: Cannot check - file does not exist"
fi

# TC-08: dynamic-verifier に禁止ペイロード定義が存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "forbidden|DROP|TRUNCATE|DELETE" "$AGENT_FILE"; then
        pass "TC-08: dynamic-verifier has forbidden payload definition"
    else
        fail "TC-08: dynamic-verifier does not have forbidden payload definition"
    fi
else
    fail "TC-08: Cannot check - file does not exist"
fi

# TC-09: dynamic-verifier に安全対策が記載
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "Safety|safe|Mitigation|安全" "$AGENT_FILE"; then
        pass "TC-09: dynamic-verifier has safety measures"
    else
        fail "TC-09: dynamic-verifier does not have safety measures"
    fi
else
    fail "TC-09: Cannot check - file does not exist"
fi

# TC-10: dynamic-verifier にレート制限が記載
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "rate|sleep|interval|レート" "$AGENT_FILE"; then
        pass "TC-10: dynamic-verifier has rate limiting"
    else
        fail "TC-10: dynamic-verifier does not have rate limiting"
    fi
else
    fail "TC-10: Cannot check - file does not exist"
fi

# TC-11: dynamic-verifier にURL検証ロジックが記載
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "url_validation|safe_hosts|localhost|127\.0\.0\.1" "$AGENT_FILE"; then
        pass "TC-11: dynamic-verifier has URL validation logic"
    else
        fail "TC-11: dynamic-verifier does not have URL validation logic"
    fi
else
    fail "TC-11: Cannot check - file does not exist"
fi

# TC-12: dynamic-verifier にタイムアウト設定が記載
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "timeout|max-time|connect-timeout" "$AGENT_FILE"; then
        pass "TC-12: dynamic-verifier has timeout settings"
    else
        fail "TC-12: dynamic-verifier does not have timeout settings"
    fi
else
    fail "TC-12: Cannot check - file does not exist"
fi

# TC-13: reference.md Output Format に verification セクションが存在
if [ -f "$REF_FILE" ]; then
    if grep -q "verification" "$REF_FILE"; then
        pass "TC-13: reference.md has verification section in Output Format"
    else
        fail "TC-13: reference.md does not have verification section"
    fi
else
    fail "TC-13: Cannot check - reference.md does not exist"
fi

# TC-14: scripts/test-dynamic-testing.sh が存在する
if [ -f "scripts/test-dynamic-testing.sh" ]; then
    pass "TC-14: test-dynamic-testing.sh exists"
else
    fail "TC-14: test-dynamic-testing.sh does not exist"
fi

echo ""
echo "=========================================="
echo "XSS Dynamic Verification Tests (Issue #17)"
echo "=========================================="
echo ""

# TC-15: dynamic-verifier に XSS ペイロード定義が存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "xss_payloads|<script>.*</script>|onerror=" "$AGENT_FILE"; then
        pass "TC-15: dynamic-verifier has XSS payload definition"
    else
        fail "TC-15: dynamic-verifier does not have XSS payload definition"
    fi
else
    fail "TC-15: Cannot check - file does not exist"
fi

# TC-16: dynamic-verifier に XSS 禁止ペイロード定義が存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "document\.cookie|document\.location|fetch\(|eval\(" "$AGENT_FILE"; then
        pass "TC-16: dynamic-verifier has XSS forbidden payload definition"
    else
        fail "TC-16: dynamic-verifier does not have XSS forbidden payload definition"
    fi
else
    fail "TC-16: Cannot check - file does not exist"
fi

# TC-17: dynamic-verifier に Content-Type 判定ロジックが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "Content-Type|text/html" "$AGENT_FILE"; then
        pass "TC-17: dynamic-verifier has Content-Type check"
    else
        fail "TC-17: dynamic-verifier does not have Content-Type check"
    fi
else
    fail "TC-17: Cannot check - file does not exist"
fi

# TC-18: dynamic-verifier に XSS 反射検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "confirmed|reflection|反射" "$AGENT_FILE"; then
        pass "TC-18: dynamic-verifier has XSS reflection detection"
    else
        fail "TC-18: dynamic-verifier does not have XSS reflection detection"
    fi
else
    fail "TC-18: Cannot check - file does not exist"
fi

# TC-19: dynamic-verifier に HTMLエンコード検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "&lt;|&gt;|&#60;|&#x3C;" "$AGENT_FILE"; then
        pass "TC-19: dynamic-verifier has HTML encoding detection"
    else
        fail "TC-19: dynamic-verifier does not have HTML encoding detection"
    fi
else
    fail "TC-19: Cannot check - file does not exist"
fi

# TC-20: dynamic-verifier に URLエンコード検出パターンが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "%3C|%3E|%22" "$AGENT_FILE"; then
        pass "TC-20: dynamic-verifier has URL encoding detection"
    else
        fail "TC-20: dynamic-verifier does not have URL encoding detection"
    fi
else
    fail "TC-20: Cannot check - file does not exist"
fi

# TC-21: SKILL.md に --enable-dynamic-xss フラグが存在
if [ -f "$SKILL_FILE" ]; then
    if grep -q "\-\-enable-dynamic-xss" "$SKILL_FILE"; then
        pass "TC-21: SKILL.md has --enable-dynamic-xss flag"
    else
        fail "TC-21: SKILL.md does not have --enable-dynamic-xss flag"
    fi
else
    fail "TC-21: Cannot check - SKILL.md does not exist"
fi

# TC-22: dynamic-verifier に XSS 検証セクションが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "XSS Verification|XSS Detection" "$AGENT_FILE"; then
        pass "TC-22: dynamic-verifier has XSS Verification section"
    else
        fail "TC-22: dynamic-verifier does not have XSS Verification section"
    fi
else
    fail "TC-22: Cannot check - file does not exist"
fi

# TC-23: dynamic-verifier に 2秒間隔のレート制限が存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "2.*秒|2.*second|sleep 2" "$AGENT_FILE"; then
        pass "TC-23: dynamic-verifier has 2-second rate limiting"
    else
        fail "TC-23: dynamic-verifier does not have 2-second rate limiting"
    fi
else
    fail "TC-23: Cannot check - file does not exist"
fi

# TC-24: dynamic-verifier に 最大3ペイロード制限が存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "max.*3|最大.*3|3.*payload" "$AGENT_FILE"; then
        pass "TC-24: dynamic-verifier has max 3 payloads limit"
    else
        fail "TC-24: dynamic-verifier does not have max 3 payloads limit"
    fi
else
    fail "TC-24: Cannot check - file does not exist"
fi

# TC-25: reference.md に XSS 動的検証の説明が存在
if [ -f "$REF_FILE" ]; then
    if grep -qE "XSS.*動的|dynamic.*XSS|--enable-dynamic-xss" "$REF_FILE"; then
        pass "TC-25: reference.md has XSS dynamic verification description"
    else
        fail "TC-25: reference.md does not have XSS dynamic verification description"
    fi
else
    fail "TC-25: Cannot check - reference.md does not exist"
fi

# TC-26: dynamic-verifier に verification_result 定義が存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "not_vulnerable|inconclusive|skipped" "$AGENT_FILE"; then
        pass "TC-26: dynamic-verifier has verification_result definitions"
    else
        fail "TC-26: dynamic-verifier does not have verification_result definitions"
    fi
else
    fail "TC-26: Cannot check - file does not exist"
fi

# TC-27: dynamic-verifier に Common Settings セクションが存在
if [ -f "$AGENT_FILE" ]; then
    if grep -qE "Common.*Settings|共通.*設定" "$AGENT_FILE"; then
        pass "TC-27: dynamic-verifier has Common Settings section"
    else
        fail "TC-27: dynamic-verifier does not have Common Settings section"
    fi
else
    fail "TC-27: Cannot check - file does not exist"
fi

echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

exit $FAILED
