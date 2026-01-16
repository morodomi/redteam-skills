---
name: attack-report
description: セキュリティスキャン結果をMarkdownレポートに変換。
---

# Attack Report

security-scan結果をMarkdownレポート形式で出力するスキル。

## Usage

```bash
/attack-report              # 直前のsecurity-scan結果をレポート化
/attack-report ./report.md  # 指定ファイルに出力
```

## Input Format

security-scan が出力するJSON形式を入力として受け取る。

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
  "summary": {
    "total": 3,
    "critical": 0,
    "high": 2,
    "medium": 1,
    "low": 0
  },
  "vulnerabilities": [...]
}
```

## Output Format

Markdown形式のレポートを生成。脆弱性はCVSSスコア降順でソートされる。

### Report Structure

```markdown
# Security Scan Report

## Executive Summary

### リスク評価

| 評価項目 | 結果 |
|----------|------|
| **総合リスク** | High |
| **検出件数** | Critical: 0, High: 2, Medium: 1, Low: 0 |
| **対象システム** | Laravel Application |

### 優先対応 Top 3

| 優先度 | 脆弱性 | CVSS | 対応期限 |
|--------|--------|------|----------|
| 1 | SQL Injection (SQLI-001) | 9.3 | 即時 |
| 2 | XSS (XSS-001) | 7.2 | 1週間以内 |
| 3 | CSRF (CSRF-001) | 5.1 | 次スプリント |

### 影響を受けるシステム

- `app/Controllers/UserController.php`
- `app/Controllers/AuthController.php`
- `resources/views/user.blade.php`

---

## Summary

| Item | Value |
|------|-------|
| Scan ID | <uuid> |
| Scanned At | <timestamp> |
| Target | <path> |
| Framework | Laravel |

### Vulnerability Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| High | 2 |
| Medium | 1 |
| Low | 0 |
| **Total** | **3** |

## Vulnerabilities

### Critical (0)

(No critical vulnerabilities found)

### High (2)

#### [SQLI-001] SQL Injection
- **CVSS 4.0**: 9.3 (Critical)
- **Vector**: `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`
- **File**: app/Controllers/UserController.php:45
- **Agent**: injection-attacker
- **References**:
  - [CWE-89](https://cwe.mitre.org/data/definitions/89.html)
  - [OWASP A03:2021](https://owasp.org/Top10/2021/A03_2021-Injection/)
- **Description**: User input concatenated in SQL query
- **Remediation**: Use parameterized queries or ORM

### Medium (1)
...

### Low (0)
...

## Recommendations

1. **High Priority**: Fix all Critical and High severity issues immediately
2. **Medium Priority**: Address Medium issues in next sprint
3. **Low Priority**: Review Low issues during code review
```

## Reference

詳細は [reference.md](reference.md) を参照。
