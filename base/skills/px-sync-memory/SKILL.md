---
name: px-sync-memory
disable-model-invocation: true
description: "Bridge auto-memory insights to Obsidian vault. Reads MEMORY.md and topic files, syncs durable entries to vault learnings, prunes stale content. Side-effect skill — never auto-triggers."
---

# sync-memory Skill

You are syncing Claude's auto-memory to the Obsidian vault.

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`.

## Acceptance
- [ ] MEMORY.md and topic files read
- [ ] Durable insights synced to vault
- [ ] Stale entries pruned
- [ ] MEMORY.md under 80 lines after sync

---

**Step 1 — Locate memory files**
- Find the auto-memory directory for the current project:
  `~/.claude/projects/-{escaped-cwd}/memory/`
- Read `MEMORY.md` (the index file)
- Read all topic files referenced by MEMORY.md (e.g., `user_preferences.md`, `feedback_testing.md`)
- If no memory files exist: "No auto-memory to sync." Exit.

**Step 2 — Classify each entry**

For each entry in MEMORY.md and topic files, classify:

| Classification | Action |
|---------------|--------|
| **Project-specific insight** (error pattern, build quirk, API gotcha) | Append to `vault/notes/learnings.md` as `[LEARN:memory-sync]` |
| **Global preference** (coding style, tool preference) | Present to user: "Add to CLAUDE.md Error Learning? [entry]" |
| **Architecture decision** | Present to user: "This belongs in vault specs/ or CLAUDE.md — not MEMORY.md" |
| **Already in vault** | Skip — note as duplicate |
| **Stale/outdated** (references deleted files, old versions, resolved bugs) | Mark for pruning |
| **Machine-specific** (paths, env vars, tool locations) | Keep in MEMORY.md — appropriate for auto-memory |

**Step 3 — Sync to vault**

For project-specific insights, append to `vault/notes/learnings.md`:
```markdown
## [LEARN:memory-sync] [short title]
- **What**: [the insight]
- **So What**: [why it matters]
- **Now What**: [how to apply it]
- **Date**: [YYYY-MM-DD]
- **Source**: auto-memory sync
```

**Step 4 — Prune MEMORY.md**

After syncing:
1. Remove entries that were synced to vault (they now live in the canonical store)
2. Remove stale/outdated entries
3. Keep machine-specific and active debugging entries
4. Verify MEMORY.md is under 80 lines
5. If still over 80 lines: consolidate further — merge similar entries, shorten descriptions

**Step 5 — Report**

```
MEMORY SYNC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Synced:    [n] entries → vault learnings
Surfaced:  [n] entries for CLAUDE.md review
Pruned:    [n] stale entries removed
Kept:      [n] entries in MEMORY.md
Lines:     [n] / 80 limit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Error Handling

| Condition | Action |
|-----------|--------|
| No memory files found | Exit cleanly |
| Vault path missing | Warn, skip vault sync, still prune |
| MEMORY.md empty | "Nothing to sync." Exit. |
| Cannot classify an entry | Keep it — don't prune what you don't understand |

## When to Run

- Before starting a new kit (`/kit:<name>`)
- Before `/context-reset` or `/clear`
- At session end (optional — Stop prompt handles most vault writes)
- When MEMORY.md exceeds 80 lines

## Removal Condition
Remove when Claude Code provides native memory-to-vault sync or when
auto-dream learns to respect vault integration boundaries natively.
