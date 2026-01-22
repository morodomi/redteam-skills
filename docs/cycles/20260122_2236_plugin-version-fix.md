# Cycle: plugin-version-fix

## Meta

| Item | Value |
|------|-------|
| Issue | #51 |
| Phase | DONE |
| Created | 2026-01-22 22:36 |

## Goal

plugin.jsonのバージョンをCHANGELOGと整合させる（1.2.0 → 4.0.0）。

## Environment

- **Distribution**: Claude Code Plugins
- **Target File**: plugins/redteam-core/.claude-plugin/plugin.json

## Deliverables

| File | Change |
|------|--------|
| plugins/redteam-core/.claude-plugin/plugin.json | version: "1.2.0" → "4.0.0" |

## Test List

- [ ] TC-01: plugin.jsonが有効なJSONである
- [ ] TC-02: versionが"4.0.0"である

## Progress

| Phase | Status | Note |
|-------|--------|------|
| INIT | Done | 2026-01-22 |
| PLAN | Done | 2026-01-22 |
| RED | Done | 2026-01-22 |
| GREEN | Done | 2026-01-22 |
| REFACTOR | Skip | Simple fix |
| REVIEW | Done | 2026-01-22 |
| COMMIT | Done | 2026-01-22 |
