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
- **rules/** — 9 universal + 4 path-scoped rules
- **commands/** — `/spec`, `/plan`, `/standup`, `/risk`, `/kit`
- **skills/** — `/scaffold-new`, `/scaffold-exist`, `/pre-commit-lint`, `/session-retro`, `/vault-gc`

### Layer 2: AI-Kits

Domain-specific packages activated on demand. Each kit provides rules, commands, and optionally MCP servers.

Activation is idempotent: `/kit:web-designer` twice = same as once. `/kit:off` deactivates.

### Layer 3: Project Config

Per-repository `.claude/rules/*.md` files with path-scoped frontmatter. Created by `/scaffold-new` or `/scaffold-exist`.

## Installation

```bash
git clone https://github.com/arcanesme/praxis.git
cd praxis
bash install.sh
```

This creates symlinks:
- `~/.claude/CLAUDE.md` → `base/CLAUDE.md`
- `~/.claude/rules/` → `base/rules/`
- `~/.claude/commands/` → `base/commands/`
- `~/.claude/skills/` → `base/skills/`

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

## Obsidian Integration

The vault serves as the human's knowledge base. Praxis writes session learnings, progress tracking, and project indices into the vault via designated skills.
