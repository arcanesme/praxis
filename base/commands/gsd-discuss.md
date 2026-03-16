---
description: Entry point for all feature work. Frames the problem, gathers SPEC questions, and recommends next phase. Use before /gsd:plan-phase.
---

You are starting the GSD discuss phase — framing the problem before planning.

**Step 1 — Load minimal context**
- Read vault_path from `~/.claude/praxis.config.json`
- Detect project from CWD matching `local_path` in vault `_index.md`
- If no project detected: ask which project before continuing

**Step 2 — Read ONLY these files (nothing else)**
1. `{vault_path}/status.md` — current state and blockers
2. Active plan (if `current_plan:` is set in status.md) — skim objectives only
3. `~/.claude/rules/profile.md` — user context

Do NOT load rules, kit context, or session history at this phase.

**Step 3 — Search for related work**
Run: `unset BUN_INSTALL && qmd search "{topic}" -n 5`
Check if specs, prior plans, or research already exist for this topic.

**Step 4 — SPEC questions**
Ask the user to answer all four:
- **WHAT**: Concrete deliverable (not vague goals)
- **DONE-WHEN**: Specific checks that prove completion
- **CONSTRAINTS**: Performance, compatibility, style requirements
- **NON-GOALS**: What this task explicitly does NOT include

If answers are ambiguous: ask 2–3 follow-up questions. Do not proceed with vague scope.

**Step 5 — Problem framing**
Output a 1-paragraph problem framing that includes:
- What exists today (from status.md / vault search)
- What gap or need the user described
- Recommendation: proceed to `/gsd:plan-phase` or write a `/spec` first

**Step 6 — Handoff**
End with: "Run `/gsd:plan-phase` to continue, or `/spec` if this needs a design spec first."
