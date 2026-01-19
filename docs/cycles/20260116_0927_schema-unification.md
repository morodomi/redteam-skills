# Cycle: schema-unification

| Item | Value |
|------|-------|
| Issue | #47 |
| Phase | DONE |
| Created | 2026-01-16 09:27 |

## Environment

| Tool | Version |
|------|---------|
| Node.js | v22.17.0 |

## Goal

security-scan出力スキーマを統一し、false-positive-filterとの整合性を確保する。

## Background

From Issue #47:
- `false-positive-filter` の入力形式は `vulnerabilities` 配列を期待
- `security-scan` の出力形式は `details` 配列を使用
- スキーマの不一致により統合時に問題が発生する可能性

## Scope

From Issue #47:
- [ ] スキーマ統一方針の決定
- [ ] security-scan SKILL.md の出力形式修正
- [ ] 関連エージェントとの整合性確認

## PLAN

### 方針

案1: security-scan側を修正し、命名を直感的に統一

### 変更内容

| Before | After | 内容 |
|--------|-------|------|
| `vulnerabilities` | `summary` | サマリ（件数）※既存パターンに統一 |
| `details` | `vulnerabilities` | 実際の脆弱性配列 |

### 変更後スキーマ

```json
{
  "metadata": {
    "scan_id": "<uuid>",
    "scanned_at": "<timestamp>",
    "target_directory": "<path>"
  },
  "recon": {
    "framework": "Laravel",
    "endpoints_count": 15,
    "high_priority_count": 5
  },
  "sca": {
    "packages_scanned": 45,
    "vulnerable_count": 3,
    "ecosystems": ["npm", "Packagist"]
  },
  "summary": {
    "total": 3,
    "critical": 0,
    "high": 2,
    "medium": 1,
    "low": 0
  },
  "vulnerabilities": [
    {
      "agent": "injection-attacker",
      "id": "SQLI-001",
      "severity": "high",
      "file": "app/Controllers/UserController.php",
      "line": 45
    }
  ]
}
```

### 命名規則の根拠

既存エージェントの命名パターンに統一:

| エージェント | カウント用 | 配列用 |
|--------------|-----------|--------|
| false-positive-filter | `summary` | `vulnerabilities` |
| attack-scenario | `summary` | `vulnerabilities` |
| sca-attacker | `summary` | `vulnerabilities` |
| **security-scan (変更後)** | `summary` | `vulnerabilities` |

### 影響範囲

| ファイル | 変更内容 |
|----------|----------|
| `plugins/redteam-core/skills/security-scan/SKILL.md` | Output Format更新 |
| `plugins/redteam-core/skills/security-scan/reference.md` | スキーマ更新 |
| `plugins/redteam-core/skills/attack-report/SKILL.md` | Input Format更新 |
| `plugins/redteam-core/skills/attack-report/reference.md` | スキーマ更新 |
| `plugins/redteam-core/skills/generate-e2e/SKILL.md` | Input Format更新 |
| `plugins/redteam-core/skills/generate-e2e/reference.md` | スキーマ更新 |
| `plugins/redteam-core/agents/dynamic-verifier.md` | Output Format更新 |
| `README.md` | サンプル出力更新 |
| `README.ja.md` | サンプル出力更新 |
| `scripts/test-vulnerability-class.sh` | テストケース修正 |

### 整合性確認

| エージェント/スキル | 変更後の整合性 |
|--------------------|---------------|
| false-positive-filter | `summary` + `vulnerabilities` 配列 → 整合 |
| attack-scenario | `summary` + `vulnerabilities` 配列 → 整合 |
| sca-attacker | `summary` + `vulnerabilities` 配列 → 整合 |
| attack-report | Input更新により整合 |
| generate-e2e | Input更新により整合 |
| dynamic-verifier | Output更新により整合 |

### Files

```
plugins/redteam-core/skills/security-scan/
├── SKILL.md      # 修正
└── reference.md  # 修正

plugins/redteam-core/skills/attack-report/
├── SKILL.md      # 修正
└── reference.md  # 修正

plugins/redteam-core/skills/generate-e2e/
├── SKILL.md      # 修正
└── reference.md  # 修正

plugins/redteam-core/agents/
└── dynamic-verifier.md  # 修正

README.md         # 修正
README.ja.md      # 修正

scripts/
├── test-schema-unification.sh    # 新規
└── test-vulnerability-class.sh   # 修正
```

## Test List

### TODO

(なし)

### WIP

(なし)

### DONE

#### security-scan
- [x] TC-01: security-scan SKILL.mdに`summary`がある
- [x] TC-02: security-scan SKILL.mdに`vulnerabilities`配列がある
- [x] TC-03: security-scan SKILL.mdに`details`が存在しない
- [x] TC-04: security-scan reference.mdに`summary`がある

#### attack-report
- [x] TC-05: attack-report SKILL.mdに`vulnerabilities`配列がある
- [x] TC-06: attack-report SKILL.mdに`details`が存在しない

#### generate-e2e
- [x] TC-07: generate-e2e SKILL.mdに`vulnerabilities`配列がある
- [x] TC-08: generate-e2e SKILL.mdに`details`が存在しない

#### dynamic-verifier
- [x] TC-09: dynamic-verifier.mdに`details`が存在しない

#### README
- [x] TC-10: README.mdに`summary`がある
- [x] TC-11: README.mdに`details`が存在しない

### GREEN結果

```
Results: 11 passed, 0 failed
```

既存テストも全PASS:
- test-vulnerability-class.sh: 15/15 passed
- test-false-positive-filter.sh: 17/17 passed

## REVIEW

### Quality Gate Results

| Reviewer | Score | Judgment |
|----------|-------|----------|
| correctness | 25 | PASS |
| performance | 15 | PASS |
| security | 15 | PASS |
| guidelines | 25 | PASS |

**Max Score: 25 → PASS**

### Findings Summary

#### Correctness (Score: 25)
- README.ja.md バージョン履歴テーブルがREADME.mdと不一致（Issue #47対象外）
- attack-report/reference.md Line 94 "Empty details array" → "Empty vulnerabilities array" 推奨（Optional）

#### Performance (Score: 15)
- 問題なし（ドキュメント変更のみ、パフォーマンス影響なし）

#### Security (Score: 15)
- 問題なし（コード変更なし、セキュリティリスクなし）

#### Guidelines (Score: 25)
- 全11ファイル正しく更新済み
- 既存パターン（false-positive-filter, attack-scenario, sca-attacker）に統一
- CHANGELOG.mdに破壊的変更を適切に記録

## Notes

- Issue #45 (false-positive-filter) の quality-gate で検出
- Phase 2 統合の前提条件
