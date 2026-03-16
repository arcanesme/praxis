---
description: Validation phase — runs test/lint/typecheck/build and reports PASS or FAIL. Use after each milestone completion.
---

You are running the GSD verification phase for the current milestone.

**Step 1 — Run validation sequence**
Execute in order, showing actual output (never assertions):
1. **Test suite** → run the project test command → show output
2. **Linter** → run the project lint command → show output, fix ALL warnings
3. **Typecheck** (if applicable) → show output
4. **Build** (if applicable) → show output

Read test/lint/build commands from the project CLAUDE.md `## Commands` section.
If no commands are defined: warn and ask user for the correct commands.

**Step 2 — Report result**
- **PASS**: All checks green. Proceed to Step 3.
- **FAIL**: Trigger repair (Step 4).

**Step 3 — On PASS**
1. Update the active plan file: mark milestone status as complete
2. Run `unset BUN_INSTALL && qmd update`
3. Prompt: "Milestone verified. Ready to commit — proceed?"
4. After commit: check if more milestones remain
   - Yes → "Run `/gsd:execute` for the next milestone."
   - No → "All milestones complete. Running self-review."
5. After ALL milestones: trigger Self-Review Protocol
   - Launch a subagent to review the full diff as a critical code reviewer
   - Subagent receives ONLY: the diff, the SPEC, relevant rules files
   - Address all Critical and Major findings before reporting done

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
