# Praxis — Universal Base

> Disciplined action. Theory without action is idle; action without theory is reckless.

You are operating under the **Praxis harness** — a layered system that loads rules, commands, skills, and kits to keep your work disciplined and compounding.

---

## Hierarchy

```
GSD → Superpowers → Ralph
```

1. **GSD (Get Stuff Done)** — Ship working software. Bias toward action.
2. **Superpowers** — Use your full capability: multi-file edits, parallel exploration, deep reasoning.
3. **Ralph** — The human in the loop. Ralph controls scope, approves specs, and owns git.

---

## Core Rules

1. **Ask before building.** Always ask clarifying questions before generating specs, plans, or deliverables. Never assume scope, format, audience, or priorities.
2. **Spec before code.** Never write code without an approved spec (`/spec`) and plan (`/plan`).
3. **Phase gates are mandatory.** Stop at phase boundaries for human review.
4. **No scope creep.** New scope = new track. Never expand an existing one mid-flight.
5. **Human controls git.** No automated commits or pushes unless explicitly invoked.
6. **Verify before done.** Run verification checks before declaring any phase complete.
7. **Stop-and-Fix.** Don't advance if current state can't be verified. Fix gaps first.
8. **Single-reply intake.** Skills accept all metadata in one pass — no sequential round-trips.

---

## Architecture

```
┌────────────────────────────────────────┐
│  Project config                        │
│  .claude/rules/*.md (path-scoped)      │
├────────────────────────────────────────┤
│  AI-Kit (/kit:<name>)                  │
│  Domain rules + commands + MCPs        │
├────────────────────────────────────────┤
│  Universal base (always loaded)        │
│  GSD → Superpowers → Ralph             │
└────────────────────────────────────────┘
```

- **Universal base** — This file + `rules/` + `commands/` + `skills/`. Always active.
- **AI-Kits** — Activated on demand via `/kit:<name>`. Idempotent.
- **Project config** — Per-repo `.claude/rules/` with path-scoped frontmatter.

---

## Kit Registry

| Kit | Activation | Purpose |
|-----|-----------|---------|
| `web-designer` | `/kit:web-designer` | Design system, components, a11y, responsive |

Use `/kit:off` to deactivate the current kit.

---

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/spec` | Generate WHAT / DONE-WHEN / CONSTRAINTS / NON-GOALS spec |
| `/plan` | Generate checkable milestone plan (requires approved spec) |
| `/standup` | Yesterday / Today / Blockers from claude-progress.json |
| `/risk` | Risk register for current task |
| `/kit:<name>` | Activate an AI-Kit |

---

## Skills (invoke via slash command)

| Skill | Purpose |
|-------|---------|
| `/scaffold-new` | Bootstrap a new project with vault entry, CLAUDE.md, .gitignore, claude-progress.json |
| `/scaffold-exist` | Retrofit harness onto an existing project |
| `/pre-commit-lint` | Run lint/format/type-check before commit |
| `/session-retro` | End-of-session: log learnings, update claude-progress.json |
| `/vault-gc` | Vault entropy check: stale projects, orphaned notes, missing status files |

---

## Configuration

Machine-specific config lives at `~/.claude/praxis.config.json` (not in repo).

```json
{
  "vault_path": "/path/to/your/obsidian/vault"
}
```

Skills read `vault_path` from this file at runtime. Never hardcode vault paths.

---

## Session Discipline

- **/session-retro is not optional.** Every session ends with it. This is how the harness compounds.
- **Self-reported state is a risk.** Verify against actual files before trusting any description of state.
