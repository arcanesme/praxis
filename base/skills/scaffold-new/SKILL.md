---
name: scaffold-new
disable-model-invocation: true
description: Scaffold a brand new project into the full harness. Invoke with /scaffold-new only.
  Creates repo CLAUDE.md, vault subtree, git identity verification, gitignore,
  pre-commit hook, and Project Registry entry. Side-effect skill — never auto-triggers.
---

# scaffold-new Skill

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json` at the start of every invocation.
If config is missing: STOP. Tell user to run `praxis/install.sh`.

## Boundaries — Rules Loading
- Do NOT load `git-workflow.md` — identity and init handled inline
- Do NOT load `security.md` — not relevant during scaffolding
- Do NOT load `terraform.md` or `github-actions.md` — no infra files touched

## Overview
Scaffolds a new project in phases:
1. **Phase 0**: Validate git identity before anything touches disk
2. **Phase 1**: Gather project metadata
3. **Phase 2**: Scaffold repo `CLAUDE.md`
4. **Phase 3**: Scaffold vault subtree
5. **Phase 3.5**: Scaffold `claude-progress.json`
6. **Phase 4**: Vault search check
7. **Phase 5**: Git init (if new repo)
8. **Phase 5.5**: Install git hooks (optional)
9. **Phase 6**: Update Project Registry + agenda.md
10. **Phase 7**: Confirm and open Obsidian

---

## Phase 0 — Identity Guard

From the user's stated project type, resolve the expected identity.
<!-- CUSTOMIZE: Replace with your git identities in profile.md -->
Read identity table from `~/.claude/rules/git-workflow.md`.

**Validation steps:**
1. Confirm `{repo_root}` falls under the correct `includeIf` directory.
   If not: **STOP**. Report the mismatch.
2. If repo exists: run `git --no-pager config user.email` and confirm match.
   If mismatch: **STOP**. Report `expected: X, got: Y`.
3. Store resolved values: `{identity_profile}`, `{ssh_key}`, `{identity_email}`

---

## Phase 1 — Gather Info

Before asking, run vault duplicate check:
```bash
obsidian search query="{slug}" path="01_Projects" limit=3
```

Ask in one message:
- **Project name** — display name
- **Project slug** — kebab-case (confirm derivation from name)
- **One-line description**
- **Type** — Work / Personal
- **Tech stack** — 1–5 items, comma-separated
- **Repo root path**
- **Repo URL** — (use `TBD` if not yet created)
- **New or existing repo?**

**Computed values:**
```
vault_path   = {config.vault_path}/01_Projects/{type}/_active/{slug}
today_date   = current date YYYY-MM-DD
```

---

## Phase 2 — Scaffold repo CLAUDE.md

1. Read `references/repo-CLAUDE-md-template.md`
2. Apply full substitution map. All placeholders must resolve.
3. Scan output for remaining `{placeholder}` patterns. Resolve before writing.
4. Write to `{repo_root}/CLAUDE.md`

---

## Phase 3 — Scaffold Vault

Create directories:
```bash
mkdir -p {vault_path}/plans {vault_path}/notes {vault_path}/specs {vault_path}/research
```

Create files from templates in `references/`:
- `_index.md` from `vault-index-template.md`
- `status.md` from `vault-status-template.md` (`current_plan:` empty)
- `tasks.md` from `vault-tasks-template.md`
- `notes/learnings.md` from `vault-learnings-template.md`
- `.gitignore` from `gitignore-template.txt` (new repos only)

---

## Phase 3.5 — Scaffold claude-progress.json

From `references/claude-progress-template.json`. Apply substitution map.
Write to `{vault_path}/claude-progress.json`.

---

## Phase 4 — Vault Search Check

Vault indexing is automatic for `obsidian` backend. No manual re-index needed.
Verify the new project is searchable: `obsidian search query="{slug}" limit=1`
On failure: warn, do not block.

---

## Phase 5 — Git Init (if new repo)

```bash
git init {repo_root}
git -C {repo_root} add CLAUDE.md
git -C {repo_root} commit -m "chore: initialize project scaffold"
```
After commit: verify `git config user.email` matches. If mismatch: **STOP**.

---

## Phase 5.5 — Git Hooks (ask first)

Ask: "Generate and install a pre-commit lint hook?"
If yes: invoke the `pre-commit-lint` skill.
If no: skip silently.

---

## Phase 6 — Update Project Registry

Append to vault CLAUDE.md Project Registry table and agenda.md.
Vault indexing is automatic.

---

## Phase 7 — Confirm & Open Vault

Open the vault in Obsidian:
- `open "obsidian://open?vault=Obsidian"`

Print summary table with all created files and bootstrap sequence.

---

## Execution Checklist

- [ ] Phase 0: Identity resolved and validated
- [ ] Phase 1: All metadata collected
- [ ] Phase 2: `{repo_root}/CLAUDE.md` — zero unreplaced placeholders
- [ ] Phase 3: Vault subtree created
- [ ] Phase 3.5: `claude-progress.json` created
- [ ] Phase 4: Vault search check (automatic indexing)
- [ ] Phase 5: Git identity verified
- [ ] Phase 5.5: Hook decision made
- [ ] Phase 6: Registry and agenda updated
- [ ] Phase 7: Summary printed

## Error Handling

| Condition | Action |
|-----------|--------|
| Identity mismatch | STOP. Report. Do not commit. |
| Files already exist | Ask before overwriting |
| Unreplaced placeholder | Resolve before writing |
| Vault search fails | Warn only |

## Removal Conditions
- Phase 0: Remove after 20+ consecutive correct identity resolutions over 60 days
- Phase 3.5: Remove when a dedicated MCP tool handles machine-readable state
- Phase 5.5: Remove when hooks managed globally via dotfiles bootstrap
