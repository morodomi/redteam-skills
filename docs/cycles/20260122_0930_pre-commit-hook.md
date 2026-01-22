# Cycle: pre-commit-hook

| Item | Value |
|------|-------|
| Issue | #49 |
| Phase | DONE |
| Created | 2026-01-22 09:30 |

## Environment

| Tool | Version |
|------|---------|
| Claude Code | Plugins |
| bash | 5.x |
| git | 2.x |

## Goal

コミット前に全テストスクリプトを自動実行し、失敗時にコミットをブロックする。

## Background

From Issue #49:
- CI/CDの一環として、コミット前に全テストを自動実行したい
- セキュリティスキルのドキュメント変更時の回帰テスト防止
- 命名規則の統一維持

### 対象テストスクリプト

```
scripts/test-*.sh (44個)
```

### 実装方式

| 方式 | 特徴 |
|------|------|
| .git/hooks/pre-commit | シンプル、リポジトリ固有 |
| husky | npm依存、チーム共有しやすい |

## Scope

From Issue #49:
- [ ] pre-commit hookスクリプト作成
- [ ] 全テストスクリプトの実行
- [ ] 失敗時のコミットブロック

## PLAN

### Design

| 項目 | 内容 |
|------|------|
| 方式 | `.git/hooks/pre-commit` |
| 実行対象 | `scripts/test-*.sh` 全44個 |
| 失敗時 | exit 1でコミットブロック |
| インストール | `scripts/install-hooks.sh` で自動配置 |
| 実行時間 | 約3秒（全テスト） |

### Files

```
scripts/
├── install-hooks.sh  # hookインストーラ (NEW)
└── pre-commit        # hookスクリプト本体 (NEW)
```

### pre-commit スクリプト

```bash
#!/bin/bash
# scripts/pre-commit - Git pre-commit hook

echo "Running pre-commit tests..."

FAILED=0
for test in scripts/test-*.sh; do
    if ! bash "$test" > /dev/null 2>&1; then
        echo "FAIL: $test"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo "Pre-commit tests failed. Commit aborted."
    exit 1
fi

echo "All tests passed."
exit 0
```

### install-hooks.sh

```bash
#!/bin/bash
# scripts/install-hooks.sh - Install git hooks

cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo "Pre-commit hook installed."
```

## Test List

### TODO

(なし)

### WIP

(なし)

### DONE

- [x] TC-01: scripts/pre-commitが存在する
- [x] TC-02: scripts/install-hooks.shが存在する
- [x] TC-03: pre-commitが実行可能（shebang確認）
- [x] TC-04: install-hooks.shが実行可能（shebang確認）
- [x] TC-05: pre-commitスクリプトのシンタックスが正しい
- [x] TC-06: テスト失敗時のexit 1が定義されている
- [x] TC-07: install-hooks.sh実行後、.git/hooks/pre-commitが存在する

### GREEN結果

```
Results: 7 passed, 0 failed
```

## REFACTOR

リファクタリング対象なし。

| 項目 | 評価 |
|------|------|
| DRY | OK - 重複なし |
| 定数化 | OK - マジックナンバーなし |
| 構造 | OK - シンプル |
| 命名 | OK - 明確 |

## REVIEW

### Quality Gate Results (1st)

| Reviewer | Score | Judgment |
|----------|-------|----------|
| correctness | 72 | WARN |
| security | 35 | PASS |
| guidelines | 35 | PASS |
| performance | 35 | PASS |

**Max Score: 72 → WARN** - GREENに戻って修正

### 修正内容

install-hooks.shにエラーハンドリングを追加:
- .gitディレクトリ存在確認
- scripts/pre-commit存在確認
- mkdir -p .git/hooks追加

### Quality Gate Results (2nd)

| Reviewer | Score | Judgment |
|----------|-------|----------|
| correctness | 35 | PASS |

**Max Score: 35 → PASS**

## Notes

- TDDワークフロー（tdd-review）でもテスト実行済み
- pre-commit hookは追加のセーフティネット
- 44個のテスト実行には時間がかかる可能性あり
