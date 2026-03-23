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
base with domain-specific AI-Kits that activate on demand via slash commands.

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
│  Praxis workflow — discuss→plan→execute→verify    │
│  Quality enforcement — debug, review, simplify    │
├─────────────────────────────────────────────────┤
│  CLAUDE CODE                                      │
│  ~/.claude/CLAUDE.md + ~/.claude/rules/*          │
│  Skill discovery, subagents, hooks                │
└─────────────────────────────────────────────────┘
```

## Activation Boundary

Custom skills and kits activate on explicit slash command for operations —
they touch the vault, scaffold projects, run commits.

False triggers on methodology: low-cost (skip the suggestion).
False triggers on operations: real consequences (wrong vault paths, unwanted scaffolds).

## Workflow Hierarchy

**Praxis owns the workflow.** Always start feature work with `/discuss` or `/next`.

- Full loop: discuss → plan → execute → verify → simplify → ship
- Lightweight: `/quick` for ad-hoc tasks, `/fast` for trivial changes
- Pure bugfixes: skip the full loop, use `/debug` directly

## Context Rot Prevention

Praxis addresses context rot through phase-scoped context loading and
file-based handoffs at phase boundaries.

| Mechanism | How |
|-----------|-----|
| Phase scoping | Load ONLY context for current phase — not everything |
| File-based handoff | SPEC → plan file → milestone steps. Conversation is not the record. |
| Vault persistence | Decisions, plans, learnings persist across sessions |
| Context reset | `/context-reset` checkpoints state before `/clear` |
| Pre-compaction hook | `vault-checkpoint.sh` saves Praxis state before compaction |

When context degradation is detected (repeated corrections, instruction drift),
use `/context-reset` to checkpoint state and restart clean.

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
| **Universal base** | Praxis workflow + quality enforcement — always loaded |
| **Kit manifest** | `KIT.md` — declares what a kit contains |
| **Skills chain** | Ordered sequence of skills a kit activates |
