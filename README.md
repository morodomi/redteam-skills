# redteam-skills

A Claude Code Plugin for automated security auditing.

[日本語版 README](README.ja.md)

## Overview

While **tdd-skills** supports development workflows (Blue Team / defense), **redteam-skills** automates security auditing (Red Team / offense).

| Plugin | Role | Analogy |
|--------|------|---------|
| [tdd-skills](https://github.com/morodomi/tdd-skills) | Development workflow | Internal code review |
| redteam-skills | Security audit | External attack simulation |

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) installed

### Plugin Installation

```bash
# Step 1: Add marketplace
/plugin marketplace add morodomi/redteam-skills

# Step 2: Install plugin
/plugin install redteam-core@morodomi-redteam-skills
```

Or use interactive UI:
```bash
/plugin
```

## Usage

### Security Scan

```bash
# Scan current directory
/security-scan

# Scan specific directory
/security-scan ./src

# Enable dynamic testing (SQLi verification)
/security-scan ./src --dynamic --target http://localhost:8000

# Enable XSS dynamic verification
/security-scan ./src --dynamic --enable-dynamic-xss --target http://localhost:8000
```

**Workflow:**

```
1. RECON Phase
   └── recon-agent: Endpoint enumeration, framework detection

2. SCAN Phase (parallel execution)
   ├── injection-attacker: SQLi, Command Injection
   ├── xss-attacker: Reflected/DOM/Stored XSS
   ├── auth-attacker: Authentication bypass
   ├── csrf-attacker: CSRF
   ├── crypto-attacker: Cryptographic vulnerabilities
   └── error-attacker: Exception handling vulnerabilities

3. VERIFY Phase (optional)
   └── dynamic-verifier: SQLi/XSS dynamic verification

4. REPORT Phase
   └── Result aggregation, JSON output
```

### Report Generation

```bash
# Generate vulnerability report
/attack-report
```

## Agents

| Agent | Target Vulnerabilities | OWASP Top 10 |
|-------|----------------------|--------------|
| recon-agent | Reconnaissance | - |
| injection-attacker | SQL/Command Injection | A03:2021 |
| xss-attacker | Reflected/Stored/DOM XSS | A03:2021 |
| auth-attacker | Authentication bypass, JWT vulnerabilities | A07:2021 |
| csrf-attacker | CSRF, Cookie attributes | A01:2021 |
| api-attacker | BOLA/BFLA/Mass Assignment | A01:2021 |
| file-attacker | Path Traversal, LFI/RFI | A01:2021 |
| ssrf-attacker | SSRF, Cloud metadata | A10:2021 |
| crypto-attacker | Weak cryptography, Debug mode | A02:2021 |
| error-attacker | Improper exception handling | A05:2021 |
| dynamic-verifier | SQLi/XSS dynamic verification | - |

## Output Format

### Vulnerability Report (JSON)

```json
{
  "metadata": {
    "schema_version": "2.0",
    "scan_id": "550e8400-e29b-41d4-a716-446655440000",
    "scanned_at": "2025-12-25T10:00:00Z",
    "target_directory": "/path/to/project"
  },
  "recon": {
    "framework": "Laravel",
    "endpoints_count": 15,
    "high_priority_count": 5
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

- PHP (Laravel, Symfony, WordPress)
- Python (Django, Flask, FastAPI)
- JavaScript/TypeScript (Express, Next.js, NestJS)
- Go (Gin, Echo)
- Java (Spring Boot)

## Documentation

- [Agent Guide](docs/AGENT_GUIDE.md) - 18 agents usage guide and framework matrix
- [Workflow](docs/WORKFLOW.md) - RECON/SCAN/ATTACK/REPORT workflow details
- [FAQ](docs/FAQ.md) - Frequently asked questions

## References

- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
- [OWASP Top 10 (2025 Draft)](https://owasp.org/www-project-top-ten/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [CWE Top 25](https://cwe.mitre.org/top25/)

## Version History

See [CHANGELOG.md](CHANGELOG.md) for details.

| Version | Changes |
|---------|---------|
| v2.1.0 | e2e-auth, e2e-ssrf, DOM/Stored XSS detection |
| v2.0.0 | E2E test generation (e2e-xss, e2e-csrf) |
| v1.2.0 | XSS dynamic verification |
| v1.1.0 | vulnerability_class support |
| v1.0.0 | All agents complete, dynamic testing |
| v0.2.0 | auth/api-attacker, attack-report |
| v0.1.0 | MVP (recon, injection, xss, security-scan) |

## Roadmap

| Version | Focus | Features |
|---------|-------|----------|
| v2.2 | Detection Enhancement | ssti-attacker, xxe-attacker, wordpress-attacker |
| v2.3 | E2E Extension | e2e-sqli, e2e-ssti, dynamic for all attackers |
| v3.0 | Report Enhancement | CVSS auto-calculation, PDF output |

## License

MIT

## Related Projects

- [tdd-skills](https://github.com/morodomi/tdd-skills) - TDD development workflow automation
- [anthropics/skills](https://github.com/anthropics/skills) - Official Claude Code skills
