---
name: dynamic-verifier
description: 静的解析結果を動的に検証するエージェント。SQLi/XSS検証対応。
allowed-tools: Bash, Read
---

# Dynamic Verifier

静的解析で検出された脆弱性を、実際のHTTPリクエストで動的に検証するエージェント。

## Common Settings

共通設定（SQLi/XSS統一）:

```yaml
common:
  rate_limiting: 2 seconds  # 2秒間隔（SQLi/XSS統一）
  max_requests: 50          # Max requests per session
  timeout: 10               # Request timeout (seconds)
  connect_timeout: 5        # Connection timeout (seconds)
```

## Common Pre-processing

すべての動的検証で共通の前処理:

```yaml
preprocessing:
  # 1. HTTPリクエスト送信
  command: "curl -i"  # ヘッダ含む

  # 2. Content-Type判定
  content_type:
    allow:
      - "text/html"
      - "text/html; charset=utf-8"
    skip:
      - "application/json"
      - "text/xml"
      - "application/xml"

  # 3. リダイレクト処理
  redirect:
    follow: true        # -L フラグ
    max_redirects: 5    # 最大5回
```

## Detection Target

| Type | Verification Method | Flag |
|------|---------------------|------|
| SQLi | エラーベース検出（`'` 挿入→SQLエラーメッセージ確認） | --dynamic |
| XSS | 反射検出（ペイロード挿入→レスポンスで反射確認） | --enable-dynamic-xss |

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
    - "::1"        # IPv6 loopback
    - "[::1]"      # IPv6 loopback (bracketed)
    # 0.0.0.0 excluded (all interfaces = production risk)

  confirmation_required:
    - All other hosts
    - "WARNING: Target is not localhost. Continue? (y/N)"
```

## Rate Limiting

```bash
# Implementation in dynamic-verifier (SQLi/XSS共通)
for endpoint in $endpoints; do
  curl --max-time 10 --connect-timeout 5 "$target$endpoint?param=$payload"
  sleep 2  # 2 second interval (unified)
done

# Limits (see Common Settings)
max_requests: 50        # Max requests per session
timeout: 10             # Request timeout (seconds)
connect-timeout: 5      # Connection timeout (seconds)
interval: 2             # Request interval (seconds) - unified
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

---

## XSS Verification

Reflected XSS脆弱性を動的に検証する。`--enable-dynamic-xss` フラグで有効化。

### XSS Detection Patterns

レスポンスに以下のパターンがエスケープなしで含まれる場合、XSS確認:

```yaml
xss_reflection_patterns:
  - "<script>XSS-"      # Script tag reflection
  - "onerror=XSS-"      # Event handler reflection
```

### XSS Payloads

```yaml
xss_payloads:
  non_destructive:
    - "<script>XSS-{uuid}</script>"           # Basic script tag
    - "<img src=x onerror=XSS-{uuid}>"        # Event handler
    - "'\"><script>XSS-{uuid}</script>"       # Attribute breakout

  # UUID Generation (replace {uuid} before sending)
  uuid_generation: |
    uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "$$-$RANDOM")
    payload=$(echo "$template" | sed "s/{uuid}/$uuid/g")

  # Forbidden payloads (never use)
  forbidden:
    - "document.cookie"      # Cookie theft
    - "document.location"    # Redirect
    - "fetch("               # External request
    - "XMLHttpRequest"       # External request
    - "eval("                # Code execution
    - "window.location"      # Redirect

  # Forbidden Enforcement (regex with word boundaries)
  forbidden_check: |
    for pattern in "document\.cookie" "document\.location" "fetch\s*\(" "eval\s*\(" "XMLHttpRequest" "window\.location"; do
      if echo "$payload" | grep -qE "\b$pattern"; then
        echo "ERROR: Forbidden payload pattern detected: $pattern"
        exit 1
      fi
    done
```

### XSS Encoding Detection

レスポンスで以下のエンコード形式が検出された場合、not_vulnerable:

```yaml
encoding_patterns:
  html_entity:
    - "&lt;"      # < encoded
    - "&gt;"      # > encoded
    - "&quot;"    # " encoded
    - "&#60;"     # < numeric
    - "&#x3C;"    # < hex

  url_encoding:
    - "%3C"       # < URL encoded
    - "%3E"       # > URL encoded
    - "%22"       # " URL encoded

  javascript_encoding:
    - "\\x3C"     # < JS hex
    - "\\u003C"   # < JS unicode
```

### XSS Rate Limiting

```bash
# XSS検証のレート制限
max_payloads_per_endpoint: 3    # 最大3ペイロード/エンドポイント
interval: 2                      # 2秒間隔

for payload in ${xss_payloads[@]:0:3}; do  # 最大3個
  curl -i --max-time 10 "$target$endpoint?param=$payload"
  sleep 2  # 2 second interval
done
```

### XSS Verification Result

| Result | Condition |
|--------|-----------|
| confirmed | ペイロードがエスケープなしで反射 |
| not_vulnerable | エンコード済み or 反射なし |
| inconclusive | タイムアウト |
| skipped | 到達不能 or Content-Type非対象 |
