# Git Safety Rules

## Prohibited Actions

- Using `--no-verify`
- Direct push to `main`/`master`
- Force push (force-with-lease is OK)
- Committing secrets/credentials

## Recommended Flow

1. Work on `develop` or `feature/*` branch
2. Merge to `main` via PR
3. Always pass pre-commit hooks

## Branch Protection

| Branch | push | force push | direct commit |
|--------|------|------------|---------------|
| main | X | X | X |
| develop | OK | X | OK |
| feature/* | OK | X | OK |
