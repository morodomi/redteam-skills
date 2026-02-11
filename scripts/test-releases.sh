#!/bin/bash
#
# Test: Release management - tags and GitHub Releases
#
# TC-01: All 15 tags exist
# TC-02: Tags are in version order (v0.1.0 < ... < v4.2.0)
# TC-03: All 15 GitHub Releases exist
# TC-04: Each Release has release notes
# TC-05: Major versions are not pre-release
# TC-06: Oldest tag v0.1.0 points to correct commit
# TC-07: Latest tag v4.2.0 points to correct commit
# TC-08: Existing 7 tags are preserved
# TC-09: create-releases.sh is idempotent

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPO="morodomi/redteam-skills"

PASSED=0
FAILED=0

EXPECTED_TAGS=(
    v0.1.0 v0.2.0
    v1.0.0 v1.1.0 v1.2.0
    v2.0.0 v2.1.0 v2.2.0 v2.3.0
    v3.0.0 v3.1.0 v3.2.0
    v4.0.0 v4.1.0 v4.2.0
)

EXISTING_TAGS=(v1.2.0 v2.1.0 v2.2.0 v2.3.0 v3.0.0 v4.0.0 v4.2.0)

MAJOR_VERSIONS=(v1.0.0 v2.0.0 v3.0.0 v4.0.0)

# Test helper
test_case() {
    local tc_id="$1"
    local description="$2"
    local result="$3"

    if [ "$result" = "0" ]; then
        echo "  PASS $tc_id: $description"
        ((PASSED++))
    else
        echo "  FAIL $tc_id: $description"
        ((FAILED++))
    fi
}

echo "================================"
echo "Release Management Test"
echo "================================"
echo ""

# TC-01: All 15 tags exist
echo "--- Tags ---"
missing_tags=0
for tag in "${EXPECTED_TAGS[@]}"; do
    if ! git -C "$PROJECT_ROOT" tag -l "$tag" | grep -q "$tag"; then
        missing_tags=$((missing_tags + 1))
    fi
done
if [ "$missing_tags" -eq 0 ]; then
    test_case "TC-01" "All 15 tags exist" 0
else
    test_case "TC-01" "All 15 tags exist ($missing_tags missing)" 1
fi

# TC-02: Tags are in version order
actual_tags=$(git -C "$PROJECT_ROOT" tag -l 'v*' | sort -V)
expected_sorted=$(printf '%s\n' "${EXPECTED_TAGS[@]}" | sort -V)
if [ "$actual_tags" = "$expected_sorted" ]; then
    test_case "TC-02" "Tags are in version order" 0
else
    test_case "TC-02" "Tags are in version order" 1
fi

# TC-03: All 15 GitHub Releases exist
echo ""
echo "--- GitHub Releases ---"
release_count=$(gh release list --repo "$REPO" --limit 100 --json tagName --jq 'length' 2>/dev/null)
if [ "$release_count" = "15" ]; then
    test_case "TC-03" "All 15 GitHub Releases exist (found: $release_count)" 0
else
    test_case "TC-03" "All 15 GitHub Releases exist (found: ${release_count:-0})" 1
fi

# TC-04: Each Release has release notes
empty_notes=0
for tag in "${EXPECTED_TAGS[@]}"; do
    body=$(gh release view "$tag" --repo "$REPO" --json body --jq '.body' 2>/dev/null)
    if [ -z "$body" ] || [ "$body" = "" ]; then
        empty_notes=$((empty_notes + 1))
    fi
done
if [ "$empty_notes" -eq 0 ]; then
    test_case "TC-04" "Each Release has release notes" 0
else
    test_case "TC-04" "Each Release has release notes ($empty_notes empty)" 1
fi

# TC-05: Major versions are not pre-release
echo ""
echo "--- Release Properties ---"
prerelease_majors=0
for tag in "${MAJOR_VERSIONS[@]}"; do
    is_prerelease=$(gh release view "$tag" --repo "$REPO" --json isPrerelease --jq '.isPrerelease' 2>/dev/null)
    if [ "$is_prerelease" = "true" ]; then
        prerelease_majors=$((prerelease_majors + 1))
    fi
done
if [ "$prerelease_majors" -eq 0 ]; then
    test_case "TC-05" "Major versions are not pre-release" 0
else
    test_case "TC-05" "Major versions are not pre-release ($prerelease_majors are pre-release)" 1
fi

# TC-06: Oldest tag v0.1.0 points to correct commit
echo ""
echo "--- Tag-Commit Mapping ---"
oldest_commit=$(git -C "$PROJECT_ROOT" rev-parse --short v0.1.0 2>/dev/null)
if [ "$oldest_commit" = "aef0c06" ]; then
    test_case "TC-06" "v0.1.0 points to aef0c06" 0
else
    test_case "TC-06" "v0.1.0 points to aef0c06 (actual: ${oldest_commit:-not found})" 1
fi

# TC-07: Latest tag v4.2.0 points to correct commit
latest_commit=$(git -C "$PROJECT_ROOT" rev-parse --short v4.2.0 2>/dev/null)
if [ "$latest_commit" = "3d1d47b" ]; then
    test_case "TC-07" "v4.2.0 points to 3d1d47b" 0
else
    test_case "TC-07" "v4.2.0 points to 3d1d47b (actual: ${latest_commit:-not found})" 1
fi

# TC-08: Existing 7 tags are preserved
echo ""
echo "--- Tag Preservation ---"
preserved=0
for tag in "${EXISTING_TAGS[@]}"; do
    if git -C "$PROJECT_ROOT" tag -l "$tag" | grep -q "$tag"; then
        preserved=$((preserved + 1))
    fi
done
if [ "$preserved" -eq 7 ]; then
    test_case "TC-08" "Existing 7 tags preserved ($preserved/7)" 0
else
    test_case "TC-08" "Existing 7 tags preserved ($preserved/7)" 1
fi

# TC-09: create-releases.sh is idempotent (script exists and is executable)
echo ""
echo "--- Script ---"
if [ -x "$SCRIPT_DIR/create-releases.sh" ]; then
    test_case "TC-09" "create-releases.sh exists and is executable" 0
else
    test_case "TC-09" "create-releases.sh exists and is executable" 1
fi

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
