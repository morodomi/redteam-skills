# Agent Guide

redteam-skillsで利用可能な18個のエージェントの使い分けガイド。

## Agent List

| # | Agent | 用途 | 検出対象 | OWASP |
|---|-------|------|----------|-------|
| 1 | recon-agent | 偵察・情報収集 | エンドポイント、フレームワーク | - |
| 2 | injection-attacker | インジェクション検出 | SQL/NoSQL/Command/LDAP Injection | A03:2021 |
| 3 | auth-attacker | 認証脆弱性検出 | 認証バイパス、JWT脆弱性、セッション管理 | A07:2021 |
| 4 | xss-attacker | XSS検出 | Reflected/Stored/DOM-based XSS | A03:2021 |
| 5 | api-attacker | API脆弱性検出 | BOLA/BFLA/Mass Assignment | A01:2021 |
| 6 | file-attacker | ファイル操作脆弱性検出 | Path Traversal、LFI/RFI | A01:2021 |
| 7 | ssrf-attacker | SSRF検出 | SSRF、クラウドメタデータアクセス | A10:2021 |
| 8 | csrf-attacker | CSRF検出 | CSRF、Cookie属性不備 | A01:2021 |
| 9 | ssti-attacker | テンプレートインジェクション検出 | Blade/Jinja2/Twig/EJS SSTI | A03:2021 |
| 10 | xxe-attacker | XXE検出 | XML External Entity Injection | A05:2021 |
| 11 | wordpress-attacker | WordPress固有脆弱性検出 | プラグイン脆弱性、設定不備 | - |
| 12 | crypto-attacker | 暗号脆弱性検出 | 弱い暗号、ハードコード秘密鍵 | A02:2021 |
| 13 | error-attacker | エラー処理脆弱性検出 | 情報漏洩、不適切な例外処理 | A05:2021 |
| 14 | dynamic-verifier | 動的検証 | SQLi/XSS実行時検証 | - |
| 15 | sca-attacker | 依存関係脆弱性検出 | 既知の脆弱性を持つライブラリ | A06:2021 |
| 16 | dast-crawler | URL自動発見 | Playwrightベースのクローリング | - |
| 17 | false-positive-filter | 誤検知除外 | 検出結果のフィルタリング | - |
| 18 | attack-scenario | 攻撃シナリオ生成 | 複合攻撃パターンの提案 | - |

## Framework Matrix

フレームワーク別の推奨エージェント。

| Framework | 必須 | 推奨 | オプション |
|-----------|------|------|------------|
| **Laravel/PHP** | injection, xss, csrf, auth | file, ssti, crypto | api, error |
| **Django/Flask** | injection, xss, ssti, auth | csrf, file | api, ssrf |
| **Express/Node** | injection, xss, api | ssrf, auth | csrf, error |
| **WordPress** | wordpress-attacker, file, auth | injection, xss | csrf |
| **API only** | api, auth, injection | ssrf, crypto | error |
| **Spring Boot** | injection, auth, api | xxe, file | crypto |

## Agent Details

### recon-agent

**用途**: スキャン前の偵察フェーズ。対象のエンドポイント列挙、使用フレームワーク特定、攻撃優先度付けを行う。

**検出対象**:
- ルーティング定義からのエンドポイント抽出
- フレームワーク・バージョン特定
- 認証が必要なエンドポイントの識別

**使用タイミング**: security-scanの最初に自動実行。手動実行も可能。

---

### injection-attacker

**用途**: SQLインジェクション、コマンドインジェクションなどのインジェクション系脆弱性を検出。

**検出対象**:
- Error-based SQLi
- Blind SQLi
- Command Injection
- LDAP Injection
- NoSQL Injection

**使用タイミング**: データベースやシェルコマンドを扱うコードがある場合。

---

### auth-attacker

**用途**: 認証・認可の脆弱性を検出。

**検出対象**:
- 認証バイパス
- JWT署名検証不備
- セッション固定
- パスワードリセット脆弱性
- 権限昇格

**使用タイミング**: ログイン機能、認証が必要なエンドポイントがある場合。

---

### xss-attacker

**用途**: クロスサイトスクリプティング脆弱性を検出。

**検出対象**:
- Reflected XSS
- Stored XSS
- DOM-based XSS

