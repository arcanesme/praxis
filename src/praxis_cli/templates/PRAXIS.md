# PRAXIS Protocol v2

> Disciplined action. Theory without action is idle; action without theory is reckless.
> This file is the single source of truth. All AI tools (Claude Code, OpenAI Codex) follow this protocol.

---

## Core Rules

1. **Ask before building.** Always ask clarifying questions before generating specs, plans, or deliverables. Never assume scope, format, audience, or priorities.
2. **Spec before code.** Never write code or content without an approved spec and plan.
3. **Tracks are units of work.** All work is organized into tracks in `praxis/tracks/`.
4. **Context is persistent.** Always read `praxis/context/` before starting any task.
5. **Phase gates are mandatory.** Stop at phase boundaries for human review.
6. **No scope creep.** New scope = new track. Never expand an existing one.
7. **Markdown only.** All praxis files are `.md`. No tool-specific formats.
8. **Human controls git.** No automated commits, pushes, or branch operations unless explicitly invoked via slash command.
9. **Completed tracks persist.** Mark as `status: COMPLETED` with a date. Do not delete or archive.
10. **Verify before done.** Every implementation phase must pass verification checks defined in `praxis/verification.md` before a checkpoint is cleared.

---

## Directory Structure

```
project-root/
├── PRAXIS.md               # This file — protocol rules (source of truth)
├── bootstrap.sh             # Generates CLAUDE.md, AGENTS.md
├── praxis/
│   ├── context/             # Project-level context
│   │   ├── product.md       # What, who, why
│   │   ├── techstack.md     # Languages, frameworks, services
│   │   ├── workflow.md      # Process, testing, definition of done
│   │   └── guidelines.md    # Style, naming, patterns, tone
│   ├── verification.md      # Per-project verification rules (configurable)
│   ├── commands/            # Portable command definitions
│   │   ├── setup.md         # Initialize project context
│   │   ├── new-track.md     # Create spec + plan
│   │   ├── implement.md     # Execute plan with phase gates
│   │   ├── review.md        # Validate completed work
│   │   ├── status.md        # Show all tracks and progress
│   │   ├── verify.md        # Run project-specific checks
│   │   ├── commit-push-pr.md # Commit, push, open PR
│   │   ├── simplify.md      # Refactor / clean code
│   │   ├── sync-context.md  # Share state between instances
│   │   └── deploy-preview.md # Push to staging
│   └── tracks/              # Units of work
│       └── {track-name}/
│           ├── spec.md
│           ├── plan.md
│           └── review.md
├── .claude/commands/        # (generated) Claude Code slash commands
├── .claude/settings.json    # (generated) Claude Code hooks (auto-format, lint)
├── CLAUDE.md                # (generated) Claude Code instructions
└── AGENTS.md                # (generated) OpenAI Codex instructions
```

---

## Track Types

| Type | Use For |
|------|---------|
| **code** | Features, bug fixes, refactors |
| **architecture** | Specs, decision docs, diagrams, compliance mappings |
| **federal** | SOWs, PWS, compliance matrices, proposal sections, past performance |
| **content** | Digital garden seeds, evergreen pieces, blog posts, documentation |

---

## Commands

### Core Workflow
| Command | Purpose |
|---------|---------|
| `setup` | Initialize project context interactively |
| `new-track` | Create spec + plan for new work |
| `implement` | Execute plan with phase gates |
| `review` | Validate work against spec + guidelines |
| `status` | Show all tracks and progress |

### Automation
| Command | Purpose |
|---------|---------|
| `verify` | Run project-specific checks from verification.md |
| `commit-push-pr` | Stage, commit, push, and open PR with track context |
| `simplify` | Refactor/clean targeted code without changing behavior |
| `sync-context` | Export current track state for another instance to pick up |
| `deploy-preview` | Push current branch to staging/preview environment |

---

## Parallel Execution

Multiple AI instances (Claude Code, Codex) can work simultaneously. Work is divided flexibly — you assign each instance its task.

