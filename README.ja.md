# redteam-skills

セキュリティ監査業務をClaude Code Agentで自動化するプラグイン。

[English README](README.md)

## 概要

**tdd-skills**が開発ワークフロー（Blue Team / 守り）を支援するのに対し、**redteam-skills**はセキュリティ監査（Red Team / 攻め）を自動化します。

| プラグイン | 役割 | 例え |
|-----------|------|------|
| [tdd-skills](https://github.com/morodomi/tdd-skills) | 開発ワークフロー | 内部コードレビュー |
| redteam-skills | セキュリティ監査 | 外部攻撃シミュレーション |

## インストール

### 前提条件

- [Claude Code](https://claude.ai/claude-code) がインストール済み

### プラグインインストール

```bash
# Claude Codeでプラグインをインストール
claude /plugin install redteam-core@github:morodomi/redteam-skills
```

または `settings.json` に直接追加:

```json
{
  "plugins": [
    "redteam-core@github:morodomi/redteam-skills"
  ]
}
```

## 使い方

### セキュリティスキャン

```bash
# 現在のディレクトリをスキャン
/security-scan

# 特定ディレクトリをスキャン
/security-scan ./src

# 動的テスト有効化（SQLi検証）
/security-scan ./src --dynamic --target http://localhost:8000

# XSS動的検証も有効化
/security-scan ./src --dynamic --enable-dynamic-xss --target http://localhost:8000
```

**ワークフロー:**

```
1. RECON Phase
   └── recon-agent: エンドポイント列挙、フレームワーク検出

2. SCAN Phase（並行実行）
   ├── injection-attacker: SQLi, Command Injection
   ├── xss-attacker: Reflected/DOM/Stored XSS
   ├── auth-attacker: 認証バイパス
   ├── csrf-attacker: CSRF
   ├── crypto-attacker: 暗号・設定脆弱性
   └── error-attacker: 例外処理脆弱性

3. VERIFY Phase（オプション）
   └── dynamic-verifier: SQLi/XSS動的検証

4. REPORT Phase
   └── 結果統合、JSON出力
```

### レポート生成

```bash
# 脆弱性レポート生成
/attack-report
```

## エージェント一覧

| エージェント | 対象脆弱性 | OWASP Top 10 |
|-------------|-----------|--------------|
| recon-agent | 偵察・情報収集 | - |
| injection-attacker | SQL/Command Injection | A03:2021 |
| xss-attacker | Reflected/Stored/DOM XSS | A03:2021 |
| auth-attacker | 認証バイパス、JWT脆弱性 | A07:2021 |
| csrf-attacker | CSRF、Cookie属性 | A01:2021 |
| api-attacker | BOLA/BFLA/Mass Assignment | A01:2021 |
| file-attacker | Path Traversal、LFI/RFI | A01:2021 |
| ssrf-attacker | SSRF、クラウドメタデータ | A10:2021 |
| crypto-attacker | 弱い暗号、デバッグモード | A02:2021 |
| error-attacker | 不適切な例外処理 | A05:2021 |
| dynamic-verifier | SQLi/XSS動的検証 | - |

## 出力形式

### 脆弱性レポート（JSON）

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
  "vulnerabilities": {
    "total": 3,
    "critical": 1,
    "high": 1,
    "medium": 1,
    "low": 0
  },
  "details": [
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

## 対応言語

- PHP (Laravel, Symfony, WordPress)
- Python (Django, Flask, FastAPI)
- JavaScript/TypeScript (Express, Next.js, NestJS)
- Go (Gin, Echo)
- Java (Spring Boot)

## 参照基準

- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
- [OWASP Top 10 (2025 Draft)](https://owasp.org/www-project-top-ten/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [CWE Top 25](https://cwe.mitre.org/top25/)

## バージョン履歴

詳細は [CHANGELOG.md](CHANGELOG.md) を参照。

| Version | 内容 |
|---------|------|
| v1.2.0 | XSS動的検証追加 |
| v1.1.0 | vulnerability_class対応 |
| v1.0.0 | 全エージェント完成、動的テスト基盤 |
| v0.2.0 | auth/api-attacker、attack-report追加 |
| v0.1.0 | MVP（recon, injection, xss, security-scan） |

## ライセンス

MIT

## 関連プロジェクト

- [tdd-skills](https://github.com/morodomi/tdd-skills) - TDD開発ワークフロー自動化
- [anthropics/skills](https://github.com/anthropics/skills) - Claude Code公式スキル
