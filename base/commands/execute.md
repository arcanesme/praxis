---
description: Implementation phase — loads scoped context and works one milestone at a time. Use after plan is approved.
---

You are executing the implementation phase.

**Step 1 — Load implementation context**
- Read vault_path from `~/.claude/praxis.config.json`
- Read `{vault_path}/status.md` → get `current_plan:`
- Read the active plan file:
  - `## SPEC` section → PROBLEM, DELIVERABLE, ACCEPTANCE, BOUNDARIES (the contract)
  - Current milestone steps and acceptance criteria only (not full plan)
- If no active plan: STOP. Tell user to run `/discuss` first.

**Step 2 — Load scoped rules**
Load ONLY rules relevant to files being touched in this milestone:
- Terraform/Azure files → `~/.claude/rules/terraform.md`, `~/.claude/rules/azure.md`
- GitHub Actions → `~/.claude/rules/github-actions.md`
- PowerShell → `~/.claude/rules/powershell.md`
- Git operations → `~/.claude/rules/git-workflow.md`
- Security-sensitive changes → `~/.claude/rules/security.md`

Do NOT load all rules. Context is scarce — spend it on implementation, not instructions.

**Step 2b — Declare file group and load boundaries**
Before implementing the current milestone, declare the file group:
- Format: `Milestone: {name} | Files: {list, max 5} | Off-limits: everything else`
- Write the file-group declaration to the plan file under the milestone entry.
- File groups can include globs (e.g., `src/components/*.tsx`).
- Read `## Boundaries` from the active plan. Boundary items are absolute off-limits —
  they override file-group declarations. If a milestone file group includes a
  boundary-protected file: STOP. Surface the conflict before proceeding.
- If current milestone has `checkpoint: decision` or `checkpoint: human-verify`:
  present the decision/output to user before proceeding. Do not auto-advance.

**Step 3 — Implement current milestone**
- One milestone at a time. Keep diffs scoped.
- Do not expand scope without explicit user approval.
- Use extended thinking for tasks touching >3 files or requiring architectural decisions.
- Before writing to or editing any file: check if it is in the declared file group.
- If a required change is discovered in an off-limits file: STOP.
  Surface as a new milestone candidate. Do not expand current milestone.
- Milestone diff must touch ONLY declared files. Undeclared file change = scope violation.

**Step 4 — Milestone completion**
When the milestone is complete:
1. Write a brief summary to the active plan file under the milestone entry
2. Confirm actual diff matches declared file group
3. Output ONE recommendation — no menu, no alternatives:
   `Next: /verify` followed by one sentence explaining why
   Example: "Next: /verify — 3 files changed in declared group, tests and lint needed"

**Rules:**
- Never skip a milestone or reorder without approval.
- If blocked: document the blocker in the plan file, suggest alternatives or escalate.
- One feature per session. Do not mix unrelated tasks.
