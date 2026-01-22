# Testing Guide

## Plugin Structure Tests

```bash
# Plugin structure validation
bash scripts/test-plugins-structure.sh

# Documentation structure validation
bash scripts/test-docs-structure.sh
```

## Test Patterns

### Agent Tests

- Verify agent file exists
- Check required sections (## Target, ## Detection, etc.)
- Validate OWASP mapping

### Skill Tests

- Verify SKILL.md < 100 lines
- Check reference.md exists
- Validate skill metadata

## Given/When/Then Format

```bash
# Given: File exists
# When: Run structure test
# Then: All checks pass
```
