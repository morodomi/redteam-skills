# redteam-skills

セキュリティ監査業務をClaude Code Agentで自動化するプラグイン集。

## 技術スタック

- **配布形式**: Claude Code Plugins
- **対象言語**: PHP, Python, JavaScript, TypeScript, Go, Java（監査対象）
- **参照基準**: OWASP Top 10, OWASP ASVS, CWE Top 25

## プロジェクト構造

```
redteam-skills/
├── plugins/
│   └── redteam-core/          # メインプラグイン
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── agents/            # 18 攻撃エージェント
│       │   ├── recon-agent.md
│       │   ├── injection-attacker.md
│       │   ├── xss-attacker.md
│       │   ├── auth-attacker.md
│       │   ├── csrf-attacker.md
│       │   ├── api-attacker.md
│       │   ├── file-attacker.md
│       │   ├── ssrf-attacker.md
│       │   ├── ssti-attacker.md
│       │   ├── xxe-attacker.md
│       │   ├── wordpress-attacker.md
│       │   ├── crypto-attacker.md
│       │   ├── error-attacker.md
│       │   ├── sca-attacker.md
│       │   ├── dast-crawler.md
│       │   ├── dynamic-verifier.md
│       │   ├── false-positive-filter.md
│       │   └── attack-scenario.md
│       ├── skills/            # スキル定義
│       │   ├── security-scan/
│       │   └── attack-report/
│       └── README.md
├── docs/                      # ドキュメント
├── CLAUDE.md
├── CHANGELOG.md
└── README.md
```

## ワークフロー

```
RECON → SCAN → ATTACK → REPORT
```

| Phase | 内容 | エージェント |
|-------|------|-------------|
| RECON | 偵察・情報収集 | recon-agent |
| SCAN | 脆弱性スキャン | 各attacker並行 |
| ATTACK | PoC検証 | 検出した脆弱性に対応 |
| REPORT | レポート生成 | attack-report |

## エージェント一覧

| エージェント | 対象 |
|-------------|------|
| recon-agent | エンドポイント列挙、技術スタック特定 |
| injection-attacker | SQL/NoSQL/Command/LDAP Injection |
| xss-attacker | Reflected/Stored/DOM-based XSS |
| auth-attacker | 認証バイパス、JWT脆弱性 |
| csrf-attacker | CSRF、Cookie属性 |
| api-attacker | BOLA/BFLA/Mass Assignment |
| file-attacker | Path Traversal、LFI/RFI |
| ssrf-attacker | SSRF、クラウドメタデータ |
| ssti-attacker | Server-Side Template Injection |
| xxe-attacker | XML External Entity Injection |
| wordpress-attacker | WordPress固有の脆弱性 |
| crypto-attacker | 弱い暗号、デバッグモード |
| error-attacker | 不適切な例外処理 |
| sca-attacker | 依存関係の脆弱性（OSV API） |
| dast-crawler | PlaywrightベースのURL自動発見 |
| dynamic-verifier | SQLi/XSS/Auth/CSRF/SSRF 動的検証 |
| false-positive-filter | コンテキストベースの誤検知除外 |
| attack-scenario | 脆弱性チェーン分析 |

## 品質基準

| 指標 | 目標 |
|------|------|
| OWASP Top 10 | 全項目カバー |
| 誤検知率 | 10%未満 |
| レポート形式 | JSON + Markdown |

## 開発ルール

1. **静的解析ベース**: コード解析による脆弱性検出
2. **チェックリスト駆動**: OWASP基準に準拠
3. **並行実行**: 複数エージェントの同時スキャン
4. **エビデンス必須**: 検出には必ず根拠を添付

## Claude Code Configuration

| Directory | Content |
|-----------|---------|
| .claude/rules/ | Always-applied rules |
| .claude/hooks/ | Recommended hooks settings |

### Rules

- tdd-workflow.md - TDD cycle enforcement
- quality.md - Quality standards
- security.md - Security checklist
- testing-guide.md - Test guide
- git-safety.md - Git safety rules
- git-conventions.md - Git conventions

### Hooks

- recommended.md - Recommended hooks configuration

## ファイル命名規則

- 設計ドキュメント: `docs/YYYYMMDD_HHMM_内容.md`
- 脆弱性レポート: `reports/YYYYMMDD_プロジェクト名.md`

## Git規約

| Type | 用途 |
|------|------|
| feat | 新エージェント・スキル追加 |
| fix | 誤検知修正、検出ロジック改善 |
| docs | ドキュメント更新 |
| refactor | リファクタリング |
| test | テスト追加 |
| chore | ビルド・設定変更 |

## コマンド

```bash
# セキュリティスキャン実行
/security-scan

# レポート生成
/attack-report
```

## tdd-skillsとの連携

```bash
# 開発時（Blue Team）
/plugin install tdd-core@tdd-skills

# リリース前監査（Red Team）
/plugin install redteam-core@redteam-skills
/security-scan
```

## ロードマップ

### 現在のステータス: v4.2.0（安定版）

計画された全機能を実装済み:

- OWASP Top 10 完全カバレッジ
- 6言語の静的解析
- 動的検証（SQLi, XSS）
- E2Eテスト生成
- SCA（依存関係スキャン）
- CVSS自動計算
- Pre-commit hooks

### ターゲットユーザー

セキュリティに詳しくないが、安全なコードを書きたい開発者。

- セキュリティ専門家は専用ツール（Burp Suite, Semgrep等）を使う
- このプラグインは自動スキャンと修正ガイダンスを提供

## 設計原則

### Claude Skills としての考え方

このプロジェクトはプログラムではなく **Claude Skills** である。

| 観点 | 考え方 |
|------|--------|
| エージェント | プロンプトで定義されたAIの振る舞い |
| スキル | ワークフローを定義したマークダウン |
| 検出ロジック | 正規表現パターン + 文脈理解 |
| 拡張方法 | .mdファイルの追加・編集 |

### 静的解析の限界と対策

| 限界 | 対策 |
|------|------|
| データフロー追跡困難 | パターンマッチ + AIによる文脈判断 |
| ビジネスロジック | チェックリストベースのガイダンス |
| 実行時の振る舞い | E2Eテスト生成で補完 |

## 参考資料

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [anthropics/skills](https://github.com/anthropics/skills)
