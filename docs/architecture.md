# Praxis Architecture

## Overview

Praxis is a layered harness for Claude Code that turns AI-assisted development into compounding value. It provides universal rules, on-demand domain kits, and per-project configuration.

## Three-Layer Model

```
┌────────────────────────────────────────┐
│  Layer 3: Project Config               │
│  .claude/rules/*.md (path-scoped)      │
├────────────────────────────────────────┤
│  Layer 2: AI-Kit (/kit:<name>)         │
│  Domain rules + commands + MCPs        │
├────────────────────────────────────────┤
│  Layer 1: Universal Base               │
│  GSD → Superpowers → Ralph             │
└────────────────────────────────────────┘
```

### Layer 1: Universal Base

Always active. Installed via `install.sh` which symlinks into `~/.claude/`.

- **CLAUDE.md** — Global identity, core rules, kit registry
- **rules/** — 11 universal + 4 path-scoped rules
- **commands/** — `/spec`, `/plan`, `/standup`, `/risk`, `/context-reset`, `/kit`
- **skills/** — `/scaffold-new`, `/scaffold-exist`, `/pre-commit-lint`, `/session-retro`, `/vault-gc`

### Layer 2: AI-Kits

Domain-specific packages activated on demand. Each kit provides rules, commands, and optionally MCP servers.

Activation is idempotent: `/kit:web-designer` twice = same as once. `/kit:off` deactivates.

### Layer 3: Project Config

Per-repository `.claude/rules/*.md` files with path-scoped frontmatter. Created by `/scaffold-new` or `/scaffold-exist`.

## Installation

### npx (recommended)

```bash
npx praxis-harness install --vault ~/Documents/Obsidian
```

This copies the harness content to `~/.praxis/` and creates symlinks in `~/.claude/`:

- `~/.claude/CLAUDE.md` → `~/.praxis/base/CLAUDE.md`
- `~/.claude/rules/` → `~/.praxis/base/rules/`
- `~/.claude/commands/` → `~/.praxis/base/commands/`
- `~/.claude/skills/` → `~/.praxis/base/skills/`

### Bash alternative

```bash
git clone https://github.com/arcanesme/praxis.git ~/praxis
bash ~/praxis/install.sh --vault ~/Documents/Obsidian
```

Symlinks directly from the repo clone (no `~/.praxis/` intermediate).

### Update

```bash
npx praxis-harness@latest update
```

## Configuration

Machine-specific config: `~/.claude/praxis.config.json`

```json
{
  "vault_path": "/path/to/obsidian/vault"
}
```

This file is gitignored and machine-specific. Skills read it at runtime.

## Rules Loading

- **Universal rules** (no `paths:` frontmatter) — always loaded
- **Scoped rules** (with `paths:` frontmatter) — loaded only when Claude Code touches matching file paths
- **Kit rules** — loaded only when kit is active

## Skills

All skills use `disable-model-invocation: true` — invoked via slash command only, never by the model autonomously.

## Context Management

Praxis prevents context rot through two complementary strategies defined in `rules/context-management.md`:

- **GSD (intra-session)** — Phase-scoped context loading. Each phase loads only what it needs; summaries written to disk at boundaries. Files are the memory, not the conversation.
- **Ralph Loop (inter-session)** — Fresh-context-per-iteration. Each story spawns a new instance with `claude-progress.json` as the sole state bridge. No conversation history carried forward.

### After Compaction

When the system compresses conversation history, Claude re-anchors by reading `claude-progress.json`, the active spec/plan, and the context management rule. The `/context-reset` command provides a manual escape hatch: it checkpoints state to disk and outputs a bootstrap block for a fresh session.

### State Bridge

`claude-progress.json` is the authoritative state file for both modes:
- GSD writes phase summaries and updates tracks
- Ralph reads it at iteration start, writes it at iteration end
- `/session-retro` updates it at end of every session
- After compaction, it is the first file re-read

## Obsidian Integration

The vault serves as the human's knowledge base. Praxis writes session learnings, progress tracking, and project indices into the vault via designated skills.
