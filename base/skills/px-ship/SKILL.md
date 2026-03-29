---
name: px-ship
disable-model-invocation: true
description: Commit, push, and open a PR in one shot. Runs pre-commit checks, crafts a commit message, pushes, and creates a PR with structured description. Use when a milestone or feature is complete and verified.
---

You are running the ship workflow — commit, push, and PR in one command.

**Step 1 — Pre-flight checks**
- Read project CLAUDE.md for build/test/lint commands
- Run in order (all must pass):
  1. Secret scan: `rg "(sk-|ghp_|pplx-|AKIA|Bearer [A-Za-z0-9+/]{20,}|DefaultEndpointsProtocol|AccountKey=)" $(git diff --staged --name-only)`
  2. Linter (from CLAUDE.md `## Commands`)
  3. Typecheck (if applicable)
  4. Test suite (from CLAUDE.md `## Commands`)
  5. Identity check: `git --no-pager config user.email` must match expected
  6. Secret deep scan: `gitleaks protect --staged` (if gitleaks available)
  7. Security scan: `semgrep --config=auto --error .` (if semgrep available, on staged files)
  8. Dependency check: `govulncheck ./...` (if Go project with go.mod)
  9. Cost check: `infracost breakdown --path=.` (if Terraform project — advisory only, do not block)
- Any HIGH/CRITICAL finding in steps 6-8 blocks the ship. Cost check is informational.
- If tools not installed: skip with note, do not block.
- If ANY check fails: STOP. Fix first, then re-run `/ship`.

**Step 2 — Stage and review changes**
- Run `git status` and `git diff --stat`
- Show the user what will be committed
- If nothing to commit: "Nothing to ship." Exit.
- If unstaged files exist: ask which to include

**Step 3 — Craft commit message**
- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Read the active plan (if set) for context on what was accomplished
- Format:
  ```
  {type}({scope}): {short description}

  {optional body — what changed and why, not how}
  ```
- Show the commit message for approval before committing

**Step 4 — Commit and push**
- `git add` the agreed files
- `git commit` with the approved message
- `git push -u origin HEAD`
- If push fails (no remote, branch conflict): report and suggest fix

**Step 5 — Create PR**
Ask: "Open a PR?" (default: yes)

If yes:
- Detect base branch from git config or default to `main`
- Read vault_path from `~/.claude/praxis.config.json`
- If active plan exists: extract objective and done-when for PR description
- Create PR using `gh pr create`:
  ```
  ## What changed
  {summary from commit + plan context}

  ## Why
  {from plan objective or user context}

  ## How to verify
  {from plan done-when, or suggest specific commands}
  ```

**Step 6 — Report**
```
SHIPPED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Commit:  {short sha} {message}
Branch:  {branch} → {base}
PR:      {url}
Checks:  secrets ✓  lint ✓  types ✓  tests ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Rules:**
- Never skip pre-flight checks. They are the safety net.
- Never force-push without explicit user approval.
- If the diff touches >20 files: warn about PR size and suggest splitting.
- This command is the end of a Praxis cycle — run after `/verify` passes.

**Step 7 — Update vault tracking**
- Read vault_path from `~/.claude/praxis.config.json`
- Update `{vault_path}/claude-progress.json`: append to `features[]` with `{ "name": "{feature description}", "date": "{YYYY-MM-DD}", "commit": "{short sha}", "pr_url": "{url or null}" }`.
