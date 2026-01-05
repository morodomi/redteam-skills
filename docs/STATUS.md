# Project Status

## Overview

| Item | Value |
|------|-------|
| Project | redteam-skills |
| Current Version | 1.0.0 |
| Last Updated | 2026-01-05 |

## Milestones

### v0.1.0 - MVP

| # | Issue | Status |
|---|-------|--------|
| 1 | プラグイン基盤構築 | Done |
| 2 | recon-agent: 偵察エージェント実装 | Done |
| 3 | injection-attacker: SQLインジェクション検出 | Done |
| 4 | xss-attacker: Reflected XSS検出 | Done |
| 5 | security-scan スキル実装 | Done |
| 6 | 基本レポート出力機能 | Done |

### v0.2.0 - 拡張

| # | Issue | Status |
|---|-------|--------|
| 7 | auth-attacker: 認証攻撃エージェント | Done |
| 8 | api-attacker: API攻撃エージェント | Done |
| 9 | attack-report スキル実装 | Done |
| 10 | OWASP Top 10 完全カバレッジ | Done |

### v1.0.0 - 完成

| # | Issue | Status |
|---|-------|--------|
| 11 | file-attacker: ファイル攻撃エージェント | Done |
| 12 | ssrf-attacker: SSRF攻撃エージェント | Done |
| 13 | dynamic-testing: 動的テストオプション（SQLi） | Done |

### v1.1.0 - 改善

| # | Issue | Status |
|---|-------|--------|
| 16 | vulnerability type フィールド追加 | Done |
| 21 | attack-report: vulnerability_class活用 | Done |

### v1.2.0 - 動的検証強化

| # | Issue | Status |
|---|-------|--------|
| 17 | dynamic-xss: XSS動的検証 | Done |

### v2.0 - E2E Test Generation

| # | Issue | Status |
|---|-------|--------|
| 22 | e2e-generator-base: E2Eテスト生成基盤 | Open |
| 23 | e2e-xss: XSS E2Eテスト生成 | Open |
| 24 | e2e-csrf: CSRF E2Eテスト生成 | Open |

### v2.1 - E2E Extended

| # | Issue | Status |
|---|-------|--------|
| 25 | e2e-auth: 認証バイパスE2Eテスト生成 | Open |
| 26 | e2e-ssrf: SSRF E2Eテスト生成 | Open |

### Future (Backlog)

| # | Issue | Status |
|---|-------|--------|
| 14 | GitHub Action化 | Open |
| 15 | カスタムルール対応 | Open |

### Closed (Won't Fix)

| # | Issue | Reason |
|---|-------|--------|
| 18 | dynamic-ssrf: SSRFコールバック検証 | OOBはスコープ外、#26で代替 |

## Recent Cycles

| Date | Feature | Issue | Status |
|------|---------|-------|--------|
| 2025-12-25 | dynamic-xss | #17 | Done |
| 2025-12-25 | csrf-attacker | #19 | Done |
| 2025-12-25 | command-injection | #20 | Done |
| 2025-12-25 | attack-report-vuln-class | #21 | Done |
| 2025-12-25 | vulnerability-type-field | #16 | Done |
| 2025-12-25 | dynamic-testing | #13 | Done |
| 2025-12-25 | ssrf-attacker | #12 | Done |
| 2025-12-25 | file-attacker | #11 | Done |
| 2025-12-25 | owasp-2025-integration | #10 | Done |
| 2025-12-25 | owasp-2025-coverage | #10 | Done |
| 2024-12-24 | attack-report-v2 | #9 | Done |
| 2024-12-24 | api-attacker | #8 | Done |
| 2024-12-24 | auth-attacker | #7 | Done |
| 2024-12-24 | attack-report | #6 | Done |
| 2024-12-24 | security-scan | #5 | Done |
| 2024-12-24 | xss-attacker | #4 | Done |
| 2024-12-24 | injection-attacker | #3 | Done |
| 2024-12-24 | recon-agent | #2 | Done |
| 2024-12-24 | plugin-foundation | #1 | Done |

## Tech Stack

- **Distribution**: Claude Code Plugins
- **Reference**: OWASP Top 10, OWASP ASVS, CWE Top 25
