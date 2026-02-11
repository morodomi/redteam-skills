# redteam-skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-4.2.0-blue.svg)](CHANGELOG.md)

**AI-powered security auditing for your codebase.** Run one command, get OWASP Top 10 coverage with 18 specialized agents across 6 languages.

[日本語版 README](README.ja.md)

> **18** security agents | **6** languages | **OWASP Top 10** full coverage | **CVSS 4.0** auto-scoring

## Quick Start

```bash
# 1. Install the plugin
/plugin marketplace add morodomi/redteam-skills
/plugin install redteam-core@morodomi-redteam-skills

# 2. Run a security scan
/security-scan

# 3. Generate a report
/attack-report
```

That's it. The scan runs 13 agents in parallel, detects vulnerabilities, and produces a JSON + Markdown report with CVSS scores and remediation guidance.

## How It Works

```
1. RECON Phase
   └── recon-agent: Endpoint enumeration, framework detection

2. SCAN Phase (13 agents in parallel)
   ├── Core Agents (5): injection, xss, crypto, error, sca
   └── Extended Agents (8): auth, api, file, ssrf, csrf, ssti, xxe, wordpress

3. VERIFY Phase
   ├── false-positive-filter: Remove false positives
   ├── dynamic-verifier: SQLi/XSS/Auth/CSRF/SSRF runtime verification
   └── attack-scenario: Vulnerability chain analysis

4. REPORT Phase
   └── CVSS 4.0 scoring, JSON + Markdown output
```

## Agents

| Agent | Target | OWASP |
|-------|--------|-------|
| recon-agent | Endpoint enumeration, tech stack detection | - |
| injection-attacker | SQL/NoSQL/Command/LDAP Injection | A03:2021 |
| xss-attacker | Reflected/Stored/DOM XSS | A03:2021 |
| auth-attacker | Authentication bypass, JWT vulnerabilities | A07:2021 |
| csrf-attacker | CSRF, Cookie attributes | A01:2021 |
| api-attacker | BOLA/BFLA/Mass Assignment | A01:2021 |
| file-attacker | Path Traversal, LFI/RFI | A01:2021 |
| ssrf-attacker | SSRF, Cloud metadata | A10:2021 |
| ssti-attacker | Server-Side Template Injection | A03:2021 |
| xxe-attacker | XML External Entity Injection | A05:2021 |
| wordpress-attacker | WordPress-specific vulnerabilities | A06:2021 |
| crypto-attacker | Weak cryptography, Debug mode | A02:2021 |
| error-attacker | Improper exception handling | A05:2021 |
| sca-attacker | Dependency vulnerabilities (OSV API) | A06:2021 |
| dast-crawler | Playwright-based URL discovery | - |
| dynamic-verifier | SQLi/XSS/Auth/CSRF/SSRF runtime verification | - |
| false-positive-filter | Context-aware false positive removal | - |
| attack-scenario | Vulnerability chain analysis | - |

## Output Format

```json
{
  "metadata": {
    "schema_version": "2.0",
    "scan_id": "550e8400-e29b-41d4-a716-446655440000",
    "scanned_at": "2025-12-25T10:00:00Z",
    "target_directory": "/path/to/project"
  },
  "summary": {
    "total": 3,
    "critical": 1,
    "high": 1,
    "medium": 1,
    "low": 0
  },
  "vulnerabilities": [
    {
      "agent": "injection-attacker",
      "id": "SQLI-001",
      "type": "error-based-sqli",
      "vulnerability_class": "sql-injection",
      "cwe_id": "CWE-89",
      "severity": "critical",
      "cvss_score": 9.8,
      "file": "app/Controllers/UserController.php",
      "line": 45,
      "code": "$db->query(\"SELECT * FROM users WHERE id = \" . $_GET['id'])",
      "description": "User input directly concatenated into SQL query",
      "remediation": "Use prepared statements with parameterized queries"
    }
  ]
}
```

## Supported Languages

| Language | Frameworks |
|----------|-----------|
| PHP | Laravel, Symfony, WordPress |
| Python | Django, Flask, FastAPI |
| JavaScript | Express, Next.js |
| TypeScript | NestJS, Express |
| Go | Gin, Echo |
| Java | Spring Boot |

## Advanced Usage

```bash
# Full scan with all 13 agents
/security-scan ./src --full-scan

# Dynamic testing with runtime verification
/security-scan ./src --dynamic --target http://localhost:8000

# Auto-generate E2E tests from scan results
/security-scan ./src --auto-e2e

# Scan with memory (learns from previous scans)
/security-scan ./src  # memory enabled by default
/security-scan ./src --no-memory  # disable memory
```

## Documentation

- [Agent Guide](docs/AGENT_GUIDE.md) - 18 agents usage guide and framework matrix
- [Workflow](docs/WORKFLOW.md) - RECON/SCAN/ATTACK/REPORT workflow details
- [FAQ](docs/FAQ.md) - Frequently asked questions

## Version History

See [CHANGELOG.md](CHANGELOG.md) for full details.

| Version | Highlights |
|---------|-----------|
| v4.2.0 | Scan memory integration (learn from previous scans) |
| v4.1.0 | Auto phase transition, 13-agent parallel scan |
| v4.0.0 | Interactive context review, pre-commit hooks |
| v3.2.0 | SCA, DAST crawler, attack scenarios, false-positive filter |
| v3.0.0 | CVSS 4.0 auto-calculation, executive summary reports |
| v2.2.0 | SSTI, XXE, WordPress detection |
| v2.0.0 | E2E test generation (Playwright) |
| v1.0.0 | All core agents, dynamic testing |

## Target Users

Developers who want to ship secure code without being security experts.

- Security professionals use specialized tools (Burp Suite, Semgrep, etc.)
- This plugin provides automated OWASP-based scanning with actionable remediation guidance
- Works as a pre-commit security gate in your development workflow

## References

- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
- [OWASP Top 10 (2025 Draft)](https://owasp.org/www-project-top-ten/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [CWE Top 25](https://cwe.mitre.org/top25/)

## Related Projects

- [tdd-skills](https://github.com/morodomi/tdd-skills) - TDD development workflow automation (Blue Team)
- [anthropics/skills](https://github.com/anthropics/skills) - Official Claude Code skills

## License

MIT
