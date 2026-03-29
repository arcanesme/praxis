---
name: freshness
disable-model-invocation: true
description: "Full dependency audit — detects outdated packages, known vulnerabilities, unmaintained deps, and typosquat risks. Produces structured report with severity classification."
---

# /freshness — Dependency Hygiene Audit

On-demand audit of all dependency manifests in the current project. Checks freshness, vulnerabilities, maintenance status, and supply chain risks.

## When to Use
- Before major releases or deployments
- When `dep-audit.sh` hook reports findings
- Periodic hygiene check (monthly recommended)
- After inheriting or onboarding to a new codebase

## Step 1 — Detect Manifests

Scan the repo root and common subdirectories for:
- `package.json` (npm/Node.js)
- `go.mod` (Go)
- `requirements.txt` / `pyproject.toml` / `Pipfile` (Python)
- `Cargo.toml` (Rust)
- `*.tf` with `required_providers` blocks (Terraform)

Report which manifests were found and which ecosystems will be audited.

## Step 2 — Run Ecosystem Auditors

For each detected manifest, run the appropriate tool (skip if not installed):

| Ecosystem | Audit command | Fallback |
|-----------|--------------|----------|
| npm | `npm audit --audit-level=high --json` | `npm outdated --json` |
| Go | `govulncheck ./...` | `go list -m -u all` |
| Python | `pip-audit --format=json` | `pip list --outdated --format=json` |
| Rust | `cargo audit` | `cargo outdated` |
| Cross-ecosystem | `osv-scanner --recursive .` | Skip |

Capture all output — this is evidence for the report.

## Step 3 — Classify Findings

For each finding, classify severity:

| Severity | Criteria | Action |
|----------|----------|--------|
| **CRITICAL** | Known exploited CVE, or CVSS ≥ 9.0 | Fix now, same session |
| **HIGH** | CVSS 7.0–8.9, or 3+ major versions behind | Fix within 1 week |
| **MEDIUM** | CVSS 4.0–6.9, or 2 major versions behind | Log as tech debt |
| **INFO** | Minor version behind, or low-risk advisory | Note for next update cycle |

## Step 4 — Check Maintenance Status

For each direct dependency:
1. Check last release date — flag if > 12 months with no release
2. Check if repository is archived
3. Flag potential typosquat patterns:
   - Extra/swapped characters: `reqest` vs `request`
   - Hyphen/underscore swap on wrong ecosystem
   - Suffix additions: `reactjs`, `react.js` vs `react`

## Step 5 — Produce Report

Output a structured table:

```
| Package | Pinned | Latest | Gap | CVEs(12mo) | Last Release | Status |
|---------|--------|--------|-----|-----------|-------------|--------|
```

Status values: `✓ Current` | `⚠ Outdated` | `✗ Vulnerable` | `☠ Critical` | `✗✗ Unmaintained`

Group by severity:
1. **CRITICAL** — fix now
2. **HIGH** — fix this session
3. **MEDIUM** — log as tech debt
4. **INFO** — note for future

## Step 6 — Archive to Vault

Read `vault_path` from `~/.claude/praxis.config.json`.
If available, write to `{vault_path}/specs/dep-audit-{YYYY-MM-DD}.md`:

```yaml
---
tags: [dep-audit, security]
date: YYYY-MM-DD
source: agent
---
```

Include: full table, tool output summaries, recommended actions.
