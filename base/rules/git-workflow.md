# Git Workflow — Rules
# Scope: All projects with git repos

## Identity — Invariants (BLOCK on violation)
<!-- NOTE: This is a TEMPLATE. install.sh generates the real file with actual identities. -->

| Type | gitconfig | SSH Key | Email | Path Match |
|------|-----------|---------|-------|------------|
| Work | {identity.work.gitconfig} | {identity.work.ssh_key} | {identity.work.email} | {identity.work.path_match} |
| Personal | {identity.personal.gitconfig} | {identity.personal.ssh_key} | {identity.personal.email} | {identity.personal.path_match} |

**Verification:** `git --no-pager config user.email`
**On mismatch:** STOP. Report `expected: X, got: Y`. Do not commit.

## Branch Strategy
- Feature branches off `main`: `feat/[task-slug]` or `fix/[task-slug]`
- Never commit directly to `main`
- Delete branches after merge

## Commit Standards
- Commit at every completed milestone. Never batch milestones into one commit.
- Format:
  ```
  type(scope): concise description

  - What changed and why (not how)
  - Milestone reference if applicable
  ```
  Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- Never amend published commits — use new commits for fixes.
- Always use `git --no-pager` for all git commands.
- Keep working tree clean — no untracked debris, no partial stages.

## Pre-Commit Invariants (BLOCK on violation)
1. Secret scan staged files: `rg "(sk-|ghp_|pplx-|AKIA|Bearer [A-Za-z0-9+/]{20,}|DefaultEndpointsProtocol|AccountKey=)" $(git diff --staged --name-only)`
2. Confirm `git config user.email` matches expected identity for this repo path.
3. Run stack linter (see terraform.md, github-actions.md as applicable).
4. Run typecheck if applicable — no commits with type errors.

## Rollback Protocol
When a previously-passing milestone breaks:
1. Identify breaking commit: `git bisect` or `git --no-pager log --oneline`
2. Surgical fix (<10 lines, isolated): fix forward, re-validate, commit.
3. Complex or unclear: `git revert <breaking-commit>`, re-validate, re-approach with revised plan.
4. Never leave `main` broken. If can't fix or revert cleanly: STOP and report.

## Vault Git Checkpoint Rule
Vault is git-tracked. Read vault_path from `~/.claude/praxis.config.json`.
- Auto-committed at session end by the export hook.
- Do not manually commit vault files during a session unless explicitly asked.
- Vault indexing is automatic (obsidian) or not needed (other backends).