### Rules for parallel work:
- Each instance reads `praxis/context/` and the relevant track before starting
- Instances must not edit the same files simultaneously
- Use `sync-context` to hand off state between instances
- Use `verify` before declaring any parallel work complete
- Track ownership is flexible — you assign and reassign as needed

---

## Verification

Verification rules are defined per-project in `praxis/verification.md`. This file is generated during `setup` and can be updated at any time.

Verification runs:
- Automatically at the end of each implementation phase (before checkpoint)
- On demand via the `verify` command
- As part of `review`

See `praxis/verification.md` for the configurable checklist.

---

## Post-Tool Hooks

After Claude Code edits code, the following hooks run automatically via `.claude/settings.json`:
- **Format** — Prettier, Black, or project-specific formatter
- **Lint** — ESLint, Ruff, or project-specific linter
- **Type check** — TypeScript tsc, mypy, or equivalent
- **Security scan** — Trivy, Bandit, or equivalent free scanner

Configure verification tools with `praxis config` and regenerate hooks with `praxis bootstrap`.
Run `praxis verify` for on-demand checks (quick mode: formatter + linter; `--full` for all).

---

## Subagents

Subagents are specialized prompts that run in a separate context to protect the main context window. They are invoked via slash commands:

- **verify** — runs all checks, reports pass/fail without polluting main context
- **simplify** — takes a file/function, returns a cleaner version
- **sync-context** — reads current track state, exports a portable summary

Subagents read `praxis/context/` and `praxis/verification.md` but operate independently.

---

## Spec Format

```markdown
---
track: {track-name}
type: {code|architecture|federal|content}
status: ACTIVE
created: {YYYY-MM-DD}
completed: null
---

# {Track Title}

## Problem
What problem does this solve and for whom.

## Approach
Chosen approach with rationale.

## Alternatives Considered
What else was evaluated and why it was rejected.

## Constraints
Technical, timeline, compliance, or resource limitations.

## Success Criteria
Measurable, verifiable outcomes that define done.

## Dependencies
What this requires. What depends on this.
```

---

## Plan Format

```markdown
---
track: {track-name}
current_phase: 1
total_phases: {n}
---

# {Track Title} — Implementation Plan

## Phase 1: {Phase Name}
> Estimated effort: {estimate}

- [ ] Task description
- [ ] Task description
- [ ] Run verify

**⏸ CHECKPOINT — Stop for review before Phase 2**

## Phase {n}: Finalize
> Estimated effort: {estimate}

- [ ] Final validation against spec success criteria
- [ ] Run verify (full)
- [ ] Update spec.md status if complete
```

---

## Review Format

```markdown
---
track: {track-name}
reviewed: {YYYY-MM-DD}
verdict: {PASS|FAIL|PARTIAL}
---

# Review: {Track Title}

## Spec Compliance
- ✅ Met | ⚠️ Partial | ❌ Not Met — per criterion

## Plan Completion
- Tasks: {x}/{total} | Phases: {x}/{total}

## Verification Results
- Output from last verify run

## Guideline Adherence
- Assessment against praxis/context/guidelines.md

## Issues Found
- Severity: LOW | MEDIUM | HIGH

## Recommendations
- Fixes, improvements, new tracks

## Verdict
**{PASS|FAIL|PARTIAL}** — {summary}
```

---

## Status Report Format

```
📋 PRAXIS STATUS — {project name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 ACTIVE TRACKS
  {track-name} [{type}]
    Phase: {current}/{total} — {phase name}
    Next task: {first unchecked task}
    Blockers: {any or "None"}
    Verification: {last result or "Not run"}

🏁 COMPLETED TRACKS
  {track-name} [{type}] — completed {date}
    Verdict: {PASS|FAIL|PARTIAL}

📊 SUMMARY
  Active: {n}  Completed: {n}
  Tasks: {checked}/{total} ({percent}%)

💡 SUGGESTED NEXT ACTION
  {recommendation}
```
