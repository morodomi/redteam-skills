# Cycle: false-positive-filter

| Item | Value |
|------|-------|
| Issue | #45 |
| Phase | DONE |
| Created | 2026-01-15 16:41 |

## Environment

| Tool | Version |
|------|---------|
| Node.js | v22.17.0 |

## Goal

静的解析の誤検知を自動的にフィルタリングし、レポートの精度を向上させる。

## Background

From Issue #45:
- パターンベースの誤検知除外
- コンテキストベースの誤検知判定
- 除外理由の記録

## Scope

From Issue #45:
- [ ] false-positive-filter エージェント作成
- [ ] パターンベースの誤検知除外
- [ ] コンテキストベースの誤検知判定
- [ ] 除外理由の記録
- [ ] 出力形式定義

## PLAN

### Background

security-scanは静的解析ベースのため、以下のような誤検知が発生する:

| 誤検知パターン | 例 |
|---------------|-----|
| サニタイズ済み | `htmlspecialchars($input)` → XSS報告 |
| テストコード | `/tests/` 内の意図的な脆弱コード |
| フレームワーク保護 | Laravelの `{{ }}` はエスケープ済み |
| 意図的な例外 | `// @security-ignore` コメント |

false-positive-filterはこれらを自動除外し、レポート精度を向上させる。

### Design

#### エージェント構造

```yaml
name: false-positive-filter
description: 誤検知自動除外エージェント。静的解析結果をフィルタリング。
allowed-tools: Read, Grep, Glob
```

#### Input Format

security-scan出力（vulnerabilities配列）を入力として受け取る:

```json
{
  "vulnerabilities": [
    {
      "id": "XSS-001",
      "type": "reflected",
      "vulnerability_class": "xss",
      "severity": "high",
      "file": "app/views/user.blade.php",
      "line": 23,
      "code": "{{ $input }}"
    }
  ]
}
```

#### Filter Rules

##### Pattern-Based Filters

| Category | Pattern | Action | Confidence |
|----------|---------|--------|------------|
| Sanitized Output | `htmlspecialchars`, `e()`, `{{ }}` | Mark as FP (XSS) | 0.95 |
| Prepared Statement | `->where()`, `DB::select()` with ? | Mark as FP (SQLi) | 0.95 |
| Test Code | `/tests/`, `/spec/`, `*Test.php` | Mark as FP (All) | 1.00 |
| Security Ignore | `@security-ignore` (with required attrs) | Mark as FP (All) | 0.90 |

**Note**: `/vendor/`, `/node_modules/` は除外対象外。sca-attackerで別途脆弱性検出。

##### @security-ignore Format

```php
// @security-ignore reason="false positive - input from trusted source" reviewer="john"
```

| Attribute | Required | Description |
|-----------|----------|-------------|
| reason | Yes | 除外理由（必須） |
| reviewer | Yes | レビュー承認者（必須） |

**属性なしの@security-ignoreはconfidence 0.50（手動レビュー必須）**

##### Context-Based Filters

| Category | Context Check | Action |
|----------|---------------|--------|
| Framework Auto-Escape | Blade `{{ }}`, Jinja2 default | Mark as FP (XSS) |
| ORM Protection | Eloquent, Django ORM | Mark as FP (SQLi) |
| CSRF Middleware | VerifyCsrfToken enabled | Mark as FP (CSRF) |

##### Sanitization Patterns by Language

```yaml
sanitization_patterns:
  php:
    xss:
      - 'htmlspecialchars\s*\('
      - 'htmlentities\s*\('
      - 'strip_tags\s*\('
      - '\{\{\s*\$'  # Blade auto-escape
      - 'e\s*\('     # Laravel helper
    sqli:
      - '->where\s*\([^,]+,\s*\?'
      - '->whereRaw\s*\([^,]+,\s*\['
      - 'DB::select\s*\([^,]+,\s*\['

  python:
    xss:
      - 'escape\s*\('
      - 'mark_safe'  # Explicit, but reviewed
      - '\{\{[^|]*\}\}'  # Jinja2 auto-escape
    sqli:
      - 'execute\s*\([^,]+,\s*\['
      - 'execute\s*\([^,]+,\s*\('
      - '\.filter\s*\('  # Django ORM

  javascript:
    xss:
      - 'textContent\s*='
      - 'encodeURIComponent\s*\('
      - 'DOMPurify\.sanitize\s*\('
    sqli:
      - '\?\s*,'  # Parameterized query
      - '\$\d+'   # Positional parameter
```

#### Confidence Scoring

| Score | Meaning | Action |
|-------|---------|--------|
| 0.95-1.00 | Very High | Auto-exclude (厳格な条件のみ) |
| 0.80-0.94 | High | Flag for quick review |
| 0.50-0.79 | Medium | Flag for manual review |
| 0.00-0.49 | Low | Keep as vulnerability |

**Note**: 自動除外は0.95以上に限定し、False Negative導入リスクを最小化。

#### Output Format

