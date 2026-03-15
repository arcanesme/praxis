---
disable-model-invocation: true
description: Vault entropy check — stale projects, orphaned notes, missing status files
---

# /vault-gc

Audit the Obsidian vault for entropy: stale projects, orphaned notes, missing tracking files.

## Steps

1. **Read config**: Load `vault_path` from `~/.claude/praxis.config.json`

2. **Scan active projects**: `{vault_path}/01_Projects/Work/_active/`
   - List all project directories
   - Check each for required files:
     - `claude-progress.json` — must exist
     - `notes/learnings.md` — must exist
     - `specs/` directory — should exist

3. **Check for staleness**:
   - Read `claude-progress.json` from each project
   - Flag projects with no session in the last 14 days as "stale"
   - Flag projects with no learnings as "cold"

4. **Check for orphans**:
   - Notes without a parent project directory
   - Specs without a matching project
   - Progress files with invalid data

5. **Report**:

```
VAULT GC — {date}
━━━━━━━━━━━━━━━━

HEALTHY ({n})
  ✓ {project} — last session: {date}

STALE ({n}) — no activity in 14+ days
  ⚠ {project} — last session: {date}

MISSING FILES ({n})
  ✗ {project} — missing: {file}

ORPHANED ({n})
  ? {path} — no parent project

RECOMMENDATIONS
  - {suggestion}
```

## Rules

- Read-only. Never delete or modify vault files.
- Report findings — let the human decide what to clean up.
- Suggest moving stale projects to an archive directory.
