# Generate E2E Reference

## JSON Input Validation

入力JSONは以下のスキーマに従う必要がある。

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| metadata | object | スキャンメタデータ |
| metadata.scan_id | string | スキャンID (UUID) |
| vulnerabilities | object | 脆弱性サマリー |
| details | array | 脆弱性詳細リスト |

### Validation Errors

| Error | Description | Resolution |
|-------|-------------|------------|
| Invalid JSON | JSONパースエラー | JSONフォーマットを確認 |
| Missing metadata | metadataフィールドがない | security-scan出力を使用 |
| Missing details | detailsフィールドがない | security-scan出力を使用 |
| Invalid schema | 必須フィールドの欠落 | スキーマに従ったJSONを入力 |

### Error Handling

```
Error: Invalid JSON input
  → JSONファイルのフォーマットを確認してください

Error: Missing required field 'metadata'
  → security-scanの出力JSONを使用してください

Error: File already exists (use --force to overwrite)
  → --forceオプションで上書き、または手動で削除
```

## Template Variables

### playwright.config.ts.tmpl

| Variable | Description | Example |
|----------|-------------|---------|
| {{BASE_URL}} | ターゲットURL | http://localhost:8000 |

### base-test.ts.tmpl

| Variable | Description | Example |
|----------|-------------|---------|
| {{VULN_TYPE}} | 脆弱性タイプ | xss |
| {{ENDPOINT}} | テスト対象エンドポイント | /users/{id} |
| {{PAYLOAD}} | テストペイロード | <script>alert(1)</script> |

## Output Files

### playwright.config.ts

Playwright設定ファイル。以下を含む:

- baseURL設定
- テストディレクトリ設定
- レポーター設定
- タイムアウト設定

### <vuln-type>.spec.ts

脆弱性タイプ別のテストファイル。以下を含む:

- テストケース定義
- ペイロード注入
- 結果検証

## Supported Vulnerability Types

| Type | Test Strategy |
|------|---------------|
| xss | DOM検証、レスポンスチェック |
| csrf | トークン検証、リクエスト送信 |
| sqli | エラーメッセージ検証 |
| auth-bypass | 認証状態検証 |

## Playwright Version

推奨バージョン: ^1.40.0

```json
{
  "devDependencies": {
    "@playwright/test": "^1.40.0"
  }
}
```
