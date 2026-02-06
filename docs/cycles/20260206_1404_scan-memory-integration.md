---
feature: scan-memory-integration
cycle: 20260206_1404_scan-memory-integration
phase: DONE
created: 2026-02-06 14:04
updated: 2026-02-06 14:04
---

# Scan Memory Integration

security-scan スキルにメモリ活用機能を追加し、スキャン知見を蓄積・活用する。

## Scope Definition

### In Scope
- [ ] RECON Phase: 過去のスキャン知見を auto memory から参照するステップ追加
- [ ] LEARN Phase: スキャン完了後に学習データを auto memory に保存するステップ追加
- [ ] Memory Convention: 保存データの構造定義

### Out of Scope
- Platform Memory Tool (API) の利用 (Reason: Claude Code Plugin なので対象外)
- 独自APIエージェントの構築 (Reason: 配布形式が変わる)
- memory-manager エージェント新規作成 (Reason: 過剰設計、既存スキル内で十分)

### Files to Change (target: 10 or less)
- plugins/redteam-core/skills/security-scan/SKILL.md (edit) - LEARN Phase 追加
- plugins/redteam-core/skills/security-scan/reference.md (edit) - Memory Integration セクション追加
- plugins/redteam-core/agents/recon-agent.md (edit) - Step 0: Check past context 追加

## Environment

### Scope
- Layer: Plugin (Claude Code Skills / Agents - Markdown)
- Plugin: N/A (Claude Code Plugin 自体を開発)
- Risk: 20 (PASS)

### Runtime
- Platform: Claude Code CLI
- Distribution: Claude Code Plugins

### Dependencies (key packages)
- Claude Code: auto memory (`~/.claude/projects/.../memory/`)
- redteam-core: v4.1.0

## Context & Dependencies

