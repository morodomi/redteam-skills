# Cycle: expect-poll-pattern

| Item | Value |
|------|-------|
| Issue | #29 |
| Phase | REVIEW |
| Created | 2026-01-09 10:01 |

## Environment

| Tool | Version |
|------|---------|
| Node.js | v22.17.0 |

## Goal

ssrf.spec.ts.tmpl の `waitForTimeout(3000)` を Playwright推奨の `expect.poll()` パターンに改善する。

## Background

From Issue #29:
- quality-gate (Issue #26) で指摘: Performance 65 (WARN), Guidelines 55 (WARN)
- `waitForTimeout()` は Playwright のアンチパターン
- 固定待機時間でテストが遅くなる

## Scope

From Issue #29:
- [ ] ssrf.spec.ts.tmpl の waitForTimeout を expect.poll() に置換
- [ ] 両テストケース（通常/認証付き）に適用
- [ ] テスト全PASS確認

## PLAN

### Current Implementation (Lines 51, 82)

```typescript
// Wait for callback (3s timeout)
await page.waitForTimeout(3000);

// PoC: Verify SSRF occurred
const received = receivedPaths.some(p => p.includes('ssrf-'));
expect(received).toBe(true);
```

### Proposed Implementation

```typescript
// Poll for callback with early exit
await expect.poll(
  () => receivedPaths.some(p => p.includes('ssrf-')),
  { timeout: 3000, intervals: [100] }
).toBe(true);
```

### Benefits

| Before | After |
|--------|-------|
| 固定3秒待機 | コールバック到着時に即座に完了 |
| waitForTimeout (アンチパターン) | expect.poll (ベストプラクティス) |
| テスト遅い | テスト高速化 |

### Changes

| File | Line | Change |
|------|------|--------|
| ssrf.spec.ts.tmpl | 50-56 | waitForTimeout → expect.poll (通常テスト) |
| ssrf.spec.ts.tmpl | 81-86 | waitForTimeout → expect.poll (認証付きテスト) |

### Files to Modify

| File | Changes |
|------|---------|
| plugins/redteam-core/skills/generate-e2e/templates/ssrf.spec.ts.tmpl | expect.poll適用 |

## Test List

### TODO

### WIP

### DONE
- [x] TC-01: [正常系] expect.pollパターンが存在
- [x] TC-02: [正常系] waitForTimeoutが削除されている
- [x] TC-03: [正常系] timeout: 3000 設定
- [x] TC-04: [正常系] intervals設定
- [x] TC-05: [境界値] 両テストケースに適用
- [x] TC-06: [異常系] 構文エラーなし

## REVIEW

### quality-gate Results

| Agent | Score | Status |
|-------|-------|--------|
| Correctness | 15 | PASS |
| Performance | 15 | PASS |
| Security | 15 | PASS |
| Guidelines | 15 | PASS |

**Max Score: 15 (PASS)**

### Optional Findings

- intervals: [100] は正しく動作（Playwrightは最後の値を繰り返す）
- 他テンプレートとの一貫性は将来課題（現時点では対応不要）

## Notes

- v2.2 マイルストーン
- 優先度: Low（機能的には現状で動作）
- Playwright ベストプラクティス準拠
