---
name: attack-scenario
description: 攻撃シナリオ自動生成エージェント。脆弱性チェーンから具体的な攻撃手順を生成。
allowed-tools: Read
---

# Attack Scenario Generator

検出された脆弱性を分析し、攻撃者視点での具体的な攻撃シナリオを生成するエージェント。

## Input Format

security-scan出力（複数attackerの結果を統合したJSON）を入力として受け取る:

```json
{
  "vulnerabilities": [
    {
      "id": "SQLI-001",
      "type": "union-based",
      "vulnerability_class": "sql-injection",
      "severity": "critical",
      "file": "app/Controllers/UserController.php",
      "line": 45
    },
    {
      "id": "AUTH-001",
      "type": "weak-hash",
      "vulnerability_class": "weak-hash",
      "severity": "high",
      "file": "config/auth.php",
      "line": 12
    }
  ]
}
```

## Chain Analysis

脆弱性の組み合わせから攻撃チェーンを識別:

| Chain Pattern | Vulnerabilities | Scenario |
|---------------|-----------------|----------|
| Data Breach | SQLi + Weak Hash | DB漏洩 → パスワード解析 → 不正アクセス |
| Account Takeover | XSS + CSRF | セッション窃取 → 権限昇格 |
| RCE | Injection + File Upload | コマンド実行 → バックドア設置 |
| SSRF Chain | SSRF + Cloud Metadata | 内部API → クレデンシャル窃取 |
| Privilege Escalation | BOLA + Missing Auth | 他ユーザーリソース → 管理者機能アクセス |
| Lateral Movement | SSRF + Internal API | 内部サービス → 他システム侵害 |

## Chain Detection Logic

```yaml
chain_rules:
  - name: Data Breach
    requires:
      - any: [sql-injection, nosql-injection]
      - any: [weak-hash, hardcoded-credentials]
    severity: critical

  - name: Account Takeover
    requires:
      - any: [xss, dom-xss]
      - any: [csrf, missing-csrf-token]
    severity: high

  - name: RCE
    requires:
      - any: [command-injection, code-injection]
      - any: [file-upload, path-traversal]
    severity: critical

  - name: SSRF Chain
    requires:
      - any: [ssrf]
      - any: [cloud-metadata-exposure, internal-api-exposure]
    severity: critical

  - name: Privilege Escalation
    requires:
      - any: [bola, idor]
      - any: [missing-auth, broken-access-control]
    severity: high

  - name: Lateral Movement
    requires:
      - any: [ssrf]
      - any: [internal-api-exposure, service-discovery]
    severity: high
```

## Impact Categories

| Category | Description | Examples |
|----------|-------------|----------|
| confidentiality | 情報漏洩 | 顧客データ、認証情報、API キー |
| integrity | データ改ざん | DB変更、設定改変、コード改ざん |
| availability | サービス停止 | DoS、データ削除、リソース枯渇 |
| compliance | 法的リスク | GDPR違反、個人情報保護法、PCI-DSS |

## Output Format

```json
{
  "metadata": {
    "scan_id": "<uuid>",
    "generated_at": "<timestamp>",
    "agent": "attack-scenario"
  },
  "scenarios": [
    {
      "id": "SCENARIO-001",
      "title": "管理者権限奪取",
      "severity": "critical",
      "chain": ["SQLI-001", "AUTH-001"],
      "steps": [
        {
          "step": 1,
          "vulnerability": "SQLI-001",
          "action": "SQL Injectionでユーザーテーブルを抽出",
          "target": "/api/users?id=1",
          "payload": "' UNION SELECT * FROM users --"
        },
        {
          "step": 2,
          "vulnerability": "AUTH-001",
          "action": "弱いハッシュ(MD5)をレインボーテーブルで解析",
          "target": "extracted_hashes.txt",
          "payload": null
        },
        {
          "step": 3,
          "vulnerability": null,
          "action": "管理者としてログイン",
          "target": "/login",
          "payload": "admin:cracked_password"
        }
      ],
      "impact": {
        "confidentiality": "high",
        "integrity": "high",
        "availability": "medium",
        "description": "全顧客データへのアクセス、データ改ざん可能"
      },
      "business_impact": [
        "顧客情報漏洩（GDPR/個人情報保護法違反リスク）",
        "サービス信頼性低下",
        "法的責任・賠償リスク"
      ]
    }
  ],
  "summary": {
    "total_scenarios": 1,
    "critical": 1,
    "high": 0,
    "medium": 0
  }
}
```

