# Project Status

## Overview

| Item | Value |
|------|-------|
| Project | redteam-skills |
| Current Version | 4.1.0 |
| Last Updated | 2026-02-05 |

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

### v1.2.0 - 動的検証強化 + リリース

| # | Issue | Status |
|---|-------|--------|
| 17 | dynamic-xss: XSS動的検証 | Done |
| 27 | docs: リリース準備ドキュメント整備 | Done |

### v2.0 - E2E Test Generation

| # | Issue | Status |
|---|-------|--------|
| 22 | e2e-generator-base: E2Eテスト生成基盤 | Done |
| 23 | e2e-xss: XSS E2Eテスト生成 | Done |
| 24 | e2e-csrf: CSRF E2Eテスト生成 | Done |

### v2.1 - E2E Extended

| # | Issue | Status |
|---|-------|--------|
| 25 | e2e-auth: 認証バイパスE2Eテスト生成 | Done |
| 26 | e2e-ssrf: SSRF E2Eテスト生成 | Done |
| 28 | xss-attacker: DOM/Stored XSS検出対応 | Done |

### v2.2 - 検出力強化

| # | Issue | Status |
|---|-------|--------|
| 31 | ssti-attacker: Server-Side Template Injection検出 | Done |
| 32 | xxe-attacker: XML External Entity Injection検出 | Done |
| 33 | wordpress-attacker: WordPress固有の脆弱性検出 | Done |
| 29 | expect.poll()パターン改善 | Done |

### v2.3 - E2E検証拡張

| # | Issue | Status |
|---|-------|--------|
| 34 | e2e-sqli: SQLi E2Eテスト生成 | Done |
| 35 | e2e-ssti: SSTI E2Eテスト生成 | Done |
| 36 | dynamic全対応: 全attackerにdynamicオプション追加 | Done |

### v3.0 - レポート強化

| # | Issue | Status |
|---|-------|--------|
| 37 | CVSS自動計算: CVSS 4.0スコア自動算出 | Done |
| 38 | レポート品質向上: エグゼクティブサマリ、改善提案詳細化 | Done |
| 39 | PDF出力: 客先提出可能なPDFレポート | Won't Fix |

### v3.1 - スキーマ統一

| # | Issue | Status |
|---|-------|--------|
| 47 | 出力スキーマ統一 | Done |
| 48 | vulnerability_class命名規則統一 | Done |

### v3.2 - SCA・DAST・分析強化

| # | Issue | Status |
|---|-------|--------|
| 40 | sca-attacker: 依存関係脆弱性検出エージェント | Done |
| 41 | sca-scan: security-scanへのSCA統合 | Done |
| 42 | dast-crawler: PlaywrightベースのURL自動発見 | Done |
| 43 | attack-scenario: 攻撃シナリオ自動生成 | Done |
| 45 | false-positive-filter: 誤検知自動除外 | Done |
| 46 | sca-attacker-v4: OSV API改善 | Done |

### v4.0 - ビジネスロジック

| # | Issue | Status |
|---|-------|--------|
| 44 | context-review: 対話型コンテキストレビュー | Done |
| 49 | pre-commit-hook: 全テスト自動実行 | Done |

### v4.1 - tdd-skills互換構造

| # | Issue | Status |
|---|-------|--------|
| 50 | v4.1 - tdd-skills互換構造への移行 | Done |
| 51 | plugin.json バージョンを4.0.0に修正 | Done |
| 52 | .claude/構造対応（tdd-skills互換） | Done |
| 53 | docs: エージェント選択ガイド・使い方ドキュメント整備 | Done |

### v4.1.1 - Auto Phase Transition

| # | Issue | Status |
|---|-------|--------|
| 54 | Auto Phase Transition: security-scan完了後に自動でattack-report呼び出し | Done |
| 55 | Parallel Scan Enhancement: 5→13エージェント並列実行 | Done |

### Closed (Won't Fix)

| # | Issue | Reason |
|---|-------|--------|
| 14 | CI/CD統合 | Plugin配布のため不要 |
| 15 | カスタムルール対応 | 既存エージェントで十分 |
| 18 | dynamic-ssrf: SSRFコールバック検証 | OOBはスコープ外、#26で代替 |
| 39 | PDF出力: 客先提出可能なPDFレポート | Markdownで十分、pandoc等で変換可能 |

## Recent Cycles

| Date | Feature | Issue | Status |
|------|---------|-------|--------|
| 2026-02-05 | auto-phase-transition | #54 | Done |
| 2026-02-05 | parallel-scan-full | #55 | Done |
| 2026-01-22 | plugin-version-fix | #51 | Done |
| 2026-01-22 | .claude-structure | #52 | Done |
| 2026-01-22 | agent-usage-docs | #53 | Done |
| 2026-01-22 | pre-commit-hook | #49 | Done |
| 2026-01-22 | context-review | #44 | Done |
| 2026-01-21 | changelog-release | - | Done |
| 2026-01-16 | naming-unification | #48 | Done |
| 2026-01-16 | schema-unification | #47 | Done |
| 2026-01-15 | false-positive-filter | #45 | Done |
| 2026-01-15 | attack-scenario | #43 | Done |
| 2026-01-15 | sca-attacker-v4 | #46 | Done |
| 2026-01-15 | dast-crawler | #42 | Done |
| 2026-01-14 | sca-scan | #41 | Done |
| 2026-01-14 | sca-attacker | #40 | Done |
| 2026-01-11 | report-quality | #38 | Done |
| 2026-01-09 | cvss-auto-calc | #37 | Done |
| 2026-01-09 | dynamic-all | #36 | Done |
| 2026-01-09 | e2e-ssti | #35 | Done |
| 2026-01-09 | e2e-sqli | #34 | Done |
| 2026-01-09 | expect-poll-pattern | #29 | Done |
| 2026-01-09 | wordpress-attacker | #33 | Done |
| 2026-01-08 | xxe-attacker | #32 | Done |
| 2026-01-08 | ssti-attacker | #31 | Done |
| 2026-01-08 | xss-dom-stored | #28 | Done |
| 2026-01-07 | e2e-ssrf | #26 | Done |
| 2026-01-06 | e2e-auth | #25 | Done |
| 2026-01-06 | e2e-csrf | #24 | Done |
| 2026-01-06 | e2e-xss | #23 | Done |
| 2026-01-05 | e2e-generator-base | #22 | Done |
| 2026-01-05 | docs-release | #27 | Done |
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