```json
{
  "metadata": {
    "scan_id": "<uuid>",
    "filtered_at": "<timestamp>",
    "agent": "false-positive-filter"
  },
  "filtered_vulnerabilities": [
    {
      "id": "SQLI-001",
      "severity": "high",
      "file": "app/Controllers/UserController.php",
      "line": 45
    }
  ],
  "false_positives": [
    {
      "id": "XSS-001",
      "original_severity": "high",
      "reason": "Sanitized by Blade auto-escape ({{ }})",
      "filter_type": "pattern",
      "pattern_matched": "\\{\\{\\s*\\$",
      "confidence": 0.95
    },
    {
      "id": "SQLI-002",
      "original_severity": "medium",
      "reason": "Test code (/tests/)",
      "filter_type": "path",
      "pattern_matched": "/tests/",
      "confidence": 1.00
    }
  ],
  "summary": {
    "original_count": 15,
    "filtered_count": 12,
    "false_positive_count": 3,
    "filter_rate": "20%"
  }
}
```

#### Filter Types

| Type | Description | Example |
|------|-------------|---------|
| pattern | 正規表現パターンマッチ | `htmlspecialchars\s*\(` |
| path | ファイルパスマッチ | `/tests/`, `/spec/` |
| context | 周辺コード解析 | ORM使用、ミドルウェア設定 |
| comment | セキュリティ無視コメント | `@security-ignore` |

#### Audit Trail

全フィルタ判定を記録し、後から検証可能にする:

```json
{
  "audit_trail": [
    {
      "id": "XSS-001",
      "decision": "filtered",
      "filter_type": "pattern",
      "confidence": 0.95,
      "reason": "Blade auto-escape {{ }}",
      "timestamp": "<timestamp>"
    },
    {
      "id": "SQLI-002",
      "decision": "kept",
      "filter_type": null,
      "confidence": 0.30,
      "reason": "No sanitization detected",
      "timestamp": "<timestamp>"
    }
  ]
}
```

**Benefits**:
- フィルタ前後の比較が可能
- 誤フィルタ時の原因追跡
- フィルタ精度の継続的改善

### Integration with security-scan

#### Phase 1: 独立エージェント（本Issue）

security-scan出力を手動で渡して実行:

```bash
# security-scan実行後
/security-scan ./src > scan-result.json

# false-positive-filterで分析
# エージェントがscan-result.jsonを読み込んでフィルタリング
```

#### Phase 2: security-scan統合（将来Issue）

security-scanのワークフローに組み込み:

```
RECON → SCAN → FILTER → REPORT
                 ↑
         false-positive-filter
```

### Files

```
plugins/redteam-core/agents/
└── false-positive-filter.md    # 新規

scripts/
└── test-false-positive-filter.sh  # 新規
```

## Test List

### TODO

(なし)

### WIP

(なし)

### DONE

#### エージェント構造
- [x] TC-01: frontmatterにname: false-positive-filterがある
- [x] TC-02: frontmatterにallowed-toolsがある
- [x] TC-03: Input Formatセクションがある

#### Filter Rules
- [x] TC-04: Pattern-Based Filtersセクションがある
- [x] TC-05: Context-Based Filtersセクションがある
- [x] TC-06: Sanitization Patterns by Languageセクションがある

#### Output Format
- [x] TC-07: Output Formatにfiltered_vulnerabilitiesがある
- [x] TC-08: Output Formatにfalse_positivesがある
- [x] TC-09: Output Formatにsummaryがある
- [x] TC-10: false_positivesにreasonフィールドがある
- [x] TC-11: false_positivesにconfidenceフィールドがある

#### Confidence Scoring
- [x] TC-12: Confidence Scoringセクションがある

#### Filter Types
- [x] TC-13: Filter Typesセクションに4タイプがある

#### Audit Trail
- [x] TC-14: Audit Trailセクションがある

#### @security-ignore
- [x] TC-15: @security-ignore Formatセクションがある
- [x] TC-16: reason/reviewer属性が必須と記載されている

#### Integration
- [x] TC-17: Integration with security-scanセクションがある

## REVIEW

### Quality Gate Results

| Reviewer | Score | Judgment |
|----------|-------|----------|
| correctness | 45 | PASS |
| performance | 35 | PASS |
| security | 35 | PASS |
| guidelines | 35 | PASS |

**Max Score: 45 → PASS**

### Findings Summary

#### Correctness (Score: 45)
- 入出力スキーマ（vulnerabilities vs details）の検討事項あり
- vulnerability_class の命名統一の余地あり
- mark_safe パターンの再検討推奨

#### Performance (Score: 35)
- 重大な問題なし
- O(n)の効率的な設計
- 将来的なストリーミング処理の検討は Optional

#### Security (Score: 35)
- 設計は妥当
- 自動除外閾値0.95は適切
- @security-ignore の reviewer 検証は将来検討

#### Guidelines (Score: 35)
- 既存パターンに準拠
- ドキュメント構造は適切
- scan_id 仕様の明確化は Optional

## Notes

- v5.0 マイルストーン
- 品質目標: 誤検知率10%未満
