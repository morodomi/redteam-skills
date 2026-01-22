# Cycle: agent-usage-docs

## Meta

| Item | Value |
|------|-------|
| Issue | #53 |
| Phase | REVIEW |
| Created | 2026-01-22 22:00 |

## Goal

18個のエージェントの使い分けガイド・ワークフロー図・FAQを整備する。

## Environment

- **Distribution**: Claude Code Plugins
- **Reference**: OWASP Top 10, OWASP ASVS, CWE Top 25
- **Current Version**: 4.0.0

## Deliverables

| File | Description |
|------|-------------|
| docs/AGENT_GUIDE.md | フレームワーク別推奨エージェント |
| docs/WORKFLOW.md | ワークフロー図 |
| docs/FAQ.md | よくある質問 |
| README.md | 更新（ドキュメントへのリンク追加） |

## Plan

### docs/AGENT_GUIDE.md
- エージェント一覧表（18個）
- フレームワーク別推奨マトリクス（Laravel/Django/Express/WordPress/API）
- 各エージェントの詳細説明（用途・検出対象・使用タイミング）

### docs/WORKFLOW.md
- 基本ワークフロー図（ASCII）
- フェーズ別説明（RECON→SCAN→ATTACK→REPORT）
- 実行例

### docs/FAQ.md（15項目）
1. 全エージェント実行すべき？
2. 動的検証（dynamic）はいつ使う？
3. E2Eテスト生成のタイミングは？
4. 誤検知が多い場合は？
5. 特定の脆弱性だけ検査したい
6. recon-agentは必須？
7. SCAスキャンの頻度は？
8. CVSSスコアの解釈方法は？
9. レポートのカスタマイズは可能？
10. CI/CDに組み込める？
11. WordPress以外のCMSは対応？
12. APIのみのプロジェクトはどう検査？
13. attack-scenarioの使いどころは？
14. context-reviewとの違いは？
15. 検出されなかった＝安全？

### README.md更新
- ドキュメントセクション追加
- 各ドキュメントへのリンク

## Test List

### AGENT_GUIDE.md
- [ ] TC-01: ファイルが存在する
- [ ] TC-02: 18個のエージェント全てを記載
- [ ] TC-03: フレームワーク別推奨マトリクスを含む
- [ ] TC-04: 各エージェントに用途・検出対象を記載

### WORKFLOW.md
- [ ] TC-05: ファイルが存在する
- [ ] TC-06: ASCII図を含む
- [ ] TC-07: RECON→SCAN→ATTACK→REPORTのフェーズ説明を含む

### FAQ.md
- [ ] TC-08: ファイルが存在する
- [ ] TC-09: 15個以上のQ&Aを含む
- [ ] TC-10: 各回答が具体的（1文以上）

### README.md
- [ ] TC-11: ドキュメントセクションが存在
- [ ] TC-12: AGENT_GUIDE/WORKFLOW/FAQへのリンクを含む

## Progress

| Phase | Status | Note |
|-------|--------|------|
| INIT | Done | 2026-01-22 |
| PLAN | Done | 2026-01-22 |
| RED | Done | 2026-01-22 |
| GREEN | Done | 2026-01-22 |
| REFACTOR | Done | 2026-01-22 |
| REVIEW | Done | 2026-01-22 |
| COMMIT | - | |
