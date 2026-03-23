---
name: plan
disable-model-invocation: true
description: Create a dated work plan for the current project. Writes to vault plans/ directory and updates status.md current_plan field. Use when starting any multi-step task.
---

You are creating a work plan for the current project.

**Step 1 — Detect project and read SPEC**
- Read vault_path from `~/.claude/praxis.config.json`
- Match CWD to `local_path` in vault `_index.md`
- Read `status.md` — check if `current_plan:` is already set
- If current_plan is set: warn. Ask if starting a new plan or updating the existing one.

**Step 1b — Consume discuss output**
Check the conversation for a SPEC block from `/discuss`:
```
SPEC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROBLEM:      ...
DELIVERABLE:  ...
ACCEPTANCE:   ...
BOUNDARIES:
  In:  ...
  Out: ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

- If a SPEC block exists in conversation: use it as the plan's objective, acceptance criteria, and boundaries.
  Do NOT re-ask what the task is.
- If no SPEC block in conversation: check vault for `{vault_path}/plans/*-context.md` (most recent).
  If found and recent (today): read it and use as the SPEC source.
- If no SPEC block found anywhere (plan invoked directly): ask in a single message:
  - What is the task or feature this plan covers?
  - What is the target completion date (or "open" if no deadline)?
  - Any known blockers or dependencies upfront?

**Step 2 — Build the plan**

```markdown
---
tags: [plan, {project-slug}]
date: {YYYY-MM-DD}
status: active
target: {date or open}
execution_type: execute | tdd | research
source: agent
---
# Plan: {title}

## Objective
One sentence.

## SPEC
PROBLEM: {from SPEC block or user input}
DELIVERABLE: {from SPEC block or user input}
ACCEPTANCE: {from SPEC block or user input}
BOUNDARIES:
  In: {from SPEC block or user input}
  Out: {from SPEC block or user input}

## Context
Why this work is happening now.

## Milestones
- [ ] {milestone 1} — {date}
- [ ] {milestone 2} — {date} | depends_on: milestone 1
- [ ] {milestone 3} — {date} | depends_on: milestone 2 | checkpoint: decision
- [ ] {milestone 4} — {date} | checkpoint: human-verify

## Steps
### {Milestone 1}
1. {step}
2. {step}

## Done When
- [ ] {specific verifiable check}

## Boundaries
<!-- Required. Files/systems that MUST NOT change during this plan. -->
<!-- Override requires explicit "OVERRIDE: {reason}" from user. -->
- DO NOT CHANGE: {file or system list}

## Blockers
<!-- Known blockers at plan creation time -->

## Session Log
<!-- Updated by session-retro -->
```

Checkpoint types:
- `checkpoint: decision` — user must confirm a choice before proceeding
- `checkpoint: human-verify` — user must validate output before proceeding
- No annotation = autonomous (default)

**Step 2b — Dependency and boundary validation**
After building the milestone list:
- Scan for circular dependencies (topological sort). If cycle detected:
  report the cycle and ask user to break it.
- Validate that every `depends_on:` reference exists in the milestone list.
- If user provided milestones out of order: reorder and note the change.
- Milestones with no `depends_on:` are independent — this is valid.
- Validate Boundaries: if user did not specify any, ask:
  "What files or systems should NOT be touched during this plan?"
  Empty boundaries are valid only if explicitly confirmed.
- Validate checkpoints: milestones with architectural decisions or user-facing output
  should be annotated as `checkpoint: decision` or `checkpoint: human-verify`.

**Step 3 — Write and wire**
- Write to: `{vault_path}/plans/{YYYY-MM-DD}_{kebab-title}.md`
- Update `status.md`: set `current_plan:`, update `last_updated`, set `loop_position: PLAN`, update `## Now What`
- Update `claude-progress.json` milestones array
- Report:
```
✓ Plan created:   {vault_path}/plans/{filename}
✓ status.md:      current_plan updated
✓ progress.json:  milestone added
```

The plan file now contains the SPEC — `/execute` reads it directly.
No information is lost at the discuss→plan→execute boundary.
