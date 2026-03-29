---
name: px-repair
disable-model-invocation: true
description: "Structured repair phase for failed milestones. 3-attempt fix-and-verify loop with root cause analysis. Triggered by /verify failure or manually."
---

# repair Skill

You are running a structured repair cycle for a failed milestone.

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`.

## Acceptance
- [ ] Failure captured with exact error, file, line
- [ ] Root cause classified (flawed implementation vs flawed spec)
- [ ] Fix applied with minimal diff
- [ ] Validation passes after fix
- [ ] Repair trace written to vault

## Boundaries
- No refactoring — fix the failure, nothing else
- No scope expansion — do not add features or change behavior beyond the fix
- No new files unless the fix requires them
- Maximum 3 attempts before STOP

---

**Step 1 — Capture failure**
- Read the failure output from `/verify` (or ask user for the error)
- Extract: exact error message, file(s), line number(s), test name (if applicable)
- State the failure in one sentence:
  `Failure: {what failed} in {file}:{line} because {symptom}.`

**Step 2 — Classify root cause**
Determine whether this is:
- **Flawed implementation** → the code doesn't match the spec. Fix forward.
- **Flawed spec** → the spec itself is wrong or incomplete. STOP.
  Report to user: "Spec issue detected: [describe the issue]. Run `/discuss` to re-spec before continuing."
  Do not attempt to fix spec issues — that's a different phase.

**Step 3 — Fix attempt (attempt {n}/3)**
- State what you're changing and why in one sentence
- Apply the minimal fix — smallest diff that addresses the root cause
- Do not refactor surrounding code
- Do not fix unrelated issues discovered during repair

**Step 4 — Re-validate**
Run the full validation sequence from `/verify` Step 1:
1. Test suite
2. Linter
3. Typecheck (if applicable)
4. Build (if applicable)

**Step 4b — Post-fix security re-scan**
After applying the fix, run the full validation sequence from /verify Step 1 (including security scan).
If the original failure was security-related:
1. Re-run the exact scanner that found the original issue
2. Confirm the specific finding is resolved
3. Verify the fix didn't introduce NEW findings in the same file

**Step 5 — Evaluate result**
- **PASS** → Milestone repaired. Commit the fix. Return to workflow.
  Output: `Repaired: {what was fixed} in {file}. Next: continue with /execute or /verify.`
- **FAIL (same error)** → Root cause was misidentified. Re-analyze in Step 2.
- **FAIL (different error)** → Fix introduced a regression. Revert the fix, re-analyze.
- Track attempt count. If attempt 3 fails → Step 6.

**Step 6 — STOP after 3 failures**
Do not attempt a 4th fix. Report:

```
REPAIR FAILED — 3 attempts exhausted
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What:    {original failure + all 3 attempt descriptions}
So What: {root cause analysis — why 3 fixes didn't work}
Now What: {recommended next step: re-spec, different approach, escalate}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Step 7 — Write repair trace to vault**
Whether the repair succeeded or failed, write to `{vault_path}/notes/{YYYY-MM-DD}_repair-trace.md`:

```markdown
---
tags: [repair, {project-slug}]
date: {YYYY-MM-DD}
source: agent
---
# Repair Trace — {short title}

## Original Failure
{error message, file, line}

## Root Cause
{classification: flawed implementation | flawed spec}
{root cause statement}

## Attempts
### Attempt 1
- Fix: {what was changed}
- Result: {PASS | FAIL — error}

### Attempt 2 (if applicable)
- Fix: {what was changed}
- Result: {PASS | FAIL — error}

### Attempt 3 (if applicable)
- Fix: {what was changed}
- Result: {PASS | FAIL — error}

## Resolution
{Fixed in attempt N | FAILED — escalated}
```

**Step 8 — Write learning (if applicable)**
If the repair reveals a recurring pattern, write a `[LEARN:bugfix]` entry to `{vault_path}/notes/learnings.md`.

## Error Handling

| Condition | Action |
|-----------|--------|
| No failure output provided | Ask user for error details |
| Spec issue detected | STOP, redirect to `/discuss` |
| Fix causes new failure | Revert fix, count as failed attempt |
| Cannot identify root cause | Count as failed attempt, try different angle |

## Callers

| Caller | When |
|--------|------|
| `/verify` Step 4 | On FAIL — delegates to `/repair` |
| Manual `/repair` | Any time a fix is needed |

## Removal Condition
Remove when an automated repair agent (e.g., SWE-agent) handles fix-and-verify loops with equivalent quality.
