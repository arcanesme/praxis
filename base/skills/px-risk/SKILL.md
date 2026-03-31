---
name: px-risk
disable-model-invocation: true
description: Add a new risk register entry to the current project vault. Assigns a risk ID, severity, mitigation, and writes to specs/risk-register.md.
---

You are adding a risk register entry for the current project.

**Step 1 — Detect project and existing risks**
- Read vault_path from `~/.claude/praxis.config.json`
- Detect project from CWD
- Search vault for existing risks using configured backend:
  - If `obsidian`: run `obsidian search query="risk register {project-slug}" limit=3`
  - If `ripgrep`: run `rg --files-with-matches "risk" {vault_path}/specs/`
  - If vault search fails: proceed without blocking
- Check if `{vault_path}/specs/risk-register.md` exists
- If found: read it to determine next sequential risk ID (R-01, R-02, etc.)

**Step 2 — Gather risk details**
Ask in a single message:
- What is the risk? (one sentence)
- What triggers it?
- Severity: Critical / High / Medium / Low
- Who owns this risk?
- What is the mitigation? (must be specific — "monitor" is not a mitigation)

**Step 3 — Write the entry**

If no risk register exists, create `{vault_path}/specs/risk-register.md`:
```markdown
---
tags: [risk-register, {project-slug}]
date: {YYYY-MM-DD}
last_updated: {YYYY-MM-DD}
source: agent
---
# {Project Name} — Risk Register
```

Append entry:
```markdown
## {R-ID} — {title}
- **Severity**: {Critical | High | Medium | Low}
- **Status**: Open
- **Trigger**: {what causes this risk to materialize}
- **Impact**: {what happens if it does}
- **Mitigation**: {specific steps — never TBD}
- **Owner**: {name or role}
- **Date identified**: {YYYY-MM-DD}
```

**Step 4 — Surface critical risks**
- If severity is Critical: add to `status.md` under `## So What` immediately.
**Step 5 — Report**
```
✓ Risk {R-ID} added:    {title} [{severity}]
✓ Risk register:        {vault_path}/specs/risk-register.md
```
