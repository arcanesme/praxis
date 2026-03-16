# Creating an AI-Kit

An AI-Kit is a self-contained domain tooling bundle. This guide walks through
creating a new kit for Praxis.

## Directory Structure

```
kits/my-kit/
  KIT.md              ← Manifest (required)
  install.sh          ← Dependency installation (required)
  teardown.sh         ← Clean removal (required)
  rules/              ← Domain-specific rules (optional)
    my-domain.md
  commands/           ← Slash commands (optional)
    my-command.md
```

## Step 1: Write KIT.md

The manifest declares what the kit contains and how it activates.

```yaml
---
name: my-kit
version: 1.0.0
description: One-line description of the domain
activation: /kit:my-kit
deactivation: /kit:off
skills_chain:
  - phase: phase-name
    skills: [skill-1, skill-2]
mcp_servers:
  - name: server-name
    command: npx -y @scope/package@latest
rules:
  - my-domain.md
removal_condition: >
  When to remove this kit — be specific.
---
```

## Step 2: Write Rules

Rules in `rules/` must have `paths:` frontmatter to auto-activate on matching files.

```yaml
---
paths:
  - "*.tsx"
  - "src/components/**"
---
```

Follow the standard rules format:
- **Invariants** (BLOCK on violation) — deterministic, always wrong
- **Conventions** (WARN on violation) — contextual, usually wrong
- **Verification commands** — exact bash commands to check compliance

## Step 3: Write Commands

Commands in `commands/` are slash commands specific to this kit's domain.
Follow the standard command format with a `description:` frontmatter.

## Step 4: Write install.sh

Install all external dependencies:
```bash
#!/bin/bash
set -euo pipefail

echo "=== Praxis: Installing my-kit ==="

# npm skills
npx skills add author/skill-name -g -y

# MCP servers
claude mcp add server-name npx -- -y @scope/package@latest

echo "=== my-kit installed ==="
```

## Step 5: Write teardown.sh

Clean removal of dependencies:
```bash
#!/bin/bash
set -euo pipefail

echo "=== Praxis: Removing my-kit ==="

npx skills remove author/skill-name -g 2>/dev/null || true

echo "=== my-kit removed ==="
echo "MCP servers must be removed manually: claude mcp remove server-name"
```

## Step 6: Test

1. Run `install.sh` — all dependencies install cleanly
2. `/kit:my-kit` — activates, prints skills chain
3. `/kit:my-kit` again — idempotent, no error
4. Work on matching files — kit rules fire
5. Kit commands work (`/my:command`)
6. `/kit:off` — deactivates cleanly
7. `teardown.sh` — removes dependencies

## Step 7: Register

Add one row to `base/CLAUDE.md` in the AI-Kit Registry table:

```markdown
| my-kit | `/kit:my-kit` | One-line domain description |
```

## Worked Example: Infrastructure Kit

The `kits/infrastructure/` kit demonstrates a real kit with planned skills,
domain-specific rules, and commands — but no npm dependencies.

### Directory Structure

```
kits/infrastructure/
  KIT.md              ← Manifest with skills_chain (all status: planned)
  install.sh          ← CLI tool verification (az, terraform, tflint, jq)
  teardown.sh         ← No npm to remove — prints manual cleanup steps
  rules/
    infrastructure.md ← Domain rules (naming, tagging, security, drift)
    infra-apply.md    ← Apply-phase command
    infra-compliance.md ← Compliance-check command
    infra-drift.md    ← Drift-detection command
    infra-plan.md     ← Plan-phase command
  commands/           ← (commands live in rules/ for this kit)
```

### KIT.md Frontmatter

```yaml
name: infrastructure
version: 1.0.0
description: Infrastructure as Code — Terraform, Azure, compliance, drift detection
activation: /kit:infrastructure
deactivation: /kit:off
skills_chain:
  - phase: plan
    skills: []
    status: planned
  - phase: apply
    skills: []
    status: planned
```

Note `status: planned` — this is how you ship a kit incrementally. The phases
are defined in the manifest, but the skills aren't built yet. Commands still
work because they're standalone `.md` files.

### How Commands Map to Skills Chain

| Phase | Command | Skills (future) |
|-------|---------|-----------------|
| plan | `/infra:plan` | infra-plan skill (planned) |
| apply | `/infra:apply` | infra-apply skill (planned) |
| drift | `/infra:drift` | infra-drift skill (planned) |
| compliance | `/infra:compliance` | infra-compliance skill (planned) |

Commands work today as slash commands. When skills are built, the skills chain
phases will orchestrate them automatically.

### Kit Rules vs Base Rules

Base rules (`base/rules/`) are universal — they load based on file paths across
all projects. Kit rules (`kits/infrastructure/rules/`) are domain-specific — they
only activate when the kit is active.

Example: `base/rules/terraform.md` loads whenever you touch `.tf` files.
`kits/infrastructure/rules/infrastructure.md` only loads when you run
`/kit:infrastructure`. This separation prevents context bloat — domain rules
don't consume tokens until the kit is activated.

### Ralph Integration

To persist kit activation across Ralph iterations, add to the project's CLAUDE.md:

```markdown
## Active kit
On session start, activate: /kit:infrastructure
```

Each Ralph iteration reads the project CLAUDE.md and activates the kit via
`/kit:infrastructure`. The command is idempotent — double-activation is a no-op.

### Teardown Pattern for Non-npm Kits

The infrastructure kit has no npm skills or MCP servers. Its `teardown.sh`
simply prints manual cleanup steps:

```bash
echo "This kit has no npm skills or MCP servers to remove."
echo "CLI tools (az, terraform, tflint) are system-level and not managed by this kit."
```

Compare with the web-designer kit, which uses `npx skills remove` for npm-based
skills. Match your teardown to your install.

## Design Principles

- **Context budget**: Kit rules + KIT.md should stay under 3000 tokens total.
  Measure after building. If over budget, split rules or trim descriptions.
- **Don't duplicate Superpowers**: If Superpowers already enforces TDD, debugging,
  or code review — don't add kit rules that overlap.
- **Skills chain is a sequence, not a replacement**: GSD still owns the outer
  workflow. The kit provides domain context INTO that workflow.
- **Removal condition is mandatory**: If you can't state when the kit becomes
  unnecessary, don't build it.
