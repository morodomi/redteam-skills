# Attack Report Reference

## Overview

attack-reportスキルは、security-scanの結果をMarkdownレポートに変換する。

## Input Schema

security-scan出力のJSON形式を入力として受け取る。

```json
{
  "metadata": {
    "scan_id": "string (UUID v4)",
    "scanned_at": "string (ISO 8601)",
    "target_directory": "string (absolute path)"
  },
  "recon": {
    "framework": "string",
    "endpoints_count": "number",
    "high_priority_count": "number"
  },
  "vulnerabilities": {
    "total": "number",
    "critical": "number",
    "high": "number",
    "medium": "number",
    "low": "number"
  },
  "details": [
    {
      "agent": "string",
      "id": "string",
      "severity": "critical | high | medium | low",
      "file": "string",
      "line": "number",
      "code": "string (optional)",
      "description": "string (optional)",
      "remediation": "string (optional)"
    }
  ]
}
```

## Output Sections

### Summary Section

スキャンの概要情報を表示。

| Field | Source |
|-------|--------|
| Scan ID | metadata.scan_id |
| Scanned At | metadata.scanned_at |
| Target | metadata.target_directory |
| Framework | recon.framework |
| Endpoints | recon.endpoints_count |

### Vulnerabilities Section

重大度別に脆弱性を一覧表示。

**表示順序**: Critical → High → Medium → Low

**各脆弱性の表示項目**:
- ID (e.g., SQLI-001)
- Type (e.g., SQL Injection)
- File and line number
- Agent that detected it
- Description (if available)
- Remediation (if available)

### Recommendations Section

対応優先度に基づく推奨事項。

| Priority | Target | Action |
|----------|--------|--------|
| Immediate | Critical | 即時対応、リリースブロック |
| High | High | 1週間以内に対応 |
| Medium | Medium | 次スプリントで対応 |
| Low | Low | コードレビューで確認 |

## Edge Cases

| Case | Handling |
|------|----------|
| No vulnerabilities | "No vulnerabilities found" メッセージ表示 |
| Missing optional fields | フィールドを省略して表示 |
| Empty details array | 各重大度セクションに "(None)" 表示 |

## Limitations

- 静的レポートのみ（インタラクティブ機能なし）
- Markdown形式のみ（HTML/PDF出力は未対応）
- 単一スキャン結果のみ（履歴比較は未対応）

## References

- [security-scan](../security-scan/SKILL.md)
- [injection-attacker](../../agents/injection-attacker.md)
- [xss-attacker](../../agents/xss-attacker.md)
