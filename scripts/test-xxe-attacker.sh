#!/bin/bash
#
# Test: xxe-attacker XXE detection (Issue #32)
#
# TC-01: [正常系] PHP simplexml XXE検出
# TC-02: [正常系] PHP LIBXML_NOENT XXE検出
# TC-03: [正常系] Python lxml XXE検出
# TC-04: [正常系] Python xml.sax XXE検出
# TC-05: [正常系] Java DocumentBuilderFactory XXE検出
# TC-06: [正常系] Node.js libxmljs XXE検出
# TC-07: [境界値] 安全なパターン除外（defusedxml等）
# TC-08: [エッジケース] 複数言語混在
# TC-09: [異常系] 対象ファイルなし

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_FILE="$PROJECT_ROOT/plugins/redteam-core/agents/xxe-attacker.md"

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
echo "xxe-attacker XXE Detection Test"
echo "================================"
echo ""

# TC-01: PHP simplexml XXE検出
echo "--- TC-01: PHP simplexml XXE Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_php=$(grep -ci "php" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_php=${has_php:-0}
    has_simplexml=$(grep -c "simplexml" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_simplexml=${has_simplexml:-0}

    if [ "$has_php" -gt 0 ] && [ "$has_simplexml" -gt 0 ]; then
        test_case "TC-01" "PHP simplexml XXE detection pattern exists" 0
    else
        test_case "TC-01" "PHP simplexml XXE detection pattern exists" 1
    fi
else
    test_case "TC-01" "PHP simplexml XXE detection pattern exists" 1
fi

# TC-02: PHP LIBXML_NOENT XXE検出
echo ""
echo "--- TC-02: PHP LIBXML_NOENT XXE Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_libxml_noent=$(grep -c "LIBXML_NOENT" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_libxml_noent=${has_libxml_noent:-0}

    if [ "$has_libxml_noent" -gt 0 ]; then
        test_case "TC-02" "PHP LIBXML_NOENT XXE detection pattern exists" 0
    else
        test_case "TC-02" "PHP LIBXML_NOENT XXE detection pattern exists" 1
    fi
else
    test_case "TC-02" "PHP LIBXML_NOENT XXE detection pattern exists" 1
fi

# TC-03: Python lxml XXE検出
echo ""
echo "--- TC-03: Python lxml XXE Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_python=$(grep -ci "python" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_python=${has_python:-0}
    has_lxml=$(grep -c "lxml" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_lxml=${has_lxml:-0}

    if [ "$has_python" -gt 0 ] && [ "$has_lxml" -gt 0 ]; then
        test_case "TC-03" "Python lxml XXE detection pattern exists" 0
    else
        test_case "TC-03" "Python lxml XXE detection pattern exists" 1
    fi
else
    test_case "TC-03" "Python lxml XXE detection pattern exists" 1
fi

# TC-04: Python xml.sax XXE検出
echo ""
echo "--- TC-04: Python xml.sax XXE Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_xml_sax=$(grep -c "xml\.sax" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_xml_sax=${has_xml_sax:-0}

    if [ "$has_xml_sax" -gt 0 ]; then
        test_case "TC-04" "Python xml.sax XXE detection pattern exists" 0
    else
        test_case "TC-04" "Python xml.sax XXE detection pattern exists" 1
    fi
else
    test_case "TC-04" "Python xml.sax XXE detection pattern exists" 1
fi

# TC-05: Java DocumentBuilderFactory XXE検出
echo ""
echo "--- TC-05: Java DocumentBuilderFactory XXE Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_java=$(grep -ci "java" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_java=${has_java:-0}
    has_documentbuilder=$(grep -c "DocumentBuilder" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_documentbuilder=${has_documentbuilder:-0}

    if [ "$has_java" -gt 0 ] && [ "$has_documentbuilder" -gt 0 ]; then
        test_case "TC-05" "Java DocumentBuilderFactory XXE detection pattern exists" 0
    else
        test_case "TC-05" "Java DocumentBuilderFactory XXE detection pattern exists" 1
    fi
else
    test_case "TC-05" "Java DocumentBuilderFactory XXE detection pattern exists" 1
fi

# TC-06: Node.js libxmljs XXE検出
echo ""
echo "--- TC-06: Node.js libxmljs XXE Detection ---"
if [ -f "$AGENT_FILE" ]; then
    has_nodejs=$(grep -ci "node" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_nodejs=${has_nodejs:-0}
    has_libxmljs=$(grep -c "libxmljs" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_libxmljs=${has_libxmljs:-0}

    if [ "$has_nodejs" -gt 0 ] && [ "$has_libxmljs" -gt 0 ]; then
        test_case "TC-06" "Node.js libxmljs XXE detection pattern exists" 0
    else
        test_case "TC-06" "Node.js libxmljs XXE detection pattern exists" 1
    fi
else
    test_case "TC-06" "Node.js libxmljs XXE detection pattern exists" 1
fi

# TC-07: 安全なパターン除外（defusedxml等）
echo ""
echo "--- TC-07: Safe Pattern Documentation ---"
if [ -f "$AGENT_FILE" ]; then
    has_safe=$(grep -ci "safe" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_safe=${has_safe:-0}
    has_defusedxml=$(grep -c "defusedxml" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_defusedxml=${has_defusedxml:-0}

    if [ "$has_safe" -gt 0 ] || [ "$has_defusedxml" -gt 0 ]; then
        test_case "TC-07" "Safe pattern documentation exists" 0
    else
        test_case "TC-07" "Safe pattern documentation exists" 1
    fi
else
    test_case "TC-07" "Safe pattern documentation exists" 1
fi

# TC-08: 複数言語混在（Output Format確認）
echo ""
echo "--- TC-08: Multiple Language Types Support ---"
if [ -f "$AGENT_FILE" ]; then
    has_vulnerability_class=$(grep -c "vulnerability_class" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
    has_vulnerability_class=${has_vulnerability_class:-0}
    has_cwe=$(grep -c "CWE-611" "$AGENT_FILE" 2>/dev/null | head -1 || echo 0)
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
    test_case "TC-09" "xxe-attacker.md exists" 0
else
    test_case "TC-09" "xxe-attacker.md exists" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
