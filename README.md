# Praxis

> Disciplined action. Theory without action is idle; action without theory is reckless.

A layered harness for Claude Code that turns AI-assisted development into compounding value. Praxis loads rules, commands, skills, and domain kits so every session builds on the last.

---

## Install

### Quick (recommended)

```bash
npx praxis-harness install --vault ~/Documents/Obsidian
```

### With Perplexity deep research

```bash
PERPLEXITY_API_KEY=pplx-xxx npx praxis-harness install --vault ~/Documents/Obsidian
```

### Bash alternative (no Node.js required)

```bash
git clone https://github.com/arcanesme/praxis.git ~/praxis
bash ~/praxis/install.sh --vault ~/Documents/Obsidian
```

### What the installer does

1. Copies harness content to `~/.praxis/`
2. Symlinks the base layer into `~/.claude/`:
   - `~/.claude/CLAUDE.md` → `~/.praxis/base/CLAUDE.md`
   - `~/.claude/rules/` → `~/.praxis/base/rules/`
   - `~/.claude/commands/` → `~/.praxis/base/commands/`
   - `~/.claude/skills/` → `~/.praxis/base/skills/`
3. Writes config to `~/.claude/praxis.config.json`
4. Registers MCP servers (if API keys provided)

### CLI flags

| Flag | Env var | Purpose |
|------|---------|---------|
| `--vault <path>` | `PRAXIS_VAULT_PATH` | Obsidian vault path |
| `--perplexity-key <key>` | `PERPLEXITY_API_KEY` | Perplexity API key |
| `--no-mcp` | — | Skip MCP registration |
| `--yes`, `-y` | — | Skip all prompts |

---

## Architecture

Praxis is a three-layer system. Each layer extends — never overrides — the one below it.

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

Always active. Provides the core identity, rules, commands, and skills.

The operating hierarchy:

1. **GSD (Get Stuff Done)** — Ship working software. Bias toward action.
2. **Superpowers** — Use full capability: multi-file edits, parallel exploration, deep reasoning.
3. **Ralph** — The human in the loop. Controls scope, approves specs, owns git.

### Layer 2: AI-Kits

Domain-specific extensions activated on demand with `/kit:<name>`. Idempotent — activating twice is the same as once. Only one kit active at a time. Deactivate with `/kit:off`.

### Layer 3: Project Config

Per-repository `.claude/rules/*.md` files with path-scoped frontmatter. Created by `/scaffold-new` or `/scaffold-exist`.

---

## Core Rules

These eight rules are always enforced:

1. **Ask before building.** Always ask clarifying questions before generating specs, plans, or deliverables. Never assume scope.
2. **Spec before code.** Never write code without an approved spec (`/spec`) and plan (`/plan`).
3. **Phase gates are mandatory.** Stop at phase boundaries for human review.
4. **No scope creep.** New scope = new track. Never expand an existing one mid-flight.
5. **Human controls git.** No automated commits or pushes unless explicitly invoked.
6. **Verify before done.** Run verification checks before declaring any phase complete.
7. **Stop-and-Fix.** Don't advance if current state can't be verified. Fix gaps first.
8. **Single-reply intake.** Skills accept all metadata in one pass — no sequential round-trips.

---

## Rules

Praxis includes 15 rule files that shape Claude's behavior. **Universal rules** are always active. **Path-scoped rules** load only when Claude touches matching files.

### Universal Rules

| Rule | What it enforces |
|------|-----------------|
| **profile** | Identity as senior engineer, direct/concise tone, bias toward action |
| **execution-loop** | Stop-and-fix gates, phase verification, single-reply intake |
| **context-management** | Context rot prevention: GSD phase discipline, Ralph story sizing, compaction recovery |
| **coding** | Code style conventions, testing requirements, error handling, dependency management |
| **code-quality** | Simplicity, YAGNI, no over-engineering, delete dead code |
| **git-workflow** | Imperative commits (≤72 chars), short-lived branches, human controls git |
| **security** | OWASP top 10, secrets in env vars only, input validation at boundaries |
| **communication** | Lead with answers, concise output, file references as `path:line`, status at milestones |
| **obsidian** | Vault structure, learnings log format (`[LEARN:tag]`), read-only outside skills |
| **architecture** | Three-layer model, file conventions, rule loading behavior |
| **deep-research** | When to use Perplexity MCP: current info, best practices, troubleshooting |