### Reference Documents
- [Platform Memory Tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool) - API版メモリの概念参考
- [Agent Teams](https://code.claude.com/docs/en/agent-teams) - 調査済み、非採用
- plugins/redteam-core/agents/false-positive-filter.md - 誤検知パターン関連

### Dependent Features
- security-scan (SKILL.md + reference.md): メインワークフロー
- recon-agent: RECON フェーズの情報収集

### Related Issues/PRs
- (新規)

## Test List

### TODO
(none)

### WIP
(none)

### DISCOVERED
(none)

### DONE
- [x] TC-01: SKILL.md が 100行以内であること (88行)
- [x] TC-02: reference.md に "Memory Integration" セクションが存在すること
- [x] TC-03: 既存ワークフロー（RECON→SCAN→REPORT→AUTO TRANSITION）がそのまま記載されていること
- [x] TC-04: SKILL.md のワークフローに LEARN Phase が追加されていること
- [x] TC-05: recon-agent.md に "Check past scan context" ステップが追加されていること
- [x] TC-06: reference.md の Memory Convention に Project / Known False Positive Patterns / Scan History サブセクションが定義されていること
- [x] TC-07: プラグイン構造テスト（test-plugins-structure.sh）が通ること
- [x] TC-08: 出力スキーマ（Output Schema）に破壊的変更がないこと
- [x] TC-09: recon-agent.md に auto memory 不在時のフォールバック動作が記述されていること
- [x] TC-10: SKILL.md の Options テーブルに --no-memory が含まれていること
- [x] TC-11: reference.md に Memory Data Exclusion（保存禁止データ）が定義されていること

## Implementation Notes

### Goal
security-scan スキルにメモリ活用機能を追加。スキャンを重ねるほど誤検知が減り、プロジェクト固有のコンテキストが蓄積される仕組みを実現する。

### Background
- v4.1.0 で全機能が安定版に到達
- Platform Memory Tool の登場により、メモリの概念がAIエージェントの標準機能になりつつある
- Claude Code の auto memory 機能は既に利用可能
- false-positive-filter はパターンベースだが、過去の判定結果を学習に使えていない

### Design Approach

**決定: A案 + B案 統合（C案は不採用）**

A（読み取り）とB（書き込み）は補完関係。C（新規エージェント）はMarkdownプラグインには過剰。

#### アーキテクチャ

```
[RECON Phase]
  Step 0 (NEW): Check auto memory for past scan context
  Step 1-6:     Existing workflow (unchanged)
          |
[SCAN Phase]    (unchanged)
          |
[REPORT Phase]  (unchanged)
          |
[AUTO TRANSITION] (unchanged)
          |
[LEARN Phase] (NEW): Save learnings to auto memory
  - Project context (tech stack, framework)
  - False positive patterns discovered
  - Scan summary history
```

#### `--no-memory` オプション仕様

| 動作 | フラグなし (default) | `--no-memory` |
|------|---------------------|---------------|
| Step 0: 過去知見の読み取り | ON | **OFF** |
| LEARN Phase: 知見の書き込み | ON | **OFF** |

`--no-memory` は読み取り・書き込み**両方を無効化**する。

#### メモリ参照時の透明性

RECON Phase で過去コンテキストを参照した場合、ユーザーに明示する:

```
Past scan context loaded: 2 FP patterns, last scan 2026-02-06 (11 findings, 3 FP)
```

メモリが存在しない場合（初回スキャン）:

```
No previous scan context found. Scan results will be saved for future reference.
```

#### Memory Convention (v1.0)

Claude Code auto memory に以下の構造で保存:

```markdown
<!-- Memory-Convention: v1.0 -->
## Security Scan Context

### Project
- Framework: Laravel 11.x
- Database: MySQL 8.0
- Auth: Sanctum
- Custom Sanitizers: App\Helpers::sanitize() (XSS safe)

### Known False Positive Patterns
- Blade {{ }} auto-escaping (XSS, confidence: 0.95)
- Eloquent ->where() with bindings (SQLi, confidence: 0.95)

### Scan History
- 2026-02-06: 3C/5H/2M/1L (11 total, 3 FP)
- 2026-01-15: 2C/8H/5M/3L (18 total, 5 FP)
```

#### Memory Data Exclusion (保存禁止データ)

以下のデータは LEARN Phase でメモリに保存してはならない:
- 脆弱性の code snippets に含まれるシークレット（API_KEY, PASSWORD 等）
- 生のペイロード（SQLi, XSS 等の攻撃文字列）
- 認証情報を含むファイルパス
- recon-agent の Sensitive Data Exclusion リストに該当するデータ

#### LEARN Phase の位置

```
AUTO TRANSITION → [OPTIONAL] E2E → LEARN Phase
```

E2E 実行時は E2E の後に LEARN を実行し、完全な結果を保存する。

#### 変更対象ファイル詳細

**1. security-scan SKILL.md**
- Workflow に "6. LEARN Phase" を追加（1行 + reference.md ポインタ）
- Options テーブルに `--no-memory` 追加（Default: Off = メモリ有効）
- LEARN Phase の詳細は reference.md に委譲（100行制約対策）

**2. security-scan reference.md**
- "Memory Integration" セクション追加
  - Memory Convention v1.0 定義（Project / Known FP Patterns / Scan History）
  - Memory Data Exclusion（保存禁止データ）
  - LEARN Phase 詳細ワークフロー
  - 透明性メッセージ仕様（参照時 / 初回スキャン時）
  - false-positive-filter 直接統合は将来課題として記載

**3. recon-agent.md**
- Workflow の先頭に "0. Check past scan context" 追加
- フォールバック: auto memory が存在しない/空の場合 → Step 1 にスキップ
- 過去コンテキストがあれば attack_priorities に反映

## Progress Log

### 2026-02-06 14:04 - INIT
- Cycle doc created
- Platform Memory Tool / Agent Teams 調査完了
- Agent Teams は非採用（Subagent 維持）

### 2026-02-06 14:XX - PLAN
- A案+B案 統合に決定、C案（memory-manager）は不採用
- Memory Convention v1.0 設計完了
- 変更対象: 3ファイル（SKILL.md, reference.md, recon-agent.md）
- Test List: 8ケース作成

### 2026-02-06 14:XX - PLAN (plan-review反映)
- plan-review実施: WARN (max score: 62/Usability)
- 6件の指摘を反映:
  1. --no-memory のスコープ明確化（読み書き両方無効）
  2. メモリ参照時の透明性メッセージ仕様追加
  3. 初回スキャン時のフォールバック UX 定義
  4. Memory Convention にバージョニング追加 (v1.0)
  5. Memory Data Exclusion（保存禁止データ）追加
  6. TC-06 拡充 + TC-09/TC-10/TC-11 追加（計11ケース）
- LEARN Phase の位置を AUTO TRANSITION → E2E → LEARN に確定

### 2026-02-06 - RED
- テストスクリプト作成: scripts/test-scan-memory-integration.sh (11 TC)
- RED確認: 7 FAIL / 4 PASS（既存機能PASS、新機能FAIL）
- FAIL: TC-02, TC-04, TC-05, TC-06, TC-09, TC-10, TC-11

### 2026-02-06 - GREEN
- 3ファイル編集: SKILL.md(88行), reference.md, recon-agent.md
- 全11テスト PASS、既存テスト回帰なし

### 2026-02-06 - REFACTOR
- SKILL.md frontmatter description を LEARN Phase 込みに更新
- 全テスト PASS 維持（30/30: 11 + 6 + 5 + 8）

### 2026-02-06 - REVIEW
- quality-gate: PASS (max score: 42)
  - Correctness: 30, Performance: 15, Security: 42
  - Architecture: 38, Guidelines: 35, Scope: 12

### 2026-02-06 - COMMIT
- feat: add scan memory integration (LEARN Phase + RECON Step 0)

---

## Next Steps

1. [Done] INIT
2. [Done] PLAN
3. [Done] RED
4. [Done] GREEN
5. [Done] REFACTOR
6. [Done] REVIEW
7. [Done] COMMIT
