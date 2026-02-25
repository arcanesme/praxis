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
tool: null        # prettier | black | gofmt | rustfmt | custom
command: null     # e.g., "npx prettier --write ."
```

### Linter
```yaml
enabled: false
tool: null        # eslint | ruff | golangci-lint | clippy | custom
command: null     # e.g., "npx eslint . --fix"
```

### Type Checker
```yaml
enabled: false
tool: null        # tsc | mypy | pyright | custom
command: null     # e.g., "npx tsc --noEmit"
```

### Security Scanner
```yaml
enabled: false
tool: null        # trivy | bandit | npm-audit | custom
command: null     # e.g., "bandit -r src/"
```

### Tests
```yaml
enabled: false
runner: null      # jest | pytest | go test | cargo test | custom
command: null     # e.g., "npm test"
coverage: false   # include coverage report
```

### Custom Checks
```yaml
# Add any project-specific checks here
checks: []
# Example:
# - name: "Check for hardcoded secrets"
#   command: "grep -rn 'API_KEY=' src/ && exit 1 || exit 0"
# - name: "Validate OpenAPI spec"
#   command: "npx @redocly/cli lint openapi.yaml"
```

## Verification Modes

### Quick (at phase checkpoints)
Run: formatter, linter
Skip: security, full test suite

### Full (at track completion and on-demand)
Run: all enabled checks

### PR (triggered by Codex 5.3 review)
Run: all enabled checks + spec compliance
