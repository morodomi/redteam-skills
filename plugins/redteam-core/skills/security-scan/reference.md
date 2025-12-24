# Security Scan Reference

## Overview

security-scanスキルは、複数のセキュリティエージェントを連携させて包括的な脆弱性スキャンを実行する。

## Workflow Details

### Phase 1: RECON

recon-agentを使用して対象コードベースの情報を収集。

**収集情報**:
- フレームワーク検出（Laravel, Django, Flask, Express等）
- エンドポイント列挙
- 攻撃優先度の決定

**出力**: 優先度付きエンドポイントリスト

### Phase 2: SCAN

RECONの結果に基づき、以下のエージェントを**並行実行**:

| Agent | Detection Target |
|-------|-----------------|
| injection-attacker | SQL Injection (Union, Error, Boolean-blind) |
| xss-attacker | Reflected XSS, Sanitization Missing |
| crypto-attacker | Debug mode, Weak hash/crypto, Default credentials, CORS |
| error-attacker | Empty catch, Fail-open, Generic exception |

**並行実行の利点**:
- スキャン時間の短縮
- 独立した検出ロジック

### Phase 3: REPORT

全エージェントの結果を統合し、JSON形式で出力。

## Output Schema

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

## Error Handling

| Error | Handling |
|-------|----------|
| No files found | Empty vulnerabilities, recon.endpoints_count = 0 |
| Agent failure | Continue with other agents, note in metadata |
| Unknown framework | Set framework = "unknown", continue scan |

## Limitations

- 静的解析のみ（動的テストは未対応）
- MVP対象: SQLi, XSS, Crypto, Error Handling
- 対応済: auth-attacker, api-attacker, crypto-attacker, error-attacker

## References

- [recon-agent](../../agents/recon-agent.md)
- [injection-attacker](../../agents/injection-attacker.md)
- [xss-attacker](../../agents/xss-attacker.md)
- [crypto-attacker](../../agents/crypto-attacker.md)
- [error-attacker](../../agents/error-attacker.md)
