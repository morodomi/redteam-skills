# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [4.1.0] - 2026-02-05

### Added
- Auto Phase Transition: security-scan完了後に自動でattack-report呼び出し (#54)
  - デフォルトで有効
  - `--no-auto-report` でスキップ可能
  - `--auto-e2e` でE2Eテスト自動生成も可能
- Parallel Scan Enhancement: 5エージェントから13エージェント並列実行に拡張 (#55)
  - Core Agents (5): injection, xss, crypto, error, sca
  - Extended Agents (8): auth, api, file, ssrf, csrf, ssti, xxe, wordpress
  - `--full-scan` オプションで全13エージェント実行

## [4.0.0] - 2026-01-22

### Added
- context-review: 対話型コンテキストレビュースキル (#44)
  - ビジネスロジックの曖昧な項目をユーザーに質問して確認
  - 4カテゴリの質問（auth-intent, error-handling, data-exposure, business-logic）
  - resolution値による判定（excluded, confirmed, needs_review）
  - security-scan, false-positive-filterとの連携

## [3.2.0] - 2026-01-21

### Added
- sca-attacker: 依存関係脆弱性検出エージェント (#40)
  - OSV API連携による脆弱性データベース照会
  - package.json, composer.json, requirements.txt対応
  - CWE-1395 / A06:2021 Vulnerable Components
- sca-scan: security-scanへのSCA統合 (#41)
  - SCAN PhaseにSCA自動実行を追加
  - `--no-sca` オプションでスキップ可能
- dast-crawler: Playwright URL自動発見エージェント (#42)
  - JSで動的生成されるURLを検出
  - フォーム・リンク自動探索
- attack-scenario: 攻撃シナリオ自動生成エージェント (#43)
  - 脆弱性チェーン分析
  - 攻撃ステップと影響の可視化
- false-positive-filter: 誤検知自動除外エージェント (#45)
  - パターンベースの誤検知除外
  - コンテキストベースの判定
  - 除外理由の記録

### Changed
- sca-attacker: OSV API改善 (#46)
  - Exponential backoff実装（3回リトライ: 2s, 4s, 8s）
  - レスポンスフォーマット詳細化

## [3.1.0] - 2026-01-16

### Changed
- **BREAKING**: 出力スキーマ統一 (#47)
  - `vulnerabilities` (サマリ) → `summary` にリネーム
  - `details` (配列) → `vulnerabilities` にリネーム
  - 既存パターン（false-positive-filter, attack-scenario, sca-attacker）に統一
  - 影響ファイル: security-scan, attack-report, generate-e2e, dynamic-verifier, README
- vulnerability_class命名規則統一 (#48)
  - `sqli` → `sql-injection` に統一
  - 命名規則ドキュメント追加

## [3.0.0] - 2026-01-11

### Added
- CVSS自動計算: 新規脆弱性タイプ対応 (#37)
  - ssti (9.3), xxe (8.2), object-injection (9.3) CVSSマッピング追加
  - ssti-attacker, xxe-attacker, wordpress-attacker Agent to Type Mapping追加
  - CWE-1336, CWE-611, CWE-502 マッピング追加
- レポート品質向上 (#38)
  - Executive Summary: リスク評価、優先対応Top3、影響システム一覧
  - Remediation Templates: Laravel, Django, Express, Flask対応
  - Glossary: 12セキュリティ用語の解説

## [2.3.0] - 2026-01-09

### Added
- e2e-sqli: SQLi E2Eテスト生成 (#34)
  - Error-based, Union-based, Boolean-blind, Time-blind対応
  - 5つのテストパターン（認証付き含む）
- e2e-ssti: SSTI E2Eテスト生成 (#35)
  - Jinja2, Twig, Blade, ERB, Freemarker対応
  - Universal/Engine-specificテストパターン
- dynamic-verifier拡張 (#36)
  - Auth: 認証バイパス検証 (--enable-dynamic-auth)
  - CSRF: CSRFトークン検証 (--enable-dynamic-csrf)
  - SSRF: コールバック検証 (--enable-dynamic-ssrf)
  - File: ファイル読取検証 (--enable-dynamic-file)

## [2.2.0] - 2026-01-09

### Added
- ssti-attacker: Server-Side Template Injection検出 (#31)
  - Jinja2, Twig, Blade, ERB, Freemarker, Velocity, Thymeleaf, Smarty, Pebble対応
  - CWE-1336 / A03:2021 Injection
- xxe-attacker: XML External Entity Injection検出 (#32)
  - PHP, Python, Java, Node.js, Go対応
  - CWE-611 / A05:2021 Security Misconfiguration
- wordpress-attacker: WordPress固有の脆弱性検出 (#33)
  - SQLi ($wpdb), XSS, LFI, Privilege Escalation, Misconfiguration
  - REST API permission_callback, XML-RPC, User Enumeration, Object Injection
  - CWE-89/79/98/862/16/203/502対応

### Changed
- e2e-ssrf: waitForTimeout(3000)をexpect.poll()に改善 (#29)
  - Playwright推奨パターン適用
  - テスト実行時間短縮（早期終了）

## [2.1.0] - 2026-01-08

### Added
- e2e-auth: 認証バイパスE2Eテスト生成 (#25)
  - unauthenticated-access, privilege-escalation, session-fixation, idor対応
- e2e-ssrf: SSRF E2Eテスト生成 (#26)
  - ローカルコールバックサーバー方式
  - ssrf, blind-ssrf, partial-ssrf対応
- xss-attacker: DOM/Stored XSS検出対応 (#28)
  - DOM XSSパターン (innerHTML, outerHTML, document.write, eval, jQuery)
  - Stored XSSパターン (Laravel, Django, Express)
  - Output Formatにdom/storedタイプ追加

## [2.0.0] - 2026-01-06

### Added
- e2e-generator-base: E2Eテスト生成基盤 (#22)
  - Playwrightベースのテストテンプレート
  - generate-e2eスキル
- e2e-xss: XSS E2Eテスト生成 (#23)
  - Reflected/DOM/Stored XSSテストテンプレート
- e2e-csrf: CSRF E2Eテスト生成 (#24)
  - トークン検証、SameSite Cookie検証

## [1.2.0] - 2025-12-25

### Added
- dynamic-verifier: XSS動的検証機能 (#17)
  - Reflected XSSペイロード検証
  - HTMLエンコード検出
  - `--enable-dynamic-xss` フラグ

### Changed
- レート制限を2秒間隔に統一（SQLi/XSS共通）

## [1.1.0] - 2025-12-25

### Added
- vulnerability_class/cwe_idフィールド対応 (#16)
- attack-report: vulnerability_class活用レポート (#21)
- injection-attacker: Command Injection対応 (#20)
- csrf-attacker: CSRF検出エージェント (#19)

## [1.0.0] - 2025-12-25

### Added
- file-attacker: Path Traversal/LFI/RFI検出
- ssrf-attacker: SSRF/クラウドメタデータ検出
- dynamic-verifier: SQLi動的テスト機能 (#13)
  - `--dynamic` フラグ
  - `--target` URL指定

### Changed
- OWASP Top 10 2021/2025 完全カバレッジ

## [0.2.0] - 2024-12-24

### Added
- auth-attacker: 認証バイパス、JWT脆弱性検出
- api-attacker: BOLA/BFLA/Mass Assignment検出
- attack-report: CVSS 4.0スコア対応
- crypto-attacker: 暗号・設定脆弱性検出
- error-attacker: 例外処理脆弱性検出

## [0.1.0] - 2024-12-24

### Added
- redteam-coreプラグイン基盤
- recon-agent: 偵察・情報収集エージェント
- injection-attacker: SQLインジェクション検出
- xss-attacker: Reflected XSS検出
- security-scan: スキャンワークフロースキル
- attack-report: レポート出力スキル

## Roadmap

### Current Status: v4.0 (Stable)

All planned features have been implemented. See README.md for details.