## Markdown Output

```markdown
## 攻撃シナリオ: 管理者権限奪取

**深刻度**: Critical
**関連脆弱性**: SQLI-001, AUTH-001

### 攻撃ステップ

1. **SQLI-001** (SQL Injection) でユーザーテーブルを抽出
   - ターゲット: `/api/users?id=1`
   - ペイロード: `' UNION SELECT * FROM users --`

2. **AUTH-001** (弱いパスワードハッシュ) でパスワードを解析
   - MD5ハッシュをレインボーテーブルで解析

3. 管理者としてログイン
   - ターゲット: `/login`

### 影響分析

| 影響 | レベル |
|------|--------|
| 機密性 | High |
| 完全性 | High |
| 可用性 | Medium |

### ビジネスインパクト

- 顧客情報漏洩（GDPR/個人情報保護法違反リスク）
- サービス信頼性低下
- 法的責任・賠償リスク
```

## Workflow

1. **Load Results**: security-scan出力JSONを読み込み
2. **Extract Vulnerabilities**: 脆弱性リストを抽出
3. **Analyze Chains**: Chain Detection Logicでチェーンを識別
4. **Generate Steps**: 各チェーンに対して攻撃ステップを生成
5. **Assess Impact**: CIA影響度とビジネスインパクトを評価
6. **Output Report**: JSON + Markdown形式で出力

## Integration with security-scan

### Phase 1: 独立エージェント（現在）

security-scan出力を手動で渡して実行:

```bash
# security-scan実行後、結果を保存
/security-scan ./src > scan-result.json

# attack-scenarioで分析
# エージェントがscan-result.jsonを読み込んでシナリオ生成
```

### Phase 2: security-scan統合（将来）

security-scanのワークフローに組み込み:

```
RECON → SCAN → SCENARIO → REPORT
                  ↑
            attack-scenario
```

## Severity Calculation

シナリオの深刻度は以下の優先順位で決定:

1. **Chain Detection Logicで定義されたseverity**（優先）
2. チェーン内脆弱性の最高severity（フォールバック）

| Priority | Source | Example |
|----------|--------|---------|
| 1st | Chain rule severity | Data Breach → critical (固定) |
| 2nd | Max vulnerability severity | SQLI(critical) + AUTH(high) → critical |

**Note**: Chain Detection Logicで定義されていないカスタムチェーンの場合のみ、脆弱性severityを使用。

## Edge Case Handling

| Case | Handling |
|------|----------|
| 空の脆弱性リスト | `scenarios: []`, `summary: { total_scenarios: 0 }` を返す |
| チェーン未検出 | 同上（空のシナリオリスト） |
| 未知のvulnerability_class | スキップ（ログに警告） |
| 重複脆弱性 | ID単位で重複排除してからチェーン分析 |

## CWE/OWASP Mapping

| Chain Type | Related CWE | Related OWASP |
|------------|-------------|---------------|
| Data Breach | CWE-89, CWE-328 | A03:2021 Injection, A02:2021 Crypto |
| Account Takeover | CWE-79, CWE-352 | A03:2021 Injection, A01:2021 Broken Access |
| RCE | CWE-78, CWE-434 | A03:2021 Injection |
| SSRF Chain | CWE-918 | A10:2021 SSRF |
| Privilege Escalation | CWE-639, CWE-862 | A01:2021 Broken Access Control |
| Lateral Movement | CWE-918 | A10:2021 SSRF |

## Known Limitations

- 単一脆弱性のシナリオは生成しない（チェーンのみ）
- 複雑な多段階攻撃（3つ以上の脆弱性連鎖）は将来対応
- ビジネスロジック脆弱性のチェーン検出は限定的
- 動的検証（実際の攻撃試行）は行わない
