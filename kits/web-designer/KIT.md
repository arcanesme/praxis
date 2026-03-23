---
name: web-designer
version: 1.0.0
description: Full-stack website design — design systems, components, audit
activation: /kit:web-designer
deactivation: /kit:off
skills_chain:
  - phase: design-system-init
    skills: [ui-ux-pro-max, design-system-patterns]
  - phase: component-build
    skills: [frontend-design, shadcn-ui, 21st-dev-mcp]
  - phase: audit
    skills: [web-accessibility, ui-skills-baseline, ui-skills-motion]
  - phase: final-lint
    skills: [web-design-guidelines]
mcp_servers:
  - name: 21st-magic
    command: npx -y @21st-dev/magic@latest
rules:
  - web-design.md
removal_condition: >
  Remove when design system is mature and component library covers 90%+
  of recurring patterns — kit becomes overhead, not leverage.
---

# Web Designer Kit

## Purpose
Chain design skills into a phased workflow for building production websites.
From design system initialization through component construction to
accessibility audit and final lint.

## Skills Chain

| # | Phase | Skills | What It Provides |
|---|-------|--------|-----------------|
| 1 | Design System Init | UI/UX Pro Max, Design System Patterns | Style direction, palette, typography, 3-tier token hierarchy |
| 2 | Component Build | frontend-design, shadcn-ui, 21st.dev MCP | Responsive grid, component primitives, production marketplace |
| 3 | Audit | web-accessibility, UI Skills (baseline + motion) | WCAG compliance, ARIA, visual polish, animation performance |
| 4 | Final Lint | web-design-guidelines | Production design standards audit |

## Workflow Integration

This kit operates WITHIN the Praxis workflow:
- **Praxis** structures the work (discuss → plan → execute → verify → simplify → ship)
- **This kit** adds domain-specific design rules and skill chain

The skills chain is a SEQUENCE, not a replacement for Praxis phases.
Use `/plan` to plan which phase to work on, then execute within that phase
using the kit's skills.

## Prerequisites

Run `install.sh` in this directory to install all required npm skills and MCP servers.
Verify with `/kit:web-designer` after install.

## MCP Servers

| Server | Purpose | Registration |
|--------|---------|-------------|
| 21st-magic | Production component marketplace | `claude mcp add 21st-magic npx -- -y @21st-dev/magic@latest` |

MCP servers persist globally once registered. Kit deactivation does not unregister them.
