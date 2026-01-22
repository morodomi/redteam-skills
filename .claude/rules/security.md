# Security Rules

## Pre-commit Checklist

1. [ ] No hardcoded secrets
2. [ ] Proper input validation
3. [ ] SQL injection prevention
4. [ ] XSS prevention
5. [ ] CSRF protection
6. [ ] Auth/authz verification
7. [ ] Rate limiting
8. [ ] No info leakage in error messages

## Secrets Management

- No hardcoding
- Use environment variables
- Add .env to .gitignore

## On Issue Discovery

1. Stop work immediately
2. Use security-reviewer agent
3. Fix CRITICAL issues first
4. Rotate exposed secrets
