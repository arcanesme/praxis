# Praxis

> *"Philosophy must be practiced, not just studied."* — Musonius Rufus

A layered harness for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Universal workflow discipline + domain-specific AI-Kits + Obsidian vault integration.

## What it does

Praxis gives Claude Code a three-layer operating system:

**Universal base** — always loaded. [GSD](https://github.com/gsd-build/get-shit-done) structures work (spec → plan → execute → verify). [Superpowers](https://github.com/obra/superpowers) enforces quality (TDD, debugging, code review). [Ralph](https://github.com/snarktank/ralph) runs autonomous execution loops.

**AI-Kits** — activated on demand via `/kit:<name>`. Each kit bundles domain-specific rules, skills, MCP servers, and slash commands. Activate the web-designer kit and your components get design system enforcement, accessibility auditing, and production lint. Deactivate with `/kit:off`.

**Project config** — per-repo rules that fire automatically based on file paths. Terraform rules load when you touch `.tf` files. GitHub Actions rules load when you touch workflow YAML. No manual switching.

## Quick start

```bash
npx praxis-harness
```

One command. Clones the repo to `~/.praxis`, installs prerequisites, symlinks into `~/.claude/`, runs health check. Node.js 18+ must be installed first.

**Subsequent commands:**
```bash
npx praxis-harness update      # pull latest + re-link
npx praxis-harness health      # verify install integrity
npx praxis-harness uninstall   # remove symlinks from ~/.claude/
```

**Alternative: manual install**
```bash
git clone https://github.com/arcanesme/praxis.git
cd praxis
bash install.sh
```

Verify install:
```bash
npx praxis-harness health
```

## After install

Open Claude Code and run:

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
/plugin marketplace add snarktank/ralph
/plugin install ralph-skills@ralph-marketplace
```

Verify with `/help` — you should see GSD, Superpowers, and Praxis commands.

## Workflow

The standard GSD workflow for feature development:

```
/standup           → orient (reads status.md, surfaces stale state)
/gsd:discuss       → frame the problem (SPEC questions, scope guard)
/gsd:plan-phase    → plan milestones (with dependency ordering)
/gsd:execute       → implement one milestone at a time (file-group isolation)
/gsd:verify        → validate (test/lint/typecheck/build, self-review)
/session-retro     → capture learnings, update vault
```

For pure bugfixes: `/debug` (test-first debugging, skips GSD).
For code review: `/review` (launches subagent review at any time).

## Commands

| Command | Purpose |
|---------|---------|
| `gsd-discuss` | Frame the problem, SPEC questions, scope guard |
| `gsd-execute` | Implement one milestone with file-group isolation |
| `gsd-verify` | Validate milestone (test/lint/build), self-review |
| `ralph` | Autonomous multi-story execution from a PRD |
| `plan` | Create a dated work plan with milestone dependencies |
| `spec` | Create a structured spec or ADR with conflict detection |
| `standup` | Session-start orientation from vault state |
| `risk` | Add a risk register entry to the vault |
| `kit` | Activate/deactivate an AI-Kit |
| `review` | Manual code review via subagent |
| `debug` | Structured test-first debugging |
| `context-reset` | Reload context from vault without clearing session |

## Ralph

Ralph is the autonomous execution mode for multi-story work. Use it when you have >5 independent stories that don't require human checkpoints.

1. Write a PRD using `/prd-writer` (structured story format with file groups and estimates)
2. Run `/ralph` to begin autonomous execution
3. Each story runs in a fresh context with its own verify cycle
4. Blocked stories are recorded and skipped — reported at run end

Ralph is not a replacement for GSD — it runs GSD internally per story. Use GSD for work that needs cross-story reasoning or architectural decisions.

## Architecture

```
┌────────────────────────────────────────┐
│  Project config                        │
│  .claude/rules/*.md (path-scoped)      │
├────────────────────────────────────────┤
│  AI-Kit (/kit:web-designer)            │
│  Skills chain + domain rules + MCPs    │
├────────────────────────────────────────┤
│  Universal base (always loaded)        │
│  GSD → Superpowers → Ralph             │
├────────────────────────────────────────┤
│  Claude Code                           │
│  ~/.claude/ + plugins + subagents      │
└────────────────────────────────────────┘
```

**Workflow hierarchy:** GSD owns the outer loop (discuss → plan → execute → verify). Superpowers enforces quality inside execution (TDD, review, debug). Ralph runs autonomous multi-story iterations. Kits inject domain context into this workflow — they don't replace it.

## Available kits

| Kit | Activate | What it does |
|-----|----------|-------------|
| web-designer | `/kit:web-designer` | Design system init → component build → accessibility audit → production lint |
| infrastructure | `/kit:infrastructure` | Terraform plan → apply → drift detection → compliance check |

More kits coming. See `docs/creating-a-kit.md` to build your own.

## Obsidian integration

Praxis integrates with an Obsidian vault for persistent project state, session learnings, and architecture decisions. The vault path is configured per machine during install — no hardcoded paths.

Skills that touch the vault read from `~/.claude/praxis.config.json`:

```json
{
  "vault_path": "/Users/you/Documents/Obsidian",
  "repo_path": "/Users/you/repos/praxis"
}
```

## Updating

```bash
npx praxis-harness update
```

Or manually: `bash scripts/update.sh` from the repo directory. Pulls latest, re-runs install to pick up new symlinks, runs health check and content lint.

## Uninstalling

```bash
npx praxis-harness uninstall
```

Or manually: `bash uninstall.sh` from the repo directory. Removes all symlinks from `~/.claude/`. Does not delete the repo, vault templates, or installed plugins.

## Requirements

- macOS or Linux
- Claude Code CLI
- Node.js 18+
- Obsidian (optional, for vault integration)

## License

MIT
