---
description: Manual code review trigger. Launches a subagent to review a diff for bugs, security, and convention violations. Use independently of Praxis phases.
---

You are running a manual code review.

**Step 1 — Determine diff scope**
Ask: "Review staged changes, last commit, or specific SHA?"
- Default to `git diff HEAD` if no answer within 10 seconds.
- Accept: `staged`, `HEAD`, `HEAD~N`, or a specific SHA.

**Step 2 — Gather the diff**
- Run the appropriate `git diff` command.
- If the diff is empty: "Nothing to review." Exit.
- If the diff exceeds 2000 lines: warn and ask whether to proceed or narrow scope.

**Step 3 — Load review context**
- Read project CLAUDE.md (if it exists in the repo root).
- Read the active plan (if `current_plan:` is set in vault status.md) — extract the SPEC only.
- Load rules based on file types in the diff:
  - `.tf` / `.tfvars` → `~/.claude/rules/terraform.md`
  - `.yml` / `.yaml` in `.github/` → `~/.claude/rules/github-actions.md`
  - `.ps1` / `.psm1` → `~/.claude/rules/powershell.md`
  - Any file → `~/.claude/rules/coding.md`, `~/.claude/rules/security.md`

**Step 4 — Launch subagent review**
Launch a subagent with ONLY these inputs (zero conversation history):
- The diff
- The SPEC (if available from Step 3)
- Relevant rules files (from Step 3)

Subagent prompt:
> Review this diff for bugs, edge cases, error handling gaps, security issues,
> and convention violations. Rate each finding:
> Critical / Major / Minor.
> Format: `{file}:{line} — {severity} — {description} — {fix}`

**Step 5 — Present findings**
Structure output by severity:

```
━━━ REVIEW RESULTS ━━━

CRITICAL ({n})
  {file}:{line} — {description} — {fix}

MAJOR ({n})
  {file}:{line} — {description} — {fix}

MINOR ({n})
  {file}:{line} — {description} — {fix}

CLEAN
  {files with no findings}
━━━━━━━━━━━━━━━━━━━━━━
```

**Step 6 — Remediation guidance**
- Critical: address immediately before proceeding.
- Major: recommend fixing before merge.
- Minor: note for future cleanup.
- If >3 findings: offer to re-run after fixes (max 3 rounds).

**Step 7 — Write review summary**
- Read vault_path from `~/.claude/praxis.config.json`
- Write summary to `{vault_path}/specs/review-{YYYY-MM-DD}-{slug}.md` with frontmatter:
  ```yaml
  ---
  tags: [review, {project-slug}]
  date: {YYYY-MM-DD}
  status: complete
  source: agent
  ---
  ```
- Vault indexing is automatic.

**Rules:**
- Works independently of Praxis phases.
- Never skip the subagent — review must come from fresh context.
- Subagent receives zero conversation history.
- If no project CLAUDE.md exists: proceed with base rules only.
