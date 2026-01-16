# Cycle: naming-unification

| Item | Value |
|------|-------|
| Issue | #48 |
| Phase | DONE |
| Created | 2026-01-16 10:11 |

## Environment

| Tool | Version |
|------|---------|
| Node.js | v22.17.0 |

## Goal

vulnerability_class命名規則を統一し、エージェント間の整合性を確保する。

## Background

From Issue #48:
- `false-positive-filter` では `sqli`, `xss` という略称を使用
- `injection-attacker` は `sql-injection` を出力
- `xss-attacker` は `xss` を出力
- 命名規則が統一されていない

## Scope

From Issue #48:
- [ ] 命名規則の統一方針決定
- [ ] 対象エージェントの出力形式修正
- [ ] マッピングテーブルまたは共通定義の作成

## PLAN

### 現状分析

| Agent | vulnerability_class | type |
|-------|-------------------|------|
| injection-attacker | `sql-injection` | union-based, error-based |
| injection-attacker | `command-injection` | direct-execution |
| xss-attacker | `xss` | reflected, dom, stored |
| ssrf-attacker | `ssrf` | ssrf |
| csrf-attacker | `csrf` | csrf-token-missing |
| ssti-attacker | `ssti` | blade-ssti, jinja2-ssti |
| xxe-attacker | `xxe` | classic-xxe |
| file-attacker | `path-traversal` | path-traversal |
| false-positive-filter | **`sqli`** (不整合) | - |

### 命名規則

```yaml
vulnerability_class:
  format: lowercase-hyphenated
  rules:
    - 完全名を使用: sql-injection, command-injection, path-traversal
    - 業界標準略称は許可: xss, ssrf, csrf, xxe, ssti, lfi, bola
    - NG: sqli (→ sql-injection), cmdi (→ command-injection)

type:
  format: lowercase-hyphenated
  purpose: vulnerability_class内の具体的な手法/バリアント
  examples:
    - sql-injection: union-based, error-based, boolean-blind, time-blind
    - xss: reflected, dom, stored
    - csrf: csrf-token-missing, csrf-protection-disabled
```

### 変更内容

| Before | After | 理由 |
|--------|-------|------|
| `sqli` | `sql-injection` | 完全名ルール適用 |

### 影響範囲

| ファイル | 変更内容 |
|----------|----------|
| `false-positive-filter.md` | `sqli` → `sql-injection` |
| `security-scan/reference.md` | 命名規則セクション追加 |

### Files

```
plugins/redteam-core/agents/
└── false-positive-filter.md  # 修正

plugins/redteam-core/skills/security-scan/
└── reference.md              # 命名規則追加

scripts/
└── test-naming-convention.sh # 新規
```

## Test List

### TODO

(なし)

### WIP

(なし)

### DONE

#### false-positive-filter
- [x] TC-01: false-positive-filterに`sqli`が存在しない
- [x] TC-02: false-positive-filterに`sql-injection`が存在する

#### security-scan reference
- [x] TC-03: reference.mdに命名規則セクションがある
- [x] TC-04: reference.mdに`vulnerability_class`フォーマット定義がある
- [x] TC-05: reference.mdに許可された略称リストがある

#### 整合性チェック
- [x] TC-06: 全エージェントで`sqli:`が使用されていない
- [x] TC-07: injection-attackerが`sql-injection`を出力する

### GREEN結果

```
Results: 7 passed, 0 failed
```

## REVIEW

### Quality Gate Results

| Reviewer | Score | Judgment |
|----------|-------|----------|
| correctness | 25 | PASS |
| security | 15 | PASS |
| guidelines | 25 | PASS |
| performance | 15 | PASS |

**Max Score: 25 → PASS**

### Findings Summary

#### Correctness (Score: 25)
- `sqli:` → `sql-injection:` 変更は命名規則に準拠
- テストスクリプトが適切に検証
- Minor: 全てのvulnerability_class値のリスト化は未実施（将来課題）

#### Security (Score: 15)
- ドキュメント/設定ファイルのみの変更
- セキュリティリスクなし

#### Guidelines (Score: 25)
- `sqli:` → `sql-injection:` 3箇所修正済み
- 命名規則セクションが適切なフォーマットで追加
- lowercase-hyphenated形式に準拠

#### Performance (Score: 15)
- ドキュメント変更のみ、パフォーマンス影響なし

## Notes

- Issue #45 (false-positive-filter) の quality-gate で検出
- Issue #47 (schema-unification) の後続タスク
