# {Project Name}
<!-- MAP: This file is ~60 lines. If you're adding explanation, it belongs in ~/.claude/rules/ -->

## Overview
{one-line description}

## Global Rules
Inherits execution engine from `~/.claude/CLAUDE.md`.
Phases (SPEC → PLAN → IMPLEMENT → VALIDATE → REPAIR → COMMIT → LOG → REPEAT),
self-review protocol, and code quality standards apply without exception.

## Identity
- **Type**: {type}
- **Git profile**: {identity_profile}
- **SSH key**: {ssh_key}
- **Email**: {identity_email}
- **includeIf path**: {repo_root}

If `git config user.email` does not return `{identity_email}`, STOP before any commit.

## Vault Project
- **Vault path**: {vault_path}
- **Project index**: `{vault_path}/_index.md`

Code lives here. Knowledge, decisions, and plans live in the vault.

| Purpose | Location |
|---------|----------|
| Project metadata | `{vault_path}/_index.md` |
| Execution plans | `{vault_path}/plans/` |
| Execution state | `{vault_path}/status.md` |
| Machine-readable state | `{vault_path}/claude-progress.json` |
| Agent learnings | `{vault_path}/notes/learnings.md` |
| Specs & decisions | `{vault_path}/specs/` |

## Tech Stack
- {stack_item_1}
- {stack_item_2}
- {stack_item_3}

## Commands
<!-- Populated by scaffold-new based on detected stack -->

### Go
```bash
test:     go test ./...
lint:     golangci-lint run
format:   goimports -w . && shfmt -w .
typecheck: go build ./...
security: govulncheck ./... && semgrep --config=auto --error .
```

### Terraform
```bash
lint:     tflint --recursive && trivy config .
format:   terraform fmt -recursive
security: trivy config --severity HIGH,CRITICAL .
cost:     infracost breakdown --path=.
```

### General
```bash
dev:    # fill in as project develops
test:   # fill in as project develops
lint:   # fill in as project develops
build:  # fill in as project develops
format: # fill in as project develops
prose:  vale .
```

## Thresholds
- coverage_minimum: 80
- max_function_lines: 60
- max_cognitive_complexity: 20

## Code Style
- Prefer simple, readable code over clever abstractions
- After finishing implementation, run `/simplify` to clean up
- If a fix feels hacky, find a cleaner solution before finishing
- No AI-generated comments or attributions in code or commits

## Verification
- Before marking any task complete, run the test suite
- Check logs before claiming a bug is fixed
- End every task instruction with a verification step
- Use `/verify-app` for end-to-end checks

## Conventions
- **Commits**: conventional commits (feat:, fix:, docs:, refactor:, test:, chore:)
- **Branches**: `{type}/{description}` (e.g., `feat/add-auth`, `fix/nsg-rule`)
- **Plans**: `{vault_path}/plans/YYYY-MM-DD_[task-slug].md`
- **Learnings**: `{vault_path}/notes/learnings.md` using [LEARN:tag] schema

## Protected Files
<!-- Files that file-guard.sh blocks from modification -->
- go.sum
- go.mod
- .github/workflows/

## Error Learning
<!-- When a mistake is corrected, write a new rule here to prevent recurrence -->
<!-- Each rule should be specific and actionable -->

## Project-Specific Rules
<!-- Add rules discovered during development -->

## After Compaction — Bootstrap Sequence

**Step 1** — Read this file top to bottom first.
**Step 2** — Active task? → read active plan. No task? → read status.md.
**Step 3** — Load stack rules only if the current task touches them.
**Step 4** — Quality re-anchor: read most recent `compact-checkpoint.md` → check Quality State section.
If lint findings existed before compaction: re-run lint, confirm status.
If tests were failing before compaction: re-run tests, confirm status.

## Compact Preservation
When compacting, always preserve:
- Active plan path
- Current milestone
- Last 3 decisions and rationale
- Any STOP conditions or blockers
