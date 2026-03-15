# Security — Rules
# Scope: All projects, all sessions

## Invariants (BLOCK on violation)

### Secrets
- NEVER hardcode secrets — no API keys, tokens, passwords, connection strings in code.
  Use environment variables or a secrets manager.
- If a secret is found in code: flag immediately, do not proceed until remediated.
- Pre-commit scan (always): `rg "(sk-|ghp_|AKIA|Bearer [A-Za-z0-9+/]{20,})" $(git diff --staged --name-only)`
- Secrets in logs: never log request bodies, headers, or responses that may contain credentials. Redact before logging.

### Input Validation
- Validate all inputs at boundaries — APIs, user input, file uploads, environment variables.
- Never trust external data without validation.
- Validate response shape, not just status code — 200 with error body is a silent failure.

### Permissions
- Least privilege — request only permissions and scopes needed.
- No wildcard IAM policies. No `chmod 777`.
- GitHub Actions: pin action versions to commit SHA, not tags.

## Conventions (WARN on violation)

### Dependencies
- Audit new dependencies before adding: `npm audit`, `pip audit`, or equivalent.
- Check for known CVEs before adding any package.
- Pin to exact versions. No floating ranges in production.

## Verification Commands
```bash
# Secret scan staged files
rg "(sk-|ghp_|AKIA|Bearer [A-Za-z0-9+/]{20,})" $(git diff --staged --name-only)

# Secret scan entire repo (audit mode)
rg "(sk-|ghp_|AKIA|Bearer [A-Za-z0-9+/]{20,})" --glob "!*.lock" .

# Check for .env files accidentally staged
git diff --staged --name-only | grep -E "\.env$|\.env\."
```
