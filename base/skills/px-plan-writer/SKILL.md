---
name: px-plan-writer
disable-model-invocation: true
description: "Writes a dated work plan to the vault plans/ directory. Creates the plan file with YAML frontmatter, milestones, and acceptance criteria. Updates status.md current_plan field. Called by /plan and /discuss workflows."
---

# plan-writer Skill

## Inputs

| Input | Required | Source |
|-------|----------|--------|
| SPEC block | Yes | From `/discuss` output or user-provided scope |
| vault_path | Yes | From `~/.claude/praxis.config.json` |
| project_slug | Yes | From CWD → `_index.md` detection |

## Output

A plan file at `{vault_path}/plans/{YYYY-MM-DD}_{task-slug}.md`

## Plan File Format

```markdown
---
tags: [plan, {project-slug}]
date: {YYYY-MM-DD}
status: active
source: agent
---

# Plan: {task title}

## SPEC
PROBLEM: {from discuss}
DELIVERABLE: {from discuss}
ACCEPTANCE: {from discuss}
BOUNDARIES: {from discuss}

## Milestones

### M1 — {milestone title}
- [ ] {step}
- [ ] {step}
**Acceptance:** {how to verify this milestone}

### M2 — {milestone title}
...

## Verification
{end-to-end checks that prove the plan is complete}
```

## Steps

1. Read vault_path from config
2. Detect project from CWD matching `local_path` in vault `_index.md`
3. Generate task slug from the SPEC PROBLEM field (kebab-case, max 40 chars)
4. Write the plan file with frontmatter
5. Update `status.md`:
   - Set `current_plan:` to the plan file path
   - Set `loop_position: PLAN`
   - Set `last_updated:` to today

## Constraints

- Each milestone must be independently verifiable
- Max 5 milestones per plan — if more are needed, split into sub-plans
- Never write a milestone without acceptance criteria
- Plan files are immutable once execution starts — create a new plan for scope changes
