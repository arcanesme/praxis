---
description: OWASP top 10, secrets handling, input validation
---

# Security

## Secrets

- Never hardcode secrets, API keys, or credentials in source code.
- Use environment variables or secret managers.
- If you spot a secret in code, flag it immediately — don't just fix it silently.
- Check `.gitignore` covers `.env`, credentials files, and key material.

## Input Validation

- Validate all external input at system boundaries (user input, API payloads, file uploads).
- Sanitize output to prevent XSS. Use parameterized queries to prevent SQL injection.
- Never trust client-side validation alone.

## OWASP Top 10

Be alert to:
- **Injection** — SQL, command, LDAP, template injection
- **Broken authentication** — weak session handling, missing MFA
- **Sensitive data exposure** — logging secrets, unencrypted storage
- **Broken access control** — missing authorization checks
- **Security misconfiguration** — default credentials, verbose errors in production

## Dependencies

- Check for known vulnerabilities before adding dependencies.
- Keep dependencies updated. Monitor security advisories.
- Prefer dependencies with active maintenance and security track records.
