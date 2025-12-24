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
  "vulnerabilities": {
    "total": 3,
    "critical": 0,
    "high": 2,
    "medium": 1,
    "low": 0
  },
  "details": [...]
}
```

## Output Format

Markdown形式のレポートを生成。

### Report Structure

```markdown
# Security Scan Report

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
- **File**: app/Controllers/UserController.php:45
- **Agent**: injection-attacker
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
