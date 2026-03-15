---
description: Web design standards — tokens, a11y, motion, responsive, commit prefix
---

# Web Design Rules

## Design Tokens

- Use CSS custom properties for all design tokens (colors, spacing, typography, shadows).
- Token naming: `--{category}-{property}-{variant}` (e.g., `--color-primary-500`, `--space-lg`).
- Never use raw values (hex codes, pixel values) outside of token definitions.
- Define tokens in a single source file. All components reference tokens, not raw values.

## Accessibility (Non-Negotiable)

- **Color contrast**: WCAG AA minimum (4.5:1 normal text, 3:1 large text).
- **Keyboard navigation**: All interactive elements must be focusable and operable via keyboard.
- **ARIA labels**: Every interactive element has an accessible name.
- **Focus indicators**: Visible focus rings on all focusable elements. Never `outline: none` without a replacement.
- **Semantic HTML**: Use `<button>`, `<nav>`, `<main>`, `<article>` — not `<div>` with role attributes.
- **Screen reader testing**: Components must make sense when read aloud.

## Motion

- Respect `prefers-reduced-motion`. Wrap all animations:
  ```css
  @media (prefers-reduced-motion: no-preference) {
    .element { transition: transform 200ms ease; }
  }
  ```
- Keep transitions under 300ms for UI feedback.
- No motion for decoration only. Motion should communicate state changes.

## Responsive

- Mobile-first. Base styles are mobile, enhance with `min-width` queries.
- Breakpoints via tokens: `--breakpoint-sm`, `--breakpoint-md`, `--breakpoint-lg`.
- Test at 320px, 768px, 1024px, 1440px minimum.
- No horizontal scrolling at any breakpoint.

## Component Standards

- One component per file.
- Every component has: default state, hover, focus, active, disabled.
- Props/variants documented with examples.
- Storybook or equivalent for visual testing.

## Commit Prefix

All commits while this kit is active use the `[web]` prefix:
- `[web] Add button component with size variants`
- `[web] Fix header nav keyboard navigation`
