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

## Design Principles

- **Context budget**: Kit rules + KIT.md should stay under 3000 tokens total.
  Measure after building. If over budget, split rules or trim descriptions.
- **Don't duplicate Superpowers**: If Superpowers already enforces TDD, debugging,
  or code review — don't add kit rules that overlap.
- **Skills chain is a sequence, not a replacement**: GSD still owns the outer
  workflow. The kit provides domain context INTO that workflow.
- **Removal condition is mandatory**: If you can't state when the kit becomes
  unnecessary, don't build it.
