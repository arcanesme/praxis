# Praxis

> *"Philosophy must be practiced, not just studied."* — Musonius Rufus

A layered harness for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Universal workflow discipline + domain-specific AI-Kits + persistent vault integration.

## What it does

Praxis gives Claude Code a three-layer operating system:

**Universal base** — always loaded. Praxis structures work (discuss → plan → execute → verify → simplify → ship). Built-in quality enforcement (debugging, code review, simplification).

**AI-Kits** — activated on demand via `/kit:<name>`. Each kit bundles domain-specific rules, skills, MCP servers, and slash commands. Activate the web-designer kit and your components get design system enforcement, accessibility auditing, and production lint. Deactivate with `/kit:off`.

**Project config** — per-repo rules that fire automatically based on file paths. Terraform rules load when you touch `.tf` files. GitHub Actions rules load when you touch workflow YAML. No manual switching.

## Quick start

```bash
npx praxis-harness
```

One command. Copies rules, commands, skills, and kits directly into `~/.claude/`. Node.js 18+ must be installed first.

**Subsequent commands:**
```bash
npx praxis-harness update      # re-copy from latest npm version
npx praxis-harness health      # verify install integrity
npx praxis-harness uninstall   # remove Praxis-owned files from ~/.claude/
```

## After install

Verify with `/help` — you should see Praxis commands (`/discuss`, `/execute`, `/verify`, `/plan`, `/ship`, `/kit:*`).

## Workflow

The standard Praxis workflow for feature development:

```
/standup           → orient (reads status.md, surfaces stale state)
/discuss       → frame the problem (conversational, scope guard)
/discover          → research options with confidence levels (before /spec)
/plan    → plan milestones (with dependency ordering + boundaries)
/execute       → implement one milestone at a time (file-group isolation)
/verify        → validate (test/lint/typecheck/build, self-review, UNIFY)
/session-retro     → capture learnings, update vault
```

For pure bugfixes: `/debug` (test-first debugging, skips the full loop).
For code review: `/review` (launches subagent review at any time).
For technical research: `/discover` (structured options evaluation before decisions).

## Commands

| Command | Purpose |
|---------|---------|
| `discuss` | Conversational problem framing, SPEC synthesis, scope guard |
| `execute` | Implement one milestone with file-group isolation + boundary enforcement |
| `verify` | Validate milestone (test/lint/build), self-review, UNIFY phase summary |

| `plan` | Create a dated work plan with milestone dependencies + checkpoints |
| `spec` | Create a structured spec or ADR with conflict detection |
| `discover` | Structured technical discovery with confidence-rated options |
| `standup` | Session-start orientation from vault state |
| `risk` | Add a risk register entry to the vault |
| `kit` | Activate/deactivate an AI-Kit |
| `review` | Manual code review via subagent |
| `debug` | Structured test-first debugging |
| `context-reset` | Reload context from vault without clearing session |

## Rules

15 rules across universal and scoped categories. Universal rules load every session. Scoped rules load only when matching file patterns are detected.

Key additions in this version:
- **context-management** — context brackets (FRESH/MODERATE/DEPLETED/CRITICAL) adapt behavior to session stage
- **vault** — Obsidian vault integration

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
│  Praxis workflow engine                 │
├────────────────────────────────────────┤
│  Vault layer                           │
│  Obsidian                              │
├────────────────────────────────────────┤
│  Claude Code                           │
│  ~/.claude/ + plugins + subagents      │
└────────────────────────────────────────┘
```

**Workflow hierarchy:** Praxis owns the outer loop (discuss → plan → execute → verify → simplify → ship). Kits inject domain context into this workflow — they don't replace it.

## Available kits

| Kit | Activate | What it does |
|-----|----------|-------------|
| web-designer | `/kit:web-designer` | Design system init → component build → accessibility audit → production lint |
| infrastructure | `/kit:infrastructure` | Terraform plan → apply → drift detection → compliance check |

More kits coming. See `docs/creating-a-kit.md` to build your own.

## Vault integration

Praxis integrates with an Obsidian vault for project state, session learnings, and architecture decisions.

The vault path is configured per machine during install:

```json
{
  "vault_path": "/Users/you/Documents/Obsidian",
  "vault_backend": "obsidian",
  "vault_name": "My Vault",
  "repo_path": "/Users/you/repos/praxis"
}
```

Requires [Obsidian CLI](https://obsidian.md) (enable in Obsidian Settings > General > Command line interface). Obsidian must be running for vault search.

## Updating

```bash
npx praxis-harness update
```

Re-copies all files from the latest npm package version. Config file is preserved.

## Uninstalling

```bash
npx praxis-harness uninstall
```

Removes all Praxis-owned files from `~/.claude/`. Does not delete config, vault templates, or installed plugins.

## Development

```bash
git clone https://github.com/arcanesme/praxis.git
cd praxis
bash install.sh
```

The git-clone + `install.sh` path uses symlinks instead of copies, so edits in the repo are immediately reflected.

## Requirements

- macOS or Linux
- Claude Code CLI
- Node.js 18+
- Obsidian with CLI enabled (for vault integration)

## License

MIT
