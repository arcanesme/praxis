---
name: scaffold-exist
disable-model-invocation: true
description: Scaffold an existing project into the full harness. Invoke with /scaffold-exist only.
  Adds missing harness files to projects that predate the scaffold standard.
  Non-destructive — never overwrites without confirmation. Side-effect skill — never auto-triggers.
---

# scaffold-exist Skill

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`. If missing: STOP.

## WHAT
Bring an existing project into full harness compliance without disrupting active work.

## DONE-WHEN
- [ ] `{vault_path}/status.md` exists with correct structure
- [ ] `{vault_path}/tasks.md` exists
- [ ] `{vault_path}/claude-progress.json` exists
- [ ] `{vault_path}/specs/` and `research/` directories exist
- [ ] `{vault_path}/_index.md` has `local_path` matching actual repo path
- [ ] Repo `CLAUDE.md` has `## Vault Project` section
- [ ] Repo `CLAUDE.md` has bootstrap sequence
- [ ] Project Registry row is accurate

## CONSTRAINTS
- NEVER delete existing vault content — only add missing files
- NEVER overwrite without explicit user confirmation
- Read `_index.md` to resolve metadata — do not ask for info already there

## NON-GOALS
- Does not reformat existing vault notes
- Does not touch existing specs/, research/, notes/ content
- Does not change git history or branch structure

---

## Phase 0 — Audit

Ask user: which project? (slug or vault path)
Compute vault_path from config. Run: `ls -la {vault_path}/`

Build and show audit table:

| File/Dir | Exists? | Action |
|----------|---------|--------|
| `_index.md` | ? | Verify `local_path` field |
| `status.md` | ? | Create if missing |
| `tasks.md` | ? | Create if missing |
| `claude-progress.json` | ? | Create if missing |
| `plans/` | ? | Create if missing |
| `specs/` | ? | Create if missing |
| `research/` | ? | Create if missing |
| `notes/learnings.md` | ? | Create if missing |
| Repo CLAUDE.md sections | ? | Add missing sections |
| Registry row | ? | Verify accuracy |

**Get user confirmation before Phase 1.**

## Phase 1 — Resolve Metadata
Read `_index.md`, extract project name, slug, repo_root, type, stack, repo_url.
Verify repo_root exists on disk.

## Phase 2 — Create Missing Vault Files
Use same templates as scaffold-new (`references/` dir). Existing files untouched.
Run `qmd update` after all writes.

## Phase 3 — Update Repo CLAUDE.md
If missing: create from template. If exists: add only missing sections (Vault Project, bootstrap, Identity). Preserve existing content.

## Phase 4 — Verify Project Registry
Read vault CLAUDE.md registry. Row missing → append. Row inaccurate → update.

## Error Handling

| Condition | Action |
|-----------|--------|
| `_index.md` missing | STOP — run scaffold-new instead |
| `local_path` doesn't exist | Warn, ask for correct path |
| Existing file would be overwritten | Ask explicit confirmation |
| `qmd update` fails | Warn only |

## Removal Condition
Remove when all active projects are migrated and scaffold-new is the only entry path.
