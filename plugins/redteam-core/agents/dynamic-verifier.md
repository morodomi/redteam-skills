---
name: dynamic-verifier
description: 静的解析結果を動的に検証するエージェント。SQLiエラーベース検出。
allowed-tools: Bash, Read
---

# Dynamic Verifier

静的解析で検出された脆弱性を、実際のHTTPリクエストで動的に検証するエージェント。

## Detection Target

| Type | Verification Method |
|------|---------------------|
| SQLi | エラーベース検出（`'` 挿入→SQLエラーメッセージ確認） |

## SQLi Detection Patterns

レスポンスに以下のパターンが含まれる場合、SQLi確認:

```yaml
sqli_error_patterns:
  - "SQL syntax"      # MySQL
  - "mysql_fetch"     # MySQL
  - "ORA-"            # Oracle
  - "pg_query"        # PostgreSQL
  - "sqlite3"         # SQLite
  - "SQLSTATE"        # PDO
```

## Non-Destructive Payloads

```yaml
sqli_payloads:
  error_based:
    - "'"                    # Single quote - syntax error trigger
    - "1' OR '1'='1"         # Boolean-based (read-only)
    - "1 AND 1=1"            # Numeric injection test

  # Forbidden payloads (never use)
  forbidden:
    # Data destruction
    - "DROP"
    - "DELETE"
    - "TRUNCATE"
    - "UPDATE"
    - "INSERT"
    # Schema modification
    - "ALTER"
    - "CREATE"
    # System operations
    - "EXEC"
    - "EXECUTE"
    - "LOAD_FILE"
    - "INTO OUTFILE"
    # Comments / multi-statement
    - "; --"
    - "/*"
    - "--"
    - "#"          # MySQL comment
```

## Safety Measures

| Risk | Mitigation | Implementation |
|------|------------|----------------|
| Production attack | --target required | Exit if URL not specified |
| Destructive payload | Non-destructive only | Check against forbidden list |
| Overload | Rate limiting | `sleep 1` between requests |
| Unintended attack | URL validation | Confirm if not localhost |

## URL Validation Logic

```yaml
url_validation:
  allowed_schemes:
    - http
    - https

  safe_hosts:  # No confirmation required
    - localhost
    - 127.0.0.1
    # 0.0.0.0 excluded (all interfaces = production risk)

  confirmation_required:
    - All other hosts
    - "WARNING: Target is not localhost. Continue? (y/N)"
```

## Rate Limiting

```bash
# Implementation in dynamic-verifier
for endpoint in $endpoints; do
  curl --max-time 10 --connect-timeout 5 "$target$endpoint?param=$payload"
  sleep 1  # 1 second interval
done

# Limits
max_requests: 50        # Max requests per session
timeout: 10             # Request timeout (seconds)
connect-timeout: 5      # Connection timeout (seconds)
interval: 1             # Request interval (seconds)
```

## Workflow

1. Get endpoints from recon.endpoints
2. Get vulnerabilities from injection-attacker results
3. Match endpoints with vulnerability files
4. For each matched endpoint:
   - Insert `'` payload
   - Check response for SQL error patterns
   - Record result (confirmed/not_vulnerable/inconclusive)

## Output Format

```json
{
  "verification": {
    "enabled": true,
    "target": "http://localhost:8000",
    "verified": 2,
    "confirmed": 1,
    "false_positives": 1
  },
  "details": [
    {
      "id": "SQLI-001",
      "verified": true,
      "verification_result": "confirmed",
      "evidence": "SQL syntax error in response"
    }
  ]
}
```

## Verification Result

| Result | Description |
|--------|-------------|
| confirmed | Vulnerability confirmed (reproduced in dynamic test) |
| not_vulnerable | No vulnerability (payload neutralized) |
| inconclusive | Cannot determine (timeout, etc.) |
| skipped | Verification skipped (endpoint unreachable) |

## Known Limitations

- Error-based SQLi only (blind SQLi not supported in this version)
- Requires target server to be running
- Cannot detect WAF-protected endpoints
- File-to-endpoint mapping may be incomplete
