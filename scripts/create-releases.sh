#!/bin/bash
#
# Create missing git tags and GitHub Releases for all versions.
# Idempotent: skips existing tags and releases.
#
# Usage: bash scripts/create-releases.sh
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CHANGELOG="$PROJECT_ROOT/CHANGELOG.md"
REPO="morodomi/redteam-skills"

# Version:Commit pairs (Bash 3.x compatible, no associative arrays)
VERSION_MAP="
v0.1.0:aef0c06
v0.2.0:b114e1f
v1.0.0:84c95f6
v1.1.0:09173ac
v1.2.0:f9ffcfe
v2.0.0:3cb5570
v2.1.0:0f18ffb
v2.2.0:a0ce30c
v2.3.0:f15ded1
v3.0.0:04df89d
v3.1.0:0a32c35
v3.2.0:57cfbdc
v4.0.0:0477bd3
v4.1.0:6147771
v4.2.0:3d1d47b
"

VERSIONS_ORDERED=(
    v0.1.0 v0.2.0
    v1.0.0 v1.1.0 v1.2.0
    v2.0.0 v2.1.0 v2.2.0 v2.3.0
    v3.0.0 v3.1.0 v3.2.0
    v4.0.0 v4.1.0 v4.2.0
)

LATEST_VERSION="v4.2.0"

# Lookup commit for a version
get_commit() {
    local version="$1"
    echo "$VERSION_MAP" | grep "^${version}:" | cut -d: -f2
}

# Extract release notes from CHANGELOG.md for a given version
extract_notes() {
    local version="$1"
    local version_num="${version#v}"
    local in_section=0
    local notes=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^##\ \[${version_num}\] ]]; then
            in_section=1
            continue
        fi
        if [ "$in_section" -eq 1 ] && [[ "$line" =~ ^##\ \[ ]]; then
            break
        fi
        if [ "$in_section" -eq 1 ]; then
            notes="${notes}${line}
"
        fi
    done < "$CHANGELOG"

    # Trim leading blank lines (BSD sed compatible)
    echo "$notes" | sed '/./,$!d'
}

echo "================================"
echo "Create Tags & Releases"
echo "================================"
echo ""

# Step 1: Create missing tags
echo "--- Creating Tags ---"
tags_created=0
tags_skipped=0

for version in "${VERSIONS_ORDERED[@]}"; do
    commit=$(get_commit "$version")
    if [ -z "$commit" ]; then
        echo "  ERROR $version: no commit mapping"
        continue
    fi
    if git -C "$PROJECT_ROOT" tag -l "$version" | grep -q "$version"; then
        echo "  SKIP $version (tag exists)"
        tags_skipped=$((tags_skipped + 1))
    else
        if git -C "$PROJECT_ROOT" show "$commit" --quiet 2>/dev/null; then
            git -C "$PROJECT_ROOT" tag "$version" "$commit"
            echo "  CREATE $version -> $commit"
            tags_created=$((tags_created + 1))
        else
            echo "  ERROR $version: commit $commit not found"
        fi
    fi
done

echo ""
echo "Tags: $tags_created created, $tags_skipped skipped"
echo ""

# Step 2: Push tags
if [ "$tags_created" -gt 0 ]; then
    echo "--- Pushing Tags ---"
    git -C "$PROJECT_ROOT" push origin --tags
    echo ""
fi

# Step 3: Create GitHub Releases
echo "--- Creating Releases ---"
releases_created=0
releases_skipped=0

for version in "${VERSIONS_ORDERED[@]}"; do
    if gh release view "$version" --repo "$REPO" > /dev/null 2>&1; then
        echo "  SKIP $version (release exists)"
        releases_skipped=$((releases_skipped + 1))
        continue
    fi

    notes=$(extract_notes "$version")
    if [ -z "$notes" ]; then
        notes="Release $version"
    fi

    latest_flag="--latest=false"
    if [ "$version" = "$LATEST_VERSION" ]; then
        latest_flag="--latest"
    fi

    gh release create "$version" \
        --repo "$REPO" \
        --title "$version" \
        --notes "$notes" \
        $latest_flag

    if [ $? -eq 0 ]; then
        echo "  CREATE $version"
        releases_created=$((releases_created + 1))
    else
        echo "  ERROR $version: release creation failed"
    fi
done

echo ""
echo "Releases: $releases_created created, $releases_skipped skipped"
echo ""
echo "================================"
echo "Done"
echo "================================"
