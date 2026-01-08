#!/bin/bash
#
# Test: ssti-attacker SSTI detection (Issue #31)
#
# TC-01: [正常系] Blade SSTI検出
# TC-02: [正常系] Jinja2 Flask SSTI検出
# TC-03: [正常系] Jinja2 Django SSTI検出
# TC-04: [正常系] Twig SSTI検出
# TC-05: [正常系] ERB SSTI検出
# TC-06: [正常系] EJS SSTI検出
# TC-07: [境界値] 安全なパターン除外
# TC-08: [エッジケース] 複数エンジン混在
# TC-09: [異常系] 対象ファイルなし

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/ssti-attacker.md"

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
echo "ssti-attacker SSTI Detection Test"
echo "================================"
echo ""

# TC-01: Blade SSTI検出
echo "--- TC-01: Blade SSTI Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_blade=$(grep -ci "blade" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_blade=${has_blade:-0}
    has_compile=$(grep -c "compileString" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_compile=${has_compile:-0}

    if [ "$has_blade" -gt 0 ] && [ "$has_compile" -gt 0 ]; then
        test_case "TC-01" "Blade SSTI detection pattern exists" 0
    else
        test_case "TC-01" "Blade SSTI detection pattern exists" 1
    fi
else
    test_case "TC-01" "Blade SSTI detection pattern exists" 1
fi

# TC-02: Jinja2 Flask SSTI検出
echo ""
echo "--- TC-02: Jinja2 Flask SSTI Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_jinja2=$(grep -ci "jinja2" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_jinja2=${has_jinja2:-0}
    has_render_template_string=$(grep -c "render_template_string" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_render_template_string=${has_render_template_string:-0}

    if [ "$has_jinja2" -gt 0 ] && [ "$has_render_template_string" -gt 0 ]; then
        test_case "TC-02" "Jinja2 Flask SSTI detection pattern exists" 0
    else
        test_case "TC-02" "Jinja2 Flask SSTI detection pattern exists" 1
    fi
else
    test_case "TC-02" "Jinja2 Flask SSTI detection pattern exists" 1
fi

# TC-03: Jinja2 Django SSTI検出
echo ""
echo "--- TC-03: Jinja2 Django SSTI Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_django=$(grep -ci "django" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_django=${has_django:-0}
    has_template=$(grep -c "Template(" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_template=${has_template:-0}

    if [ "$has_django" -gt 0 ] && [ "$has_template" -gt 0 ]; then
        test_case "TC-03" "Jinja2 Django SSTI detection pattern exists" 0
    else
        test_case "TC-03" "Jinja2 Django SSTI detection pattern exists" 1
    fi
else
    test_case "TC-03" "Jinja2 Django SSTI detection pattern exists" 1
fi

# TC-04: Twig SSTI検出
echo ""
echo "--- TC-04: Twig SSTI Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_twig=$(grep -ci "twig" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_twig=${has_twig:-0}
    has_createtemplate=$(grep -c "createTemplate" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_createtemplate=${has_createtemplate:-0}

    if [ "$has_twig" -gt 0 ] && [ "$has_createtemplate" -gt 0 ]; then
        test_case "TC-04" "Twig SSTI detection pattern exists" 0
    else
        test_case "TC-04" "Twig SSTI detection pattern exists" 1
    fi
else
    test_case "TC-04" "Twig SSTI detection pattern exists" 1
fi

# TC-05: ERB SSTI検出
echo ""
echo "--- TC-05: ERB SSTI Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_erb=$(grep -ci "erb" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_erb=${has_erb:-0}
    has_erb_new=$(grep -c "ERB\.new" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_erb_new=${has_erb_new:-0}

    if [ "$has_erb" -gt 0 ] && [ "$has_erb_new" -gt 0 ]; then
        test_case "TC-05" "ERB SSTI detection pattern exists" 0
    else
        test_case "TC-05" "ERB SSTI detection pattern exists" 1
    fi
else
    test_case "TC-05" "ERB SSTI detection pattern exists" 1
fi

# TC-06: EJS SSTI検出
echo ""
echo "--- TC-06: EJS SSTI Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_ejs=$(grep -ci "ejs" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_ejs=${has_ejs:-0}
    has_ejs_render=$(grep -c "ejs\.render" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_ejs_render=${has_ejs_render:-0}

    if [ "$has_ejs" -gt 0 ] && [ "$has_ejs_render" -gt 0 ]; then
        test_case "TC-06" "EJS SSTI detection pattern exists" 0
    else
        test_case "TC-06" "EJS SSTI detection pattern exists" 1
    fi
else
    test_case "TC-06" "EJS SSTI detection pattern exists" 1
fi

# TC-07: 安全なパターン除外
echo ""
echo "--- TC-07: Safe Pattern Documentation ---"
if [ -f "$AGENT_FILE" ]; then
    has_safe=$(grep -ci "safe" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_safe=${has_safe:-0}
    has_view=$(grep -c "view(" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_view=${has_view:-0}
    has_render_template=$(grep -c "render_template(" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_render_template=${has_render_template:-0}

    if [ "$has_safe" -gt 0 ] || [ "$has_view" -gt 0 ] || [ "$has_render_template" -gt 0 ]; then
        test_case "TC-07" "Safe pattern documentation exists" 0
    else
        test_case "TC-07" "Safe pattern documentation exists" 1
    fi
else
    test_case "TC-07" "Safe pattern documentation exists" 1
fi

# TC-08: 複数エンジン混在（Output Format確認）
echo ""
echo "--- TC-08: Multiple Engine Types Support ---"
if [ -f "$AGENT_FILE" ]; then
    has_vulnerability_class=$(grep -c "vulnerability_class" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_vulnerability_class=${has_vulnerability_class:-0}
    has_ssti=$(grep -c '"ssti"' "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_ssti=${has_ssti:-0}
    has_cwe=$(grep -c "CWE-1336" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_cwe=${has_cwe:-0}

    if [ "$has_vulnerability_class" -gt 0 ] && [ "$has_cwe" -gt 0 ]; then
        test_case "TC-08" "Output format with vulnerability_class and CWE exists" 0
    else
        test_case "TC-08" "Output format with vulnerability_class and CWE exists" 1
    fi
else
    test_case "TC-08" "Output format with vulnerability_class and CWE exists" 1
fi

# TC-09: 対象ファイルなし
echo ""
echo "--- TC-09: Agent File Exists ---"
if [ -f "$AGENT_FILE" ]; then
    test_case "TC-09" "ssti-attacker.md exists" 0
else
    test_case "TC-09" "ssti-attacker.md exists" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
