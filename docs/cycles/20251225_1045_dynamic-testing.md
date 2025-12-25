# TDD Cycle: dynamic-testing

## Overview

| Item | Value |
|------|-------|
| Feature | dynamic-testing: 動的テストオプション |
| Issue | #13 |
| Phase | INIT |
| Started | 2025-12-25 10:45 |

## Environment

| Tool | Version |
|------|---------|
| Claude Code | 2.0.75 |
| Platform | darwin (macOS) |

## Goal

security-scan スキルに動的テストオプションを追加する。現在は静的解析のみだが、実際にHTTPリクエストを送信して脆弱性を検証する機能を追加する。

**スコープ縮小**: plan-reviewの結果、安全対策を確実に実装するためSQLiエラーベースのみに限定。

### 機能概要（このサイクル）

| Feature | Description |
|---------|-------------|
| --dynamic フラグ | 動的テストを有効化 |
| --target オプション | 検証対象URL（必須） |
| SQLi検証 | エラーベース検出のみ |
| 安全対策 | 非破壊ペイロード、レート制限 |

### 対象脆弱性（このサイクル）

| Type | Dynamic Test | Status |
|------|--------------|--------|
| SQLi | エラーベース検証 | **対象** |
| XSS | 反射検証 | → #17 |
| SSRF | コールバック検証 | → #18 |

### Out of Scope

| Issue | Feature | Reason |
|-------|---------|--------|
| #17 | dynamic-xss | スコープ縮小により分離 |
| #18 | dynamic-ssrf | スコープ縮小により分離 |

## Background

### 現在のアーキテクチャ

```
security-scan
├── Phase 1: RECON (recon-agent)
├── Phase 2: SCAN (静的解析)
│   ├── injection-attacker
│   ├── xss-attacker
│   ├── auth-attacker
│   ├── api-attacker
│   ├── crypto-attacker
│   ├── error-attacker
│   ├── file-attacker
│   └── ssrf-attacker
└── Phase 3: REPORT
```

### 動的テスト追加後

```
security-scan --dynamic --target http://localhost:8000
├── Phase 1: RECON
├── Phase 2: SCAN (静的解析)
├── [VERIFY] (--dynamic時のみ、オプショナル) ← NEW
└── Phase 3: REPORT
```

**注**: 既存の3フェーズ構成を維持。VERIFYはPhase番号なし（オプショナルステップ）。

## PLAN

### スコープ

security-scan に動的テストオプション（--dynamic）を追加する。
**このサイクルではSQLiエラーベース検証のみ実装**。

### ファイル構成

```
plugins/redteam-core/
├── agents/
│   └── dynamic-verifier.md    # NEW: 動的検証エージェント
└── skills/
    └── security-scan/
        ├── SKILL.md           # UPDATE: --dynamic オプション追加
        └── reference.md       # UPDATE: Phase 3 VERIFY 追加
scripts/
└── test-dynamic-testing.sh    # NEW
```

### データフロー

```
recon-agent → endpoints配列
     ↓
injection-attacker → vulnerabilities配列（file, line, code）
     ↓
dynamic-verifier → endpoints + vulnerabilities を照合
     ↓
検証対象リスト生成:
  {
    "vulnerability_id": "SQLI-001",
    "endpoint": "/api/users",
    "method": "POST",
    "parameter": "sort",
    "file": "UserController.php",
    "line": 45
  }
```

**照合ロジック**:
1. `recon.endpoints` からHTTPメソッド・パス・パラメータを取得
2. `vulnerabilities[].file` とエンドポイントのファイルパスを照合
3. マッチしたエンドポイントを検証対象として抽出

### 新エージェント: dynamic-verifier

| Item | Value |
|------|-------|
| Name | dynamic-verifier |
| Role | 静的解析結果を動的に検証 |
| Tools | Bash, Read |

#### 検証対象（このサイクル）

| Type | Verification Method |
|------|---------------------|
| SQLi | エラーベース検出（`'` 挿入→SQLエラーメッセージ確認） |

#### 非破壊ペイロード定義

```yaml
sqli_payloads:
  error_based:
    - "'"                    # Single quote - syntax error trigger
    - "1' OR '1'='1"         # Boolean-based (read-only)
    - "1 AND 1=1"            # Numeric injection test

  # 禁止ペイロード（使用しない）
  forbidden:
    # データ破壊
    - "DROP"
    - "DELETE"
    - "TRUNCATE"
    - "UPDATE"
    - "INSERT"
    # スキーマ変更
    - "ALTER"
    - "CREATE"
    # システム操作
    - "EXEC"
    - "EXECUTE"
    - "LOAD_FILE"
    - "INTO OUTFILE"
    # コメント・複数文
    - "; --"
    - "/*"
    - "--"
```

#### 安全対策

| Risk | Mitigation | Implementation |
|------|------------|----------------|
| 本番環境への攻撃 | --target 必須 | URLが明示されない場合はエラー終了 |
| 破壊的ペイロード | 非破壊リストのみ | forbidden listに該当するものは送信しない |
| 過負荷 | レート制限 | `sleep 1` between requests |
| 意図しない攻撃 | URL検証 | localhost以外は確認プロンプト |

#### URL検証ロジック

