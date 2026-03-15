# Obsidian — Second Brain Integration
<!-- Universal — loads every session. Defines how Claude interacts with the vault. -->

---

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
- ALWAYS run `unset BUN_INSTALL && qmd search "{query}" -n 5` before reading vault files.
- Never navigate to a vault file by path alone — you may read a stale or superseded version.

### Auto-save these to vault without being asked
- Architecture decisions → `specs/YYYY-MM-DD_title.md`
- Technical specs or designs → `specs/YYYY-MM-DD_title.md`
- Research findings (>3 sentences) → `research/YYYY-MM-DD_topic.md`
- Risk register entries → `specs/risk-register.md`
- Patterns or corrections discovered → `notes/learnings.md` as [LEARN:tag]
- Meeting notes or client context → `notes/YYYY-MM-DD_meeting.md`

Never ask "should I save this?" for the above categories — just save it.

### qmd update after every write
- Run `unset BUN_INSTALL && qmd update` after EVERY vault file write. No exceptions.
- Do not batch — run after each write, not once at the end.

### Never run qmd embed mid-session
- `qmd embed` is the vector re-index. Slow. Runs at SessionEnd via hook.

---

## Conventions — WARN on violation

### Project detection
- Detect current project by matching CWD against `local_path` in any `_index.md`.
- If CWD is ambiguous: ask before writing to vault. Never guess which project.

### Vault file purposes — strict separation

| File | Contains | Does NOT contain |
|------|---------|-----------------|
| `_index.md` | Project metadata: repo, stack, goals, links | Session state, plans, decisions |
| `status.md` | Execution state: What/So What/Now What | Historical completed work |
| `tasks.md` | Active/Backlog/Blocked/Completed task lists | Specs, decisions, research |
| `plans/` | Dated work plans with milestones and steps | Completed archives |
| `specs/` | ADRs, technical specs, risk register, proposals | In-progress drafts |
| `research/` | Investigation findings before decisions | Decisions (those go to specs/) |
| `notes/learnings.md` | [LEARN:tag] entries, patterns, corrections | General meeting notes |

### Writing format for vault files
Every vault file must have Obsidian-compatible frontmatter:
```yaml
---
tags: [type, project-slug]
date: YYYY-MM-DD
source: agent | human | meeting
---
```

Use `[[wikilinks]]` for all internal vault references — never relative paths.

### Planning workflow
When "let's work on X" or "plan out Y":
1. Run `/plan` to create a dated plan in `vault/plans/`
2. Update `status.md` current_plan field
3. Work from the plan — check off milestones as they complete
4. At session end: run `/session-retro`

**The vault drives work. Conversation is the interface, not the record.**

---

## Second Brain Principles

**Write decisions when they're made, not when they're needed.**

**Update status.md at the end of every session.**
vault-gc flags projects where status.md is >14 days stale.

**Use [LEARN:tag] for patterns, not just errors.**
Every time something works better than expected, log why.

---

## Removal Condition
Permanent. Remove only if the Obsidian vault is replaced by a different
knowledge management system entirely.
