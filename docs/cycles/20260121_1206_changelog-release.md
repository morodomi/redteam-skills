# Cycle: changelog-release

| Item | Value |
|------|-------|
| Issue | - |
| Phase | DONE |
| Created | 2026-01-21 12:06 |

## Environment

| Tool | Version |
|------|---------|
| Claude Code | Plugins |

## Goal

CHANGELOG.mdのRoadmap乖離を解消し、v3.1.0以降の実装済み機能を正確に反映する。

## Background

CHANGELOGのRoadmapが古く、実装済み機能が「Planned」のまま:
- v4.0: sca-attacker (#40) - 実装済み
- v4.1: dast-crawler (#42) - 実装済み
- v4.2: attack-scenario (#43) - 実装済み
- v5.0: false-positive-filter (#45) - 実装済み

また、以下の機能がCHANGELOGに未記載:
- #46: sca-attacker-v4 (sca-scan統合)
- #47: schema-unification
- #48: naming-unification

## Scope

- [ ] v3.1.0セクションに#47, #48を追加
- [ ] v3.2.0セクション作成（#40, #41/46, #42, #43, #45）
- [ ] Roadmap更新（完了分削除、#44のみ残す）
- [ ] docs/STATUS.md更新（Current Version, Milestones）

## PLAN

### 変更内容

#### 1. CHANGELOG.md

**v3.1.0セクション追記:**
- #47: 出力スキーマ統一 (既存、内容確認)
- #48: vulnerability_class命名規則統一 (追加)

**v3.2.0セクション新規作成:**
| Issue | 機能 | 日付 |
|-------|------|------|
| #40 | sca-attacker: 依存関係脆弱性検出 | 2026-01-14 |
| #41 | sca-scan: security-scanへのSCA統合 | 2026-01-14 |
| #42 | dast-crawler: Playwright URL自動発見 | 2026-01-15 |
| #43 | attack-scenario: 攻撃シナリオ自動生成 | 2026-01-15 |
| #45 | false-positive-filter: 誤検知自動除外 | 2026-01-15 |
| #46 | sca-attacker-v4: OSV API改善 | 2026-01-15 |

**Roadmap更新:**
- 削除: v4.0, v4.1, v4.2, v5.0 (false-positive-filter)
- 残す: v5.0 - context-reviewer (#44) のみ

#### 2. docs/STATUS.md

- Current Version: 3.0.0 → 3.2.0
- Last Updated: 2026-01-11 → 2026-01-21
- v4.0-v5.0 マイルストーン更新 (Done/Planned)
- Recent Cycles追加 (#41-#48)

### Files

```
CHANGELOG.md           # リリース情報更新
docs/STATUS.md         # バージョン・マイルストーン更新
```

## Test List

### TODO

(なし)

### WIP

(なし)

### DONE

#### CHANGELOG.md
- [x] TC-01: v3.1.0に#48が記載されている
- [x] TC-02: v3.2.0セクションが存在する
- [x] TC-03: v3.2.0に#40, #41, #42, #43, #45, #46が記載
- [x] TC-04: Roadmapにv4.1-v4.2が存在しない
- [x] TC-05: Roadmapにcontext-reviewer (#44)のみ残っている

#### docs/STATUS.md
- [x] TC-06: Current Versionが3.2.0
- [x] TC-07: Last Updatedが2026-01-21
- [x] TC-08: v3.2 sca-attackerがDone
- [x] TC-09: v3.2 dast-crawlerがDone
- [x] TC-10: v3.2 attack-scenarioがDone
- [x] TC-11: v3.2 false-positive-filterがDone
- [x] TC-12: v4.0 context-reviewerがPlanned

### GREEN結果

```
Results: 12 passed, 0 failed
```

## REFACTOR

リファクタリング対象なし（ドキュメント更新のみ）。

## REVIEW

### Quality Gate Results

| Reviewer | Score | Judgment |
|----------|-------|----------|
| correctness | 10 | PASS |
| security | 0 | PASS |
| guidelines | 10 | PASS |
| performance | 0 | PASS |

**Max Score: 10 → PASS**

### Findings Summary

- ドキュメント更新のみ、セキュリティ/パフォーマンス影響なし
- CHANGELOG.md: v3.2.0追加、Roadmap整理、フォーマット準拠
- docs/STATUS.md: バージョン・マイルストーン更新、整合性OK

## Notes

- ドキュメント更新のみ、コード変更なし
- リリースタグは不要（ドキュメント整備）