```yaml
url_validation:
  allowed_schemes:
    - http
    - https

  safe_hosts:  # 確認なしで許可
    - localhost
    - 127.0.0.1
    # 0.0.0.0 は除外（全インターフェースバインド=本番環境リスク）

  confirmation_required:  # 確認プロンプト表示
    - その他すべてのホスト
    - "WARNING: Target is not localhost. Continue? (y/N)"
```

#### レート制限実装

```bash
# dynamic-verifier内での実装
for endpoint in $endpoints; do
  curl --max-time 10 --connect-timeout 5 "$target$endpoint?param=$payload"
  sleep 1  # 1秒間隔
done

# 制限値
max_requests: 50        # 1セッションあたり最大リクエスト数
timeout: 10             # リクエストタイムアウト（秒）
connect_timeout: 5      # 接続タイムアウト（秒）
interval: 1             # リクエスト間隔（秒）
```

#### SQLi検出ロジック

```
1. 静的解析で検出されたエンドポイントを取得
2. パラメータに ' を挿入してリクエスト送信
3. レスポンスを解析:
   - "SQL syntax" → confirmed (SQLi確認)
   - "mysql_fetch" → confirmed
   - "ORA-" → confirmed (Oracle)
   - "pg_query" → confirmed (PostgreSQL)
   - 正常レスポンス → not_vulnerable
   - タイムアウト → inconclusive
```

### Workflow 更新

```
security-scan --dynamic --target http://localhost:8000
├── Phase 1: RECON
├── Phase 2: SCAN (静的解析)
├── [VERIFY] (--dynamic時のみ) ← NEW
│   └── dynamic-verifier
│       - recon.endpoints + vulnerabilities を照合
│       - 非破壊ペイロード送信（max 50 requests）
│       - レスポンス解析（SQLエラーメッセージ確認）
│       - sleep 1 between requests
└── Phase 3: REPORT
```

### Usage 更新

```bash
# 静的解析のみ（既存）
/security-scan ./src

# 動的テスト有効化（--target必須）
/security-scan ./src --dynamic --target http://localhost:8000
```

### Output Format 拡張

**後方互換性**: `verification`セクションはオプショナル。既存ツールは無視可能。

```json
// --dynamic なしの場合（既存形式、変更なし）
{
  "metadata": { ... },
  "recon": { ... },
  "vulnerabilities": { ... },
  "details": [
    {
      "id": "SQLI-001",
      "type": "union-based",
      "file": "UserController.php",
      "line": 45
    }
  ]
}

// --dynamic ありの場合（verification追加）
{
  "metadata": { ... },
  "recon": { ... },
  "vulnerabilities": { ... },
  "verification": {                    // オプショナルセクション
    "enabled": true,
    "target": "http://localhost:8000",
    "verified": 2,
    "confirmed": 1,
    "false_positives": 1
  },
  "details": [
    {
      "id": "SQLI-001",
      "type": "union-based",
      "file": "UserController.php",
      "line": 45,
      "verified": true,                // オプショナルフィールド
      "verification_result": "confirmed",
      "evidence": "SQL syntax error in response"
    }
  ]
}
```

### Verification Result

| Result | Description |
|--------|-------------|
| confirmed | 脆弱性確認（動的テストで再現） |
| not_vulnerable | 脆弱性なし（ペイロードが無効化） |
| inconclusive | 判定不能（タイムアウト等） |
| skipped | 検証スキップ（エンドポイント到達不可） |

## Test List

### TODO
- [ ] TC-01: dynamic-verifier.md が存在する
- [ ] TC-02: dynamic-verifier に Bash ツールが許可されている
- [ ] TC-03: security-scan SKILL.md に --dynamic オプションが記載
- [ ] TC-04: security-scan SKILL.md に --target オプションが記載
- [ ] TC-05: security-scan reference.md に [VERIFY] ステップが記載
- [ ] TC-06: dynamic-verifier に SQLi 検証パターンが存在
- [ ] TC-07: dynamic-verifier に非破壊ペイロード定義が存在
- [ ] TC-08: dynamic-verifier に禁止ペイロード定義が存在
- [ ] TC-09: dynamic-verifier に安全対策が記載
- [ ] TC-10: dynamic-verifier にレート制限が記載
- [ ] TC-11: dynamic-verifier にURL検証ロジックが記載
- [ ] TC-12: dynamic-verifier にタイムアウト設定が記載
- [ ] TC-13: reference.md Output Format に verification セクションが存在
- [ ] TC-14: scripts/test-dynamic-testing.sh が存在する

## Phase Log

| Phase | Status | Note |
|-------|--------|------|
| INIT | Done | Cycle doc作成 |
| PLAN | Done | 設計完了、Test List 10件 |
| plan-review | Done | Critical 7件検出、スコープ縮小決定 |
| PLAN v2 | Done | SQLiのみに限定、#17/#18分離、Test List 12件 |
| plan-review v2 | Done | Critical 6件検出 |
| PLAN v3 | Done | Phase構成、データフロー、安全対策詳細化、Test List 14件 |
| plan-review v3 | Done | Critical 2件検出（軽微） |
| PLAN v4 | Done | 0.0.0.0削除、forbidden list拡張 |
| RED | Done | 14テスト作成、13 FAIL / 1 PASS |
| GREEN | Done | 14 PASS / 0 FAIL |
| REFACTOR | Done | 変更不要（構造一貫性OK） |
| REVIEW | Done | code-review実行、2件修正（Limitations記載、#コメント追加） |
| COMMIT | - | |
