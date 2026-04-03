---
paths:
  - "*.tsx"
  - "*.jsx"
  - "*.vue"
  - "*.css"
  - "*.scss"
  - "src/components/**"
  - "design-system/**"
  - "styles/**"
---

# Web Design — Rules

Scope: Frontend component and design system files.
Part of: web-designer AI-Kit.

## Invariants (BLOCK on violation)

### Design Tokens

- No inline styles in component files — use design tokens or Tailwind utilities.
- No hardcoded color values (`#fff`, `rgb(...)`) — must reference token variables
  (`var(--color-primary)`, Tailwind classes, or theme values).
- Check: `grep -rn "color:" src/components/ | grep -v "var(--" | grep -v "tailwind"`

### Semantic HTML

- No `<div>` click handlers — use `<button>` for actions, `<a>` for navigation.
- Check: `grep -rn 'onClick.*<div' src/components/`
- Every interactive element must have explicit keyboard handling (`onKeyDown` or
  native keyboard support via semantic elements).

### Accessibility

- Every `<img>` must have an `alt` attribute (empty `alt=""` for decorative images).
- Form inputs must have associated `<label>` elements or `aria-label`.
- Color contrast must meet WCAG AA minimum (4.5:1 for text, 3:1 for large text).

## Conventions (WARN on violation)

### Component Structure

- Component files follow `ComponentName/index.tsx` + `ComponentName.module.css`
  (or `ComponentName.tsx` with Tailwind — pick one pattern per project, don't mix).
- Design tokens live in `design-system/tokens/` or equivalent.
- Shared components live in `src/components/ui/` — page-specific components
  live in `src/components/[page-name]/`.

### Animation and Motion

- Animation durations use token values, not magic numbers.
- Respect `prefers-reduced-motion` — wrap animations in media query.
- CSS transitions preferred over JS animation libraries for simple effects.

### Performance

- Images have explicit `width` and `height` to prevent CLS (Cumulative Layout Shift).
- Lazy-load images below the fold (`loading="lazy"`).
- No layout-triggering CSS in animation loops (`top`, `left`, `width`, `height` — use `transform` and `opacity`).

### Design System Hygiene

- New components must use existing tokens before creating new ones.
- If a new token is needed: add to the token file, not inline.
- Component variants use a consistent API pattern (props, not className overrides).

## Verification Commands

```bash
# Token compliance — find hardcoded colors
grep -rn "color:" src/components/ | grep -v "var(--" | grep -v "token" | grep -v "tailwind"

# Semantic HTML — find div click handlers
grep -rn 'onClick.*<div' src/components/

# Accessibility — find images without alt
grep -rn '<img' src/components/ | grep -v 'alt='

# CLS prevention — find images without dimensions
grep -rn '<img' src/components/ | grep -v 'width' | grep -v 'height'

# Accessibility audit (if axe-core installed)
npx axe-core src/ --exit
```

## Removal Condition

Remove when the project's design system is mature with >90% component coverage
and design review is handled by a dedicated design tool or CI pipeline.
