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

### xss.spec.ts.tmpl

| Variable | Description | Example |
|----------|-------------|---------|
| {{VULN_ID}} | 脆弱性ID | XSS-001 |
| {{ENDPOINT}} | テスト対象エンドポイント | /search |
| {{PARAM_NAME}} | URLパラメータ名（Reflected用） | q |
| {{INPUT_SELECTOR}} | 入力要素セレクタ（DOM/Stored用） | #search-input |
| {{VIEW_ENDPOINT}} | 表示ページ（Stored用） | /comments |

### csrf.spec.ts.tmpl

| Variable | Description | Example |
|----------|-------------|---------|
| {{VULN_ID}} | 脆弱性ID | CSRF-001 |
| {{ENDPOINT}} | テスト対象エンドポイント | /profile/update |
| {{AUTH_ENDPOINT}} | 認証エンドポイント | /login |
| {{AUTH_EMAIL}} | 認証用メールアドレス | test@example.com |
| {{AUTH_PASSWORD}} | 認証用パスワード | password |

### auth.spec.ts.tmpl

| Variable | Description | Example |
|----------|-------------|---------|
| {{VULN_ID}} | 脆弱性ID | AUTH-001 |
| {{AUTH_TYPE}} | 認証タイプ | unauthenticated-access |
| {{ENDPOINT}} | テスト対象エンドポイント | /admin/dashboard |
| {{AUTH_ENDPOINT}} | 認証エンドポイント | /login |
| {{AUTH_EMAIL}} | 認証用メールアドレス | test@example.com |
| {{AUTH_PASSWORD}} | 認証用パスワード | password |
| {{OTHER_USER_ID}} | 他ユーザーID（IDOR用） | 456 |

## XSS Test Types

XSSテストは3タイプに対応: reflected, dom, stored

| Type | Description | Test Strategy |
|------|-------------|---------------|
| reflected | URLパラメータ経由のXSS | URL注入→DOM検証 |
| dom | クライアントサイドでのXSS | DOM操作→スクリプト実行検証 |
| stored | 保存後に表示されるXSS | 保存→表示ページで検証 |

### Empty XSS Vulnerabilities

XSS脆弱性が0件の場合、xss.spec.tsは生成されない。
playwright.config.tsのみが出力される。

## CSRF Test Types

CSRFテストは3タイプに対応: csrf-token-missing, csrf-protection-disabled, samesite-cookie-missing

| Type | Description | Test Strategy |
|------|-------------|---------------|
| csrf-token-missing | CSRFトークンなしでリクエスト成功 | トークンなしPOST→成功検証 |
| csrf-protection-disabled | CSRF保護が無効化されている | 保護なしリクエスト→成功検証 |
| samesite-cookie-missing | SameSite属性が未設定/None | Cookie属性チェック |

### Empty CSRF Vulnerabilities

CSRF脆弱性が0件の場合、csrf.spec.tsは生成されない。
playwright.config.tsのみが出力される。

## Auth Test Types

認証テストは4タイプに対応: unauthenticated-access, privilege-escalation, session-fixation, idor

| Type | Description | Test Strategy |
|------|-------------|---------------|
| unauthenticated-access | 認証なしで保護リソースアクセス | 401/403期待、200=脆弱 |
| privilege-escalation | 一般ユーザーで管理者機能アクセス | 403期待、200=脆弱 |
| session-fixation | ログイン前後のセッションID比較 | ID変化=安全、同一=脆弱 |
| idor | 他ユーザーのリソースアクセス | 403期待、200=脆弱 |

### Empty Auth Vulnerabilities

Auth脆弱性が0件の場合、auth.spec.tsは生成されない。
playwright.config.tsのみが出力される。

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
