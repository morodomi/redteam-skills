---
feature: release-management
cycle: 20260210_2100_release-management
phase: DONE
created: 2026-02-10 21:00
updated: 2026-02-10 21:00
risk: 10 (PASS)
---

# Release Management Improvement

欠落タグの補完とGitHub Releasesの作成。プロジェクトの成熟度を伝え、発見性を向上させる。

## Scope Definition

### In Scope
- [ ] 欠落タグ8個の作成（v0.1.0, v0.2.0, v1.0.0, v1.1.0, v2.0.0, v3.1.0, v3.2.0, v4.1.0）
- [ ] 全15バージョンのGitHub Releases作成（CHANGELOGベース）
- [ ] リリース自動化スクリプトの作成

### Out of Scope
- CHANGELOG.mdの内容変更 (Reason: 既に十分な品質)
- CI/CDパイプライン (Reason: Plugin配布のため不要)

### Files to Change (target: 10 or less)
- scripts/create-release.sh (new) - リリース作成自動化スクリプト

## Environment

| Item | Value |
|------|-------|
| gh | GitHub CLI |
| git | Git |

## Existing Tags

v4.2.0, v4.0.0, v3.0.0, v2.3.0, v2.2.0, v2.1.0, v1.2.0

## Missing Tags

v0.1.0, v0.2.0, v1.0.0, v1.1.0, v2.0.0, v3.1.0, v3.2.0, v4.1.0

## PLAN

### 設計方針

1. **欠落タグ作成**: CHANGELOGの各バージョン最終コミットに軽量タグを作成
2. **GitHub Releases**: 全15バージョンに対してCHANGELOGベースのリリースノートを作成
   - 最新バージョン(v4.2.0)のみ `--latest` 指定、他は `--latest=false`（通知スパム防止）
   - リリースノートはCHANGELOG.mdの該当セクションをそのまま使用
3. **検証スクリプト**: タグとReleasesの整合性を検証するテストスクリプト

### 整合性保証

- 既存タグ7個（v1.2.0, v2.1.0, v2.2.0, v2.3.0, v3.0.0, v4.0.0, v4.2.0）は変更しない
- 新規タグ8個（v0.1.0, v0.2.0, v1.0.0, v1.1.0, v2.0.0, v3.1.0, v3.2.0, v4.1.0）を追加
- 合計15タグ = CHANGELOG.mdの全バージョンと1:1対応
- タグ作成前に `git show <hash> --quiet` で各コミットの存在を確認
- 冪等性: 既存タグはスキップ、既存Releaseはスキップ

### バージョン - コミット対応表

| Version | Commit | Commit Message |
|---------|--------|----------------|
| v0.1.0 | aef0c06 | docs: STATUS更新 (attack-report完了) |
| v0.2.0 | b114e1f | docs: Issue #10完了 (OWASP統合完了) |
| v1.0.0 | 84c95f6 | docs: v1.0.0完了 |
| v1.1.0 | 09173ac | docs: Issue #19完了 (csrf-attacker完了) |
| v2.0.0 | 3cb5570 | docs: Issue #24完了 (e2e-csrf完了) |
| v3.1.0 | 0a32c35 | docs: cycle docs Phase更新 (schema統一完了) |
| v3.2.0 | 57cfbdc | docs: CHANGELOG/STATUS更新 - v3.2.0 |
| v4.1.0 | 6147771 | feat: auto phase transition (v4.1.0) |

### ファイル構成

| File | Action | Purpose |
|------|--------|---------|
| scripts/test-releases.sh | new | タグ・Release検証テスト |
| scripts/create-releases.sh | new | Release一括作成スクリプト |

## Test List

### DONE
- [ ] TC-01: [正常系] 全15タグが存在すること
- [ ] TC-02: [正常系] タグがバージョン順に並んでいること（v0.1.0 < ... < v4.2.0）
- [ ] TC-03: [正常系] 全15 GitHub Releasesが存在すること
- [ ] TC-04: [正常系] 各Releaseにリリースノートが含まれること
- [ ] TC-05: [正常系] メジャーバージョン(v1.0.0, v2.0.0, v3.0.0, v4.0.0)がpre-releaseでないこと
- [ ] TC-06: [境界値] 最古タグv0.1.0が正しいコミットを指すこと
- [ ] TC-07: [境界値] 最新タグv4.2.0が正しいコミットを指すこと
- [ ] TC-08: [異常系] 既存タグ7個が保持されていること（破壊されていない）
- [ ] TC-09: [冪等性] スクリプト再実行で既存タグ・Releaseがスキップされること

## Progress Log

- 2026-02-10 21:00 [PLAN] plan-review BLOCK (score 85): scope-reviewer「既存タグ整合性検証不足」→ 整合性保証セクション追加、TC-08/TC-09追加で解消

## Notes

- タグは対応コミットに紐づける
- Release notesはCHANGELOG.mdから生成
- 既存タグ7個は変更しない
