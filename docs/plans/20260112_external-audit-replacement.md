# External Audit Replacement Plan

| Item | Value |
|------|-------|
| Created | 2026-01-12 |
| Status | DRAFT |
| Goal | 非クリティカルシステム向けのAIセキュリティ診断基盤 |
| Review | WARN → 前提修正後 PASS (2026-01-12) |

## Assumptions (前提条件)

| 項目 | 値 |
|------|-----|
| 開発費 | 0（オープンソース開発） |
| 対象 | 内製システム、ソースコード完全保有 |
| 責任 | 対象システム保有会社が最終責任 |
| 用途 | 決済・重要情報を持たない非クリティカルシステム |
| コンプライアンス | PMが判断（外部診断要否はPM責任） |
| 配布形態 | オープンソース Agent Skills |

## Background

### 現状の課題

- 非クリティカルシステムにも外部診断を依頼している
- 外部診断は年1-2回（リアルタイム性なし）
- 生成AIの能力で診断基準・ワークフローを与えれば同等の結果が得られる可能性

### 目標

1. 生成AIに診断基準とワークフローを与えて自動診断
2. 人間の専門家と同等品質のレポート出力
3. 継続的なセキュリティ検証（CI/CD統合可能）

## Gap Analysis

### 現状のカバレッジ（実態調査後）

| 領域 | 現状 | 外部診断 | ギャップ |
|------|------|----------|----------|
| SAST | 100% | 100% | なし |
| DAST | **80%** | 100% | 20% (クローラーのみ) |
| SCA | **0%** | 80% | **80%** (最大ギャップ) |
| インフラ | 0% | 90% | 90% (スコープ外) |
| ビジネスロジック | 0% | 70% | 70% |
| 認証/認可 | **70%** | 90% | 20% |
| API | **60%** | 85% | 25% |

### 既存実装の実態

| 機能 | 実装状況 | エージェント/スキル |
|------|----------|-------------------|
| SAST (13種) | ✅ 完了 | injection/xss/auth/api/crypto/error/file/ssrf/csrf/ssti/xxe/wordpress-attacker |
| DAST (6種) | ✅ 完了 | dynamic-verifier (SQLi/XSS/Auth/CSRF/SSRF/File) |
| E2E生成 | ✅ 完了 | generate-e2e |
| レポート | ✅ 完了 | attack-report (CVSS/CWE/OWASP/Executive Summary) |
| **SCA** | ❌ 未実装 | なし |
| **クローラー** | ❌ 未実装 | (recon-agentは静的解析のみ) |
| **攻撃シナリオ** | ❌ 未実装 | (レポートに含まれていない) |

### 外部診断で検出される典型的な脆弱性

| カテゴリ | 割合 | 現状対応 |
|----------|------|----------|
| SQLi/XSS/Injection | 25% | ✅ 対応済 (SAST+DAST) |
| 認証/セッション | 20% | ✅ 対応済 (auth-attacker+dynamic) |
| **依存ライブラリCVE** | 20% | ❌ **未対応** |
| 設定ミス | 15% | ✅ 対応済 (crypto-attacker) |
| ビジネスロジック | 10% | △ 部分対応 |
| その他 | 10% | ✅ 対応済 |

## Roadmap (Corrected)

### 方針転換

```
当初案: DAST基盤を新規構築
修正後: 既存dynamic-verifierを活かし、真のギャップを埋める

既存実装:
├── SAST: 13エージェント ✅
├── DAST: dynamic-verifier (6種対応) ✅
├── E2E生成: generate-e2e ✅
└── レポート: attack-report (CVSS/Executive Summary) ✅

真のギャップ:
├── SCA: 依存関係脆弱性 ❌
├── クローラー: 動的URL発見 ❌
└── 攻撃シナリオ: 想定攻撃の可視化 ❌
```

### Phase 1: SCA統合 (v4.0) - 1週間 【最優先】

**目標**: 依存関係の脆弱性を検出（外部診断で必ず指摘される項目）

| 機能 | 説明 |
|------|------|
| sca-attacker | 依存関係ファイル解析 + OSV API照合 |
| sca-scan | security-scanへの統合 |

