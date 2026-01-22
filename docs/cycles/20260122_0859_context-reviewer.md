# Cycle: context-reviewer

| Item | Value |
|------|-------|
| Issue | #44 |
| Phase | DONE |
| Created | 2026-01-22 08:59 |

## Environment

| Tool | Version |
|------|---------|
| Claude Code | Plugins |

## Goal

LLMを活用してビジネスコンテキストを理解し、パターンマッチでは判断できない脆弱性を検出するエージェントを作成する。

## Background

From Issue #44:
- パターンベースの静的解析では検出できない脆弱性がある
- ビジネスコンテキストの理解が必要な判断がある
- 例: 「このAPIは認証不要で正しい？」「この例外処理で問題ない？」

### 期待される機能

1. **ビジネスコンテキストの理解**
   - CLAUDE.md/README.mdからプロジェクト概要を取得
   - OpenAPI/GraphQLスキーマを解析

2. **設計意図に基づく判断**
   - 認証・認可の妥当性評価
   - 例外処理の適切性判断

3. **LLMへの判断委譲**
   - パターンで判断できない場合にLLMが文脈を理解して判断

### 判断例

| ケース | 判断 |
|--------|------|
| 認証不要のAPI | 公開API/内部APIを判断 |
| 例外処理 | 設計意図を理解 |
| 価格計算ロジック | ドメイン知識に基づく判断 |

## Scope

From Issue #44:
- [ ] context-reviewer エージェント作成
- [ ] CLAUDE.md/README.mdからコンテキスト取得
- [ ] OpenAPI/GraphQLスキーマ解析
- [ ] 認証・認可の妥当性評価
- [ ] 出力形式定義

## PLAN

### Background

既存のattackerエージェントはパターンマッチで脆弱性を検出するが、以下のケースは判断困難:

| ケース | 問題 |
|--------|------|
| 認証不要API | 意図的に公開なのか、設計ミスなのか判断不能 |
| 例外処理 | 適切なエラーハンドリングか判断不能 |
| ビジネスロジック | ドメイン知識なしに妥当性判断不能 |

### 設計方針の転換

| 当初案 | 修正案 |
|--------|--------|
| LLMが自動判断 | **ユーザーに質問して確認** |
| エージェント | **対話型スキル** |
| 非対話 | **Claude Codeの対話機能を活用** |

### Design

#### 位置づけ

```
security-scan (RECON → SCAN → REPORT)
    ↓
/context-review (対話型スキル) ← NEW
    ↓
  ユーザーに質問
    ↓
  回答を反映して最終判定
    ↓
attack-report
```

#### 他スキルとの比較

| スキル | 役割 | 対話 |
|--------|------|------|
| security-scan | 自動スキャン | No |
| false-positive-filter | パターン除外 | No |
| **context-review** | **曖昧項目の確認** | **Yes** |
| attack-report | レポート生成 | No |

#### ワークフロー

```
1. ANALYZE Phase
   - security-scan結果を読み込み
   - 曖昧な検出項目を抽出

2. QUESTION Phase
   - ユーザーに質問を提示
   - 選択肢形式で回答を取得

3. RESOLVE Phase
   - 回答を反映して判定確定
   - 結果をJSON出力
```

#### 質問カテゴリ

| Category | 質問例 |
|----------|--------|
| auth-intent | 「このAPIは認証不要で正しいですか？」 |
| error-handling | 「本番環境でスタックトレースは無効ですか？」 |
| data-exposure | 「このレスポンスに機密情報は含まれますか？」 |
| business-logic | 「この計算ロジックは仕様通りですか？」 |

#### 質問フォーマット

