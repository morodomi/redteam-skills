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

RECONの結果に基づき、エージェントを**並行実行**。

#### Core Agents (default: 5)

| Agent | Detection Target |
|-------|-----------------|
| injection-attacker | SQL Injection (Union, Error, Boolean-blind) |
| xss-attacker | Reflected XSS, DOM XSS, Stored XSS |
| crypto-attacker | Debug mode, Weak hash/crypto, Default credentials, CORS |
| error-attacker | Empty catch, Fail-open, Generic exception |
| sca-attacker | Dependency vulnerabilities (OSV API) |

#### Extended Agents (--full-scan: +8)

| Agent | Detection Target |
|-------|-----------------|
| auth-attacker | Authentication bypass, JWT vulnerabilities |
| api-attacker | BOLA, BFLA, Mass Assignment |
| file-attacker | Path Traversal, LFI, RFI |
| ssrf-attacker | SSRF, Cloud metadata access |
| csrf-attacker | CSRF token missing, SameSite cookie |
| ssti-attacker | Jinja2, Twig, Blade, ERB template injection |
| xxe-attacker | XML External Entity injection |
| wordpress-attacker | WordPress-specific vulnerabilities |

**並行実行の利点**:
- スキャン時間の短縮
- 独立した検出ロジック

### [VERIFY] (--dynamic / --enable-dynamic-xss 時のみ)

動的テストによる脆弱性検証。オプション指定時のみ実行。

| Agent | Role | Flag |
|-------|------|------|
| dynamic-verifier (SQLi) | SQLiエラーベース検証 | --dynamic |
| dynamic-verifier (XSS) | XSS反射検出検証 | --enable-dynamic-xss |

**安全対策**:
- --target必須（明示的なURL指定）
- 非破壊ペイロードのみ使用
- レート制限（2秒間隔、最大3ペイロード/エンドポイント）
- localhost以外は確認プロンプト

### Phase 3: REPORT

全エージェントの結果を統合し、JSON形式で出力。

### Phase 4: AUTO TRANSITION

スキャン完了後、自動的に次のスキルを呼び出す。

**デフォルト動作**:
```
検出件数: Critical 0, High 2, Medium 1

レポートを生成します。

Skill(redteam-core:attack-report)
```

**context-reviewが必要な場合**:
```
曖昧な検出が3件あります。context-reviewを実行しますか? [Y/n]

→ Y の場合: Skill(redteam-core:context-review)
→ 完了後: Skill(redteam-core:attack-report)
```

**オプション**:
- `--no-auto-report`: 自動レポート生成をスキップ
- `--auto-e2e`: レポート後にE2Eテスト自動生成

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

## Naming Convention

### vulnerability_class

脆弱性カテゴリを示すフィールド。`vulnerability_class` format: lowercase-hyphenated。

| Format | Rule |
|--------|------|
| 完全名 | `sql-injection`, `command-injection`, `path-traversal` |
| 業界標準略称 | `xss`, `ssrf`, `csrf`, `xxe`, `ssti`, `lfi`, `bola` |

**許可されない略称**: `sqli` (→ `sql-injection`), `cmdi` (→ `command-injection`)

### type

`vulnerability_class`内の具体的な攻撃手法/バリアントを示すフィールド。

| vulnerability_class | type examples |
|--------------------|---------------|
| sql-injection | union-based, error-based, boolean-blind, time-blind |
| xss | reflected, dom, stored |
| csrf | csrf-token-missing, csrf-protection-disabled |
| ssrf | ssrf, blind-ssrf, partial-ssrf |

## Error Handling

| Error | Handling |
|-------|----------|
| No files found | Empty vulnerabilities, recon.endpoints_count = 0 |
| Agent failure | Continue with other agents, note in metadata |
| Unknown framework | Set framework = "unknown", continue scan |

## Memory Integration

スキャン知見を auto memory に蓄積し、次回スキャンで活用する。

### Overview

- **読み取り**: RECON Phase の Step 0 で過去のスキャンコンテキストを参照
- **書き込み**: LEARN Phase でスキャン結果の知見を保存
- `--no-memory` で読み書き両方を無効化

### LEARN Phase

AUTO TRANSITION / E2E 完了後に実行。スキャン結果から以下を auto memory に保存する。

**実行タイミング**:
```
AUTO TRANSITION → [OPTIONAL] E2E → LEARN Phase
```

**メモリ参照時の表示**:
```
Past scan context loaded: 2 FP patterns, last scan 2026-02-06 (11 findings, 3 FP)
```

**初回スキャン時の表示**:
```
No previous scan context found. Scan results will be saved for future reference.
```

### Memory Convention (v1.0)

<!-- Memory-Convention: v1.0 -->

auto memory に以下の構造で保存する:

```markdown
## Security Scan Context

### Project
- Framework: Laravel 11.x
- Database: MySQL 8.0
- Auth: Sanctum
- Custom Sanitizers: App\Helpers::sanitize() (XSS safe)

### Known False Positive Patterns
- Blade {{ }} auto-escaping (XSS, confidence: 0.95)
- Eloquent ->where() with bindings (SQLi, confidence: 0.95)

### Scan History
- 2026-02-06: 3C/5H/2M/1L (11 total, 3 FP)
```

### Memory Data Exclusion

以下のデータは LEARN Phase でメモリに保存してはならない:

- 脆弱性の code snippets に含まれるシークレット（API_KEY, PASSWORD 等）
- 生のペイロード（SQLi, XSS 等の攻撃文字列）
- 認証情報を含むファイルパス
- recon-agent の Sensitive Data Exclusion リストに該当するデータ

### Known Limitations

- false-positive-filter との直接統合は将来課題（現在は auto memory 経由の間接参照）
- Claude Code auto memory の仕様変更に依存

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
- [auth-attacker](../../agents/auth-attacker.md)
- [api-attacker](../../agents/api-attacker.md)
- [file-attacker](../../agents/file-attacker.md)
- [ssrf-attacker](../../agents/ssrf-attacker.md)
- [csrf-attacker](../../agents/csrf-attacker.md)
- [ssti-attacker](../../agents/ssti-attacker.md)
- [xxe-attacker](../../agents/xxe-attacker.md)
- [wordpress-attacker](../../agents/wordpress-attacker.md)
- [dynamic-verifier](../../agents/dynamic-verifier.md)
