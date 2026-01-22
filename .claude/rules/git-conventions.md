# Git Conventions

## Commit Message Format

```
<type>: <subject>
```

## Types

| Type | Description | Example |
|------|-------------|---------|
| feat | New feature/agent/skill | feat: add ssti-attacker agent |
| fix | Bug fix, false positive correction | fix: reduce XSS false positives |
| docs | Documentation | docs: update AGENT_GUIDE |
| refactor | Code restructuring | refactor: simplify detection logic |
| test | Test additions | test: add injection tests |
| chore | Build/config changes | chore: update plugin.json |

## Good Commit Message

```
feat: add SSTI detection for Blade templates

- Pattern matching for {{ }} and {!! !!}
- Support for Laravel Blade syntax

Closes #123
```