**使用タイミング**: ユーザー入力を表示する画面がある場合。

---

### api-attacker

**用途**: REST API固有の脆弱性を検出。

**検出対象**:
- BOLA (Broken Object Level Authorization)
- BFLA (Broken Function Level Authorization)
- Mass Assignment
- Excessive Data Exposure
- Rate Limiting不備

**使用タイミング**: REST APIを提供している場合。

---

### file-attacker

**用途**: ファイル操作に関する脆弱性を検出。

**検出対象**:
- Path Traversal
- Local File Inclusion (LFI)
- Remote File Inclusion (RFI)
- 任意ファイルアップロード

**使用タイミング**: ファイルアップロード、ファイル読み込み機能がある場合。

---

### ssrf-attacker

**用途**: Server-Side Request Forgery脆弱性を検出。

**検出対象**:
- 内部ネットワークアクセス
- クラウドメタデータアクセス (169.254.169.254)
- ファイルスキーム悪用

**使用タイミング**: URLを受け取って外部リソースにアクセスする機能がある場合。

---

### csrf-attacker

**用途**: Cross-Site Request Forgery脆弱性を検出。

**検出対象**:
- CSRFトークン不備
- SameSite Cookie属性不備
- Refererチェック不備

**使用タイミング**: 状態変更を伴うPOST/PUT/DELETE操作がある場合。

---

### ssti-attacker

**用途**: Server-Side Template Injection脆弱性を検出。

**検出対象**:
- Blade (Laravel)
- Jinja2 (Flask/Django)
- Twig (Symfony)
- EJS (Express)

**使用タイミング**: テンプレートエンジンを使用している場合。

---

### xxe-attacker

**用途**: XML External Entity Injection脆弱性を検出。

**検出対象**:
- XXE（外部エンティティ参照）
- Billion Laughs Attack
- SSRF via XXE

**使用タイミング**: XMLパース処理がある場合。

---

### wordpress-attacker

**用途**: WordPress固有の脆弱性を検出。

**検出対象**:
- 脆弱なプラグイン・テーマ
- wp-config.php露出
- XML-RPC悪用
- ユーザー列挙
- ファイルエディタ有効化

**使用タイミング**: WordPressサイトを監査する場合。

---

### crypto-attacker

**用途**: 暗号化・設定に関する脆弱性を検出。

**検出対象**:
- 弱い暗号アルゴリズム (MD5, SHA1, DES)
- ハードコードされた秘密鍵
- デバッグモード有効
- 安全でないランダム生成

**使用タイミング**: 暗号化処理、認証処理がある場合。

---

### error-attacker

**用途**: エラー処理に関する脆弱性を検出。

**検出対象**:
- スタックトレース露出
- 詳細なエラーメッセージ
- 例外の握りつぶし
- ログへの機密情報出力

**使用タイミング**: 本番環境のエラー処理を監査する場合。

---

### dynamic-verifier

**用途**: 静的解析で検出した脆弱性を動的に検証。

**検出対象**:
- SQLi（実際のエラーレスポンス確認）
- XSS（実際のスクリプト実行確認）

**使用タイミング**: `--dynamic`オプション指定時に自動実行。

---

### sca-attacker

**用途**: 依存関係の既知脆弱性を検出。

**検出対象**:
- npm/pip/composer パッケージの既知CVE
- OSV Database照合

**使用タイミング**: サードパーティライブラリを使用している場合。

---

### dast-crawler

**用途**: Webアプリケーションのエンドポイントを自動発見。

**検出対象**:
- Playwrightを使用した動的クローリング
- SPAのルート発見
- フォーム・リンクの収集

**使用タイミング**: 対象URLが分からない場合の事前調査。

---

### false-positive-filter

**用途**: 検出結果から誤検知を除外。

**検出対象**:
- テストコード内の検出
- サニタイズ済み入力の誤検知
- フレームワーク保護済みの誤検知

**使用タイミング**: security-scan後に自動実行。手動でも実行可能。

---

### attack-scenario

**用途**: 検出した脆弱性を組み合わせた攻撃シナリオを生成。

**検出対象**:
- 複合攻撃チェーン
- 権限昇格パス
- データ窃取シナリオ

**使用タイミング**: 複数の脆弱性が検出された場合にリスク評価として使用。
