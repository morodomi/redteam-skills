---
name: false-positive-filter
description: 誤検知自動除外エージェント。静的解析結果をフィルタリング。
allowed-tools: Read, Grep, Glob
---

# False Positive Filter

静的解析で検出された脆弱性の誤検知を自動的にフィルタリングするエージェント。

## Input Format

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

## Filter Rules

### Pattern-Based Filters

| Category | Pattern | Action | Confidence |
|----------|---------|--------|------------|
| Sanitized Output | `htmlspecialchars`, `e()`, `{{ }}` | Mark as FP (XSS) | 0.95 |
| Prepared Statement | `->where()`, `DB::select()` with ? | Mark as FP (SQLi) | 0.95 |
| Test Code | `/tests/`, `/spec/`, `*Test.php` | Mark as FP (All) | 1.00 |
| Security Ignore | `@security-ignore` (with required attrs) | Mark as FP (All) | 0.90 |

**Note**: `/vendor/`, `/node_modules/` は除外対象外。sca-attackerで別途脆弱性検出。

### @security-ignore Format

```php
// @security-ignore reason="false positive - input from trusted source" reviewer="john"
```

| Attribute | Required | Description |
|-----------|----------|-------------|
| reason | Yes | 除外理由（必須） |
| reviewer | Yes | レビュー承認者（必須） |

**属性なしの@security-ignoreはconfidence 0.50（手動レビュー必須）**

### Context-Based Filters

| Category | Context Check | Action |
|----------|---------------|--------|
| Framework Auto-Escape | Blade `{{ }}`, Jinja2 default | Mark as FP (XSS) |
| ORM Protection | Eloquent, Django ORM | Mark as FP (SQLi) |
| CSRF Middleware | VerifyCsrfToken enabled | Mark as FP (CSRF) |

### Sanitization Patterns by Language

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
      - '\{\{[^|]*\}\}'  # Jinja2 auto-escape
      # Note: mark_safe は除外対象外（エスケープ無効化のため脆弱）
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

## Confidence Scoring

| Score | Meaning | Action |
|-------|---------|--------|
| 0.95-1.00 | Very High | Auto-exclude (厳格な条件のみ) |
| 0.80-0.94 | High | Flag for quick review |
| 0.50-0.79 | Medium | Flag for manual review |
| 0.00-0.49 | Low | Keep as vulnerability |

**Note**: 自動除外は0.95以上に限定し、False Negative導入リスクを最小化。

## Output Format

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

## Filter Types

| Type | Description | Example |
|------|-------------|---------|
| pattern | 正規表現パターンマッチ | `htmlspecialchars\s*\(` |
| path | ファイルパスマッチ | `/tests/`, `/spec/` |
| context | 周辺コード解析 | ORM使用、ミドルウェア設定 |
| comment | セキュリティ無視コメント | `@security-ignore` |

## Audit Trail

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

## Workflow

1. security-scan出力を受け取る
2. 各脆弱性に対してフィルタルールを適用:
   - Pattern-Based: コード内のサニタイズパターンをチェック
   - Context-Based: フレームワーク保護をチェック
   - Path-Based: テストコードパスをチェック
   - Comment-Based: @security-ignoreコメントをチェック
3. Confidence scoreを計算
4. 0.95以上は自動除外、それ以外はフラグ付き
5. 結果をJSON形式で出力

## Integration with security-scan

### Phase 1: 独立エージェント

security-scan出力を手動で渡して実行:

```bash
# security-scan実行後
/security-scan ./src > scan-result.json

# false-positive-filterで分析
# エージェントがscan-result.jsonを読み込んでフィルタリング
```

### Phase 2: security-scan統合（将来）

security-scanのワークフローに組み込み:

```
RECON → SCAN → FILTER → REPORT
                 ↑
         false-positive-filter
```

## Known Limitations

- 静的解析ベースのため、実行時の動的なサニタイズは検出不可
- フレームワーク固有の保護機構は事前定義が必要
- カスタムサニタイズ関数は手動でパターン追加が必要
