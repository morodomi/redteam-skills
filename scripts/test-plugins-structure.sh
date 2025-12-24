#!/bin/bash
#
# Test: redteam-core plugin structure
#
# TC-01: plugin.json exists
# TC-02: plugin.json is valid JSON
# TC-03: plugin.json has required fields (name, version)
# TC-04: agents/ directory exists
# TC-05: skills/ directory exists
# TC-06: README.md exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="$PROJECT_ROOT/plugins/redteam-core"

PASSED=0
FAILED=0

# Test helper
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
echo "redteam-core Plugin Structure Test"
echo "================================"
echo ""

# TC-01: plugin.json exists
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    test_case "TC-01" "plugin.json exists" 0
else
    test_case "TC-01" "plugin.json exists" 1
fi

# TC-02: plugin.json is valid JSON
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    if cat "$PLUGIN_DIR/.claude-plugin/plugin.json" | python3 -m json.tool > /dev/null 2>&1; then
        test_case "TC-02" "plugin.json is valid JSON" 0
    else
        test_case "TC-02" "plugin.json is valid JSON" 1
    fi
else
    test_case "TC-02" "plugin.json is valid JSON" 1
fi

# TC-03: plugin.json has required fields (name, version)
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    name=$(cat "$PLUGIN_DIR/.claude-plugin/plugin.json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('name',''))" 2>/dev/null)
    version=$(cat "$PLUGIN_DIR/.claude-plugin/plugin.json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('version',''))" 2>/dev/null)
    if [ -n "$name" ] && [ -n "$version" ]; then
        test_case "TC-03" "plugin.json has required fields (name, version)" 0
    else
        test_case "TC-03" "plugin.json has required fields (name, version)" 1
    fi
else
    test_case "TC-03" "plugin.json has required fields (name, version)" 1
fi

# TC-04: agents/ directory exists
if [ -d "$PLUGIN_DIR/agents" ]; then
    test_case "TC-04" "agents/ directory exists" 0
else
    test_case "TC-04" "agents/ directory exists" 1
fi

# TC-05: skills/ directory exists
if [ -d "$PLUGIN_DIR/skills" ]; then
    test_case "TC-05" "skills/ directory exists" 0
else
    test_case "TC-05" "skills/ directory exists" 1
fi

# TC-06: README.md exists
if [ -f "$PLUGIN_DIR/README.md" ]; then
    test_case "TC-06" "README.md exists" 0
else
    test_case "TC-06" "README.md exists" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
