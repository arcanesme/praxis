---
description: Run accessibility and design system compliance audit. Use to verify components meet WCAG standards and follow design token conventions. Optionally scope to a specific directory.
---

You are auditing design system compliance and accessibility.

**Step 1 — Determine scope**
If argument provided (e.g., `/web:audit src/components/Button`): audit that path only.
If no argument: audit all component directories.

**Step 2 — Token compliance**
```bash
# Find hardcoded colors in components
grep -rn "color:" src/components/ | grep -v "var(--" | grep -v "token" | grep -v "tailwind"

# Find hardcoded spacing
grep -rn "margin:\|padding:" src/components/ | grep -rn "[0-9]px" | grep -v "var(--"
```

**Step 3 — Semantic HTML**
```bash
# Div click handlers
grep -rn 'onClick.*<div' src/components/

# Images without alt
grep -rn '<img' src/components/ | grep -v 'alt='

# Inputs without labels
grep -rn '<input' src/components/ | grep -v 'aria-label' | grep -v 'id=.*label'
```

**Step 4 — Accessibility (if tools available)**
```bash
# axe-core (if installed)
npx axe-core src/ --exit 2>/dev/null || echo "axe-core not installed — manual review needed"
```

**Step 5 — Motion and performance**
```bash
# Animations without reduced-motion check
grep -rn '@keyframes\|animation:' src/components/ | head -20
grep -rn 'prefers-reduced-motion' src/components/ | head -20
# Compare counts — every animation file should have a motion query

# Images without dimensions (CLS risk)
grep -rn '<img' src/components/ | grep -v 'width' | grep -v 'height'
```

**Step 6 — Report**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WEB AUDIT — {scope}  ({today_date})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Token compliance:    {pass/fail count}
  Semantic HTML:       {pass/fail count}
  Accessibility:       {pass/fail count}
  Motion/performance:  {pass/fail count}

  BLOCKING ({n})
  ✗ {finding}

  WARNINGS ({n})
  ⚠ {finding}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
