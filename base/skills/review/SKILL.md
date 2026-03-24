---
name: review
disable-model-invocation: true
description: "Manual code review trigger. Launches a subagent to review a diff for bugs, security, and convention violations. Use independently of Praxis phases."
---

# review Skill

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
  - Any file → `~/.claude/rules/coding.md`

**Step 4 — Launch subagent review**
Launch a subagent with ONLY these inputs (zero conversation history):
- The diff
- The SPEC (if available from Step 3)
- Relevant rules files (from Step 3)

Subagent prompt:
> You are a critical code reviewer. Review this diff for bugs, edge cases,
> error handling gaps, security issues, and convention violations.
> Rate each finding: Critical / Major / Minor.
> Format: `{file}:{line} — {severity} — {description} — {fix}`
> If the diff is clean, say "No findings."

Do NOT include any conversation history, project context, or user preferences
beyond the explicitly provided inputs.

**Step 5 — Present findings**
Parse the subagent output and structure by severity:

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

**Step 7 — Write review findings to vault**
- Read vault_path from `~/.claude/praxis.config.json`
- Write full structured findings to `{vault_path}/specs/review-{YYYY-MM-DD}-{slug}.md`:
  ```markdown
  ---
  tags: [review, {project-slug}]
  date: {YYYY-MM-DD}
  status: complete
  source: agent
  ---
  # Code Review — {slug} ({date})

  ## Findings

  ### CRITICAL ({n})
  {file}:{line} — {description} — {fix}

  ### MAJOR ({n})
  {file}:{line} — {description} — {fix}

  ### MINOR ({n})
  {file}:{line} — {description} — {fix}

  ## Clean Files
  {list of files with no findings}

  ## Diff Scope
  {git diff command used}
  ```

## Error Handling

| Condition | Action |
|-----------|--------|
| Empty diff | "Nothing to review." Exit. |
| Subagent fails to launch | Return error, do not retry |
| Subagent output unparseable | Return raw output as single Minor finding |
| Rules file missing | Warn, proceed with available rules |

## Callers

| Caller | Context |
|--------|---------|
| User via `/review` | Manual review trigger |
| `/verify` Step 5 | Post-milestone Self-Review Protocol |
| `execution-loop.md` | Self-Review Protocol reference |

## Rules
- Works independently of Praxis phases.
- Never skip the subagent — review must come from fresh context.
- Subagent receives zero conversation history.