### Path-Scoped Rules

These load automatically when Claude touches files matching the glob pattern.

| Rule | Activates on | What it enforces |
|------|-------------|-----------------|
| **terraform** | `**/*.tf`, `**/*.tfvars`, `**/terraform/**` | Module structure, remote state, `terraform plan` before apply, checkov/tfsec |
| **github-actions** | `.github/**` | Pin actions to SHA, minimal permissions, use caching, secrets management |
| **azure** | `**/*.bicep`, `**/azure*`, `**/az*` | CAF naming convention, Managed Identities, required tags (Env/Owner/Project/CostCenter) |
| **powershell** | `**/*.ps1`, `**/*.psm1`, `**/*.psd1` | Approved verbs, PascalCase, `$ErrorActionPreference = 'Stop'`, SecureString for credentials |

---

## Commands

Slash commands generate structured output for planning and review.

### `/spec` — Specification

Generates a spec before any code is written. Structure:

- **WHAT** — Scope definition
- **DONE-WHEN** — Success criteria
- **CONSTRAINTS** — Technical and business constraints
- **NON-GOALS** — Explicitly out of scope

Process: Ask clarifying questions → draft → present for approval → do NOT proceed until approved.

### `/plan` — Implementation Plan

Generates a phase-gated implementation plan. Requires an approved spec.

- Breaks work into phases, each independently completable
- Every phase ends with a verification checkpoint
- Human reviews at each gate before proceeding

### `/standup` — Daily Standup

Reads `claude-progress.json` and generates:

- **YESTERDAY** — What was done
- **TODAY** — What's planned
- **BLOCKERS** — What's stuck
- **CONTEXT** — Relevant background

### `/risk` — Risk Register

Generates a risk table for the current task:

| Risk | Category | Severity | Mitigation |
|------|----------|----------|------------|

Categories: Technical, Security, Schedule, Operational. Every HIGH risk gets a concrete mitigation.

### `/context-reset` — Context Checkpoint

The escape hatch when context rot is visible (repeated instructions, forgotten constraints, spec violations).

1. Writes current milestone + last 3 decisions to vault as `context-checkpoint.md`
2. Updates `claude-progress.json` with current state
3. Outputs a bootstrap block to paste into a fresh session after `/clear`

The bootstrap block contains everything a new session needs: active spec, current plan phase, key constraints, and the checkpoint file path.

### `/kit:<name>` — Kit Activation

Activates a domain-specific AI-Kit. Loads the kit's rules, commands, and notes any MCP servers to set up. Use `/kit:off` to deactivate.

---

## Skills

Skills are human-invoked only (`disable-model-invocation: true`). Claude never runs them autonomously.

### `/scaffold-new` — Bootstrap New Project

Creates a new project with full harness wiring:

- Vault entry at `{vault}/01_Projects/Work/_active/{project}/`
  - `specs/` directory
  - `notes/learnings.md`
- Project files: `CLAUDE.md`, `.gitignore`, `claude-progress.json`
- Auto-detects tech stack

**Input (single reply):** project name, type (code/architecture/content), tech stack, repo path.

### `/scaffold-exist` — Retrofit Existing Project

Adds the harness to an existing project without disrupting current structure. Skips files that already exist, appends to `.gitignore`.

**Input (single reply):** project name, repo path.

### `/pre-commit-lint` — Pre-Commit Checks

Detects and runs available tools in order:

1. **Formatter** (Prettier, Black, etc.)
2. **Linter** (ESLint, Ruff, etc.)
3. **Type checker** (tsc, mypy, etc.)

