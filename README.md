# Praxis

> *"Philosophy must be practiced, not just studied."* — Musonius Rufus

A layered harness for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Universal workflow discipline + domain-specific AI-Kits + persistent vault integration.

## What it does

Praxis gives Claude Code a three-layer operating system:

**Universal base** — always loaded. Praxis structures work (discuss → plan → execute → verify → simplify → ship). Built-in quality enforcement (debugging, code review, simplification).

**AI-Kits** — activated on demand via `/px-kit:<name>`. Each kit bundles domain-specific rules, skills, MCP servers, and slash commands. Activate the web-designer kit and your components get design system enforcement, accessibility auditing, and production lint. Deactivate with `/px-kit:off`.

**Project config** — per-repo rules that fire automatically based on file paths. Terraform rules load when you touch `.tf` files. GitHub Actions rules load when you touch workflow YAML. No manual switching.

## Quick start

```bash
npx @esoteric-logic/praxis-harness@latest
```

One command. Copies rules, commands, skills, and kits directly into `~/.claude/`. Node.js 18+ must be installed first.

> **Always use `@latest`** — `npx` caches packages locally. Without `@latest`, you may get a stale version on machines that installed previously.

**Subsequent commands:**
```bash
npx @esoteric-logic/praxis-harness@latest update      # re-copy from latest npm version
npx @esoteric-logic/praxis-harness@latest health      # verify install integrity
npx @esoteric-logic/praxis-harness@latest uninstall   # remove Praxis-owned files from ~/.claude/
```

## After install

Verify with `/help` — you should see Praxis commands (`/px-discuss`, `/px-execute`, `/px-verify`, `/px-plan`, `/px-ship`, `/px-kit:*`).

## Workflow

The standard Praxis workflow for feature development:

```
/px-standup           → orient (reads status.md, surfaces stale state)
/px-discuss          → frame the problem (conversational, scope guard)
/px-discover         → research options with confidence levels (before /px-spec)
/px-plan             → plan milestones (with dependency ordering + boundaries)
/px-execute          → implement one milestone at a time (file-group isolation)
/px-verify           → validate (test/lint/typecheck/build, self-review, UNIFY)
/px-session-retro    → capture learnings, update vault
```

For pure bugfixes: `/px-debug` (test-first debugging, skips the full loop).
For code review: `/px-review` (launches subagent review at any time).
For technical research: `/px-discover` (structured options evaluation before decisions).

## Commands

| Command | Purpose |
|---------|---------|
| `px-discuss` | Conversational problem framing, SPEC synthesis, scope guard |
| `px-execute` | Implement one milestone with file-group isolation + boundary enforcement |
| `px-verify` | Validate milestone (test/lint/build), self-review, UNIFY phase summary |

| `px-plan` | Create a dated work plan with milestone dependencies + checkpoints |
| `px-spec` | Create a structured spec or ADR with conflict detection |
| `px-discover` | Structured technical discovery with confidence-rated options |
| `px-standup` | Session-start orientation from vault state |
| `px-risk` | Add a risk register entry to the vault |
| `px-kit` | Activate/deactivate an AI-Kit |
| `px-review` | Manual code review via subagent |
| `px-simplify` | Post-implementation code simplification via subagent |
| `px-debug` | Structured test-first debugging |
| `px-ship` | Commit, push, and PR in one command with pre-flight checks |
| `px-verify-app` | End-to-end verification with regression analysis |
| `px-session-retro` | End-of-session retrospective with learnings extraction |
| `px-status-update` | Manual vault status.md update |
| `px-repair` | Structured 3-attempt fix-and-verify loop for failed milestones |
| `px-sync-memory` | Bridge auto-memory insights to Obsidian vault |
| `px-context-probe` | Assess context health and recommend action |
| `px-context-reset` | Reload context from vault without clearing session |

## Prompt Engine

Build and manage system prompts for Claude Projects, Perplexity Spaces, and Claude Code from a single source of truth.

### Quick reference

| Command | What it does |
|---------|-------------|
| `/px-prompt my-project` | Create a new project (1 question — describe it) |
| `/px-prompt --deal irs-masterfile` | New Maximus capture deal (0 questions — Perplexity researches) |
| `/px-prompt --deal benefeds --type recompete` | New deal with explicit type |
| `/px-prompt --advance irs-masterfile` | Move deal to next capture phase |
| `/px-prompt --edit my-project "add NIST 800-53"` | Edit one section, auto-regenerate outputs |
| `/px-prompt --refresh my-project` | Re-run Perplexity research, diff and update |
| `/px-prompt --deploy my-project` | Copy outputs to clipboard with platform URLs |
| `/px-prompt --dashboard` | Project index with budgets and staleness |
| `/px-prompt --sync` | Recompile all projects, show diffs |
| `/px-prompt --scan my-project` | Full quality and budget audit |

### Deal lifecycle (Maximus captures)

