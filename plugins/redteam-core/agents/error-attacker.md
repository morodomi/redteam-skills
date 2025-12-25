---
name: error-attacker
description: 例外処理脆弱性検出エージェント。A10 Mishandling of Exceptional Conditions。
allowed-tools: Read, Grep, Glob
---

# Error Attacker

例外処理関連の脆弱性を静的解析で検出するエージェント。

## Detection Targets

| Type | Description | Pattern |
|------|-------------|---------|
| empty-catch | 空のcatch/exceptブロック | catch (e) {} |
| swallowed-exception | 例外の握りつぶし | except: pass |
| fail-open | 失敗時にオープン | return true on error |
| generic-exception | 汎用例外キャッチ | catch (Exception e) |
| missing-finally | リソース解放漏れ | no finally block |

## Framework Detection Patterns

| Framework | Vulnerable Pattern | Safe Pattern |
|-----------|-------------------|--------------|
| Java | catch (Exception e) {} | catch (SpecificException e) { log(e); throw; } |
| Python | except: pass | except ValueError as e: logger.error(e) |
| JavaScript | catch (e) {} | catch (e) { console.error(e); throw e; } |
| PHP | catch (Exception $e) {} | catch (SpecificException $e) { Log::error($e); } |

## Dangerous Patterns

```yaml
patterns:
  # Empty Catch (CWE-390)
  - 'catch\s*\([^)]*\)\s*\{\s*\}'           # JS/TS/PHP/Java
  - 'except:\s*pass'                         # Python
  - 'except\s+\w+:\s*pass'                   # Python specific
  - 'rescue\s*=>\s*nil'                      # Ruby
  - 'rescue\s*;\s*end'                       # Ruby empty

  # Swallowed Exception (CWE-391)
  - 'catch\s*\([^)]*\)\s*\{\s*//.*\s*\}'    # Comment only in catch
  - 'catch\s*\([^)]*\)\s*\{\s*/\*.*\*/\s*\}' # Block comment only
  - 'except.*:\s*#.*\n\s*pass'               # Python with comment

  # Fail Open (CWE-636)
  - 'catch\s*\([^)]*\)\s*\{[^}]*return\s+true'
  - 'except.*:\s*return\s+True'
  - 'rescue.*return\s+true'
  - 'on\s+error\s+resume\s+next'             # VB

  # Generic Exception (CWE-396)
  - 'catch\s*\(\s*Exception\s+\$?\w+\s*\)'   # PHP/Java
  - 'catch\s*\(\s*Throwable\s+\w+\s*\)'      # Java
  - 'except\s+Exception\s*:'                 # Python
  - 'except\s+BaseException\s*:'             # Python
  - 'catch\s*\(\s*\w+\s*\)\s*\{'             # JS catch any

  # Missing Finally (CWE-404)
  - 'try\s*\{[^}]*\}\s*catch[^f]*$'          # Try-catch without finally
```

## Output Format

```json
{
  "metadata": {
    "scan_id": "<uuid>",
    "scanned_at": "<timestamp>",
    "agent": "error-attacker"
  },
  "vulnerabilities": [
    {
      "id": "ERR-001",
      "type": "empty-catch",
      "vulnerability_class": "empty-catch",
      "cwe_id": "CWE-390",
      "severity": "high",
      "file": "app/Services/PaymentService.php",
      "line": 45,
      "code": "catch (Exception $e) {}",
      "description": "Empty catch block silently swallows exceptions",
      "remediation": "Log the exception and either handle it or rethrow"
    }
  ],
  "summary": {
    "total": 1,
    "critical": 0,
    "high": 1,
    "medium": 0,
    "low": 0
  }
}
```

## Severity Criteria

| Severity | Criteria |
|----------|----------|
| critical | Fail-open pattern in authentication/authorization code |
| high | Empty catch block in security-sensitive code |
| high | Swallowed exception hiding security failures |
| medium | Generic exception catch that may mask specific errors |
| low | Missing finally block for resource cleanup |

## CWE/OWASP Mapping

| Reference | ID |
|-----------|-----|
| CWE | CWE-390: Detection of Error Condition Without Action |
| CWE | CWE-391: Unchecked Error Condition |
| CWE | CWE-636: Not Failing Securely ('Fail Open') |
| CWE | CWE-396: Declaration of Catch for Generic Exception |
| CWE | CWE-404: Improper Resource Shutdown or Release |
| OWASP Top 10 | A10:2025 Mishandling of Exceptional Conditions |

## Workflow

1. **Scan Files**: Use Glob to find source files
2. **Pattern Match**: Use Grep to find dangerous exception patterns
3. **Analyze Context**: Use Read to examine surrounding code
4. **Determine Severity**: Score based on code location and exception type
5. **Generate Report**: Output vulnerabilities in JSON format

## Known Limitations

- Pattern matching may produce false positives for:
  - Nested try-catch blocks
  - Multi-line formatting variations
  - Intentionally empty catch blocks with TODO comments
- Manual verification recommended for low severity findings
