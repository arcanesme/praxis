---
name: px-simplify
disable-model-invocation: true
description: "Post-implementation code simplification. Launches a subagent to review recent changes for unnecessary complexity, over-abstraction, and opportunities to simplify. Runs after any implementation phase. Side-effect skill — never auto-triggers."
---

# simplify Skill

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`.
Detect current project by matching CWD to `local_path` in vault `_index.md`.

## Acceptance
- [ ] Diff analyzed by isolated subagent
- [ ] Simplification opportunities identified and categorized
- [ ] User-approved changes applied
- [ ] No functional regressions (tests pass after changes)

## Boundaries
Out of scope:
- Does not add features or change behavior
- Does not refactor architecture — only simplifies within existing structure
- Does not touch files outside the recent diff
- Does not run without user reviewing proposed changes

---

## Phase 1 — Determine Scope

Determine what to simplify:
- Default: `git diff HEAD~1` (last commit)
- Accept: `HEAD~N`, specific SHA, or `staged`
- If diff is empty: "Nothing to simplify." Exit.
- If diff >2000 lines: warn and ask to narrow scope

## Phase 2 — Launch Subagent

Follow the subagent dispatch protocol (see `/subagent` skill for reference).
Launch a subagent with ONLY these inputs (zero conversation history):

```
You are a code simplification expert. Your only goal is to make this code
simpler, more readable, and more maintainable WITHOUT changing behavior.

## Diff to simplify
{the diff}

## Project conventions (if available)
{contents of project CLAUDE.md}

## Review for these simplification patterns:

1. **Over-abstraction**: helpers/utilities created for one-time use,
   premature abstractions, unnecessary indirection layers
2. **Unnecessary complexity**: complex conditionals that could be simplified,
   nested ternaries, over-engineered error handling for impossible cases
3. **Dead paths**: code paths that can never execute given the current logic,
   unused parameters, redundant null checks
4. **Verbosity**: code that does in 10 lines what could be done in 3,
   unnecessary intermediate variables, redundant type annotations
5. **Missed language idioms**: patterns where the language has a simpler
   built-in way (e.g., optional chaining, destructuring, list comprehensions)

For each finding, provide:
- File and line range
- Category (1-5 above)
- Current code (exact snippet)
- Simplified code (exact replacement)
- Why it's simpler (one sentence)

If the code is already clean, say "No simplifications found."
Do NOT suggest changes that alter behavior or add features.
```

## Phase 3 — Present Findings

Structure output by impact:

```
━━━ SIMPLIFY — {n} opportunities ━━━

{file}:{lines} — {category}
  Before: {current code snippet}
  After:  {simplified code snippet}
  Why:    {one sentence}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask: "Apply all / select specific / skip?"

## Phase 4 — Apply Changes

For each approved simplification:
1. Apply the edit
2. Run the test suite after ALL edits
3. If tests fail: revert the last edit, report which simplification broke tests
4. Show final diff of simplifications applied

## Phase 4b — Persist Findings

Write simplification findings to `{vault_path}/notes/{YYYY-MM-DD}_simplify-findings.md`:
```markdown
---
tags: [simplify, {project-slug}]
date: {YYYY-MM-DD}
source: agent
---
# Simplify Findings — {date}

## Applied ({n})
{file}:{lines} — {category} — {why}

## Skipped ({n})
{file}:{lines} — {category} — {reason skipped}
```

## Phase 5 — Write Learning (optional)

If a pattern recurred (same category hit 3+ times):
- Write a `[LEARN:simplify]` entry to `{vault_path}/notes/learnings.md`:
  ```markdown
  ## [LEARN:simplify] {Pattern name}
  - **What**: {what complexity pattern was found}
  - **So What**: {why it makes code harder to maintain}
  - **Now What**: {what to do instead going forward}
  - **Date**: {YYYY-MM-DD}
  ```

## Error Handling

| Condition | Action |
|-----------|--------|
| Empty diff | Exit cleanly |
| Tests fail after simplification | Revert last edit, report |
| Subagent finds nothing | "Code is clean. No simplifications." |
| No test command configured | Warn, ask user to verify manually |

## Integration Points

| Caller | When |
|--------|------|
| `/verify` Step 3b | After UNIFY, before session-retro |
| Manual `/simplify` | Any time after implementation |

## Removal Condition
Remove when an external linter or formatter handles all 5 simplification
categories with auto-fix support.
