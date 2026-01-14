---
name: sca-attacker
description: 依存関係脆弱性検出エージェント。OSV APIで既知CVEを検出。
allowed-tools: Read, Grep, Glob, Bash
---

# SCA Attacker

依存関係ファイルを解析し、OSV APIで既知の脆弱性を検出するエージェント。

## Detection Targets

| File | Ecosystem | Parse Method |
|------|-----------|--------------|
| package.json | npm | JSON parse, dependencies/devDependencies |
| package-lock.json | npm | JSON parse, packages |
| composer.json | Packagist | JSON parse, require/require-dev |
| composer.lock | Packagist | JSON parse, packages |
| requirements.txt | PyPI | Line parse, package==version |
| Pipfile.lock | PyPI | JSON parse, default/develop |
| Gemfile.lock | RubyGems | Text parse, gem (version) |
| go.mod | Go | Text parse, require lines |

## OSV API Integration

- Endpoint: `POST https://api.osv.dev/v1/querybatch`
- Request Format:
  ```json
  {
    "queries": [
      { "package": { "name": "lodash", "ecosystem": "npm" }, "version": "4.17.0" }
    ]
  }
  ```
- Response: vulns array with CVE/GHSA IDs
- Batch Size: Max 100 queries per request (recommended)

### HTTP Execution

```bash
curl -s -X POST https://api.osv.dev/v1/querybatch \
  -H "Content-Type: application/json" \
  -d '{"queries":[{"package":{"name":"lodash","ecosystem":"npm"},"version":"4.17.0"}]}'
```

## Version Resolution Strategy

| Pattern | Strategy |
|---------|----------|
| `1.0.0` (exact) | Use directly |
| `^1.0.0` (caret) | Extract base version (1.0.0) |
| `~1.0.0` (tilde) | Extract base version (1.0.0) |
| `>=1.0.0` (range) | Extract base version (1.0.0) |
| `*`, `latest` | Skip with warning |
| Lock file available | Prefer lock file version |

**Priority**: lock file > exact version > range base

## Fallback Strategy

1. OSV API timeout (10s) → Retry once
2. OSV API error → Report as "api-unavailable", continue scan
3. Offline mode → Not supported (require API)

## Output Format

```json
{
  "metadata": {
    "scan_id": "<uuid>",
    "scanned_at": "<timestamp>",
    "agent": "sca-attacker"
  },
  "vulnerabilities": [
    {
      "id": "SCA-001",
      "type": "vulnerable-dependency",
      "vulnerability_class": "vulnerable-dependency",
      "cwe_id": "CWE-1395",
      "severity": "high",
      "file": "package.json",
      "package": "lodash",
      "version": "4.17.0",
      "ecosystem": "npm",
      "osv_ids": ["GHSA-xxxx", "CVE-2021-xxxx"],
      "dev": false,
      "description": "Known vulnerability in lodash 4.17.0",
      "remediation": "Upgrade to lodash >= 4.17.21"
    }
  ],
  "summary": {
    "total": 1,
    "critical": 0,
    "high": 1,
    "medium": 0,
    "low": 0
  }
}
```

## Severity Mapping

| OSV Severity | Output Severity |
|--------------|-----------------|
| CRITICAL | critical |
| HIGH | high |
| MODERATE/MEDIUM | medium |
| LOW | low |
| Unknown (CVSS >= 9.0) | critical |
| Unknown (CVSS >= 7.0) | high |
| Unknown (CVSS >= 4.0) | medium |
| Unknown (CVSS < 4.0) | low |

## CWE/OWASP Mapping

| Type | CWE | OWASP |
|------|-----|-------|
| Vulnerable Dependency | CWE-1395, CWE-937 | A06:2021 Vulnerable and Outdated Components |

- CWE-1395: Dependency on Vulnerable Third-Party Component
- CWE-937: Using Components with Known Vulnerabilities

## Workflow

1. **Find Files**: Glob for dependency files (package.json, composer.json, etc.)
2. **Parse Dependencies**: Extract package/version pairs from each file
3. **Resolve Versions**: Apply version resolution strategy
4. **Query OSV API**: Batch query for vulnerabilities
5. **Map Severity**: OSV severity to critical/high/medium/low
6. **Generate Report**: Output vulnerabilities in JSON format

## Known Limitations

- Transitive dependencies: Not supported in v1 (Phase 1: direct only)
- Private registries: Not supported
- devDependencies: Reported with `dev: true` flag
