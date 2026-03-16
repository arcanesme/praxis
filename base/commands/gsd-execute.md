---
description: Implementation phase — loads scoped context and works one milestone at a time. Use after plan is approved.
---

You are executing the GSD implementation phase.

**Step 1 — Load implementation context**
- Read vault_path from `~/.claude/praxis.config.json`
- Read `{vault_path}/status.md` → get `current_plan:`
- Read the active plan file — focus on the CURRENT milestone only (not full plan)
- If no active plan: STOP. Tell user to run `/gsd:discuss` first.

**Step 2 — Load scoped rules**
Load ONLY rules relevant to files being touched in this milestone:
- Terraform/Azure files → `~/.claude/rules/terraform.md`, `~/.claude/rules/azure.md`
- GitHub Actions → `~/.claude/rules/github-actions.md`
- PowerShell → `~/.claude/rules/powershell.md`
- Git operations → `~/.claude/rules/git-workflow.md`
- Security-sensitive changes → `~/.claude/rules/security.md`

Do NOT load all rules. Context is scarce — spend it on implementation, not instructions.

**Step 3 — Implement current milestone**
- One milestone at a time. Keep diffs scoped.
- Do not expand scope without explicit user approval.
- Use extended thinking for tasks touching >3 files or requiring architectural decisions.

**Step 4 — Milestone completion**
When the milestone is complete:
1. Write a brief summary to the active plan file under the milestone entry
2. Prompt: "Milestone complete. Run `/gsd:verify` to validate."

**Step 5 — Ralph handoff trigger**
If remaining milestones >5 and all are independent (no cross-milestone reasoning):
- Suggest: "Remaining milestones are independent — consider Ralph for unattended execution."
- Do not auto-switch. User decides.

**Rules:**
- Never skip a milestone or reorder without approval.
- If blocked: document the blocker in the plan file, suggest alternatives or escalate.
- One feature per session. Do not mix unrelated tasks.
