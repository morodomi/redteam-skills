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
| sca-attacker | Dependency vulnerabilities (OSV API) |

**並行実行の利点**:
- スキャン時間の短縮
- 独立した検出ロジック

### [VERIFY] (--dynamic / --enable-dynamic-xss 時のみ)

動的テストによる脆弱性検証。オプション指定時のみ実行。

| Agent | Role | Flag |
|-------|------|------|
| dynamic-verifier (SQLi) | SQLiエラーベース検証 | --dynamic |
| dynamic-verifier (XSS) | XSS反射検出検証 | --enable-dynamic-xss |

**XSS動的検証** (`--enable-dynamic-xss`):
- ペイロード挿入→レスポンスで反射確認
- エスケープなし反射 → confirmed
- エンコード済み or 反射なし → not_vulnerable
- Content-Type: text/html のみ検証

**安全対策**:
- --target必須（明示的なURL指定）
- 非破壊ペイロードのみ使用
- レート制限（2秒間隔、最大3ペイロード/エンドポイント）
- localhost以外は確認プロンプト

### Phase 3: REPORT

全エージェントの結果を統合し、JSON形式で出力。

## Output Schema

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
  "sca": {
    "packages_scanned": "number",
    "vulnerable_count": "number",
    "ecosystems": "string[] (npm, Packagist, PyPI, Go, etc.)"
  },
  "summary": {
    "total": "number",
    "critical": "number",
    "high": "number",
    "medium": "number",
    "low": "number"
  },
  "verification": {
    "enabled": "boolean (optional, --dynamic時のみ)",
    "target": "string (optional)",
    "verified": "number (optional)",
    "confirmed": "number (optional)",
    "false_positives": "number (optional)"
  },
  "vulnerabilities": [
    {
      "agent": "string",
      "id": "string",
      "type": "string (attack technique)",
      "vulnerability_class": "string (category: sql-injection, xss, ssrf, etc.)",
      "cwe_id": "string (optional, e.g. CWE-89)",
      "severity": "critical | high | medium | low",
      "file": "string",
      "line": "number",
      "code": "string (optional)",
      "description": "string (optional)",
      "remediation": "string (optional)",
      "verified": "boolean (optional, --dynamic時のみ)",
      "verification_result": "confirmed | not_vulnerable | inconclusive | skipped (optional)",
      "evidence": "string (optional)"
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

- 動的テストはSQLiエラーベース検出、XSS反射検出に対応
- XSS動的検証はReflected XSSのみ（DOM-based XSSは静的解析で対応）
- MVP対象: SQLi, XSS, Crypto, Error Handling
- 対応済: auth-attacker, api-attacker, crypto-attacker, error-attacker, dynamic-verifier

## References

- [recon-agent](../../agents/recon-agent.md)
- [injection-attacker](../../agents/injection-attacker.md)
- [xss-attacker](../../agents/xss-attacker.md)
- [crypto-attacker](../../agents/crypto-attacker.md)
- [error-attacker](../../agents/error-attacker.md)
- [sca-attacker](../../agents/sca-attacker.md)
- [dynamic-verifier](../../agents/dynamic-verifier.md)
