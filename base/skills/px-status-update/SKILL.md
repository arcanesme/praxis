---
name: px-status-update
disable-model-invocation: true
description: "Atomic update to vault status.md. Ensures consistent format, enforces the 100-line limit, and archives resolved items. Called at milestone boundaries, session end, and phase transitions."
---

# status-update Skill

## Required Fields (top of status.md, always present)

```yaml
current_plan: {path or "none"}
last_updated: {YYYY-MM-DD}
last_session: {ISO timestamp}
loop_position: DISCUSS | PLAN | EXECUTE | VERIFY | IDLE
```

## Steps

1. Read vault_path from `~/.claude/praxis.config.json`
2. Read current `{vault_path}/status.md`
3. Update the required fields at the top
4. Add or update the What / So What / Now What section:
   - **What**: Facts only — what was done, what exists now
   - **So What**: Why it matters — blockers, risks, progress
   - **Now What**: Next actions, ordered by priority
5. Check line count — if >100 lines, archive resolved sections:
   - Move completed What/So What/Now What blocks to `{vault_path}/notes/{date}_status-archive.md`
   - Keep only active/unresolved items in status.md
6. Write the updated file

## When to Call

| Trigger | What to Update |
|---------|---------------|
| Milestone complete | Add accomplishment to What, advance Now What |
| Phase transition | Update `loop_position` |
| Session end | Update `last_session`, write current state |
| Blocker hit | Add blocker to So What, propose resolution in Now What |
| Plan created/changed | Update `current_plan` |

## Constraints

- status.md must stay under 100 lines — archive aggressively
- Never delete content — always archive to notes/
- A status.md older than 14 days is stale — vault-gc flags these
- Use `[[wikilinks]]` for all internal vault references
