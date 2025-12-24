# redteam-core

Security audit automation plugin for Claude Code.

## Install

```bash
/plugin install redteam-core@redteam-skills
```

## Workflow

```
RECON → SCAN → ATTACK → REPORT
```

## Agents

| Agent | Target |
|-------|--------|
| recon-agent | Reconnaissance, endpoint enumeration |
| injection-attacker | SQL/NoSQL/Command Injection |
| auth-attacker | Authentication bypass, JWT vulnerabilities |
| xss-attacker | Reflected/Stored/DOM-based XSS |
| api-attacker | BOLA/BFLA/Mass Assignment |
| file-attacker | Path Traversal, LFI/RFI |
| ssrf-attacker | SSRF, cloud metadata access |

## Skills

| Skill | Description |
|-------|-------------|
| security-scan | Run security scan workflow |
| attack-report | Generate vulnerability report |

## References

- [OWASP Top 10](https://owasp.org/Top10/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
