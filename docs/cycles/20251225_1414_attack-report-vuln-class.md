# TDD Cycle: attack-report-vuln-class

## Overview

| Item | Value |
|------|-------|
| Feature | attack-report: vulnerability_class/cwe_id活用 |
| Issue | #21 |
| Created | 2025-12-25 14:14 |
| Status | INIT |

## Goal

attack-reportでvulnerability_classとcwe_idフィールドを活用し、CVSSマッピング精度を向上させる。

## Background

- 依存: Issue #16でsecurity-scan出力にvulnerability_class/cwe_idを追加済み
- 現状: attack-reportはagent名から脆弱性タイプを推測
- 目標: vulnerability_classから直接CVSSベクターを選択

## Scope

- [ ] vulnerability_classからCVSSベクター自動選択
- [ ] cwe_idからOWASPカテゴリ自動マッピング
- [ ] schema_version 2.0対応

## Environment

| Item | Value |
|------|-------|
| Project Type | Claude Code Plugin |
| Distribution | Markdown-based agents/skills |
| Testing | Shell scripts (scripts/test-*.sh) |

## PLAN

### 設計方針

1. **Input Schema更新**: vulnerability_class, cwe_id, schema_versionを追加
2. **CVSSマッピング**: vulnerability_classから直接CVSSベクターを選択
3. **CWE/OWASPマッピング**: cwe_idがあれば直接使用、なければtype経由
4. **後方互換性**: schema_version < 2.0時はAgent to Type Mappingでフォールバック

### マッピング優先順位

```
CVSS取得:
1. details[].vulnerability_class → CVSS表
2. (fallback) agent名 → Agent to Type Mapping → CVSS表

CWE取得:
1. details[].cwe_id → 直接使用
2. (fallback) type → CWE/OWASP Mapping表
```

### 変更ファイル

1. `plugins/redteam-core/skills/attack-report/reference.md`
   - Input Schema: vulnerability_class, cwe_id, schema_version追加
   - マッピングロジック説明を更新
   - file-attacker, ssrf-attacker のCVSS/CWE追加

### 追加するCVSS/CWEマッピング

| vulnerability_class | CWE | CVSS Score | OWASP |
|---------------------|-----|------------|-------|
| ssrf | CWE-918 | 8.6 | A01:2025 |
| path-traversal | CWE-22 | 7.5 | A01:2025 |
| lfi | CWE-98 | 7.5 | A05:2025 |
| arbitrary-file-upload | CWE-434 | 9.0 | A01:2025 |

**注**: file-attackerのtype定義（lfi, arbitrary-file-upload）に準拠

## Test List

### Input Schema
- [ ] TC-01: Input Schemaにschema_versionフィールドあり
- [ ] TC-02: Input Schemaにvulnerability_classフィールドあり
- [ ] TC-03: Input Schemaにcwe_idフィールドあり

### CVSSマッピング
- [ ] TC-04: CVSS表にssrfエントリあり
- [ ] TC-05: CVSS表にpath-traversalエントリあり
- [ ] TC-06: CVSS表にlfiエントリあり
- [ ] TC-07: CVSS表にarbitrary-file-uploadエントリあり

### CWE/OWASPマッピング
- [ ] TC-08: CWE/OWASP表にssrf (CWE-918)あり
- [ ] TC-09: CWE/OWASP表にpath-traversal (CWE-22)あり

### 後方互換性
- [ ] TC-10: Agent to Type Mappingが維持されている
- [ ] TC-11: file-attackerのデフォルトtypeが定義されている
- [ ] TC-12: ssrf-attackerのデフォルトtypeが定義されている

## Phase Log

| Phase | Status | Notes |
|-------|--------|-------|
| INIT | Done | Cycle doc作成 |
| PLAN | Done | 12テストケース定義 |
| plan-review | Done | Score 35 PASS、命名修正 |
| RED | Done | 13テスト作成、2 PASS / 11 FAIL |
| GREEN | Done | reference.md更新、13 PASS |
| REFACTOR | Done | リファクタリング不要（ドキュメント追加のみ） |
| REVIEW | Done | quality-gate全PASS (max 15) |
| COMMIT | Done | bc803af |
