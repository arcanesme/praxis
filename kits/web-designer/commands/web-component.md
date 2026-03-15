---
description: Full component lifecycle — scaffold, build, test, audit. Use when creating a new UI component. Follows the web-designer kit skills chain.
---

You are building a component using the web-designer skills chain.

**Step 1 — Component spec**
Ask in a single message:
- Component name (PascalCase)
- Purpose (one sentence)
- Variants needed (e.g., primary/secondary/ghost)
- Interactive? (hover, click, keyboard)
- Where does it live? (shared `ui/` or page-specific)

**Step 2 — Scaffold**
Create component directory:
```
src/components/{location}/{ComponentName}/
  index.tsx          ← Main component
  {ComponentName}.test.tsx  ← Tests
  {ComponentName}.stories.tsx  ← Storybook (if project uses it)
```

**Step 3 — Build (skills chain phase 2)**
Implement following these rules:
- Use design tokens from `design-system/tokens/` — no hardcoded values
- Use semantic HTML elements — no div click handlers
- Include keyboard handling for all interactive elements
- Include `aria-label` or associated `<label>` for form elements
- Use existing component primitives (shadcn/ui) where applicable
- Check 21st.dev MCP for production-ready implementations before building from scratch

**Step 4 — Test**
Write tests covering:
- Renders without errors
- Each variant renders correctly
- Interactive states work (click, keyboard)
- Accessibility: semantic structure, aria attributes

**Step 5 — Audit (skills chain phase 3)**
Run accessibility and design compliance checks:
- Token compliance: no hardcoded colors
- Semantic HTML: no div handlers
- WCAG: color contrast, keyboard nav
- Motion: respects prefers-reduced-motion

**Step 6 — Report**
```
✓ Component: {ComponentName}
  Files:    {list created files}
  Variants: {list}
  Tests:    {pass/fail count}
  Audit:    {pass/fail with details}
```
