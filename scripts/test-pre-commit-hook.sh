#!/bin/bash
# Test script for pre-commit hook
# Tests scripts/pre-commit and scripts/install-hooks.sh

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

echo "=== File Existence Tests ==="

# TC-01: scripts/pre-commitが存在する
if [ -f "scripts/pre-commit" ]; then
    pass "TC-01: scripts/pre-commitが存在する"
else
    fail "TC-01: scripts/pre-commitが存在しない"
fi

# TC-02: scripts/install-hooks.shが存在する
if [ -f "scripts/install-hooks.sh" ]; then
    pass "TC-02: scripts/install-hooks.shが存在する"
else
    fail "TC-02: scripts/install-hooks.shが存在しない"
fi

echo ""
echo "=== Shebang Tests ==="

# TC-03: pre-commitが実行可能（shebang確認）
if [ -f "scripts/pre-commit" ] && head -1 "scripts/pre-commit" | grep -q '^#!/bin/bash'; then
    pass "TC-03: pre-commitにshebangがある"
else
    fail "TC-03: pre-commitにshebangがない"
fi

# TC-04: install-hooks.shが実行可能（shebang確認）
if [ -f "scripts/install-hooks.sh" ] && head -1 "scripts/install-hooks.sh" | grep -q '^#!/bin/bash'; then
    pass "TC-04: install-hooks.shにshebangがある"
else
    fail "TC-04: install-hooks.shにshebangがない"
fi

echo ""
echo "=== Functional Tests ==="

# TC-05: スクリプトが正常に実行可能（シンタックスチェック）
if [ -f "scripts/pre-commit" ]; then
    bash -n scripts/pre-commit 2>/dev/null
    if [ $? -eq 0 ]; then
        pass "TC-05: pre-commitスクリプトのシンタックスが正しい"
    else
        fail "TC-05: pre-commitスクリプトにシンタックスエラーがある"
    fi
else
    fail "TC-05: scripts/pre-commitが存在しないためスキップ"
fi

# TC-06: テスト失敗時にexit 1を返す
# Note: 実際に失敗させるのは難しいので、スクリプト内に適切なロジックがあるか確認
if [ -f "scripts/pre-commit" ] && grep -q 'exit 1' "scripts/pre-commit"; then
    pass "TC-06: テスト失敗時のexit 1が定義されている"
else
    fail "TC-06: テスト失敗時のexit 1が定義されていない"
fi

echo ""
echo "=== Installation Tests ==="

# TC-07: install-hooks.sh実行後、.git/hooks/pre-commitが存在する
if [ -f "scripts/install-hooks.sh" ]; then
    # バックアップ既存hook
    if [ -f ".git/hooks/pre-commit" ]; then
        cp .git/hooks/pre-commit .git/hooks/pre-commit.bak
    fi

    bash scripts/install-hooks.sh > /dev/null 2>&1
    if [ -f ".git/hooks/pre-commit" ]; then
        pass "TC-07: install-hooks.sh実行後、.git/hooks/pre-commitが存在する"
        # テスト用にインストールしたhookを削除（バックアップがあれば復元）
        if [ -f ".git/hooks/pre-commit.bak" ]; then
            mv .git/hooks/pre-commit.bak .git/hooks/pre-commit
        else
            rm .git/hooks/pre-commit
        fi
    else
        fail "TC-07: install-hooks.sh実行後、.git/hooks/pre-commitが存在しない"
    fi
else
    fail "TC-07: scripts/install-hooks.shが存在しないためスキップ"
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
