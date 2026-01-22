# Context Review Reference

質問テンプレートとカテゴリ詳細。

## Question Templates

### auth-intent (認証意図確認)

```markdown
### Q{n}: 認証不要API [auth-intent]
ファイル: {file}:{line}
検出: {detection_reason}

このAPIは認証不要で正しいですか？

1. はい、公開APIです（脆弱性から除外）
2. いいえ、認証が必要です（脆弱性として報告）
3. わからない（手動レビュー推奨）
```

**トリガー条件:**
- auth-attackerで「Missing Auth Check」検出
- ミドルウェアなしのルート
- @login_required なしのビュー

### error-handling (エラー処理確認)

```markdown
### Q{n}: エラー情報露出 [error-handling]
ファイル: {file}:{line}
検出: {detection_reason}

本番環境でも有効ですか？

1. 開発環境のみ（APP_DEBUG=false等で無効）
2. 本番でも有効（脆弱性として報告）
3. わからない（手動レビュー推奨）
```

**トリガー条件:**
- error-attackerで「Stack Trace Exposure」検出
- デバッグモード関連の設定
- 詳細エラーメッセージ出力

### data-exposure (データ露出確認)

```markdown
### Q{n}: データ露出 [data-exposure]
ファイル: {file}:{line}
検出: {detection_reason}

このレスポンスに機密情報は含まれますか？

1. いいえ、公開情報のみです（脆弱性から除外）
2. はい、機密情報が含まれます（脆弱性として報告）
3. わからない（手動レビュー推奨）
```

**トリガー条件:**
- api-attackerで「Mass Assignment」検出
- レスポンスに全カラム出力
- ユーザー情報の過剰露出

### business-logic (ビジネスロジック確認)

```markdown
### Q{n}: ビジネスロジック [business-logic]
ファイル: {file}:{line}
検出: {detection_reason}

この処理は仕様通りですか？

1. はい、仕様通りです（脆弱性から除外）
2. いいえ、問題があります（脆弱性として報告）
3. わからない（手動レビュー推奨）
```

**トリガー条件:**
- 価格計算、権限チェック等のロジック
- パターンマッチで判断困難な項目
- ドメイン知識が必要な判断

## Category Priority

質問の優先順位:

| Priority | Category | Reason |
|----------|----------|--------|
| 1 | auth-intent | 認証漏れは重大な脆弱性 |
| 2 | data-exposure | 情報漏洩リスク |
| 3 | error-handling | 情報収集に悪用可能 |
| 4 | business-logic | ドメイン固有の問題 |

## Answer Mapping

| 回答 | resolution | 説明 |
|------|------------|------|
| 1 (はい/公開) | excluded | 意図的な設計として除外 |
| 2 (いいえ/問題) | confirmed | 脆弱性として確定 |
| 3 (わからない) | needs_review | 手動レビュー推奨 |

## Context Sources

質問生成時に参照するコンテキスト:

| Source | Purpose |
|--------|---------|
| CLAUDE.md | プロジェクト概要、設計方針 |
| README.md | 機能概要、公開API一覧 |
| openapi.yaml | APIスキーマ、認証要件 |
| routes/*.php | ルート定義、ミドルウェア |

## Best Practices

1. **質問は具体的に**: ファイル名、行番号、検出理由を明示
2. **選択肢は明確に**: 各選択肢の結果を明示
3. **1問ずつ確認**: ユーザーの負担を軽減
4. **コンテキスト提供**: 判断に必要な情報を提示
