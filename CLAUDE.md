# Praxis
<!-- MAP: This file is ~60 lines. If you're adding explanation, it belongs in ~/.claude/rules/ -->

## Overview
Layered Claude Code harness — workflow discipline, AI-Kits, persistent vault integration

## Global Rules
Inherits execution engine from `~/.claude/CLAUDE.md`.
Phases (SPEC → PLAN → IMPLEMENT → VALIDATE → REPAIR → COMMIT → LOG → REPEAT),
self-review protocol, and code quality standards apply without exception.

## Identity
- **Type**: Personal
- **Git profile**: personal
- **SSH key**: default
- **Email**: jeffreyattoh@reddogsme.com
- **includeIf path**: /Users/esoteric-mac/Documents/Projects/Personal/praxis

If `git config user.email` does not return `jeffreyattoh@reddogsme.com`, STOP before any commit.

## Vault Project
- **Vault path**: /Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis
- **Project index**: `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/_index.md`

Code lives here. Knowledge, decisions, and plans live in the vault.

| Purpose | Location |
|---------|----------|
| Project metadata | `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/_index.md` |
| Execution plans | `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/plans/` |
| Execution state | `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/status.md` |
| Machine-readable state | `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/claude-progress.json` |
| Agent learnings | `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/notes/learnings.md` |
| Specs & decisions | `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/specs/` |

## Tech Stack
- Node.js
- Bash
- Markdown

## Commands
```bash
dev:    node --check bin/praxis.js
test:   node --check bin/praxis.js
lint:   bash scripts/lint-harness.sh .
build:  # N/A — no build step
format: # N/A — no formatter configured
```

## Code Style
- Prefer simple, readable code over clever abstractions
- After finishing implementation, run `/px-simplify` to clean up
- If a fix feels hacky, find a cleaner solution before finishing
- No AI-generated comments or attributions in code or commits

## Verification
- Before marking any task complete, run the test suite
- Check logs before claiming a bug is fixed
- End every task instruction with a verification step
- Use `/px-verify-app` for end-to-end checks

## Conventions
- **Commits**: conventional commits (feat:, fix:, docs:, refactor:, test:, chore:)
- **Branches**: `feat/description` or `fix/description`
- **Plans**: `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/plans/YYYY-MM-DD_[task-slug].md`
- **Learnings**: `/Users/esoteric-mac/Documents/Esoteric Vault/01_Projects/Personal/_active/praxis/notes/learnings.md` using [LEARN:tag] schema

## Error Learning
- **Shell JSON via heredoc breaks on special chars** — Always use `jq -n` with `--arg` for safe JSON construction. Never interpolate shell variables into JSON heredocs.
- **npx caches stale versions** — Always use `npx @esoteric-logic/praxis-harness@latest` with `@latest` suffix. Without it, machines reuse cached older versions.
- **Escaped spaces in config paths** — Vault paths in `praxis.config.json` must use literal spaces, not `\\ ` escapes. `jq -r` outputs escaped backslashes verbatim, breaking filesystem access.
- **Secret-scan hook scans entire file** — The PreToolUse secret-scan hook checks the whole file on any edit, not just the diff. Files containing secret-matching regex patterns (like the `/px-ship` skill) cannot be edited via the Edit tool — use `cat >>` append instead.
- **gh auth identity mismatch** — Personal repos need `gh auth switch --user <personal>` before push. The active `gh` account defaults to work identity, which lacks push access to personal repos.

## Project-Specific Rules

## Memory
Keep MEMORY.md under 80 lines. Use topic files for overflow.
Prefer linking to Obsidian vault notes over expanding MEMORY.md.
Run `/px-sync-memory` when MEMORY.md exceeds 80 lines.

## After Compaction — Bootstrap Sequence

**Step 1** — Read this file top to bottom first.
**Step 2** — Active task? → read active plan. No task? → read status.md.
**Step 3** — Load stack rules only if the current task touches them.

## Compact Preservation
When compacting, always preserve:
- Active plan path
- Current milestone
- Last 3 decisions and rationale
- Any STOP conditions or blockers
