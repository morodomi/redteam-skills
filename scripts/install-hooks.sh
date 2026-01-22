#!/bin/bash
# scripts/install-hooks.sh - Install git hooks

# Check if .git directory exists
if [ ! -d ".git" ]; then
    echo "Error: Not a git repository. Run from repository root."
    exit 1
fi

# Check if source file exists
if [ ! -f "scripts/pre-commit" ]; then
    echo "Error: scripts/pre-commit not found."
    exit 1
fi

# Create hooks directory if needed
mkdir -p .git/hooks

cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo "Pre-commit hook installed."
