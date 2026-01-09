# Cycle: wordpress-attacker

| Item | Value |
|------|-------|
| Issue | #33 |
| Phase | DONE |
| Created | 2026-01-09 09:18 |

## Environment

| Tool | Version |
|------|---------|
| Node.js | v22.17.0 |

## Goal

WordPress固有の脆弱性を検出するエージェントを新規作成する。

## Background

From Issue #33:
- 対象: プラグイン/テーマの脆弱性パターン、wp-config.php設定不備、REST API、ユーザー列挙、XML-RPC
- OWASP: 複数カテゴリ (A01, A03, A05, A07)

## Scope

From Issue #33:
- [ ] agents/wordpress-attacker.md 作成
- [ ] プラグイン/テーマ用パターン定義
- [ ] wp-config.php チェックリスト
- [ ] テストスクリプト作成

## PLAN

### Design

```
wordpress-attacker.md
├── Detection Targets (SQLi, XSS, LFI, Privilege Escalation, Misconfig)
├── WordPress-Specific Patterns ($wpdb, hooks, REST API)
├── Dangerous Patterns (正規表現)
├── Safe Patterns (誤検知除外)
├── wp-config.php Checklist
├── Output Format (vulnerability_class: wordpress-*)
└── Severity Criteria
```

### Vulnerability Categories

| Category | Type | OWASP |
|----------|------|-------|
| wp-sqli | $wpdb->query without prepare | A03:2021 Injection |
| wp-xss | echo $_GET/$_POST without esc_* | A03:2021 Injection |
| wp-lfi | include/require with user input | A03:2021 Injection |
| wp-privilege | Missing current_user_can | A01:2021 Broken Access Control |
| wp-config | Debug enabled, weak keys | A05:2021 Security Misconfiguration |
| wp-rest-api | Missing permission_callback | A01:2021 Broken Access Control |
| wp-xmlrpc | XML-RPC enabled without restriction | A05:2021 Security Misconfiguration |
| wp-user-enum | Author enumeration via REST/feed | A07:2021 Identification Failures |

### Dangerous Patterns

| Category | Pattern | Risk |
|----------|---------|------|
| SQLi | `$wpdb->query("...{$var}")` | prepared文なしのSQL実行 |
| SQLi | `$wpdb->get_results("...$_")` | ユーザー入力の直接連結 |
| XSS | `echo $_GET['...']` | エスケープなしの出力 |
| XSS | `echo $_POST['...']` | エスケープなしの出力 |
| LFI | `include($_GET['...'])` | ユーザー入力によるファイル読込 |
| Privilege | `add_action('wp_ajax_...'` without `current_user_can` | 権限チェック欠如 |
| REST API | `permission_callback => '__return_true'` | 認可なしのAPI公開 |

### Safe Patterns (除外)

| Pattern | Reason |
|---------|--------|
| `$wpdb->prepare()` | プリペアドステートメント使用 |
| `esc_html()`, `esc_attr()`, `wp_kses()` | 適切なエスケープ |
| `sanitize_text_field()`, `absint()` | 入力サニタイズ |
| `current_user_can()` | 権限チェックあり |
| `permission_callback => function` | カスタム認可関数 |

### wp-config.php Checklist

| Setting | Secure Value | Risk |
|---------|--------------|------|
| WP_DEBUG | false (production) | デバッグ情報漏洩 |
| DISALLOW_FILE_EDIT | true | 管理画面からのファイル編集禁止 |
| AUTH_KEY etc. | Unique values | セッションハイジャック防止 |
| DB_PASSWORD | Strong password | DB不正アクセス |
| table_prefix | Non-default | SQLi攻撃難化 |

### CWE Mapping

| Category | CWE |
|----------|-----|
| wp-sqli | CWE-89: SQL Injection |
| wp-xss | CWE-79: Cross-site Scripting |
| wp-lfi | CWE-98: PHP File Inclusion |
| wp-privilege | CWE-862: Missing Authorization |
| wp-config | CWE-16: Configuration |
| wp-rest-api | CWE-862: Missing Authorization |
| wp-xmlrpc | CWE-16: Configuration |
| wp-user-enum | CWE-200: Information Exposure |

NOTE: 既存injection-attacker/xss-attackerとの関係
- injection-attacker: 汎用SQLi/CMDi検出
- xss-attacker: 汎用XSS検出
- wordpress-attacker: WordPress固有パターン ($wpdb, esc_*, wp_ajax等)

### Files to Create/Modify

| File | Changes |
|------|---------|
| plugins/redteam-core/agents/wordpress-attacker.md | 新規作成 |
| scripts/test-wordpress-attacker.sh | テストスクリプト |

## Test List

### TODO

### WIP

### DONE
- [x] TC-01: [正常系] $wpdb SQLi検出
- [x] TC-02: [正常系] echo XSS検出
- [x] TC-03: [正常系] include LFI検出
- [x] TC-04: [正常系] wp_ajax権限チェック欠如検出
- [x] TC-05: [正常系] REST API permission_callback検出
- [x] TC-06: [正常系] wp-config.php WP_DEBUG検出
- [x] TC-07: [境界値] Safe Pattern除外 (prepare, esc_html)
- [x] TC-08: [エッジケース] 複数脆弱性タイプ混在
- [x] TC-09: [異常系] 対象ファイルなし

## REVIEW

### quality-gate Results

| Agent | Score | Status |
|-------|-------|--------|
| Correctness | 45 | PASS |
| Performance | 35 | PASS |
| Security | 35 | PASS |
| Guidelines | 35 | PASS |

**Max Score: 45 (PASS)**

### Optional Improvements (Applied)

- [x] wp-xmlrpc / wp-user-enum の具体的な検出パターン追加
- [x] $wpdb->insert/update/delete パターン追加
- [x] WP_DEBUGパターンの精度向上 (define関数形式)
- [x] register_rest_route の negative lookahead 修正
- [x] unserialize() 脆弱性パターン追加 (wp-deserialize)

## Notes

- v2.2 マイルストーン
- 複数OWASPカテゴリにまたがる (A01 Broken Access Control, A03 Injection, A05 Security Misconfiguration, A07 Identification and Authentication Failures)
