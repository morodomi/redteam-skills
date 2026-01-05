# Cycle: e2e-generator-base

| Item | Value |
|------|-------|
| Issue | #22 |
| Phase | DONE |
| Created | 2026-01-05 17:39 |

## Environment

| Tool | Version |
|------|---------|
| Node.js | v22.17.0 |
| Playwright | (to be installed) |

## Goal

静的解析で検出した脆弱性から、Playwrightテストコードを自動生成する基盤を構築する。

## Background

redteam-skills v1.xは静的解析中心。v2.0でE2Eテスト自動生成を追加し、脆弱性の動的検証を可能にする。

## Scope

From Issue #22:
- [ ] Playwright設定ファイル生成
- [ ] テストテンプレート基盤
- [ ] 静的解析結果パーサー
- [ ] テストファイル出力

## PLAN

### Design

```
security-scan JSON → generate-e2e skill → Playwright tests
```

### Architecture

| Component | Description |
|-----------|-------------|
| generate-e2e skill | スキャン結果からテスト生成を実行（ロジック埋め込み） |
| templates/ | Playwrightテストテンプレート（skill内配置） |

**Note:** 生成ロジックはskill内に埋め込み。agents/は攻撃エージェント専用のため使用しない。

### Files to Create

| File | Description |
|------|-------------|
| plugins/redteam-core/skills/generate-e2e/SKILL.md | スキル定義 |
| plugins/redteam-core/skills/generate-e2e/reference.md | 詳細仕様 |
| plugins/redteam-core/skills/generate-e2e/templates/playwright.config.ts.tmpl | Playwright設定 |
| plugins/redteam-core/skills/generate-e2e/templates/base-test.ts.tmpl | ベーステスト |

### Dependencies

| Package | Version | Note |
|---------|---------|------|
| Playwright | ^1.40.0 | テンプレート内で指定 |

### Usage

```bash
/generate-e2e                    # 直前のscan結果からテスト生成
/generate-e2e ./scan-result.json # 指定JSONから生成
/generate-e2e --force            # 既存ファイル上書き
```

### Output

```
<target-project>/
└── tests/
    └── security/
        ├── playwright.config.ts
        └── <vuln-type>.spec.ts
```

### File Overwrite Behavior

- デフォルト: 既存ファイルがある場合は警告して中断
- `--force`: 既存ファイルを上書き

### References

- [Playwright TypeScript](https://playwright.dev/docs/test-typescript)
- [Playwright Test API](https://playwright.dev/docs/api/class-test)

## Test List

### TODO

### WIP

### DONE
- [x] TC-01: [正常系] security-scan JSON入力からPlaywright設定ファイル生成
- [x] TC-02: [正常系] 脆弱性詳細からベーステストファイル生成（テンプレート変数置換検証含む）
- [x] TC-03: [正常系] 出力ディレクトリ(tests/security/)への書き込み
- [x] TC-04: [境界値] 脆弱性0件の場合の処理（設定ファイルのみ生成）
- [x] TC-05: [エッジケース] 既存ファイルがある場合 → 警告して中断
- [x] TC-06: [エッジケース] --force オプションで既存ファイル上書き
- [x] TC-07: [異常系] 不正なJSON入力時のエラーハンドリング
- [x] TC-08: [異常系] 出力ディレクトリ書き込み権限エラー

## Notes

- v2.0の基盤Issue
- 個別脆弱性テスト生成は別Issue (#23-26)
