# Security Rules

> Security standards for all projects. Referenced by: security-engineer, code-reviewer, api-developer

---

## Secrets Management

| Rule | Description |
|------|-------------|
| Never hardcode secrets | Use .env, environment variables, or secrets manager |
| Never log secrets | No passwords, tokens, or keys in log output |
| Never commit secrets | .env, credentials.json must be in .gitignore |
| Rotate on exposure | If a secret is exposed, rotate immediately |
| Least privilege | Grant minimum required permissions |

---

## OWASP Top 10 Checklist

| # | Vulnerability | Prevention |
|---|--------------|------------|
| A01 | Broken Access Control | Auth on every endpoint, deny by default, RBAC |
| A02 | Cryptographic Failures | HTTPS everywhere, bcrypt/argon2 for passwords, no MD5/SHA1 for security |
| A03 | Injection | Parameterized queries, input validation, output encoding |
| A04 | Insecure Design | Threat modeling, secure defaults, principle of least privilege |
| A05 | Security Misconfiguration | No default credentials, disable debug mode, minimize attack surface |
| A06 | Vulnerable Components | Regular dependency audits, pin versions, update promptly |
| A07 | Auth Failures | Rate limiting, MFA, secure session management, strong passwords |
| A08 | Data Integrity | Verify signatures, validate CI/CD pipelines, integrity checks |
| A09 | Logging Failures | Log security events, protect log integrity, never log sensitive data |
| A10 | SSRF | Validate/sanitize URLs, allowlist outbound hosts, segment networks |

---

## Input Validation

| Input Source | Validation Required |
|-------------|-------------------|
| API request body | Schema validation (JSON Schema, Pydantic) |
| URL parameters | Type checking, allowlist values |
| File uploads | Type checking, size limits, content validation |
| CSV imports | Schema validation, type coercion, value ranges |
| Database results | Trust but verify (unexpected NULLs, types) |

---

## Authentication & Authorization

| Rule | Description |
|------|-------------|
| Auth on every endpoint | No unprotected routes (except health checks) |
| Token expiry | Access tokens: 15-60 min, Refresh tokens: 7-30 days |
| Password storage | bcrypt or argon2, never plaintext or reversible |
| Session management | Secure cookies, HttpOnly, SameSite, rotate on auth |
| Rate limiting | Login attempts: 5 per minute, API: per-client limits |

---

## Dependency Security

```bash
# Python: audit dependencies
pip audit

# Node.js: audit dependencies
npm audit

# Check for outdated packages
pip list --outdated
npm outdated
```

Run dependency audits in CI and before every release.
