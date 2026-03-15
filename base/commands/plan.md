---
description: Create a dated work plan for the current project. Writes to vault plans/ directory and updates status.md current_plan field. Use when starting any multi-step task.
---

You are creating a work plan for the current project.

**Step 1 — Detect project**
- Read vault_path from `~/.claude/praxis.config.json`
- Match CWD to `local_path` in vault `_index.md`
- Read `status.md` — check if `current_plan:` is already set
- If current_plan is set: warn. Ask if starting a new plan or updating the existing one.

**Step 2 — Gather plan details**
Ask in a single message:
- What is the task or feature this plan covers?
- What is the target completion date (or "open" if no deadline)?
- Any known blockers or dependencies upfront?

**Step 3 — Build the plan**

```markdown
---
tags: [plan, {project-slug}]
date: {YYYY-MM-DD}
status: active
target: {date or open}
source: agent
---
# Plan: {title}

## Objective
One sentence.

## Context
Why this work is happening now.

## Milestones
- [ ] {milestone 1} — {date}
- [ ] {milestone 2} — {date}

## Steps
### {Milestone 1}
1. {step}
2. {step}

## Done When
- [ ] {specific verifiable check}

## Blockers
<!-- Known blockers at plan creation time -->

## Session Log
<!-- Updated by session-retro -->
```

**Step 4 — Write and wire**
- Write to: `{vault_path}/plans/{YYYY-MM-DD}_{kebab-title}.md`
- Update `status.md`: set `current_plan:`, update `last_updated`, update `## Now What`
- Update `claude-progress.json` milestones array
- Run `unset BUN_INSTALL && qmd update` after all writes
- Report:
```
✓ Plan created:   {vault_path}/plans/{filename}
✓ status.md:      current_plan updated
✓ progress.json:  milestone added
✓ QMD index:      updated
```
