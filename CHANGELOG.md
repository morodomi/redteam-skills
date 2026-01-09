# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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

### v2.3 - E2E検証拡張 (Planned)
- e2e-sqli: SQLi E2Eテスト生成 (#34)
- e2e-ssti: SSTI E2Eテスト生成 (#35)
- dynamic全対応: 全attackerにdynamicオプション追加 (#36)

### v3.0 - レポート強化 (Planned)
- CVSS自動計算: CVSS 4.0スコア自動算出 (#37)
- レポート品質向上: エグゼクティブサマリ、改善提案詳細化 (#38)
- PDF出力: 客先提出可能なPDFレポート (#39)
