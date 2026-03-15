# Execution Loop — Rules
# Scope: All projects, all sessions
# Extracted from ~/.claude/CLAUDE.md to reduce root file size

## Core Loop (MANDATORY — every non-trivial task)

### Phase 1: SPEC
Answer four questions before any code or file is written:
- **WHAT**: Concrete deliverable (not vague goals)
- **DONE-WHEN**: Specific checks that prove completion
- **CONSTRAINTS**: Performance, compatibility, style requirements
- **NON-GOALS**: What this task explicitly does NOT include
If ambiguous: ask 2–3 clarifying questions before proceeding.

### Phase 2: PLAN
- Break work into milestones small enough to complete and verify in one pass.
- Each milestone MUST have: description, acceptance criteria, validation command.
- Save plan to `{vault_path}/plans/YYYY-MM-DD_[task-slug].md` with frontmatter:
  ```yaml
  ---
  created: YYYY-MM-DD
  status: active
  tags: [relevant, tags]
  ---
  ```
- Update `{vault_path}/status.md` → `current_plan:` field.
- Do NOT begin implementation until the plan is approved.

### Phase 3: IMPLEMENT
- One milestone at a time. Keep diffs scoped.
- Do not expand scope without explicit approval.
- Use extended thinking for tasks touching >3 files or requiring architectural decisions.

### Phase 4: VALIDATE
After EACH milestone — show actual output, not assertions:
1. Run test suite → show output
2. Run linter → show output, fix ALL warnings
3. Run typecheck (if applicable) → show output
4. Run build (if applicable) → show output
5. Report: PASS or FAIL with specifics

### Phase 5: REPAIR (Stop-and-Fix)
If ANY validation fails:
- Do NOT proceed to the next milestone.
- Fix NOW. Re-validate. Then proceed.
- If cannot fix in 3 attempts: STOP.
  Report: **What** (full error + 3 attempts) → **So What** (root cause) → **Now What** (next steps)

### Phase 6: COMMIT
- Commit at milestone completion. See git-workflow.md.
- Never let uncommitted work span multiple milestones.

### Phase 7: LOG
- Update `{vault_path}/status.md`: what was done, decisions made, what's next.
- Mark completed milestone status in the plan file.
- Update `{vault_path}/_index.md` goals if project direction changed.
- Run `qmd update` after any vault file writes.

### Phase 8: REPEAT
Next milestone. Loop until plan complete.

## Self-Review Protocol
After ALL milestones, before reporting done:
1. Use a subagent to review the diff as a critical code reviewer.
   Prompt: "Review this diff for bugs, edge cases, error handling gaps, security issues,
   and violations of project conventions. Rate each: Critical / Major / Minor."
   — Subagent receives ONLY: the diff, the SPEC, relevant rules files. NOT the conversation history.
2. Address all Critical and Major findings.
3. Re-validate after fixes.
4. If reviewer found >3 issues: run review again (max 3 rounds).

## Context Management
- Use subagents (Task tool) for exploration, research, and review.
- One feature per session. Do not mix unrelated tasks.
- After 2 failed corrections: suggest /clear and fresh start with better prompt.
- When compacting: preserve active plan path, current milestone, last 3 decisions, any STOP conditions.
