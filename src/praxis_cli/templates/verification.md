---
last_updated: null
---

# Verification Rules

> Per-project configuration for automated checks. Updated during `praxis setup`.
> These rules are executed by the `verify` command and at every phase checkpoint.

## Format
Define the command to run. Leave blank or set `enabled: false` to skip.

### Formatter
```yaml
enabled: false
command: null     # e.g., "black .", "npx prettier --write ."
```

### Linter
```yaml
enabled: false
command: null     # e.g., "ruff check .", "npx eslint . --fix"
```

### Type Checker
```yaml
enabled: false
command: null     # e.g., "mypy src/", "npx tsc --noEmit"
```

### Security Scanner
```yaml
enabled: false
command: null     # e.g., "bandit -r src/", "trivy fs ."
```

### Tests
```yaml
enabled: false
command: null     # e.g., "pytest", "npm test"
```

## Verification Modes

### Quick (at phase checkpoints)
Run: formatter, linter

### Full (at track completion and on-demand)
Run: all enabled checks
