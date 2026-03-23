---
name: verify-app
disable-model-invocation: true
description: End-to-end application verification. Launches a subagent to run the full
  test suite, check build, verify runtime behavior, and confirm acceptance criteria.
  Use after implementation to catch integration issues that unit tests miss.
  Side-effect skill — never auto-triggers.
---

# verify-app Skill

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`.
Detect current project by matching CWD to `local_path` in vault `_index.md`.

## Acceptance
- [ ] Full test suite passes (not just changed tests)
- [ ] Build succeeds with zero warnings
- [ ] Lint passes with zero warnings
- [ ] Typecheck passes (if applicable)
- [ ] Acceptance criteria verified (from active plan)
- [ ] No regressions detected in related functionality
- [ ] Verification report written

## Boundaries
Out of scope:
- Does not fix issues — reports them for the user to address
- Does not modify code
- Does not deploy or publish

---

## Phase 1 — Load Verification Context

- Read project CLAUDE.md `## Commands` section for test/build/lint commands
- If no commands defined: STOP. Ask user for the correct commands.
- Read active plan (if `current_plan:` set in status.md) — extract `## Done When` criteria
- Read `claude-progress.json` for current milestone context

## Phase 2 — Run Verification Suite

Execute in order, capturing ALL output:

### 2a — Build
```bash
{build_command from CLAUDE.md}
```
- PASS: zero exit code, zero warnings
- FAIL: capture full error output

### 2b — Lint
```bash
{lint_command from CLAUDE.md}
```
- PASS: zero exit code, zero warnings
- FAIL: capture warnings/errors with file:line

### 2c — Typecheck
```bash
{typecheck_command from CLAUDE.md}
```
- PASS: zero exit code
- FAIL: capture type errors
- SKIP: if no typecheck command configured

### 2d — Test Suite
```bash
{test_command from CLAUDE.md}
```
- PASS: all tests pass
- FAIL: capture failing test names + error output

### 2e — Acceptance Criteria
For each item in the plan's `## Done When`:
- If it's a command: run it and check output
- If it's a manual check: present to user for confirmation
- If it's a URL or UI check: ask user to verify
- Mark each criterion: PASS / FAIL / NEEDS HUMAN

## Phase 3 — Regression Check

Launch a subagent with zero conversation history:

```
You are a regression analyst. Given the following changes and test results,
identify potential regressions in related functionality.

## Recent changes
{git diff HEAD~1 --stat}

## Changed files
{list of modified files}

## Test output
{test suite output}

## Questions to answer:
1. Are there changed files with no corresponding test coverage?
2. Do any changed files have downstream consumers that weren't tested?
3. Are there integration points (API boundaries, shared state, event handlers)
   that the unit tests might miss?
4. Based on the file names and structure, what manual checks would you recommend?

Format each concern as:
- {file} — {concern} — {recommended verification step}
```

## Phase 4 — Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  VERIFY-APP — {project} ({date})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Build:        {PASS | FAIL}
  Lint:         {PASS | FAIL | {n} warnings}
  Typecheck:    {PASS | FAIL | SKIP}
  Tests:        {PASS | FAIL — {n}/{total} passed}

  Acceptance Criteria:
  {criterion 1}:  {PASS | FAIL | NEEDS HUMAN}
  {criterion 2}:  {PASS | FAIL | NEEDS HUMAN}

  Regression Concerns:
  {file} — {concern}

  Overall:      {READY TO SHIP | ISSUES FOUND}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Phase 5 — Guidance

- **READY TO SHIP**: "All checks pass. Run `/ship` to commit, push, and PR."
- **ISSUES FOUND**: List each issue with recommended fix. Do not attempt to fix.
- **NEEDS HUMAN**: List what the user needs to manually verify.

## Error Handling

| Condition | Action |
|-----------|--------|
| No test command | STOP. Ask user for commands. |
| Build/test command crashes | Report crash, suggest checking deps |
| No active plan | Run checks without acceptance criteria |
| All checks pass but regression concerns exist | Report as READY with caveats |

## Integration Points

| Caller | When |
|--------|------|
| Manual `/verify-app` | After any implementation |
| `/verify` | Can replace or complement Step 1 |

## Removal Condition
Remove when CI/CD pipeline covers all verification steps and results are
accessible via MCP or CLI, making local verification redundant.
