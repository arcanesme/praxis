---
name: px-next
disable-model-invocation: true
description: Auto-advance to the next workflow phase. Reads status.md loop_position and plan state to determine what comes next. Use anytime to keep moving.
---

You are advancing the Praxis workflow to the next phase.

**Step 1 — Read current state**
- Read vault_path from `~/.claude/praxis.config.json`
- Read `{vault_path}/status.md` → get `loop_position` and `current_plan`
- If `current_plan` is set: read the plan file — check milestone completion status

**Step 2 — Determine next action**

| loop_position | Plan state | Action |
|---------------|------------|--------|
| IDLE | No plan | Ask "What are we working on?" — behave like `/discuss` |
| IDLE | Plan exists, incomplete milestones | "Existing plan has work remaining. Resume?" → `/execute` |
| IDLE | Plan exists, all milestones done | "Plan complete. Run `/ship` to commit+push+PR?" |
| DISCUSS | — | "Discuss complete. Run `/plan` to create the work plan." → invoke `/plan` |
| PLAN | — | "Plan ready. Run `/execute` to start implementation." → invoke `/execute` |
| EXECUTE | — | "Milestone complete. Run `/verify` to validate." → invoke `/verify` |
| VERIFY | Last verify passed | "Verified. Run `/simplify` to clean up, then `/ship`." → invoke `/simplify` |
| VERIFY | Last verify failed | "Verification failed. Fix the issue, then run `/verify` again." |

**Step 3 — Update loop_position**
After invoking the next command, update `status.md` → `loop_position` to reflect the new phase.

**Rules:**
- Always show one clear next action — no menus.
- If state is ambiguous (e.g., status.md is stale): read the plan file to determine actual progress.
- This command is a convenience — it never skips phases or bypasses verification.
