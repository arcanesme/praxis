---
name: code-quality
version: 1.0.0
description: "Code quality enforcement — parallel deterministic gate (SAST, secrets, SCA, IaC) + AI review layer (over-engineering, smells, structure, performance)"
activation: /kit:code-quality
deactivation: /kit:off
skills_chain:
  - phase: gate
    skills: [sast-scan, secrets-scan, sca-scan, iac-scan]
    status: active
  - phase: ai-review
    skills: [over-engineering, code-smells, structural-review, performance-review, test-quality]
    status: active
  - phase: self-review
    skills: [self-review]
    status: active
---

# Code Quality Kit

Parallel deterministic gate + AI review layer for comprehensive code quality enforcement.

## Architecture

```
LAYER 1 — Deterministic Gate (pre-push)
  SAST (OpenGrep) → Secrets (TruffleHog) → SCA (OSV-Scanner) → IaC (Checkov)
  All run in parallel. CRITICAL = block. HIGH = block if new. MEDIUM = warn.

LAYER 2 — AI Review (post-commit)
  Over-engineering → Code smells → Structural quality → Performance → Test quality
  Produces structured JSON findings. CRITICAL = block. HIGH = warn.
```

## Tools Required
- `opengrep` — SAST scanner (Semgrep fork, free)
- `trufflehog` — secrets scanner
- `osv-scanner` — dependency vulnerability scanner (Google)
- `checkov` — IaC policy scanner
- `jq` — JSON processing
- `bc` — arithmetic in shell

## Install
```bash
bash ~/.claude/kits/code-quality/install.sh
```

## Uninstall
```bash
bash ~/.claude/kits/code-quality/teardown.sh
```

## Configuration
- `configs/thresholds.json` — gate policy, coverage thresholds, complexity limits
- `configs/checks-registry.json` — all checks with severity, category, fix guidance
