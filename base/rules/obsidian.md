---
description: Vault integration, learnings log, session notes
---

# Obsidian Integration

## Vault Path

Always read the vault path from `~/.claude/praxis.config.json`. Never hardcode it.

```json
{
  "vault_path": "/path/to/vault"
}
```

## Project Structure in Vault

Active projects live at: `{vault_path}/01_Projects/Work/_active/{project-name}/`

Each project directory contains:
- `specs/` — Architecture decisions, specifications
- `notes/` — Session notes, learnings, command references
- `claude-progress.json` — Machine-readable progress tracking

## Learnings Log

File: `{project-dir}/notes/learnings.md`

Format: `[LEARN:tag] Description` — one line per learning.

Tags: `architecture`, `tooling`, `process`, `debugging`, `performance`, `security`, `testing`.

## Session Notes

Use the `templates/session-note.md` template. One note per significant session.

## Rules

- Create vault entries via `/scaffold-new` or `/scaffold-exist` — never manually.
- Read vault state to inform context, but don't modify vault files outside of designated skills.
- The vault is the human's knowledge base. Treat it with respect.