```markdown
## Context Review

スキャン結果を確認しました。以下について確認が必要です：

### Q1: 認証不要API [AUTH-INTENT]
ファイル: app/Http/Controllers/Api/StatusController.php:15
検出: 認証ミドルウェアなし

このAPIは認証不要で正しいですか？

1. はい、公開APIです（脆弱性から除外）
2. いいえ、認証が必要です（脆弱性として報告）
3. わからない（手動レビュー推奨）

### Q2: エラー情報露出 [ERROR-HANDLING]
ファイル: app/Exceptions/Handler.php:45
検出: スタックトレース出力

本番環境でも有効ですか？

1. 開発環境のみ（APP_DEBUG=falseで無効）
2. 本番でも有効（脆弱性として報告）
3. わからない
```

#### 出力形式

```json
{
  "metadata": {
    "review_id": "<uuid>",
    "reviewed_at": "<timestamp>",
    "skill": "context-review"
  },
  "questions": [
    {
      "id": "Q1",
      "category": "auth-intent",
      "file": "app/Http/Controllers/Api/StatusController.php",
      "line": 15,
      "question": "このAPIは認証不要で正しいですか？",
      "answer": 1,
      "resolution": "excluded",
      "reason": "ユーザー確認: 公開API"
    }
  ],
  "summary": {
    "total_questions": 5,
    "excluded": 3,
    "confirmed_vuln": 1,
    "needs_review": 1
  }
}
```

#### resolution値

| Value | Meaning | 対応 |
|-------|---------|------|
| excluded | 意図的、脆弱性でない | レポートから除外 |
| confirmed | 脆弱性として確定 | レポートに含める |
| needs_review | 判断保留 | 手動レビュー推奨としてマーク |

### Files

```
plugins/redteam-core/skills/context-review/
├── SKILL.md      # スキル定義
└── reference.md  # 質問テンプレート・カテゴリ詳細
```

## Test List

### TODO

(なし)

### WIP

(なし)

### DONE

#### スキル構造
- [x] TC-01: skills/context-review/SKILL.mdが存在する
- [x] TC-02: frontmatterにname, descriptionがある
- [x] TC-03: Usageセクションが存在する

#### ワークフローセクション
- [x] TC-04: Workflowセクションが存在する
- [x] TC-05: ANALYZE Phaseが定義されている
- [x] TC-06: QUESTION Phaseが定義されている
- [x] TC-07: RESOLVE Phaseが定義されている

#### 質問カテゴリ
- [x] TC-08: Question Categoriesセクションが存在する
- [x] TC-09: auth-intentカテゴリが定義されている
- [x] TC-10: error-handlingカテゴリが定義されている
- [x] TC-11: data-exposureカテゴリが定義されている
- [x] TC-12: business-logicカテゴリが定義されている

#### 出力形式
- [x] TC-13: Output Formatセクションが存在する
- [x] TC-14: resolution値(excluded/confirmed/needs_review)が定義されている

#### リファレンス
- [x] TC-15: reference.mdが存在する
- [x] TC-16: 質問テンプレートが定義されている

### GREEN結果

```
Results: 16 passed, 0 failed
```

## REFACTOR

リファクタリング対象なし。

| 項目 | 評価 |
|------|------|
| DRY | OK - 重複なし |
| 構造 | OK - 明確なセクション分け |
| 命名 | OK - 一貫した命名 |
| フォーマット | OK - 他スキルと統一 |

## REVIEW

### Quality Gate Results

| Reviewer | Score | Judgment |
|----------|-------|----------|
| correctness | 35 | PASS |
| security | 25 | PASS |
| guidelines | 15 | PASS |
| performance | 15 | PASS |

**Max Score: 35 → PASS**

### Findings Summary

- correctness: 軽微な改善提案のみ（入力検証の明記、回答0件時の動作等）
- security: 問題なし（マークダウン定義、ローカル実行）
- guidelines: 既存スキルと構造・命名規則が統一
- performance: N/A（実行可能コードではない）

## Notes

- v4.0 (現Roadmap) の主要機能
- false-positive-filter (#45) は実装済み
- LLM活用のため、プロンプト設計が重要
