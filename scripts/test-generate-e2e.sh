#!/bin/bash
#
# Test: generate-e2e skill structure
#
# TC-01: [正常系] security-scan JSON入力からPlaywright設定ファイル生成
# TC-02: [正常系] 脆弱性詳細からベーステストファイル生成
# TC-03: [正常系] 出力ディレクトリ(tests/security/)への書き込み
# TC-04: [境界値] 脆弱性0件の場合の処理
# TC-05: [エッジケース] 既存ファイルがある場合
# TC-06: [エッジケース] --force オプション
# TC-07: [異常系] 不正なJSON入力時のエラーハンドリング
# TC-08: [異常系] 出力ディレクトリ書き込み権限エラー

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/plugins/redteam-core/skills/generate-e2e"
SKILL_FILE="$SKILL_DIR/SKILL.md"
REFERENCE_FILE="$SKILL_DIR/reference.md"
TEMPLATE_DIR="$SKILL_DIR/templates"
PLAYWRIGHT_CONFIG_TMPL="$TEMPLATE_DIR/playwright.config.ts.tmpl"
BASE_TEST_TMPL="$TEMPLATE_DIR/base-test.ts.tmpl"

PASSED=0
FAILED=0

test_case() {
    local tc_id="$1"
    local description="$2"
    local result="$3"

    if [ "$result" = "0" ]; then
        echo "✓ $tc_id: $description"
        ((PASSED++))
    else
        echo "✗ $tc_id: $description"
        ((FAILED++))
    fi
}

echo "================================"
echo "generate-e2e Skill Structure Test"
echo "================================"
echo ""

# TC-01: Playwright config template exists with proper structure
echo "--- TC-01: Playwright Config Generation ---"

# TC-01a: skills/generate-e2e/ directory exists
if [ -d "$SKILL_DIR" ]; then
    test_case "TC-01a" "skills/generate-e2e/ directory exists" 0
else
    test_case "TC-01a" "skills/generate-e2e/ directory exists" 1
fi

# TC-01b: SKILL.md exists
if [ -f "$SKILL_FILE" ]; then
    test_case "TC-01b" "SKILL.md exists" 0
else
    test_case "TC-01b" "SKILL.md exists" 1
fi

# TC-01c: YAML frontmatter (name, description) exists
if [ -f "$SKILL_FILE" ]; then
    has_frontmatter=$(head -1 "$SKILL_FILE" | grep -c "^---$")
    has_name=$(grep -c "^name:" "$SKILL_FILE" 2>/dev/null || echo 0)
    has_description=$(grep -c "^description:" "$SKILL_FILE" 2>/dev/null || echo 0)

    if [ "$has_frontmatter" -gt 0 ] && [ "$has_name" -gt 0 ] && [ "$has_description" -gt 0 ]; then
        test_case "TC-01c" "YAML frontmatter (name, description) exists" 0
    else
        test_case "TC-01c" "YAML frontmatter (name, description) exists" 1
    fi
else
    test_case "TC-01c" "YAML frontmatter (name, description) exists" 1
fi

# TC-01d: templates/ directory exists
if [ -d "$TEMPLATE_DIR" ]; then
    test_case "TC-01d" "templates/ directory exists" 0
else
    test_case "TC-01d" "templates/ directory exists" 1
fi

# TC-01e: playwright.config.ts.tmpl exists
if [ -f "$PLAYWRIGHT_CONFIG_TMPL" ]; then
    test_case "TC-01e" "playwright.config.ts.tmpl exists" 0
else
    test_case "TC-01e" "playwright.config.ts.tmpl exists" 1
fi

# TC-01f: playwright.config.ts.tmpl contains defineConfig
if [ -f "$PLAYWRIGHT_CONFIG_TMPL" ]; then
    has_define_config=$(grep -c "defineConfig" "$PLAYWRIGHT_CONFIG_TMPL" 2>/dev/null || echo 0)
    if [ "$has_define_config" -gt 0 ]; then
        test_case "TC-01f" "playwright.config.ts.tmpl contains defineConfig" 0
    else
        test_case "TC-01f" "playwright.config.ts.tmpl contains defineConfig" 1
    fi
else
    test_case "TC-01f" "playwright.config.ts.tmpl contains defineConfig" 1
fi

# TC-01g: playwright.config.ts.tmpl specifies baseURL placeholder
if [ -f "$PLAYWRIGHT_CONFIG_TMPL" ]; then
    has_baseurl=$(grep -ci "baseURL\|BASE_URL\|{{.*url.*}}" "$PLAYWRIGHT_CONFIG_TMPL" 2>/dev/null || echo 0)
    if [ "$has_baseurl" -gt 0 ]; then
        test_case "TC-01g" "playwright.config.ts.tmpl has baseURL placeholder" 0
    else
        test_case "TC-01g" "playwright.config.ts.tmpl has baseURL placeholder" 1
    fi
else
    test_case "TC-01g" "playwright.config.ts.tmpl has baseURL placeholder" 1
fi

