---
name: context-review
description: 対話型コンテキストレビュー。ビジネスロジックの曖昧な項目をユーザーに質問して確認。
---

# Context Review

security-scan結果の曖昧な項目について、ユーザーに質問して確認する対話型スキル。

## Usage

```bash
/context-review                    # 直近のsecurity-scan結果をレビュー
/context-review ./scan-result.json # 指定ファイルをレビュー
```

## Workflow

```
1. ANALYZE Phase
   - security-scan結果を読み込み
   - 曖昧な検出項目を抽出
   - 質問リストを生成

2. QUESTION Phase
   - ユーザーに質問を提示
   - 選択肢形式で回答を取得
   - 1問ずつ確認

3. RESOLVE Phase
   - 回答を反映して判定確定
   - 結果をJSON出力
   - attack-reportへの入力として使用可能
```

## Question Categories

| Category | Description | 質問例 |
|----------|-------------|--------|
| auth-intent | 認証要否の意図確認 | 「このAPIは認証不要で正しいですか？」 |
| error-handling | 例外処理の妥当性 | 「本番環境でスタックトレースは無効ですか？」 |
| data-exposure | データ露出の意図確認 | 「このレスポンスに機密情報は含まれますか？」 |
| business-logic | ビジネスロジック検証 | 「この計算ロジックは仕様通りですか？」 |

## Question Format

各質問は以下の形式で提示:

```markdown
### Q1: 認証不要API [auth-intent]
ファイル: app/Http/Controllers/Api/StatusController.php:15
検出: 認証ミドルウェアなし

このAPIは認証不要で正しいですか？

1. はい、公開APIです（脆弱性から除外）
2. いいえ、認証が必要です（脆弱性として報告）
3. わからない（手動レビュー推奨）
```

## Resolution Values

| Value | Meaning | 対応 |
|-------|---------|------|
| excluded | 意図的、脆弱性でない | レポートから除外 |
| confirmed | 脆弱性として確定 | レポートに含める |
| needs_review | 判断保留 | 手動レビュー推奨としてマーク |

## Output Format

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

## Integration

### With security-scan

```bash
# 1. スキャン実行
/security-scan ./src

# 2. コンテキストレビュー（対話型）
/context-review

# 3. レポート生成
/attack-report
```

### With false-positive-filter

context-reviewはfalse-positive-filterと補完関係:

| スキル | 方式 | 対象 |
|--------|------|------|
| false-positive-filter | パターンマッチ | 明確な誤検知 |
| context-review | ユーザー確認 | 曖昧な項目 |

## Reference

詳細: [reference.md](reference.md)
