# Creating an AI-Kit

## Overview

An AI-Kit is a domain-specific extension for Praxis. It bundles rules, commands, and optionally MCP servers into a package that can be activated on demand.

## Kit Structure

```
kits/{kit-name}/
├── KIT.md              # Manifest (required)
├── install.sh          # MCP/dependency setup (optional)
├── rules/
│   └── {domain}.md     # Domain-specific rules
└── commands/
    └── {command}.md    # Domain-specific commands
```

## KIT.md Manifest

```markdown
# {Kit Name}

> One-line description.

## Activation

\`\`\`
/kit:{kit-name}
\`\`\`

## What This Kit Provides

### Rules
- `rules/{file}.md` — Description

### Commands
- `/{command}` — Description

### MCP Servers (optional)
- **{server-name}** — Description

## MCP Setup (optional)

Run `install.sh` to register MCP servers.

## Commit Prefix (optional)

`[{prefix}]` — Used for all commits while kit is active.
```

## Rules

### File Format

Rules are markdown with YAML frontmatter:

```markdown
---
description: What this rule covers
---

# {Title}

{Content}
```

Kit rules extend (never override) base rules.

### Commands

Follow the same format as base commands. The command filename (minus `.md`) becomes the slash command name.

## Registration

Add the kit to the registry in `base/CLAUDE.md`:

```markdown
| `{kit-name}` | `/kit:{kit-name}` | {description} |
```

## Guidelines

- Keep kits focused on a single domain
- Rules should be actionable, not aspirational
- Commands should collect all input in one prompt (single-reply intake)
- Test the kit on a real project before publishing
- Kit activation must be idempotent
