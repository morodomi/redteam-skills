# TDD Cycle: injection-attacker

## Overview

| Item | Value |
|------|-------|
| Feature | injection-attacker SQLインジェクション検出 |
| Issue | #3 |
| Phase | DONE |
| Started | 2024-12-24 13:09 |

## Environment

| Tool | Version |
|------|---------|
| Claude Code | 2.0.75 |
| Platform | darwin (macOS) |

## Goal

SQLインジェクション脆弱性を検出するエージェントを実装する。

### MVP対象
- Union-based SQLi
- Error-based SQLi
- Blind SQLi（Boolean）

## PLAN

### スコープ

injection-attackerエージェントファイルの作成。静的解析によるSQLi検出。

### ファイル構成

```
plugins/redteam-core/agents/
└── injection-attacker.md    # SQLi検出エージェント定義
```

### エージェント設計

```yaml
name: injection-attacker
description: SQLインジェクション検出エージェント。静的解析でSQLi脆弱性を検出。
allowed-tools: Read, Grep, Glob
```

### 検出対象（MVP）

| Type | Description | Pattern |
|------|-------------|---------|
| Union-based | UNION SELECT攻撃 | 文字列結合でのSQL構築 |
| Error-based | エラーメッセージ利用 | 未処理の例外、エラー出力 |
| Boolean-blind | 条件分岐による推測 | 動的WHERE句構築 |

### フレームワーク別検出パターン

| Framework | Vulnerable Pattern | Safe Pattern |
|-----------|-------------------|--------------|
| Laravel | `DB::raw($input)`, `whereRaw($input)` | `DB::table()->where()`, Eloquent ORM |
| Django | `cursor.execute(f"...{input}")` | `cursor.execute("...%s", [input])` |
| Flask | `db.execute(f"...{input}")` | `db.execute("...?", (input,))` |
| Express | `query("SELECT..."+input)` | `query("SELECT...?", [input])` |

### 危険パターン（Grep対象）

```yaml
patterns:
  # PHP/Laravel
  - 'DB::raw\s*\('
  - 'whereRaw\s*\('
  - '\$.*->query\s*\('
  - 'mysql_query\s*\('

  # Python/Django/Flask
  - 'execute\s*\(\s*f["\']'
  - 'execute\s*\(\s*["\'].*%'
  - 'cursor\.execute\s*\([^,]+\)'

  # Node.js/Express
  - 'query\s*\(\s*[`"\'].*\+'
  - 'query\s*\(\s*`.*\$\{'
```

### 出力形式

```json
{
  "metadata": {
    "scan_id": "<uuid>",
    "scanned_at": "<timestamp>",
    "agent": "injection-attacker"
  },
  "vulnerabilities": [
    {
      "id": "SQLI-001",
      "type": "union-based",
      "severity": "critical",
      "file": "app/Http/Controllers/UserController.php",
      "line": 45,
      "code": "DB::raw($request->input('sort'))",
      "description": "User input directly passed to DB::raw()",
      "remediation": "Use parameterized queries or Eloquent ORM"
    }
  ],
  "summary": {
    "total": 1,
    "critical": 1,
    "high": 0,
    "medium": 0,
    "low": 0
  }
}
```

### 重大度基準

| Severity | Criteria |
|----------|----------|
| critical | ユーザー入力が直接SQLに結合 + 認証なし |
| high | ユーザー入力が直接SQLに結合 + 認証あり |
| medium | 動的SQL構築 + 部分的なバリデーション |
| low | 潜在的な危険パターン + 安全な使用の可能性 |

### CWE/OWASP マッピング

| Reference | ID |
|-----------|-----|
| CWE | CWE-89: SQL Injection |
| OWASP Top 10 | A03:2021 Injection |

## Test List

### DONE
- [x] TC-01: injection-attacker.md が存在する
- [x] TC-02: YAML frontmatter（name, description, allowed-tools）が存在する
- [x] TC-03: 検出対象セクション（Union/Error/Boolean）が存在する
- [x] TC-04: フレームワーク別検出パターン表が存在する
- [x] TC-05: 危険パターン（Grepパターン）が定義されている
- [x] TC-06: 出力形式（JSONスキーマ）が存在する
- [x] TC-07: 重大度基準が存在する
- [x] TC-08: CWE/OWASPマッピングが存在する

## Phase Log

| Phase | Status | Note |
|-------|--------|------|
| INIT | Done | Cycle doc作成 |
| PLAN | Done | エージェント設計、Test List作成 |
| RED | Done | 8テスト作成、全失敗確認 |
| GREEN | Done | injection-attacker.md作成、全テスト成功 |
| REFACTOR | Done | リファクタリング不要（構造クリーン） |
| REVIEW | Done | テスト全PASS、code-review完了（Critical=拡張項目） |
| COMMIT | Done | b3051c3 |

## References

- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [CWE-89: SQL Injection](https://cwe.mitre.org/data/definitions/89.html)
