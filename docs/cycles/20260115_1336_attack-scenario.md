# Cycle: attack-scenario

| Item | Value |
|------|-------|
| Issue | #43 |
| Phase | DONE |
| Created | 2026-01-15 13:36 |

## Environment

| Tool | Version |
|------|---------|
| Node.js | v22.17.0 |

## Goal

検出された脆弱性から具体的な攻撃シナリオを自動生成するエージェントを作成。

## Background

From Issue #43:
- 脆弱性チェーンの可視化
- 攻撃成功時の影響分析
- 攻撃ステップの具体化
- レポートの説得力向上

## Scope

From Issue #43:
- [ ] attack-scenario エージェント作成
- [ ] 脆弱性チェーン分析機能
- [ ] 攻撃ステップ生成
- [ ] 影響分析出力

## PLAN

### Background

security-scanで検出された脆弱性は個別にリストされるが、
攻撃者視点での「シナリオ」として可視化されていない。

attack-scenarioは検出脆弱性を分析し、
具体的な攻撃手順と影響を生成してレポートの説得力を向上させる。

### Design

#### エージェント構造

```yaml
name: attack-scenario
description: 攻撃シナリオ自動生成エージェント。脆弱性チェーンから具体的な攻撃手順を生成。
allowed-tools: Read
```

#### Input Format

security-scan出力（複数attackerの結果を統合したJSON）を入力として受け取る:

```json
{
  "vulnerabilities": [
    { "id": "SQLI-001", "severity": "critical", ... },
    { "id": "AUTH-001", "severity": "high", ... }
  ]
}
```

#### Chain Analysis

脆弱性の組み合わせから攻撃チェーンを識別:

| Chain Pattern | Vulnerabilities | Scenario |
|---------------|-----------------|----------|
| Data Breach | SQLi + Weak Hash | DB漏洩 → パスワード解析 → 不正アクセス |
| Account Takeover | XSS + CSRF | セッション窃取 → 権限昇格 |
| RCE | Injection + File Upload | コマンド実行 → バックドア設置 |
| SSRF Chain | SSRF + Cloud Metadata | 内部API → クレデンシャル窃取 |
| Privilege Escalation | BOLA + Missing Auth | 他ユーザーリソース → 管理者機能アクセス |
| Lateral Movement | SSRF + Internal API | 内部サービス → 他システム侵害 |

#### Chain Detection Logic

```yaml
chain_rules:
  - name: Data Breach
    requires:
      - any: [sql-injection, nosql-injection]
      - any: [weak-hash, hardcoded-credentials]
    severity: critical

  - name: Privilege Escalation
    requires:
      - any: [bola, idor, missing-auth]
      - any: [missing-auth, broken-access-control]
    severity: high

  - name: Lateral Movement
    requires:
      - any: [ssrf]
      - context: internal_api_detected
    severity: high
```

#### Impact Categories

| Category | Description | Examples |
|----------|-------------|----------|
| confidentiality | 情報漏洩 | 顧客データ、認証情報 |
| integrity | データ改ざん | DB変更、設定改変 |
| availability | サービス停止 | DoS、データ削除 |
| compliance | 法的リスク | GDPR違反、個人情報保護法 |

#### Output Format

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
      "chain": ["SQLI-001", "AUTH-002"],
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
          "vulnerability": "AUTH-002",
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

#### Markdown Output

```markdown
## 攻撃シナリオ: 管理者権限奪取

**深刻度**: Critical
**関連脆弱性**: SQLI-001, AUTH-002

### 攻撃ステップ

1. **SQLI-001** (SQL Injection) でユーザーテーブルを抽出
   - ターゲット: `/api/users?id=1`
   - ペイロード: `' UNION SELECT * FROM users --`

2. **AUTH-002** (弱いパスワードハッシュ) でパスワードを解析
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

### Files

```
plugins/redteam-core/agents/
└── attack-scenario.md    # 新規

scripts/
└── test-attack-scenario.sh  # 新規
```

### Integration with security-scan

#### Phase 1: 独立エージェント（本Issue）

security-scan出力を手動で渡して実行:

```bash
# security-scan実行後
/security-scan ./src > scan-result.json

# attack-scenarioで分析（手動）
# → エージェントがscan-result.jsonを読み込んでシナリオ生成
```

#### Phase 2: security-scan統合（将来Issue）

security-scanのワークフローに組み込み:

```
RECON → SCAN → SCENARIO → REPORT
                  ↑
            attack-scenario
```

```yaml
# security-scan SKILL.md への追加（将来）
options:
  --scenario: 攻撃シナリオ生成を有効化

workflow:
  3. SCENARIO Phase（オプション）
     └── attack-scenario で脆弱性チェーン分析
```

**本Issueのスコープ**: Phase 1（独立エージェント）のみ

## Test List

### TODO

#### エージェント構造
- [ ] TC-01: frontmatterにname: attack-scenarioがある
- [ ] TC-02: frontmatterにallowed-toolsがある
- [ ] TC-03: Input Formatセクションがある

#### Chain Analysis
- [ ] TC-04: Chain Analysisセクションがある
- [ ] TC-05: Chain Patternテーブルに6パターンがある
- [ ] TC-06: Chain Detection Logicセクションがある

#### Output Format
- [ ] TC-07: Output Formatにscenariosがある
- [ ] TC-08: Output Formatにstepsがある
- [ ] TC-09: Output Formatにimpactがある

#### Impact Analysis
- [ ] TC-10: Impact Categoriesセクションがある
- [ ] TC-11: business_impactフィールドがある

#### Integration
- [ ] TC-12: Integration with security-scanセクションがある

### WIP

(なし)

### DONE

- [x] TC-01: frontmatterにname: attack-scenarioがある
- [x] TC-02: frontmatterにallowed-toolsがある
- [x] TC-03: Input Formatセクションがある
- [x] TC-04: Chain Analysisセクションがある
- [x] TC-05: Chain Patternテーブルに6パターンがある
- [x] TC-06: Chain Detection Logicセクションがある
- [x] TC-07: Output Formatにscenariosがある
- [x] TC-08: Output Formatにstepsがある
- [x] TC-09: Output Formatにimpactがある
- [x] TC-10: Impact Categoriesセクションがある
- [x] TC-11: business_impactフィールドがある
- [x] TC-12: Integration with security-scanセクションがある

## REVIEW

(REVIEWフェーズで記入)

## Notes

- v4.2 マイルストーン
- 関連: #42 dast-crawler（発見エンドポイントを活用可能）