**対象ファイル**:
- package.json / package-lock.json (Node.js)
- composer.json / composer.lock (PHP)
- requirements.txt / Pipfile.lock (Python)
- Gemfile.lock (Ruby)
- go.mod (Go)

**データソース**:
- OSV (Google Open Source Vulnerabilities) - 無料API

```
plugins/redteam-core/agents/
└── sca-attacker.md

plugins/redteam-core/skills/
└── sca-scan/
    └── SKILL.md
```

**期待効果**: 外部診断指摘の20%をカバー

### Phase 2: クローラー (v4.1) - 1-2週間 【中優先】

**目標**: ブラウザベースで動的にURL発見

| 機能 | 説明 |
|------|------|
| dast-crawler | Playwright MCPでサイトクロール |
| endpoint-discovery | JSで生成されるエンドポイント発見 |

**実装方針**:
- recon-agent (静的) + dast-crawler (動的) の併用
- 発見したURLをdynamic-verifierに渡す

```
plugins/redteam-core/agents/
└── dast-crawler.md
```

**期待効果**: 静的解析で見逃すエンドポイントをカバー

### Phase 3: 攻撃シナリオ生成 (v4.2) - 1週間 【中優先】

**目標**: 検出脆弱性から具体的な攻撃シナリオを生成

| 機能 | 説明 |
|------|------|
| attack-scenario | 脆弱性チェーンの可視化 |
| impact-analysis | 攻撃成功時の影響分析 |

**出力例**:
```markdown
## 攻撃シナリオ: 管理者権限奪取

1. SQLI-001 (SQLi) でユーザー一覧を取得
2. AUTH-002 (弱いパスワードハッシュ) でパスワードをクラック
3. 管理者としてログイン
4. 全データにアクセス可能

影響: 顧客情報漏洩、サービス停止リスク
```

**期待効果**: レポートの説得力向上

### Phase 4: ビジネスロジックレビュー (v5.0) - 2-3週間 【低優先】

**目標**: LLMによる文脈理解と判断

| 機能 | 説明 |
|------|------|
| context-reviewer | ビジネスコンテキスト理解 |
| false-positive-filter | 誤検知の自動除外 |

**例**:
- 「このAPIは認証不要で正しい？」→ 公開API/内部APIを判断
- 「この例外処理で問題ない？」→ 設計意図を理解

**期待効果**: 誤検知率低減、ビジネスロジック脆弱性の一部検出

### Future: 拡張オプション

以下は必要に応じて追加:

| 機能 | 用途 | 優先度 |
|------|------|--------|
| cloud-auditor | AWS/GCP設定検査 | 低 |
| iac-scanner | Terraform/CloudFormation | 低 |
| oauth-tester | OAuth 2.0/OIDC検証 | 低 |
| compliance-mapper | PCI-DSS/SOC2マッピング | 低 |

## Resource Estimation

### 開発工数 (Corrected)

| Phase | 内容 | 工数 | 累計 |
|-------|------|------|------|
| v4.0 | SCA統合 | 1週間 | 1週間 |
| v4.1 | クローラー | 1-2週間 | 2-3週間 |
| v4.2 | 攻撃シナリオ | 1週間 | 3-4週間 |
| v5.0 | ビジネスロジック | 2-3週間 | 5-7週間 |

**合計**: 5-7週間（約1.5ヶ月）
**最小MVP (v4.0-4.2)**: 3-4週間

### コスト

| 項目 | 値 |
|------|-----|
| 開発費 | 0（オープンソース開発） |
| 外部診断削減 | 年間50-200万円/システム |
| ROI | 即時成立 |

## Risk Assessment

### 技術リスク（ツール側）

| リスク | 影響 | 対策 |
|--------|------|------|
| 検出精度 | 誤検知/検出漏れ | レポートに信頼度明示、人間が最終確認 |
| LLM品質ばらつき | 判断の不安定性 | プロンプト標準化、ルールベース優先 |

### 利用側リスク（注意喚起）

