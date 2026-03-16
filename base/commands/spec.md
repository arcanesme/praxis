---
description: Create a structured spec or ADR for the current project. Writes directly to vault specs/ directory. Use for any significant decision, design, or work item that needs documentation before implementation.
---

You are creating a spec for the current project.

**Step 1 — Identify project context**
- Read vault_path from `~/.claude/praxis.config.json`
- Detect project from CWD matching `local_path` in vault `_index.md`
- Read `status.md` to understand current state
- If no project detected: ask which project before continuing

**Step 2 — Gather spec details**
Ask the following in a single message:
- What is this spec for? (one sentence)
- Type: ADR (architecture decision) / PLAN (work plan) / RISK (risk register entry) / SPEC (technical spec)
- Is there an existing related spec in `specs/`? (run `unset BUN_INSTALL && qmd search "{topic}" -n 3` first)

**Step 2b — Cross-spec conflict check**
After the vault search from Step 2, check for conflicts with accepted ADRs:
- Run: `unset BUN_INSTALL && qmd search "{topic}" -n 10`
- For each result with `status: accepted` or `status: proposed`:
  - Compare the decision direction. Does the new spec contradict an accepted decision?
- If conflict detected, present:
  ```
  This conflicts with {spec-path} (accepted {date}).
  Options:
  1. Supersede — update existing ADR status to 'superseded', link to this one
  2. Extend — amend the existing ADR instead of creating a new one
  3. Proceed with awareness — document the tension in ## Consequences
  ```
- Never silently create a spec that contradicts an accepted ADR.
- If no conflicts: proceed silently.

**Step 3 — Answer the four SPEC questions**
- **WHAT**: Concrete deliverable
- **DONE-WHEN**: Specific checks that prove completion
- **CONSTRAINTS**: Performance, compatibility, compliance requirements
- **NON-GOALS**: What this explicitly does NOT include

**Step 4 — Write the spec**

For ADR type:
```markdown
---
tags: [adr, {project-slug}]
date: {YYYY-MM-DD}
status: proposed
source: agent
---
# ADR: {title}

## Decision
One sentence. What was decided.

## Context
Why this decision was needed. What constraints applied.

## Options Considered
| Option | Pros | Cons |
|--------|------|------|

## Consequences
What this makes easier, harder, or impossible going forward.
```

For SPEC type:
```markdown
---
tags: [spec, {project-slug}]
date: {YYYY-MM-DD}
status: draft
source: agent
---
# Spec: {title}

## What
{concrete deliverable}

## Done When
- [ ] {specific verifiable check}

## Constraints
{requirements}

## Non-Goals
{what this explicitly does NOT include}

## Design
{technical detail}
```

For RISK type:
```markdown
---
tags: [risk, {project-slug}]
date: {YYYY-MM-DD}
severity: critical | high | medium | low
status: open
source: agent
---
# Risk: {R-ID} — {title}

## Description
What the risk is and what triggers it.

## Impact
What happens if this materializes.

## Mitigation
Specific steps — never "TBD".

## Owner
Who is responsible.
```

**Step 5 — Write to vault**
- Filename: `{YYYY-MM-DD}_{kebab-title}.md`
- Location: `{vault_path}/specs/`
- Run `unset BUN_INSTALL && qmd update` after writing
- Report: `✓ Spec written to {vault_path}/specs/{filename}`