```
/px-prompt --deal irs-masterfile          # Create — Perplexity researches from name alone
/px-prompt --advance irs-masterfile       # Shaping → Mid Capture
/px-prompt --advance irs-masterfile       # Mid Capture → Pre-Proposal
/px-prompt --refresh irs-masterfile       # Re-run OSINT before submission
/px-prompt --advance irs-masterfile       # Pre-Proposal → Pre-Submission
/px-prompt --deploy irs-masterfile        # Copy to clipboard, paste to platforms
```

### Deal types

| Type | Flag | When | Emphasis |
|------|------|------|----------|
| Recompete | `--type recompete` | Incumbent holds the contract | Defense, ghost matrix, transition |
| New Start | `--type new-start` | No incumbent, fresh opportunity | Discovery, innovation, OSINT |
| Task Order | `--type task-order` | Competing on existing IDIQ/BPA | Speed, rates, vehicle history |
| IDIQ/BPA | `--type idiq` | Winning the vehicle itself | Broad capabilities, teaming |

Auto-detected from research if `--type` not specified.

### Non-Maximus projects

```
/px-prompt cybersecurity-advisor          # Describe it → inference engine → research → deploy
/px-prompt elect-azure                    # Work on existing project
```

Any project — federal, enterprise, personal. The engine infers role, domains, and platforms from your description.

### CLI tools (direct use)

```bash
node bin/prompt-compile.js --dashboard    # Project dashboard
node bin/prompt-compile.js --sync         # Recompile all projects
node bin/prompt-compile.js <project>      # Compile one project
node bin/prompt-knowledge.js <project>    # Render knowledge pack templates
node bin/prompt-blocks.js --category domains  # List available blocks
```

## Rules

16 rules across universal and scoped categories. Universal rules load every session. Scoped rules load only when matching file patterns are detected.

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
| web-designer | `/px-kit:web-designer` | Design system init → component build → accessibility audit → production lint |
| infrastructure | `/px-kit:infrastructure` | Terraform plan → apply → drift detection → compliance check |
| api | `/px-kit:api` | RESTful conventions → OpenAPI specs → contract testing |
| security | `/px-kit:security` | Threat modeling → IAM review → OWASP audit |
| data | `/px-kit:data` | Schema design → migration planning → query optimization |

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

### What gets documented automatically

Praxis auto-documents your work in the vault with zero manual effort. Two independent layers ensure nothing is lost:

1. **Shell hooks** capture facts (git state, timestamps) even if Claude runs out of context
2. **Stop prompt** captures meaning (summaries, decisions, learnings) from conversation context

**At session end** (zero action needed):
- `status.md` — updated with What/So What/Now What
- `claude-progress.json` — session entry with summary, accomplishments, milestones, features
- `notes/{date}_session-note.md` — session summary, decisions, learnings, next steps
- `notes/decision-log.md` — checkpoint decisions, scope changes (appended)
- `notes/learnings.md` — [LEARN:tag] pattern entries (appended)
- `specs/` — ADRs for architectural decisions made during the session

**During workflow skills** (automatic within each skill):

| Skill | Auto-writes to vault |
|-------|---------------------|
| `/px-execute` | `status.md` loop position, `decision-log.md` scope events |
| `/px-verify` | `claude-progress.json` milestones[] |
| `/px-review` | `specs/review-{date}-{slug}.md` (full findings breakdown) |
| `/px-simplify` | `notes/{date}_simplify-findings.md` |
| `/px-debug` | `notes/{date}_debug-trace.md` |
| `/px-verify-app` | `specs/verify-app-{date}-{slug}.md` |
| `/px-ship` | `claude-progress.json` features[] |

**On context compaction** (automatic fallback):
- `plans/{date}-compact-checkpoint.md` — git state, active plan, loop position
- `claude-progress.json` — session entry preserved

## Updating

### Updating the harness

```bash
npx @esoteric-logic/praxis-harness@latest update
```

Re-copies all hooks, skills, rules, and kits from the latest npm package version. Config file is preserved.

> **Always use `@latest`** to avoid `npx` serving a cached older version.

### Updating existing projects

After a harness update that adds new vault files (like `decision-log.md`), run `/px-scaffold-exist` in a Claude Code session to audit your vault and add any missing files. This is non-destructive — it never overwrites existing content.

```
Step 1: npx @esoteric-logic/praxis-harness@latest update   → deploys new hooks, skills, rules
Step 2: /px-scaffold-exist                                   → audits vault, adds missing files
```

New projects get everything automatically via `/px-scaffold-new`.

## Uninstalling

```bash
npx @esoteric-logic/praxis-harness@latest uninstall
```

Removes all Praxis-owned files from `~/.claude/`. Does not delete config, vault templates, or installed plugins.

## Development

```bash
git clone https://github.com/arcanesme/praxis.git
cd praxis
bash install.sh
```

The git-clone + `install.sh` path uses symlinks instead of copies, so edits in the repo are immediately reflected.

**Testing:**
```bash
bash scripts/lint-harness.sh .     # structure, frontmatter, placeholders, registry
bash scripts/test-harness.sh .     # shellcheck, JSON, cross-skill refs, hook wiring, kit structure
```

## Requirements

- macOS or Linux
- Claude Code CLI
- Node.js 18+
- Obsidian with CLI enabled (for vault integration)

## License

MIT
