# redteam-skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-4.2.0-blue.svg)](CHANGELOG.md)

**AIによるコードベースのセキュリティ監査。** コマンド1つで、18の専門エージェントが6言語のOWASP Top 10カバレッジを提供します。

[English README](README.md)

> **18** セキュリティエージェント | **6** 言語対応 | **OWASP Top 10** 完全カバレッジ | **CVSS 4.0** 自動スコアリング

## クイックスタート

```bash
# 1. プラグインをインストール
/plugin marketplace add morodomi/redteam-skills
/plugin install redteam-core@morodomi-redteam-skills

# 2. セキュリティスキャンを実行
/security-scan

# 3. レポートを生成
/attack-report
```

スキャンは13エージェントを並列実行し、脆弱性を検出、CVSSスコアと修正ガイダンス付きのJSON + Markdownレポートを出力します。

## 仕組み

```
1. RECON Phase
   └── recon-agent: エンドポイント列挙、フレームワーク検出

2. SCAN Phase（13エージェント並列）
   ├── Core Agents (5): injection, xss, crypto, error, sca
   └── Extended Agents (8): auth, api, file, ssrf, csrf, ssti, xxe, wordpress

3. VERIFY Phase
   ├── false-positive-filter: 誤検知除外
   ├── dynamic-verifier: SQLi/XSS/Auth/CSRF/SSRF 動的検証
   └── attack-scenario: 脆弱性チェーン分析

4. REPORT Phase
   └── CVSS 4.0スコアリング、JSON + Markdown出力
```

## エージェント一覧

| エージェント | 対象 | OWASP |
|-------------|------|-------|
| recon-agent | エンドポイント列挙、技術スタック検出 | - |
| injection-attacker | SQL/NoSQL/Command/LDAP Injection | A03:2021 |
| xss-attacker | Reflected/Stored/DOM XSS | A03:2021 |
| auth-attacker | 認証バイパス、JWT脆弱性 | A07:2021 |
| csrf-attacker | CSRF、Cookie属性 | A01:2021 |
| api-attacker | BOLA/BFLA/Mass Assignment | A01:2021 |
| file-attacker | Path Traversal、LFI/RFI | A01:2021 |
| ssrf-attacker | SSRF、クラウドメタデータ | A10:2021 |
| ssti-attacker | Server-Side Template Injection | A03:2021 |
| xxe-attacker | XML External Entity Injection | A05:2021 |
| wordpress-attacker | WordPress固有の脆弱性 | A06:2021 |
| crypto-attacker | 弱い暗号、デバッグモード | A02:2021 |
| error-attacker | 不適切な例外処理 | A05:2021 |
| sca-attacker | 依存関係の脆弱性（OSV API） | A06:2021 |
| dast-crawler | PlaywrightベースのURL自動発見 | - |
| dynamic-verifier | SQLi/XSS/Auth/CSRF/SSRF 動的検証 | - |
| false-positive-filter | コンテキストベースの誤検知除外 | - |
| attack-scenario | 脆弱性チェーン分析 | - |

## 出力形式

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

## 対応言語

| 言語 | フレームワーク |
|------|--------------|
| PHP | Laravel, Symfony, WordPress |
| Python | Django, Flask, FastAPI |
| JavaScript | Express, Next.js |
| TypeScript | NestJS, Express |
| Go | Gin, Echo |
| Java | Spring Boot |

## 高度な使い方

```bash
# 全13エージェントでスキャン
/security-scan ./src --full-scan

# 動的テスト（実行時検証）
/security-scan ./src --dynamic --target http://localhost:8000

# スキャン結果からE2Eテスト自動生成
/security-scan ./src --auto-e2e

# スキャンメモリ（過去のスキャンから学習）
/security-scan ./src  # メモリはデフォルトで有効
/security-scan ./src --no-memory  # メモリを無効化
```

## ドキュメント

- [Agent Guide](docs/AGENT_GUIDE.md) - 18エージェントの使い方とフレームワーク対応表
- [Workflow](docs/WORKFLOW.md) - RECON/SCAN/ATTACK/REPORTワークフロー詳細
- [FAQ](docs/FAQ.md) - よくある質問

## バージョン履歴

詳細は [CHANGELOG.md](CHANGELOG.md) を参照。

| Version | 主な変更 |
|---------|---------|
| v4.2.0 | スキャンメモリ統合（過去のスキャンから学習） |
| v4.1.0 | 自動フェーズ遷移、13エージェント並列スキャン |
| v4.0.0 | 対話型コンテキストレビュー、pre-commit hooks |
| v3.2.0 | SCA、DASTクローラー、攻撃シナリオ、誤検知フィルター |
| v3.0.0 | CVSS 4.0自動計算、エグゼクティブサマリレポート |
| v2.2.0 | SSTI、XXE、WordPress検出 |
| v2.0.0 | E2Eテスト生成（Playwright） |
| v1.0.0 | 全コアエージェント、動的テスト基盤 |

## ターゲットユーザー

セキュリティの専門家でなくても、安全なコードを書きたい開発者向け。

- セキュリティ専門家は専用ツール（Burp Suite, Semgrep等）を使う
- このプラグインはOWASPベースの自動スキャンと修正ガイダンスを提供
- 開発ワークフローのpre-commitセキュリティゲートとして機能

## 参照基準

- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
- [OWASP Top 10 (2025 Draft)](https://owasp.org/www-project-top-ten/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [CWE Top 25](https://cwe.mitre.org/top25/)

## 関連プロジェクト

- [tdd-skills](https://github.com/morodomi/tdd-skills) - TDD開発ワークフロー自動化（Blue Team）
- [anthropics/skills](https://github.com/anthropics/skills) - Claude Code公式スキル

## ライセンス

MIT
