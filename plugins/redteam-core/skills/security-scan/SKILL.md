---
name: security-scan
description: セキュリティスキャンを実行。RECON→SCAN→REPORT→AUTO TRANSITIONワークフロー。
---

# Security Scan

セキュリティスキャンを実行するスキル。エージェントを連携して脆弱性を検出し、自動でレポートを生成。

## Usage

```bash
/security-scan           # 現在のディレクトリをスキャン
/security-scan ./src     # 指定ディレクトリをスキャン

# フルスキャン（13エージェント並列）
/security-scan ./src --full-scan

# 動的テスト有効化（--target必須）
/security-scan ./src --dynamic --target http://localhost:8000

# レポート自動生成をスキップ
/security-scan ./src --no-auto-report

# レポート後にE2Eテスト自動生成
/security-scan ./src --auto-e2e
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| --full-scan | 全13エージェント並列実行 | Off (5 core agents) |
| --no-auto-report | 自動attack-reportをスキップ | 有効 |
| --auto-e2e | レポート後に自動E2E生成 | Off |
| --dynamic | SQLi動的テストを有効化 | Off |
| --enable-dynamic-xss | XSS動的テストを有効化 | Off |
| --target | 検証対象URL | Required if --dynamic |
| --no-sca | SCAスキャンをスキップ | Off |

## Workflow

```
1. RECON Phase
   └── recon-agent

2. SCAN Phase (parallel)
   ├── Core Agents (default: 5)
   └── Extended Agents (--full-scan: +8)

3. REPORT Phase
   └── JSON output

4. AUTO TRANSITION (unless --no-auto-report)
   └── Skill(redteam-core:attack-report)

5. [OPTIONAL] E2E (if --auto-e2e)
   └── Skill(redteam-core:generate-e2e)
```

## Auto Transition

スキャン完了後、自動的にattack-reportを呼び出す:

```
検出件数: Critical 0, High 2, Medium 1

レポートを生成します。

Skill(redteam-core:attack-report)
```

`--no-auto-report` でスキップ可能。

## Agent Integration

| Phase | Agent | Role |
|-------|-------|------|
| RECON | recon-agent | 情報収集・優先度付け |
| SCAN | 5 core / 13 full | 脆弱性検出（並行実行） |

## Reference

詳細は [reference.md](reference.md) を参照。