Reports PASS/FAIL per tool with file/line errors. Blocks commit if anything fails.

### `/session-retro` — Session Retrospective

**Non-negotiable at the end of every session.** This is how the harness compounds.

- Summarizes the session: ACCOMPLISHED / IN PROGRESS / LEARNINGS / NEXT SESSION
- Extracts learnings with tags: `[LEARN:architecture]`, `[LEARN:tooling]`, `[LEARN:process]`, etc.
- Appends to `{vault}/…/notes/learnings.md`
- Updates `claude-progress.json`

### `/vault-gc` — Vault Garbage Collection

Read-only audit of your Obsidian vault:

- **Stale projects** — No session in 14+ days
- **Missing files** — Projects without `claude-progress.json` or `learnings.md`
- **Orphaned notes** — Notes without a parent project, specs without a project
- Reports findings with recommendations. Never deletes or modifies.

---

## Kits

### Web Designer

**Activate:** `/kit:web-designer`

Provides design system tooling for web projects:

- **Rules:** Design tokens, a11y non-negotiables, motion/responsive patterns
- **Commands:** `/web-init` (design system setup), `/web-component` (full component lifecycle)
- **MCP:** `21st-magic` — AI-powered design tool integration
- **Commit prefix:** `[web]` for all commits while active

**MCP setup:**
```bash
npx praxis-harness kit install web-designer
# or manually:
claude mcp add 21st-magic npx -- -y @21st-dev/magic@latest
```

### Azure

**Activate:** `/kit:azure`

Provides Azure infrastructure and cloud operations tooling:

- **Rules:** IaC lifecycle (Bicep-first), deployment patterns (blue/green, canary, ring-based), cost management, monitoring/observability, incident response, networking, identity/access
- **Commands:** `/az-deploy` (validate → what-if → deploy with rollback plan), `/az-review` (security/cost/reliability/naming audit)
- **MCP:** `azure-devops` (Microsoft official — work items, PRs, builds, wikis), `azure-mcp` (resource management)
- **Commit prefix:** `[az]` for all commits while active

**MCP setup:**
```bash
npx praxis-harness kit install azure
# or manually:
claude mcp add azure-devops --scope user -- npx -y @azure-devops/mcp YOUR_ORG
claude mcp add azure-mcp --scope user -- npx -y azure-mcp
```

Azure DevOps MCP requires Node.js >= 20 and triggers browser-based auth on first use. Azure Resource MCP uses your local `az login` credentials.

---

## MCP Servers

| Server | Purpose | Registered by |
|--------|---------|---------------|
| `perplexity` | Deep research — current docs, best practices, troubleshooting | `install` command |
| `21st-magic` | UI component generation (web-designer kit only) | `kit install web-designer` |
| `azure-devops` | Azure DevOps: work items, PRs, builds, wikis | `kit install azure` |
| `azure-mcp` | Azure resource management: subscriptions, groups, deployments | `kit install azure` |

**Perplexity usage** (from `rules/deep-research.md`):
- Use for info beyond Claude's training cutoff, best practices research, troubleshooting
- Don't use for questions answerable from training data or before exhausting local context
- Compose specific queries, cite findings, cross-reference with official docs

---

## Templates

Praxis includes reference templates used by skills to scaffold consistent project structure.

| Template | Used by | Purpose |
|----------|---------|---------|
| `project-index.md` | `/scaffold-new` | Vault project overview with links, stack, and active tracks |
| `adr.md` | Manual | Architecture Decision Record (status/context/decision/consequences) |
| `plan.md` | `/plan` | Phase-gated implementation plan with checkpoints |
| `session-note.md` | `/session-retro` | Session summary with goals, decisions, learnings |
| `claude-progress.json` | `/scaffold-new` | Machine-readable progress tracking (sessions, tracks, learnings count) |

---

## Obsidian Integration

Praxis uses your Obsidian vault as a knowledge base that compounds across sessions.

### Vault structure

