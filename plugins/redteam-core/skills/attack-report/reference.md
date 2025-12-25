# Attack Report Reference

## Overview

attack-reportスキルは、security-scanの結果をMarkdownレポートに変換する。

## Input Schema

security-scan出力のJSON形式を入力として受け取る。

```json
{
  "metadata": {
    "schema_version": "string (default: 1.0, current: 2.0)",
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
      "type": "string (attack technique)",
      "vulnerability_class": "string (category, optional for schema 2.0)",
      "cwe_id": "string (optional, e.g. CWE-89)",
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

## CVSS 4.0 Vector Mapping

脆弱性タイプからCVSS 4.0 Base Scoreを算出。

| Vulnerability Type | CVSS 4.0 Vector | Score |
|-------------------|-----------------|-------|
| sql-injection | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N | 9.3 |
| command-injection | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N | 9.3 |
| xss-reflected | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:A/VC:L/VI:L/VA:N/SC:L/SI:L/SA:N | 5.1 |
| xss-stored | CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:P/VC:H/VI:H/VA:N/SC:L/SI:L/SA:N | 7.2 |
| hardcoded-credentials | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N | 9.1 |
| missing-auth | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N | 9.1 |
| broken-access-control | CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N | 8.5 |
| mass-assignment | CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N | 8.5 |
| bola | CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:L/VA:N/SC:N/SI:N/SA:N | 7.1 |
| rate-limiting-missing | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:L/SC:N/SI:N/SA:N | 5.3 |
| excessive-data-exposure | CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N | 6.5 |
| debug-enabled | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:L/VI:N/VA:N/SC:N/SI:N/SA:N | 5.3 |
| weak-hash | CVSS:4.0/AV:N/AC:H/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N | 5.9 |
| weak-crypto | CVSS:4.0/AV:N/AC:H/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N | 7.4 |
| default-credentials | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N | 9.1 |
| insecure-cors | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:A/VC:L/VI:L/VA:N/SC:N/SI:N/SA:N | 4.8 |
| empty-catch | CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:N/VI:N/VA:H/SC:N/SI:N/SA:N | 6.3 |
| swallowed-exception | CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:N/VI:N/VA:H/SC:N/SI:N/SA:N | 6.3 |
| fail-open | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N | 9.1 |
| generic-exception | CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:N/VI:N/VA:L/SC:N/SI:N/SA:N | 2.3 |
| missing-finally | CVSS:4.0/AV:L/AC:H/AT:P/PR:N/UI:N/VC:N/VI:N/VA:L/SC:N/SI:N/SA:N | 1.8 |
| ssrf | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:L/VA:N/SC:H/SI:N/SA:N | 8.6 |
| path-traversal | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N | 7.5 |
| lfi | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N | 7.5 |
| arbitrary-file-upload | CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N | 9.0 |

### Agent to Type Mapping

| Agent | Default Type |
|-------|--------------|
| injection-attacker | sql-injection |
| xss-attacker | xss-reflected |
| auth-attacker | hardcoded-credentials |
| api-attacker | mass-assignment |
| crypto-attacker | weak-crypto |
| error-attacker | empty-catch |
| file-attacker | path-traversal |
| ssrf-attacker | ssrf |

## CWE/OWASP Mapping

| Type | CWE | OWASP |
|------|-----|-------|
| sql-injection | CWE-89 | A05:2025 |
| command-injection | CWE-78 | A05:2025 |
| xss-reflected | CWE-79 | A05:2025 |
| xss-stored | CWE-79 | A05:2025 |
| hardcoded-credentials | CWE-798 | A07:2025 |
| missing-auth | CWE-306 | A07:2025 |
| broken-access-control | CWE-862 | A01:2025 |
| mass-assignment | CWE-915 | API3:2023 |
| bola | CWE-639 | API1:2023 |
| rate-limiting-missing | CWE-770 | API4:2023 |
| excessive-data-exposure | CWE-200 | API3:2023 |
| debug-enabled | CWE-489 | A02:2025 |
| weak-hash | CWE-328 | A04:2025 |
| weak-crypto | CWE-327 | A04:2025 |
| default-credentials | CWE-1392 | A02:2025 |
| insecure-cors | CWE-942 | A02:2025 |
| empty-catch | CWE-390 | A10:2025 |
| swallowed-exception | CWE-391 | A10:2025 |
| fail-open | CWE-636 | A10:2025 |
| generic-exception | CWE-396 | A10:2025 |
| missing-finally | CWE-404 | A10:2025 |
| ssrf | CWE-918 | A01:2025 |
| path-traversal | CWE-22 | A01:2025 |
| lfi | CWE-98 | A05:2025 |
| arbitrary-file-upload | CWE-434 | A01:2025 |

## Link Templates

参照リンクの生成テンプレート。

```
CWE: https://cwe.mitre.org/data/definitions/{ID}.html
OWASP Top 10: https://owasp.org/Top10/2025/A{XX}_{YYYY}-{Name}/
OWASP API: https://owasp.org/API-Security/editions/2023/en/0xa{X}-{kebab-case-name}/
```

例:
- https://cwe.mitre.org/data/definitions/89.html
- https://owasp.org/Top10/2025/A05_2025-Injection/
- https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/

## References

- [security-scan](../security-scan/SKILL.md)
- [injection-attacker](../../agents/injection-attacker.md)
- [xss-attacker](../../agents/xss-attacker.md)
- [crypto-attacker](../../agents/crypto-attacker.md)
- [error-attacker](../../agents/error-attacker.md)
