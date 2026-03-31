---
name: px-verify
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
5. **Security scan** (if tools available):
   - **Go**: `gosec ./...` OR `golangci-lint run --enable=gosec` (if golangci-lint available)
   - **DeepSource**: `deepsource issues list <file>` for files in diff (if deepsource CLI available)
   - If either tool finds HIGH/CRITICAL: treat as blocking — must fix before proceeding.
   - If tools not installed: skip with advisory note, do not block. DeepSource cloud validates on push.
6. **Quality gate** → run `/px-quality-gate` on changed files → BLOCK on naming/prose/structure violations. See `px-quality-gate` skill for full check list.
7. **Functional check** — ask: "Is there a smoke test, `terraform plan` output, or browser check needed for this milestone?" If yes: block until user confirms it passed. If no: proceed.

Read test/lint/build commands from the project CLAUDE.md `## Commands` section.
If no commands are defined: warn and ask user for the correct commands.

**Step 2 — Report result**
- **PASS**: All checks green. Proceed to Step 3.
- **FAIL**: Trigger repair (Step 4).

**Step 3 — On PASS**
1. Update the active plan file: mark milestone status as complete
2. Update `{vault_path}/claude-progress.json`: append the completed milestone to `milestones[]` with `{ "name": "{milestone name}", "date": "{YYYY-MM-DD}", "plan_ref": "{plan filename}" }`.
3. Commit immediately — verification passed, no permission needed.
   Use conventional commit format. See git-workflow.md.
4. Check if more milestones remain:
   - Yes → "Milestone committed. Run `/execute` for the next milestone."
   - No → "All milestones committed. Running self-review."
5. After ALL milestones: trigger Self-Review Protocol (Subagent Isolation)
   - Launch a subagent for code review. The subagent receives ONLY:
     1. The diff: `git diff main...HEAD` (or `git diff HEAD~N` for N commits)
     2. The SPEC/ACCEPTANCE section from the active plan
     3. Relevant rules files (scoped to file types in the diff)
   - The subagent must NOT receive session conversation history or implementation notes.
   - Two-pass review:
     - **Pass 1 — Spec compliance**: Does the diff deliver what ACCEPTANCE requires? Flag gaps.
     - **Pass 2 — Code quality**: Bugs, security issues, dead code, missing error handling, maintainability.
   - If either pass finds issues: list them. Do not auto-fix — report back to the operator.

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
Run `/repair` — it handles the structured fix-and-verify loop:
- Captures the failure, classifies root cause, attempts up to 3 fixes
- Re-runs validation after each attempt
- STOPs with What/So What/Now What after 3 failures
- Writes repair trace and learnings to vault

**Rules:**
- Never say "tests pass" without showing output.
- Never skip lint warnings — they compound into tech debt.
- Validation is the evidence. Conversation claims are not.
