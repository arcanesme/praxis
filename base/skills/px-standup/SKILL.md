---
name: px-standup
disable-model-invocation: true
description: Generate a standup summary for the current project. Reads status.md, tasks.md, and active plan. Use at the start or end of any working session.
---

You are generating a standup summary for the current project.

**Step 1 — Load project state**
Read vault_path from `~/.claude/praxis.config.json`. Then read in order (detect from CWD — do not ask):
1. `{vault_path}/_index.md` → project name, stack, goals
2. `{vault_path}/status.md` → current_plan, last_updated, What/So What/Now What
3. `{vault_path}/tasks.md` → Active, Blocked sections
4. If `current_plan` is set → read `{vault_path}/plans/{current_plan}` → Milestones, Blockers

**Step 2 — Output standup format**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STANDUP — {Project Name}  ({today_date})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  DONE
  {bullet from completed milestones or tasks}

  IN PROGRESS
  {active plan name} — {next milestone}

  BLOCKED
  {blocker with owner if known}

  NEXT
  {first item from Now What in status.md}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Last updated: {last_updated from status.md}
  Active plan:  {current_plan or "none"}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Rules:**
- If status.md `## What` is empty: say so — do not invent state.
- If no active plan: say "No active plan — check tasks.md backlog."
- If last_updated is >7 days ago: warn "⚠ status.md is {N} days stale"
- Standup = facts only. No opinions or recommendations.

**Step 3 — Offer next action**
After printing standup, ask one question only:
"Update status.md with today's progress, or continue working?"