```
{vault}/01_Projects/Work/_active/{project}/
  specs/           Approved specifications
  notes/
    learnings.md   Cumulative learnings log
```

### Learnings format

```
[LEARN:architecture] Discovered that X pattern works better than Y for Z
[LEARN:tooling] Found that tool X requires flag Y for correct behavior
[LEARN:process] Smaller phases with verification gates catch issues earlier
```

Tags: `architecture`, `tooling`, `process`, `debugging`, `performance`, `security`, `testing`

### Configuration

Machine-specific config at `~/.claude/praxis.config.json`:

```json
{
  "vault_path": "/path/to/your/obsidian/vault"
}
```

Skills read `vault_path` at runtime. Never hardcode vault paths.

---

## Context Management

Praxis uses two complementary strategies to prevent context rot — the degradation in Claude's adherence as the context window fills.

### GSD (Intra-Session)

Controls drift *within* a session through phase-scoped context loading:

- Load only what the current phase needs — don't preload everything
- Write phase summaries to disk at every boundary (the handoff is files, not conversation)
- Re-read files instead of relying on recall from earlier in the conversation
- Confirm key constraints at every phase gate before proceeding

### Ralph Loop (Inter-Session)

Eliminates drift *between* sessions by starting fresh:

- Each story spawns a new context with only `claude-progress.json` + git as shared state
- Stories must be right-sized: 1 component, 1 migration, 1 endpoint (completable in a single window)
- No conversation history carried forward — the agent re-reads the spec and codebase each time
- Use for >5 independent stories, overnight runs, or when GSD performance has degraded

### When to Switch

| Signal | Action |
|--------|--------|
| Repeating instructions already given | Run `/context-reset`, switch to Ralph |
| Contradicting earlier decisions | Re-read spec and plan, re-state constraints |
| Forgetting constraints from the spec | Re-read the spec file, confirm at next gate |
| >5 independent stories remaining | Switch to Ralph loop |
| Single complex task requiring reasoning | Stay in GSD |

### After Compaction

When the system compresses conversation history, Claude automatically re-anchors by reading `claude-progress.json`, the active spec/plan, and `rules/context-management.md` before continuing.

---

## Creating a Kit

See [`docs/creating-a-kit.md`](docs/creating-a-kit.md) for the full guide. In short:

```
kits/{kit-name}/
  KIT.md                 Manifest (description, activation, rules, commands, MCPs)
  install.sh             Optional MCP registration script
  rules/                 Domain-specific rules (extend, never override base)
  commands/              Domain-specific slash commands
```

Register the kit in `base/CLAUDE.md` under the Kit Registry table.

---

## Project Structure

```
praxis/
├── bin/
│   └── cli.js               npx CLI entry point
├── base/
│   ├── CLAUDE.md             Global identity + core rules + kit registry
│   ├── rules/                14 universal + path-scoped rules
│   ├── commands/             5 slash commands
│   └── skills/               5 invocable skills (human-only)
├── kits/
│   └── web-designer/         Domain kit: design systems + a11y
├── templates/                Reference templates for vault + projects
├── docs/
│   ├── architecture.md       Three-layer architecture reference
│   └── creating-a-kit.md     Guide for building new kits
├── package.json              npm package manifest (zero dependencies)
├── install.sh                Bash fallback installer
└── uninstall.sh              Bash uninstaller
```

---

## Managing Praxis

```bash
# Check installation status
npx praxis-harness status

# Update to latest
npx praxis-harness@latest update

# List available kits
npx praxis-harness kit list

# Install a kit's MCP servers
npx praxis-harness kit install web-designer

# Uninstall
npx praxis-harness uninstall
```

---

## Security

This repo is safe for public use. All secrets stay local:

- **API keys** — Stored in `~/.claude.json` by `claude mcp add`, never in repo files
- **Vault path** — Written to `~/.claude/praxis.config.json`, which is gitignored
- **`.env` files** — Gitignored by default

**Never commit** API keys, vault paths, or credentials to this repo.

---

## License

MIT
