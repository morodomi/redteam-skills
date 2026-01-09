#!/bin/bash
#
# Test: wordpress-attacker WordPress vulnerability detection (Issue #33)
#
# TC-01: [正常系] $wpdb SQLi検出
# TC-02: [正常系] echo XSS検出
# TC-03: [正常系] include LFI検出
# TC-04: [正常系] wp_ajax権限チェック欠如検出
# TC-05: [正常系] REST API permission_callback検出
# TC-06: [正常系] wp-config.php WP_DEBUG検出
# TC-07: [境界値] Safe Pattern除外 (prepare, esc_html)
# TC-08: [エッジケース] 複数脆弱性タイプ混在
# TC-09: [異常系] 対象ファイルなし

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/wordpress-attacker.md"

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

echo "========================================"
echo "wordpress-attacker WordPress Vuln Test"
echo "========================================"
echo ""

# TC-01: $wpdb SQLi検出
echo "--- TC-01: \$wpdb SQLi Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_wpdb=$(grep -c "wpdb" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_wpdb=${has_wpdb:-0}
    has_sqli=$(grep -ci "sql" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_sqli=${has_sqli:-0}

    if [ "$has_wpdb" -gt 0 ] && [ "$has_sqli" -gt 0 ]; then
        test_case "TC-01" "\$wpdb SQLi detection pattern exists" 0
    else
        test_case "TC-01" "\$wpdb SQLi detection pattern exists" 1
    fi
else
    test_case "TC-01" "\$wpdb SQLi detection pattern exists" 1
fi

# TC-02: echo XSS検出
echo ""
echo "--- TC-02: echo XSS Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_echo=$(grep -c "echo" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_echo=${has_echo:-0}
    has_get_post=$(grep -c "_GET\|_POST" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_get_post=${has_get_post:-0}

    if [ "$has_echo" -gt 0 ] && [ "$has_get_post" -gt 0 ]; then
        test_case "TC-02" "echo XSS detection pattern exists" 0
    else
        test_case "TC-02" "echo XSS detection pattern exists" 1
    fi
else
    test_case "TC-02" "echo XSS detection pattern exists" 1
fi

# TC-03: include LFI検出
echo ""
echo "--- TC-03: include LFI Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_include=$(grep -c "include\|require" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_include=${has_include:-0}

    if [ "$has_include" -gt 0 ]; then
        test_case "TC-03" "include LFI detection pattern exists" 0
    else
        test_case "TC-03" "include LFI detection pattern exists" 1
    fi
else
    test_case "TC-03" "include LFI detection pattern exists" 1
fi

# TC-04: wp_ajax権限チェック欠如検出
echo ""
echo "--- TC-04: wp_ajax Privilege Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_wp_ajax=$(grep -c "wp_ajax" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_wp_ajax=${has_wp_ajax:-0}
    has_current_user_can=$(grep -c "current_user_can" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_current_user_can=${has_current_user_can:-0}

    if [ "$has_wp_ajax" -gt 0 ] && [ "$has_current_user_can" -gt 0 ]; then
        test_case "TC-04" "wp_ajax privilege detection pattern exists" 0
    else
        test_case "TC-04" "wp_ajax privilege detection pattern exists" 1
    fi
else
    test_case "TC-04" "wp_ajax privilege detection pattern exists" 1
fi

# TC-05: REST API permission_callback検出
echo ""
echo "--- TC-05: REST API permission_callback Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_rest_api=$(grep -c "rest_api\|register_rest_route" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_rest_api=${has_rest_api:-0}
    has_permission_callback=$(grep -c "permission_callback" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_permission_callback=${has_permission_callback:-0}

    if [ "$has_rest_api" -gt 0 ] && [ "$has_permission_callback" -gt 0 ]; then
        test_case "TC-05" "REST API permission_callback detection exists" 0
    else
        test_case "TC-05" "REST API permission_callback detection exists" 1
    fi
else
    test_case "TC-05" "REST API permission_callback detection exists" 1
fi

# TC-06: wp-config.php WP_DEBUG検出
echo ""
echo "--- TC-06: wp-config.php WP_DEBUG Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_wp_debug=$(grep -c "WP_DEBUG" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_wp_debug=${has_wp_debug:-0}
    has_wp_config=$(grep -c "wp-config" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_wp_config=${has_wp_config:-0}

    if [ "$has_wp_debug" -gt 0 ] && [ "$has_wp_config" -gt 0 ]; then
        test_case "TC-06" "wp-config.php WP_DEBUG detection exists" 0
    else
        test_case "TC-06" "wp-config.php WP_DEBUG detection exists" 1
    fi
else
    test_case "TC-06" "wp-config.php WP_DEBUG detection exists" 1
fi

# TC-07: Safe Pattern除外 (prepare, esc_html)
echo ""
echo "--- TC-07: Safe Pattern Documentation ---"
if [ -f "$AGENT_FILE" ]; then
    has_prepare=$(grep -c "prepare" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_prepare=${has_prepare:-0}
    has_esc_html=$(grep -c "esc_html\|esc_attr" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_esc_html=${has_esc_html:-0}

    if [ "$has_prepare" -gt 0 ] && [ "$has_esc_html" -gt 0 ]; then
        test_case "TC-07" "Safe pattern documentation exists" 0
    else
        test_case "TC-07" "Safe pattern documentation exists" 1
    fi
else
    test_case "TC-07" "Safe pattern documentation exists" 1
fi

# TC-08: 複数脆弱性タイプ混在（Output Format確認）
echo ""
echo "--- TC-08: Multiple Vulnerability Types Support ---"
if [ -f "$AGENT_FILE" ]; then
    has_vulnerability_class=$(grep -c "vulnerability_class" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_vulnerability_class=${has_vulnerability_class:-0}
    has_cwe=$(grep -c "CWE-89\|CWE-79\|CWE-862" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
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
    test_case "TC-09" "wordpress-attacker.md exists" 0
else
    test_case "TC-09" "wordpress-attacker.md exists" 1
fi

echo ""
echo "========================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
