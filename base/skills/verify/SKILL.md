---
name: verify
disable-model-invocation: true
description: Validation phase — runs test/lint/typecheck/build and reports PASS or FAIL. Use after each milestone completion.
---

You are running the verification phase for the current milestone.

**Step 1 — Run validation sequence**
Execute in order, showing actual output (never assertions):
1. **Test suite** → run the project test command → show output
2. **Linter** → run the project lint command → show output, fix ALL warnings
3. **Typecheck** (if applicable) → show output
4. **Build** (if applicable) → show output
5. **Functional check** — ask: "Is there a smoke test, `terraform plan` output, or browser check needed for this milestone?" If yes: block until user confirms it passed. If no: proceed.

Read test/lint/build commands from the project CLAUDE.md `## Commands` section.
If no commands are defined: warn and ask user for the correct commands.

**Step 2 — Report result**
- **PASS**: All checks green. Proceed to Step 3.
- **FAIL**: Trigger repair (Step 4).

**Step 3 — On PASS**
1. Update the active plan file: mark milestone status as complete
2. Commit immediately — verification passed, no permission needed.
   Use conventional commit format. See git-workflow.md.
3. Check if more milestones remain:
   - Yes → "Milestone committed. Run `/execute` for the next milestone."
   - No → "All milestones committed. Running self-review."
4. After ALL milestones: trigger Self-Review Protocol
   - Launch a subagent to review the full diff as a critical code reviewer
   - Subagent receives ONLY: the diff, the SPEC (from plan file `## SPEC` section), relevant rules files
   - Address all Critical and Major findings before reporting done

**Step 3b — UNIFY (mandatory after all milestones verified)**
After self-review passes, write phase summary:
- Write `{vault_path}/plans/{YYYY-MM-DD}_{project-slug}-phase-summary.md`:
  ```markdown
  ---
  tags: [unify, {project-slug}]
  date: {YYYY-MM-DD}
  source: agent
  ---
  # Phase Summary: {plan title}

  ## Planned vs Actual
  - Original milestones: {list from plan}
  - Completed: {list with dates}
  - Changed or dropped: {list with reasons}

  ## Decisions Made
  - {decision}: {rationale}

  ## Acceptance Criteria
  | Criterion | Status |
  |-----------|--------|
  | {from Done When} | PASS / FAIL |

  ## Deferred Items
  - {item}: {reason deferred, suggested next step}
  ```
- Run `/simplify` on the full diff to clean up implementation
- Report: "Phase summary written. Run `/verify-app` for e2e checks, then `/ship` to commit+push+PR."

**Rules:**
- UNIFY fires after ALL milestones verified, not per-milestone. session-retro still runs at session end for learnings — complementary, not redundant.
- `/simplify` runs after UNIFY, before shipping. It is the quality gate between "it works" and "it's clean".

**Step 4 — On FAIL (Stop-and-Fix)**
1. Identify the failure: exact error, file, line
2. Fix NOW. Do not proceed to the next milestone.
3. Re-run the full validation sequence (Step 1)
4. If still failing after 3 attempts: STOP.
   Report: **What** (full error + 3 attempts) → **So What** (root cause) → **Now What** (next steps)
5. Write failure details to the active plan file if >1 attempt was needed

**Rules:**
- Never say "tests pass" without showing output.
- Never skip lint warnings — they compound into tech debt.
- Validation is the evidence. Conversation claims are not.
