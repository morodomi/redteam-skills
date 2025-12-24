# redteam-skills

セキュリティ監査業務をClaude Code Agentで自動化するプラグイン集。

## 概要

**tdd-skills**が開発ワークフロー（Blue Team / 守り）を支援するのに対し、**redteam-skills**はセキュリティ監査（Red Team / 攻め）を自動化します。

| プラグイン | 役割 | 例え |
|-----------|------|------|
| [tdd-skills](https://github.com/morodomi/tdd-skills) | 開発ワークフロー | 内部コードレビュー |
| redteam-skills | セキュリティ監査 | 外部攻撃シミュレーション |

## インストール

```bash
# Claude Codeでプラグインをインストール
/plugin install redteam-core@redteam-skills
```

## 使い方

### セキュリティスキャン

```bash
/security-scan
```

ワークフロー:
1. **RECON** - エンドポイント列挙、技術スタック特定
2. **SCAN** - 各攻撃エージェントによる並行スキャン
3. **ATTACK** - 高スコア脆弱性のPoC検証
4. **REPORT** - 脆弱性レポート生成

### レポート生成

```bash
/attack-report
```

## エージェント

| エージェント | 対象脆弱性 |
|-------------|-----------|
| recon-agent | 偵察・情報収集 |
| injection-attacker | SQL/NoSQL/Command/LDAP Injection |
| auth-attacker | 認証バイパス、JWT脆弱性 |
| xss-attacker | Reflected/Stored/DOM-based XSS |
| api-attacker | BOLA/BFLA/Mass Assignment |
| file-attacker | Path Traversal、LFI/RFI |
| ssrf-attacker | SSRF、クラウドメタデータ |

## 出力形式

### 脆弱性レポート（JSON）

```json
{
  "id": "VULN-001",
  "type": "SQL Injection",
  "severity": "critical",
  "cvss": 9.8,
  "endpoint": "POST /api/users/login",
  "parameter": "username",
  "payload": "admin'--",
  "evidence": "Response contains 'Welcome admin'",
  "remediation": [
    "プリペアドステートメントを使用",
    "入力値のバリデーション強化"
  ]
}
```

### サマリーレポート（Markdown）

```markdown
# Security Audit Report

## Executive Summary
- Critical: 2件
- High: 5件
- Medium: 8件
- Low: 12件
```

## 参照基準

- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [CWE Top 25](https://cwe.mitre.org/top25/)

## ロードマップ

- [ ] **v0.1.0** - MVP（recon, injection, xss, security-scan）
- [ ] **v0.2.0** - 拡張（auth, api, attack-report）
- [ ] **v1.0.0** - 完成（全エージェント、CI/CD統合）

## ライセンス

MIT

## 関連プロジェクト

- [tdd-skills](https://github.com/morodomi/tdd-skills) - TDD開発ワークフロー自動化
- [anthropics/skills](https://github.com/anthropics/skills) - Claude Code公式スキル
