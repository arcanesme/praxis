---
paths:
  - ".github/workflows/**"
  - ".github/actions/**"
---
# GitHub Actions — Rules
# Scope: Projects with .github/workflows/*.yml files

## Invariants (BLOCK on violation)

### Secret Handling
- NEVER hardcode secrets in workflow files — use `${{ secrets.NAME }}` only.
- NEVER print secrets to logs — mask all secret values.
- Check: `rg "(password|token|key|secret)\s*[:=]\s*['\"]?[A-Za-z0-9+/]{8,}" .github/`
- On violation: BLOCK commit immediately.

### Action Pinning
- Pin all third-party actions to a full commit SHA, not a tag.
  Correct:   `uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683`
  Incorrect: `uses: actions/checkout@v4`

### Permissions
- Declare explicit `permissions:` block on every job — no implicit defaults.
- Minimum required permissions only. No `write-all`.

## Conventions (WARN on violation)

### Workflow Structure
- One workflow file per concern (deploy, test, lint — not one monolithic workflow)
- Job names: kebab-case, descriptive (`deploy-staging`, not `job1`)
- Use `environment:` protection rules for production deployments

### Triggers
- Be explicit — avoid `on: push` without branch filters
- PRs: `on: pull_request: branches: [main]`
- Deploys: `on: push: branches: [main]` or manual `workflow_dispatch`

## Verification Commands
```bash
# actionlint (if installed)
actionlint .github/workflows/*.yml

# Check for unpinned actions
rg "uses: [^@]+@(v[0-9]|main|master|latest)" .github/

# Check for hardcoded secrets
rg "(password|token|key|secret)\s*[:=]\s*['\"]?[A-Za-z0-9+/]{8,}" .github/
```
