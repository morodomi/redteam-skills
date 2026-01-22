# Workflow

redteam-skillsのセキュリティスキャンワークフロー。

## Basic Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                         RECON Phase                              │
│                      (recon-agent)                               │
│   エンドポイント列挙 → フレームワーク特定 → 優先度付け           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                         SCAN Phase                               │
│                    (並列実行: 8-10 agents)                       │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│  │ injection    │ │ xss          │ │ auth         │             │
│  │ -attacker    │ │ -attacker    │ │ -attacker    │             │
│  └──────────────┘ └──────────────┘ └──────────────┘             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│  │ csrf         │ │ api          │ │ file         │             │
│  │ -attacker    │ │ -attacker    │ │ -attacker    │             │
│  └──────────────┘ └──────────────┘ └──────────────┘             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│  │ ssrf         │ │ ssti         │ │ crypto       │             │
│  │ -attacker    │ │ -attacker    │ │ -attacker    │             │
│  └──────────────┘ └──────────────┘ └──────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        ATTACK Phase                              │
│                 (optional: --dynamic flag)                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              dynamic-verifier                             │   │
│  │   静的解析結果を動的に検証（SQLi/XSS実行確認）           │   │
│  └──────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              false-positive-filter                        │   │
│  │   誤検知を自動除外                                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              attack-scenario                              │   │
│  │   複合攻撃シナリオ生成                                    │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        REPORT Phase                              │
│                     (attack-report)                              │
│   JSON出力 → Markdown変換 → CVSS算出 → 改善提案                 │
└─────────────────────────────────────────────────────────────────┘
```

## Phase Details

### RECON Phase

**実行エージェント**: recon-agent

**目的**: 対象コードベースの理解と攻撃対象の特定

**処理内容**:
1. ルーティング定義の解析
2. エンドポイント一覧の作成
3. 使用フレームワーク・バージョンの特定
4. 認証要否の判定
5. 攻撃優先度の付与（High/Medium/Low）

**出力**:
```json
{
  "framework": "Laravel",
  "endpoints": [
    {
      "method": "POST",
      "path": "/api/users",
      "auth_required": true,
      "priority": "high"
    }
  ]
}
```

### SCAN Phase

**実行エージェント**: 複数の*-attackerエージェント（並列実行）

**目的**: 静的解析による脆弱性検出

**処理内容**:
1. ソースコードのパターンマッチング
2. データフロー解析
3. 脆弱性候補の特定
4. CVE/CWE IDの付与
5. 重大度（Severity）の判定

**並列実行の利点**:
- 各エージェントが独立して動作
- 検出速度の向上
- エージェント間の結果重複は後でマージ

### ATTACK Phase

**実行エージェント**: dynamic-verifier, false-positive-filter, attack-scenario

**目的**: 静的解析結果の検証と精度向上

**dynamic-verifier**:
- 実際にHTTPリクエストを送信
- SQLiならエラーレスポンスを確認
- XSSならスクリプト実行を確認

**false-positive-filter**:
- テストコード内の検出を除外
- フレームワークで保護済みの検出を除外
- サニタイズ済み入力の誤検知を除外

**attack-scenario**:
- 複数の脆弱性を組み合わせた攻撃チェーンを提案
- 例: XSS → セッションハイジャック → 権限昇格

### REPORT Phase

**実行エージェント**: attack-report skill

**目的**: 検出結果の集約とレポート生成

**出力形式**:
- JSON（機械可読）
- Markdown（人間可読）
- CVSSスコア付き

## Usage Examples

### Basic Scan

```bash
# 現在のディレクトリをスキャン
/security-scan

# 特定ディレクトリをスキャン
/security-scan ./src
```

### Dynamic Testing

```bash
# SQLi/XSS動的検証を有効化
/security-scan ./src --dynamic --target http://localhost:8000

# XSS動的検証も有効化
/security-scan ./src --dynamic --enable-dynamic-xss --target http://localhost:8000
```

### Report Generation

```bash
# レポート生成
/attack-report

# 特定のスキャン結果からレポート生成
/attack-report --scan-id 550e8400-e29b-41d4-a716-446655440000
```

### SCA (Software Composition Analysis)

```bash
# 依存関係の脆弱性スキャン
# security-scan内で自動実行される
/security-scan ./
```

## Workflow Variants

### Quick Scan (RECON → SCAN → REPORT)

動的検証を省略した高速スキャン。

```bash
/security-scan ./src
```

### Full Scan (RECON → SCAN → ATTACK → REPORT)

動的検証を含む完全スキャン。

```bash
/security-scan ./src --dynamic --target http://localhost:8000
```

### Targeted Scan

特定のエージェントのみ実行。

```bash
# SQLインジェクションのみ
# (recon結果を渡して特定エージェントを呼び出す)
```
