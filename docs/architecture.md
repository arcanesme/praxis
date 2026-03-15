---
title: "Praxis: System Architecture"
type: architecture-adr
status: ready-for-review
created: 2026-03-15
scope: global harness
---

# Praxis — Architecture

> "Philosophy must be practiced, not just studied." — Musonius Rufus

Praxis is a layered harness for Claude Code. It combines a universal workflow
base (GSD + Superpowers + Ralph) with domain-specific AI-Kits that activate
on demand via slash commands.

## Layer Architecture

```
┌─────────────────────────────────────────────────┐
│  PROJECT CONFIG                                  │
│  .claude/rules/*.md (path-scoped, per-repo)      │
│  CLAUDE.md (project-specific overrides)           │
├─────────────────────────────────────────────────┤
│  AI-KIT (activated via /kit:<n>)                  │
│  Skills chain + domain rules + MCP servers        │
│  Loads ONLY when invoked, unloads on /kit:off     │
├─────────────────────────────────────────────────┤
│  UNIVERSAL BASE (always loaded)                   │
│  GSD        — spec→plan→execute→verify workflow   │
│  Superpowers — TDD, debugging, code review        │
│  Ralph      — autonomous PRD→execute loop         │
├─────────────────────────────────────────────────┤
│  CLAUDE CODE                                      │
│  ~/.claude/CLAUDE.md + ~/.claude/rules/*          │
│  Plugin system, skill discovery, subagents        │
└─────────────────────────────────────────────────┘
```

## Activation Boundary

External plugins (GSD, Superpowers) auto-activate for methodology — they
enforce workflow discipline and quality standards. Custom skills and kits
activate on explicit slash command for operations — they touch the vault,
scaffold projects, run commits.

False triggers on methodology: low-cost (skip the suggestion).
False triggers on operations: real consequences (wrong vault paths, unwanted scaffolds).

## Workflow Hierarchy

**GSD owns the outer workflow.** Always start feature work with GSD.
Superpowers' brainstorm/write-plan/execute-plan commands are redundant
when GSD is running — never invoke alongside GSD phases.

**Superpowers owns quality enforcement within execution.** TDD, debugging,
and code review activate automatically inside whatever GSD sets up.

**One exception — pure bugfixes.** Skip GSD entirely. Use Superpowers
debugging methodology directly.

**Ralph is the outer loop.** Spawns fresh instances. GSD + Superpowers
operate within each iteration.

## AI-Kit Pattern

A kit is a self-contained domain tooling bundle:

```
~/.claude/kits/<kit-name>/
  KIT.md              ← Manifest
  install.sh          ← Dependency installation
  teardown.sh         ← Clean removal
  rules/              ← Domain-specific rules
  commands/           ← Domain slash commands
```

Kits activate via `/kit:<n>`, deactivate via `/kit:off`.
The `/kit` command is idempotent — double-activate is a no-op.
This is critical for Ralph integration.

### Ralph Integration

Kit activation persists across Ralph iterations via project `CLAUDE.md`:

```markdown
## Active kit
On session start, activate: /kit:web-designer
```

No modification to `ralph.sh` needed.

## Distribution

Praxis is a standalone repo that symlinks into `~/.claude/`.

```
praxis/
  install.sh          ← Full bootstrap
  uninstall.sh        ← Clean removal
  base/               ← Universal layer (CLAUDE.md, rules, commands, skills)
  kits/               ← Domain AI-Kits
  templates/          ← Obsidian vault templates
  docs/               ← Architecture and guides
```

Vault path is machine-specific, configured during `install.sh` via interactive
prompt, stored in `~/.claude/praxis.config.json` (gitignored).

## Naming Convention

| Term | Meaning |
|------|---------|
| **Praxis** | The complete harness system |
| **AI-Kit** | A domain-specific tooling bundle |
| **Universal base** | GSD + Superpowers + Ralph — always loaded |
| **Kit manifest** | `KIT.md` — declares what a kit contains |
| **Skills chain** | Ordered sequence of skills a kit activates |
