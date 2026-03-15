---
description: Three-layer harness architecture reference
---

# Praxis Architecture

## Three Layers

### Layer 1: Universal Base (always loaded)

Symlinked into `~/.claude/` by `install.sh`. Provides:
- `CLAUDE.md` — Global identity, rules, kit registry
- `rules/` — Universal and path-scoped rules
- `commands/` — Slash commands (`/spec`, `/plan`, `/standup`, `/risk`, `/kit`)
- `skills/` — Invocable skills (`/scaffold-new`, `/session-retro`, etc.)

### Layer 2: AI-Kits (on demand)

Domain-specific packages activated via `/kit:<name>`. Each kit provides:
- `KIT.md` — Manifest with description and activation instructions
- `rules/` — Domain-specific rules loaded when kit is active
- `commands/` — Domain-specific slash commands
- `install.sh` — Optional setup (e.g., register MCP servers)

Kits are idempotent: activating twice produces the same result as once.

### Layer 3: Project Config (per-repo)

Per-repository `.claude/rules/*.md` with path-scoped frontmatter. These override or extend base rules for project-specific conventions.

## Config

Machine-specific config: `~/.claude/praxis.config.json` (gitignored).

## File Conventions

- Rules: markdown with YAML frontmatter. `paths:` key for scoping.
- Commands: markdown following Claude Code custom command format.
- Skills: `SKILL.md` with `disable-model-invocation: true`.
- Templates: markdown or JSON. Used by skills at runtime.
