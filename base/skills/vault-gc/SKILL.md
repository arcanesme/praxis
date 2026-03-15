---
name: vault-gc
disable-model-invocation: true
description: Audit vault health and detect entropy. Invoke manually with /vault-gc
  only. Two modes — full audit (manual) and lightweight staleness check (called
  inline by session-retro). Never auto-deletes. Side-effect skill — never auto-triggers.
allowed-tools: Bash, Read, Write
---

# vault-gc Skill

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`. Scan projects under `{vault_path}/01_Projects/`.

## Two Modes

| Mode | Trigger | Scope | Output |
|------|---------|-------|--------|
| **Lightweight** | Called by session-retro | Staleness check only | One line or silence |
| **Full Audit** | Manual `/vault-gc` | All entropy categories | Prioritized report |

---

## Mode A — Lightweight

Scan `last_updated` from every `status.md` in active project directories.
Flag any project >14 days stale.

- Silent if 0 stale
- One line if 1–2: `⚠ vault-gc: 2 projects stale (project-a, project-b)`
- Escalate if 3+: `⚠ vault-gc: {N} projects stale — run /vault-gc for details`
- Exit 0 always — never block the session

---

## Mode B — Full Audit

### Check 1: Stale Projects
For each project in active directories:
- CRITICAL: >60 days stale
- HIGH: 30–60 days stale
- MEDIUM: 14–30 days stale

### Check 2: Orphan Plans
Plans in `plans/` not referenced by `current_plan:` in `status.md`,
and not status: completed or archived.

### Check 3: Vault↔Repo Drift
Projects with `local_path` in `_index.md` where the repo no longer exists on disk,
or repo exists but is missing CLAUDE.md.

### Check 4: Secret Exposure Scan
Scan last 10 commits across all active repos for accidental secret patterns.

### Report Format
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  VAULT GC — Full Audit  ({today_date})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CRITICAL ({n})
  ✗ [secret-exposure] project-a — potential secret in last 10 commits
  ✗ [stale] project-b — 72 days since last update

HIGH ({n})
  ✗ [repo-drift] project-c — local_path not found

MEDIUM ({n})
  ⚠ [orphan-plan] project-d — old-plan.md (status: active, not current)

CLEAN ({n} projects)
  ✓ project-e, project-f

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {total} findings  |  {clean} clean
  vault-gc never auto-deletes — act on findings manually
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After report: ask user if they want to address any specific finding.
Do NOT auto-remediate.

## Error Handling

| Condition | Action |
|-----------|--------|
| `status.md` missing | Use `_index.md` mtime as fallback |
| `last_updated` malformed | Skip project, note in report |
| `local_path` expansion fails | Skip drift check, note in report |
| `git log` fails | Skip secret scan, note in report |

## Removal Condition
Remove when a dedicated vault health dashboard covers all four entropy categories.
