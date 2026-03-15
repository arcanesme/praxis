# Web Designer Kit

> Design system initialization, component lifecycle, accessibility, responsive design.

## Activation

```
/kit:web-designer
```

## What This Kit Provides

### Rules
- `rules/web-design.md` — Token usage, a11y non-negotiables, motion, responsive, commit prefix

### Commands
- `/web-init` — Initialize a design system for the project
- `/web-component` — Full component lifecycle (design → build → test → document)

### MCP Servers
- **21st-magic** — AI-powered design tool integration

## MCP Setup

Run `install.sh` to register the MCP server:

```bash
cd kits/web-designer
bash install.sh
```

This registers: `claude mcp add 21st-magic npx -- -y @21st-dev/magic@latest`

## Commit Prefix

When this kit is active, prefix commits with `[web]`:
- `[web] Add button component with variants`
- `[web] Fix contrast ratio on dark theme`
