---
description: Checkpoint current session state to vault files before a context reset. Use when context degradation is detected (repeated corrections, loop behavior, instruction drift).
---

You are preparing a clean context reset for the current session.

**Step 1 — Identify project context**
- Read vault_path from `~/.claude/praxis.config.json`
- Detect project from CWD matching `local_path` in vault `_index.md`
- If no project detected: ask which project before continuing

**Step 2 — Read current state**
- Read the active plan file (from `status.md` → `current_plan:` field)
- Read `claude-progress.json` for machine state
- Identify: current milestone, last 3 decisions, any STOP conditions or blockers

**Step 3 — Write context checkpoint**
Write a standalone checkpoint file at `{vault_path}/plans/{YYYY-MM-DD}-context-checkpoint.md`:

```markdown
---
tags: [checkpoint, {project-slug}]
date: {YYYY-MM-DD}
source: agent
---
# Context Checkpoint — {YYYY-MM-DD HH:MM}

## Active Plan
{plan filename}

## Last Milestone Completed
{milestone name and status}

## Decisions (last 3)
1. {decision} — {rationale}
2. {decision} — {rationale}
3. {decision} — {rationale}

## Active STOP Conditions
{any blockers or stop conditions, or "None"}

## Next Step
{what should happen when the session resumes}
```

**Step 4 — Update status.md**
Update `status.md` with current What / So What / Now What:
- **What**: what was accomplished before the reset
- **So What**: why the reset is happening (context degradation symptoms)
- **Now What**: resume from the checkpoint in the active plan

**Step 5 — Update claude-progress.json**
Write a session snapshot to `claude-progress.json`:
- Update `last_session` with current date and a note about the context reset

**Step 6 — Instruct the user**
Print:
```
Context checkpoint saved to:
  Checkpoint: {vault_path}/plans/{YYYY-MM-DD}-context-checkpoint.md
  Status:     {vault_path}/status.md
  Progress:   {vault_path}/claude-progress.json

Run /clear to reset context, then paste this bootstrap prompt:

  Context reset. Bootstrap:
  1. Read project CLAUDE.md
  2. Read {vault_path}/plans/{current-plan}
  3. Read {vault_path}/plans/{YYYY-MM-DD}-context-checkpoint.md
  4. Resume from milestone: {milestone-name}
```
