# TDD Cycle: command-injection

## Overview

| Item | Value |
|------|-------|
| Feature | injection-attacker: Command Injection対応追加 |
| Issue | #20 |
| Created | 2025-12-25 14:40 |
| Status | DONE |

## Goal

injection-attackerにCommand Injection (CWE-78) 検出機能を追加する。

## Background

- CWE Top 25 2025: 上位ランク（CWE-78）
- 現状: SQLインジェクションのみ対応
- 目標: OS Command Injection検出を追加

## Scope

- [ ] command-injection type追加
- [ ] 検出パターン定義（exec, shell_exec, system, popen等）
- [ ] vulnerability_class/cwe_id対応
- [ ] CVSS/OWASPマッピング追加

## Environment

| Item | Value |
|------|-------|
| Project Type | Claude Code Plugin |
| Distribution | Markdown-based agents/skills |
| Testing | Shell scripts (scripts/test-*.sh) |

## PLAN

### 設計方針

1. **injection-attacker.md拡張**: 既存SQLi検出にCommand Injection追加
2. **attack-report連携**: CVSS/CWE/OWASPマッピング追加
3. **後方互換性**: 既存機能を維持
4. **リスク対策**: ID分離、Safe Pattern除外

### リスク対策（plan-review指摘対応）

| リスク | 対策 |
|--------|------|
| Multi-type混乱 | ID prefix分離: SQLI-xxx, CMD-xxx |
| Agent to Type Mapping | Default Type（フォールバック用）として維持 |
| 誤検知 | Safe Pattern除外セクション追加 |
| OWASP版不整合 | A05:2025に統一（Issue #21で解決済み） |

### 変更ファイル

1. `plugins/redteam-core/agents/injection-attacker.md`
   - description更新: 「SQLインジェクション」→「インジェクション」
   - Detection Targets: Command Injection追加
   - Dangerous Patterns: exec, shell_exec, system, popen等
   - Safe Patterns: フレームワーク標準ライブラリ除外
   - Output Format例: CMD-001追加
   - CWE/OWASP Mapping: CWE-78追加、A05:2025に統一

2. `plugins/redteam-core/skills/attack-report/reference.md`
   - CVSS表: command-injection追加（Score 9.3）
   - CWE/OWASP表: command-injection | CWE-78 | A05:2025

3. `scripts/test-command-injection.sh` (新規)
   - 検出パターン存在確認
   - Safe Pattern除外確認
   - CVSS/CWE/OWASPマッピング確認

### Command Injection検出パターン

| Framework | Dangerous Pattern |
|-----------|-------------------|
| PHP | exec(), shell_exec(), system(), passthru(), popen(), proc_open(), backticks |
| Python | os.system(), subprocess.call(), subprocess.Popen(), os.popen() |
| Node.js | child_process.exec(), child_process.spawn(), execSync() |
| Go | exec.Command(), os/exec |

### CVSSベクター

```
command-injection: CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N (9.3)
```
※ SQLiと同等の深刻度（任意コード実行）

## Test List

### injection-attacker.md
- [ ] TC-01: Detection Targetsにcommand-injectionあり
- [ ] TC-02: Dangerous Patternsにexec関連パターンあり
- [ ] TC-03: Dangerous Patternsにshell_exec関連パターンあり
- [ ] TC-04: Dangerous Patternsにsystem関連パターンあり
- [ ] TC-05: Safe Patternsセクションあり
- [ ] TC-06: CWE/OWASP MappingにCWE-78あり
- [ ] TC-07: OWASP参照がA05:2025に統一

### attack-report/reference.md
- [ ] TC-08: CVSS表にcommand-injectionあり
- [ ] TC-09: CWE/OWASP表にcommand-injection (CWE-78)あり

### Output Format
- [ ] TC-10: Output例にCMD-xxx形式のIDあり

## Phase Log

| Phase | Status | Notes |
|-------|--------|-------|
| INIT | Done | Cycle doc作成 |
| PLAN | Done | 10テストケース定義 |
| plan-review | Done | Score 72 WARN、リスク対策追加 |
| RED | Done | 11テスト作成、1 PASS / 10 FAIL |
| GREEN | Done | injection-attacker.md + reference.md更新、11 PASS |
| REFACTOR | Done | リファクタリング不要（既存パターン準拠） |
| REVIEW | Done | quality-gate WARN (72)、改善提案は次Issue |
| COMMIT | Done | a415bef |
