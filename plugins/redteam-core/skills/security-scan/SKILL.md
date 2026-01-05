---
name: security-scan
description: セキュリティスキャンを実行。RECON→SCAN→REPORTワークフロー。
---

# Security Scan

セキュリティスキャンを実行するスキル。エージェントを連携して脆弱性を検出。

## Usage

```bash
/security-scan           # 現在のディレクトリをスキャン
/security-scan ./src     # 指定ディレクトリをスキャン

# 動的テスト有効化（--target必須）
/security-scan ./src --dynamic --target http://localhost:8000

# XSS動的検証も有効化
/security-scan ./src --dynamic --enable-dynamic-xss --target http://localhost:8000
```

## Options

| Option | Description | Required |
|--------|-------------|----------|
| --dynamic | SQLi動的テストを有効化 | No |
| --enable-dynamic-xss | XSS動的テストを有効化 | No |
| --target | 検証対象URL | Yes (if --dynamic or --enable-dynamic-xss) |

## Workflow

```
1. RECON Phase
   └── recon-agent で情報収集
       - エンドポイント列挙
       - フレームワーク検出
       - 攻撃優先度付け

2. SCAN Phase（並行実行）
   ├── injection-attacker（SQLi検出）
   ├── xss-attacker（XSS検出）
   ├── crypto-attacker（暗号・設定脆弱性）
   └── error-attacker（例外処理脆弱性）

3. REPORT Phase
   └── 結果を統合してJSON出力
```

## Agent Integration

| Phase | Agent | Role |
|-------|-------|------|
| RECON | recon-agent | 情報収集・優先度付け |
| SCAN | injection-attacker | SQLインジェクション検出 |
| SCAN | xss-attacker | XSS脆弱性検出 |
| SCAN | crypto-attacker | 暗号・設定脆弱性検出 |
| SCAN | error-attacker | 例外処理脆弱性検出 |

## Output Format

```json
{
  "metadata": {
    "scan_id": "<uuid>",
    "scanned_at": "<timestamp>",
    "target_directory": "<path>"
  },
  "recon": {
    "framework": "Laravel",
    "endpoints_count": 15,
    "high_priority_count": 5
  },
  "vulnerabilities": {
    "total": 3,
    "critical": 0,
    "high": 2,
    "medium": 1,
    "low": 0
  },
  "details": [
    {
      "agent": "injection-attacker",
      "id": "SQLI-001",
      "severity": "high",
      "file": "app/Controllers/UserController.php",
      "line": 45
    }
  ]
}
```

## Reference

詳細は [reference.md](reference.md) を参照。