| リスク | 利用者の責任 |
|--------|-------------|
| 規制要件 | PMが外部診断要否を判断 |
| 検出漏れによる被害 | 対象システム保有会社が責任 |
| コンプライアンス | 利用者が自社要件を確認 |

**免責**: このツールはオープンソースとして提供。最終判断・責任は利用者にある。

## Decision Matrix

### 利用判断フロー（PM向け）

```
┌─ 決済機能あり？ ─────────── Yes → 外部診断必須
│
├─ 個人情報大量保持？ ────── Yes → 外部診断推奨
│
├─ B2B顧客から診断報告書要求？ ─ Yes → 外部診断必須
│
└─ 上記すべてNo ──────────── → redteam-skillsで対応可能
```

### 利用シナリオ

| シナリオ | 内容 |
|----------|------|
| 社内ツール | redteam-skillsのみで十分 |
| 非クリティカルWebサービス | redteam-skillsメイン + 必要時外部 |
| クリティカルシステム | 外部診断必須、redteam-skillsは補完 |

## Success Metrics

### v5.0完了時の目標

| 指標 | 目標値 |
|------|--------|
| OWASP Top 10検出率 | 90%以上 |
| 依存関係CVE検出率 | 95%以上 |
| 誤検知率 | 20%以下 |
| 診断実行時間 | 30分以内 |
| レポート品質 | 専門家レベル |

## Next Actions

### v4.0 Issue候補 【最優先】

```
#40 sca-attacker: 依存関係脆弱性検出エージェント
#41 sca-scan: OSV API連携スキル
```

### v4.1 Issue候補

```
#42 dast-crawler: PlaywrightベースのURL自動発見
```

### v4.2 Issue候補

```
#43 attack-scenario: 攻撃シナリオ自動生成
```

### v5.0 Issue候補

```
#44 context-reviewer: ビジネスロジックレビュー
#45 false-positive-filter: 誤検知自動除外
```

## References

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [OWASP ZAP](https://www.zaproxy.org/)
- [Playwright](https://playwright.dev/)
- [OSV](https://osv.dev/)
- [Trivy](https://trivy.dev/)

---

## Plan Review Results (2026-01-12)

### Initial Review (前提修正前)

| Reviewer | Score | Recommendation |
|----------|-------|----------------|
| Scope | 58/100 | WARN |
| Architecture | 35/100 | PASS |
| Risk | 68/100 | WARN |

**主な懸念**: ROI、コンプライアンス、責任範囲

### 前提修正後の再評価

以下の前提が明確化されたため、懸念は解消:

| 懸念 | 解消理由 |
|------|----------|
| ROI 5.6-16年 | 開発費0（オープンソース） |
| コンプライアンス | PMが判断、ツールの責任外 |
| 責任範囲 | 対象システム保有会社が責任 |
| スコープ過大 | 4 Phaseに簡素化、合計5-7週間 |

### 残る技術課題

| 課題 | 対策 |
|------|------|
| dynamic-verifier / dast-* 重複 | 移行計画を明記 |
| recon-agent / dast-crawler 分離 | recon=静的、dast=動的で分離 |

### Updated Verdict

**PASS**: 前提条件が明確化され、企画として承認可能

### 追加レビュー (既存実装の実態調査)

実態調査により、ロードマップを修正:

| 当初案 | 実態 | 修正後 |
|--------|------|--------|
| v4.0 DAST基盤 | dynamic-verifierで実装済み | v4.0 SCA統合 |
| v4.1 SCA | 未実装 | v4.1 クローラー |
| v4.2 AIレビュアー | 未実装 | v4.2 攻撃シナリオ |
| v5.0 統合レポート | Executive Summary実装済み | v5.0 ビジネスロジック |

**修正理由**:
- dynamic-verifier.md (507行) で既にSQLi/XSS/Auth/CSRF/SSRF/Fileの動的検証が実装済み
- attack-report v3.0でExecutive Summaryが実装済み
- 真のギャップはSCA (依存関係) とクローラー (動的URL発見)

**最終判定**: PASS (修正版ロードマップで承認)
