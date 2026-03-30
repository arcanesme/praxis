---
name: px-pre-commit-lint
disable-model-invocation: true
description: "Generate a stack-aware pre-commit hook script for a repo. Use when setting up a new repo, when asked to install pre-commit checks, add linting to commits, or wire pre-commit-lint. Also invoked by scaffold-new Phase 5.5. NOT invoked at commit time — generates a shell script that runs at commit time."
---

# pre-commit-lint Skill

## Deliverable
A `.git/hooks/pre-commit` bash script that:
1. Always runs: secret scan + git identity check
2. Conditionally runs: stack-specific linters based on staged file extensions
3. Hard blocks on secrets, identity mismatch, and critical lint failures
4. Warns (exit 0) on missing optional tools

## Acceptance
- [ ] `.git/hooks/pre-commit` exists and is executable
- [ ] `bash -n .git/hooks/pre-commit` passes
- [ ] Identity email hardcoded from repo CLAUDE.md
- [ ] Script detects staged file types before running stack checks
- [ ] All tool invocations guarded with `command -v <tool>`

## Boundaries
In scope: generating the pre-commit hook script

Out of scope:
- Script must complete in <10 seconds (performance constraint)
- NEVER invoke `claude` inside the hook
- Tool not found → WARN and skip, never block
- Only block on: secrets, identity mismatch, syntax errors
- Portable bash (no zsh-isms)

---

## Phase 0 — Detect Stack and Identity

1. Read `{repo_root}/CLAUDE.md` → extract `{identity_email}` and `{stack}`
2. Detect stack from repo: `git ls-files | grep -E "\.(tf|ps1|yml|py|ts|sh|go)$" | sed 's/.*\.//' | sort -u`
3. Check tool availability: tflint, trivy, actionlint, ruff, mypy, terraform, shellcheck, golangci-lint, hadolint, govulncheck, infracost, markdownlint, gitleaks, commitlint

## Phase 1 — Generate Hook

Always include: preamble (helpers, staged file detection), identity check, secret scan.
Append stack sections based on detected flags:
- **Terraform**: fmt check, validate, layer boundary enforcement, tflint
- **PowerShell**: StrictMode check, ErrorActionPreference check, PSScriptAnalyzer
- **Shell**: bash -n syntax, set -euo check, shellcheck
- **GitHub Actions**: actionlint, unpinned action check
- **Python**: ruff, mypy
- **Go** (if golangci-lint available): `golangci-lint run` on staged .go files
- **Security** (if tools available):
  - `gitleaks protect --staged` (replaces regex-based secret scan if gitleaks available)
- **Terraform security** (if tools available):
  - `trivy config --severity HIGH,CRITICAL --exit-code 1` on staged .tf files
  - `infracost breakdown --path=.` (advisory only, exit 0)
- **Docker** (if hadolint available):
  - `hadolint` on staged Dockerfiles
  - `trivy config` on staged Dockerfiles (if trivy available)
- **Dependencies** (if applicable):
  - `govulncheck ./...` (if go.mod exists and govulncheck available)
- **Markdown** (if markdownlint available):
  - `markdownlint` on staged .md files

### Commit Message Hook
Generate a SEPARATE `.git/hooks/commit-msg` file that runs:
- `commitlint --edit $1` (if commitlint available)

Append summary footer.

## Phase 2 — Write and Verify

1. Scan for unreplaced `{placeholder}` patterns — resolve all
2. Write to `{repo_root}/.git/hooks/pre-commit`
3. `chmod +x`
4. `bash -n` syntax validation
5. Report: checks enabled, tools missing

## Error Handling

| Condition | Action |
|-----------|--------|
| CLAUDE.md missing Identity | Ask user for email |
| `bash -n` fails | Fix before writing |
| `.git/` not found | STOP — not a git repo |
| All tools missing for stack | Warn, generate with skip guards |

## Removal Condition
Remove when hooks managed globally via dotfiles bootstrap.
