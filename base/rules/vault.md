# Vault — Second Brain Integration
<!-- Universal — loads every session. Defines how Claude interacts with the vault. -->

---

## Vault Backend

Vault backend is Obsidian. Search: `obsidian search query="{query}" limit=5`
Scope searches with `path=` filter: `obsidian search query="{query}" path="01_Projects" limit=5`

**Note:** The Obsidian CLI requires Obsidian to be running. If Obsidian is not running, vault search will fail.
Use `[[wikilinks]]` for all internal vault references.

## Vault Location
Read vault_path from `~/.claude/praxis.config.json`.
If the config file is missing, tell the user to run `praxis/install.sh`.
All `{vault_path}` references below resolve from this config.

---

## The Vault Is the Brain — Not Conversation

Decisions made in conversation but not written to `specs/` do not exist next session.
Plans discussed but not written to `plans/` will be re-discovered and re-debated.
This is entropy. The vault prevents it.

---

## Invariants — BLOCK on violation

### Search before reading
- ALWAYS run a vault search before reading vault files.
- Never navigate to a vault file by path alone — you may read a stale or superseded version.

### Auto-save these to vault without being asked
- Architecture decisions → `specs/YYYY-MM-DD_title.md`
- Technical specs or designs → `specs/YYYY-MM-DD_title.md`
- Research findings (>3 sentences) → `research/YYYY-MM-DD_topic.md`
- Risk register entries → `specs/risk-register.md`
- Patterns or corrections discovered → `notes/learnings.md` as [LEARN:tag]
- Meeting notes or client context → `notes/YYYY-MM-DD_meeting.md`

Never ask "should I save this?" for the above categories — just save it.

### No manual index update needed
- Obsidian indexes vault changes in real-time — no update command required.

---

## Conventions — WARN on violation

### Project detection
- Detect current project by matching CWD against `local_path` in any `_index.md`.
- If CWD is ambiguous: ask before writing to vault. Never guess which project.

### Vault file purposes — strict separation

| File | Contains | Does NOT contain |
|------|---------|-----------------|
| `_index.md` | Project metadata: repo, stack, goals, links | Session state, plans, decisions |
| `status.md` | Execution state: What/So What/Now What. **Max 100 lines.** Archive resolved items to `notes/`. | Historical completed work, session transcripts |
| `tasks.md` | Active/Backlog/Blocked/Completed task lists | Specs, decisions, research |
| `plans/` | Dated work plans with milestones and steps | Completed archives |
| `specs/` | ADRs, technical specs, risk register, proposals | In-progress drafts |
| `research/` | Investigation findings before decisions | Decisions (those go to specs/) |
| `notes/learnings.md` | [LEARN:tag] entries, patterns, corrections | General meeting notes |

### Writing format for vault files
Every vault file must have YAML frontmatter:
```yaml
---
tags: [type, project-slug]
date: YYYY-MM-DD
source: agent | human | meeting
---
```

Use `[[wikilinks]]` for all internal vault references.

### Bootstrap templates
If `status.md`, `tasks.md`, or `_index.md` are missing from a project vault directory,
scaffold them from `templates/` in the praxis repo. Run `/scaffold-exist` if the
project predates the scaffold standard. Never create these files freehand — use templates.

### Planning workflow
When "let's work on X" or "plan out Y":
1. Run `/plan` to create a dated plan in `vault/plans/`
2. Update `status.md` current_plan field
3. Work from the plan — check off milestones as they complete
4. At session end: run `/session-retro`

**The vault drives work. Conversation is the interface, not the record.**

### Status digest discipline
- status.md must stay under 100 lines. If it exceeds this: archive resolved
  What/So What/Now What sections to `notes/{date}_status-archive.md` and trim.
- Required fields at top (always present):
  ```
  current_plan: {path or "none"}
  last_updated: {YYYY-MM-DD}
  last_session: {ISO timestamp}
  loop_position: DISCUSS | PLAN | EXECUTE | VERIFY | IDLE
  ```
- loop_position tracks where in the Praxis cycle the project currently sits.
  Update at every phase transition.
- A status.md older than 14 days is stale. vault-gc flags these.

---

## Second Brain Principles

**Write decisions when they're made, not when they're needed.**

**Update status.md at the end of every session.**
vault-gc flags projects where status.md is >14 days stale.

**Use [LEARN:tag] for patterns, not just errors.**
Every time something works better than expected, log why.

---

## Removal Condition
Permanent. Remove only if persistent vault state is replaced by
a different mechanism entirely.
