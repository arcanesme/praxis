# Praxis

> Disciplined action. Theory without action is idle; action without theory is reckless.

A layered harness for Claude Code that turns AI-assisted development into compounding value.

## Install

```bash
git clone https://github.com/arcanesme/praxis.git ~/praxis
cd ~/praxis
bash install.sh
```

This symlinks the base layer into `~/.claude/` and prompts for your Obsidian vault path.

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

**Universal base** — Always active. Rules, commands, and skills loaded via symlinks.

**AI-Kits** — Domain-specific extensions activated with `/kit:<name>`. Idempotent.

**Project config** — Per-repo `.claude/rules/` with path-scoped frontmatter.

## Commands

| Command | Purpose |
|---------|---------|
| `/spec` | Generate WHAT / DONE-WHEN / CONSTRAINTS / NON-GOALS spec |
| `/plan` | Generate checkable milestone plan (requires approved spec) |
| `/standup` | Yesterday / Today / Blockers from claude-progress.json |
| `/risk` | Risk register for current task |
| `/kit:<name>` | Activate an AI-Kit (`/kit:off` to deactivate) |

## Skills

| Skill | Purpose |
|-------|---------|
| `/scaffold-new` | Bootstrap a new project into the harness |
| `/scaffold-exist` | Retrofit harness onto an existing project |
| `/pre-commit-lint` | Run lint/format/type-check before commit |
| `/session-retro` | End-of-session learnings + progress update |
| `/vault-gc` | Vault entropy check |

## Available Kits

| Kit | Activation | Purpose |
|-----|-----------|---------|
| Web Designer | `/kit:web-designer` | Design systems, components, a11y, responsive |

## Structure

```
base/
  CLAUDE.md              Global identity + rules + kit registry
  rules/                 Universal + path-scoped rules
  commands/              Slash commands
  skills/                Invocable skills

kits/
  web-designer/          First domain kit

templates/               Reusable templates for projects + vault
docs/                    Architecture + kit creation guide
scripts/                 Update script
```

## Update

```bash
bash ~/praxis/scripts/update.sh
```

## Uninstall

```bash
bash ~/praxis/uninstall.sh
```

## License

MIT
