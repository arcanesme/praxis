---
name: debug
disable-model-invocation: true
description: Structured test-first debugging. Reproduce the bug, write a failing test, isolate root cause, fix, verify. Use for pure bugfixes — skips the full loop.
---

You are running structured debugging.

**Step 1 — Gather bug report**
Ask for all of these (accept partial, fill gaps from code):
- **Observed behavior**: What actually happens?
- **Expected behavior**: What should happen instead?
- **Reproduction steps**: Exact sequence to trigger the bug.
- **Suspect files**: Where in the code does the user think the bug is?
- **When it last worked**: What changed since then? (check `git log` if unknown)

If the user provides an error message or stack trace: use that as the starting point.

**Step 2 — Write a failing test**
Before touching any implementation code:
1. Write a test that demonstrates the bug — it MUST fail.
2. Run the test. Confirm it fails with the expected error.
3. If the test passes: re-examine the bug report. The reproduction may be wrong,
   or the bug may not be where the user thinks.
4. Show the failing test output.

**Step 3 — Isolate root cause**
- Read suspect files. Trace the code path from input to failure.
- Use `rg` to find related call sites, error handlers, recent changes.
- State the root cause in one sentence:
  `Root cause: {what is wrong} in {file}:{line} because {why}.`
- If root cause is unclear after tracing: add diagnostic logging or breakpoints,
  reproduce again, and narrow down.

**Step 4 — Fix the root cause**
- Fix the root cause, not the symptom. Keep the fix minimal.
- Do not refactor surrounding code as part of the fix.
- Do not add unrelated improvements.
- If the fix requires changing the test: explain why the original test was wrong.

**Step 5 — Verify**
1. Run the failing test from Step 2 — it MUST now pass.
2. Run the full test suite — no regressions.
3. Run the linter — clean.
4. Show all output.

**Step 6 — Write learnings**
- Read vault_path from `~/.claude/praxis.config.json`
- If this bug represents a pattern (not a one-off typo):
  write a `[LEARN:bugfix]` entry to `{vault_path}/notes/learnings.md`:
  ```markdown
  ## [LEARN:bugfix] {Short title}
  - **What**: {what went wrong}
  - **So What**: {why it matters, how it could recur}
  - **Now What**: {what to do to prevent recurrence}
  - **Date**: {YYYY-MM-DD}
  ```
- Vault indexing is automatic.

**Rules:**
- Never fix without first reproducing.
- Never say "fixed" without showing the test passing.
- Skips the full loop — for pure bugfixes only.
- If the "bug" is actually a feature gap: redirect to `/discuss`.
- If the fix touches >5 files: it is not a bugfix. Use the full loop.
