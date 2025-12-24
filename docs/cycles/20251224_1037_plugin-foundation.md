# TDD Cycle: plugin-foundation

## Overview

| Item | Value |
|------|-------|
| Feature | redteam-coreプラグイン基盤構築 |
| Issue | #1 |
| Phase | INIT |
| Started | 2024-12-24 10:37 |

## Environment

| Tool | Version |
|------|---------|
| Claude Code | 2.0.75 |
| Platform | darwin (macOS) |

## Goal

redteam-coreプラグインの基盤を構築し、Claude Codeからプラグインとして認識される状態にする。

## PLAN

### スコープ

プラグイン構造のみ。セキュリティ基盤（免責事項、ログ機構）は別Issueで対応。

### ファイル構成

```
plugins/redteam-core/
├── .claude-plugin/
│   └── plugin.json      # プラグイン定義
├── agents/              # 空ディレクトリ（後で追加）
├── skills/              # 空ディレクトリ（後で追加）
└── README.md            # プラグイン説明

scripts/
└── test-plugins-structure.sh  # 構造テスト
```

### plugin.json

```json
{
  "name": "redteam-core",
  "description": "Security audit automation. RECON → SCAN → ATTACK → REPORT",
  "version": "0.1.0",
  "author": { "name": "morodomi" },
  "repository": "https://github.com/morodomi/redteam-skills",
  "license": "MIT"
}
```

## Test List

### DONE
- [x] TC-01: plugins/redteam-core/.claude-plugin/plugin.json が存在する
- [x] TC-02: plugin.json が有効なJSONフォーマットである
- [x] TC-03: plugin.json に必須フィールド（name, version）が存在する
- [x] TC-04: plugins/redteam-core/agents/ ディレクトリが存在する
- [x] TC-05: plugins/redteam-core/skills/ ディレクトリが存在する
- [x] TC-06: plugins/redteam-core/README.md が存在する

## Phase Log

| Phase | Status | Note |
|-------|--------|------|
| INIT | Done | Cycle doc作成 |
| PLAN | Done | 構造設計、Test List作成 |
| RED | Done | 6テスト作成、全失敗確認 |
| GREEN | Done | プラグイン構造実装、全テスト成功 |
| REFACTOR | Done | .gitkeep追加 |
| REVIEW | Done | テスト全PASS、code-review完了 |
| COMMIT | - | |

## References

- [tdd-skills](https://github.com/morodomi/tdd-skills) - 参考プラグイン構造
- [anthropics/skills](https://github.com/anthropics/skills) - 公式スキル
