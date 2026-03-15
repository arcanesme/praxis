---
description: Bootstrap a design system for the current project. Creates token files, theme config, and base component structure. Use at the start of any new web project.
---

You are bootstrapping a design system for the current project.

**Step 1 — Assess current state**
- Check if `design-system/` or equivalent already exists
- Check if Tailwind config exists (`tailwind.config.*`)
- Check if any CSS variables or tokens are already defined
- If design system exists: report what's there and ask what to update

**Step 2 — Gather design direction**
Ask in a single message:
- Brand colors (primary, secondary, accent) — or "suggest based on project type"
- Typography preference (serif, sans-serif, mono, or specific fonts)
- Design aesthetic (minimal, bold, editorial, playful, corporate)
- Dark mode support needed? [Y/n]

**Step 3 — Create token hierarchy**
Create 3-tier token structure:
1. **Primitive tokens** — raw values (`--color-blue-500: #3B82F6`)
2. **Semantic tokens** — meaning (`--color-primary: var(--color-blue-500)`)
3. **Component tokens** — usage (`--button-bg: var(--color-primary)`)

Write to `design-system/tokens/` (or project-appropriate location).

**Step 4 — Create base components**
Scaffold these if they don't exist:
- Button (primary, secondary, ghost variants)
- Input (text, with label and error state)
- Card (with header, body, footer slots)
- Typography (h1-h6, body, caption)

**Step 5 — Report**
```
✓ Design system initialized
  Tokens:     {path}/tokens/
  Components: {path}/components/
  Theme:      {tailwind.config or css vars file}
  Dark mode:  {enabled/disabled}
```
