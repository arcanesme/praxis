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
git clone https://github.com/arcanesme/praxis.git
cd praxis
chmod +x install.sh
./install.sh
```

The installer will:
- Check and install prerequisites (Homebrew, Node.js, jq, Claude Code CLI)
- Prompt for your Obsidian vault path
- Symlink the base layer into `~/.claude/`
- Install GSD
- Offer to install available kit dependencies
- Print manual steps for plugins that require a Claude Code session

## After install

Open Claude Code and run:

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
/plugin marketplace add snarktank/ralph
/plugin install ralph-skills@ralph-marketplace
```

Verify with `/help` — you should see GSD, Superpowers, and Praxis commands.

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
cd /path/to/praxis
git pull
./install.sh
```

Symlinked files update automatically on `git pull`. New files need a re-run of `install.sh` to create symlinks.

## Uninstalling

```bash
cd /path/to/praxis
chmod +x uninstall.sh
./uninstall.sh
```

Removes all symlinks from `~/.claude/`. Does not delete the repo, vault templates, or installed plugins.

## Requirements

- macOS
- Claude Code CLI
- Node.js 18+
- Obsidian (optional, for vault integration)

## License

MIT