echo ""
echo "--- TC-02: Base Test Template ---"

# TC-02a: base-test.ts.tmpl exists
if [ -f "$BASE_TEST_TMPL" ]; then
    test_case "TC-02a" "base-test.ts.tmpl exists" 0
else
    test_case "TC-02a" "base-test.ts.tmpl exists" 1
fi

# TC-02b: base-test.ts.tmpl imports from @playwright/test
if [ -f "$BASE_TEST_TMPL" ]; then
    has_import=$(grep -c "@playwright/test" "$BASE_TEST_TMPL" 2>/dev/null || echo 0)
    if [ "$has_import" -gt 0 ]; then
        test_case "TC-02b" "base-test.ts.tmpl imports @playwright/test" 0
    else
        test_case "TC-02b" "base-test.ts.tmpl imports @playwright/test" 1
    fi
else
    test_case "TC-02b" "base-test.ts.tmpl imports @playwright/test" 1
fi

# TC-02c: base-test.ts.tmpl has test structure (test.describe or test())
if [ -f "$BASE_TEST_TMPL" ]; then
    has_test=$(grep -c "test\(" "$BASE_TEST_TMPL" 2>/dev/null || echo 0)
    has_describe=$(grep -c "test.describe" "$BASE_TEST_TMPL" 2>/dev/null || echo 0)
    if [ "$has_test" -gt 0 ] || [ "$has_describe" -gt 0 ]; then
        test_case "TC-02c" "base-test.ts.tmpl has test structure" 0
    else
        test_case "TC-02c" "base-test.ts.tmpl has test structure" 1
    fi
else
    test_case "TC-02c" "base-test.ts.tmpl has test structure" 1
fi

echo ""
echo "--- TC-03: Output Directory Specification ---"

# TC-03a: SKILL.md documents output directory
if [ -f "$SKILL_FILE" ]; then
    has_output_dir=$(grep -c "tests/security" "$SKILL_FILE" 2>/dev/null || echo 0)
    if [ "$has_output_dir" -gt 0 ]; then
        test_case "TC-03a" "SKILL.md documents tests/security/ output" 0
    else
        test_case "TC-03a" "SKILL.md documents tests/security/ output" 1
    fi
else
    test_case "TC-03a" "SKILL.md documents tests/security/ output" 1
fi

echo ""
echo "--- TC-04: Empty Vulnerabilities Handling ---"

# TC-04a: SKILL.md documents empty vulnerabilities behavior
if [ -f "$SKILL_FILE" ]; then
    has_empty_doc=$(grep -ci "0件\|empty\|no vulnerabilities" "$SKILL_FILE" 2>/dev/null || echo 0)
    if [ "$has_empty_doc" -gt 0 ]; then
        test_case "TC-04a" "SKILL.md documents empty vulnerabilities behavior" 0
    else
        test_case "TC-04a" "SKILL.md documents empty vulnerabilities behavior" 1
    fi
else
    test_case "TC-04a" "SKILL.md documents empty vulnerabilities behavior" 1
fi

echo ""
echo "--- TC-05/06: File Overwrite Behavior ---"

# TC-05a: SKILL.md documents default overwrite behavior (warning)
if [ -f "$SKILL_FILE" ]; then
    has_overwrite=$(grep -ci "overwrite\|上書き\|既存" "$SKILL_FILE" 2>/dev/null || echo 0)
    if [ "$has_overwrite" -gt 0 ]; then
        test_case "TC-05a" "SKILL.md documents file overwrite behavior" 0
    else
        test_case "TC-05a" "SKILL.md documents file overwrite behavior" 1
    fi
else
    test_case "TC-05a" "SKILL.md documents file overwrite behavior" 1
fi

# TC-06a: SKILL.md documents --force option
if [ -f "$SKILL_FILE" ]; then
    has_force=$(grep -c "\-\-force" "$SKILL_FILE" 2>/dev/null || echo 0)
    if [ "$has_force" -gt 0 ]; then
        test_case "TC-06a" "SKILL.md documents --force option" 0
    else
        test_case "TC-06a" "SKILL.md documents --force option" 1
    fi
else
    test_case "TC-06a" "SKILL.md documents --force option" 1
fi

echo ""
echo "--- TC-07/08: Error Handling ---"

# TC-07a: reference.md exists (detailed error handling docs)
if [ -f "$REFERENCE_FILE" ]; then
    test_case "TC-07a" "reference.md exists" 0
else
    test_case "TC-07a" "reference.md exists" 1
fi

# TC-07b: reference.md documents JSON validation
if [ -f "$REFERENCE_FILE" ]; then
    has_json_error=$(grep -ci "invalid.*json\|json.*error\|validation" "$REFERENCE_FILE" 2>/dev/null || echo 0)
    if [ "$has_json_error" -gt 0 ]; then
        test_case "TC-07b" "reference.md documents JSON validation" 0
    else
        test_case "TC-07b" "reference.md documents JSON validation" 1
    fi
else
    test_case "TC-07b" "reference.md documents JSON validation" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
