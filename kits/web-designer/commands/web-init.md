Initialize a design system for the current project.

## Instructions

1. **Collect requirements** (single prompt):
   - Framework (React, Vue, Svelte, vanilla)
   - Styling approach (CSS modules, Tailwind, styled-components, vanilla CSS)
   - Existing brand assets (colors, fonts, logo)

2. **Create design token file**:
   - Colors: primary, secondary, neutral, semantic (success, warning, error, info)
   - Typography: font families, sizes, weights, line heights
   - Spacing: consistent scale (4px base recommended)
   - Shadows: elevation levels
   - Borders: radius values
   - Breakpoints: sm, md, lg, xl

3. **Create base component structure**:
   ```
   src/components/
   ├── tokens/
   │   ├── colors.css
   │   ├── typography.css
   │   ├── spacing.css
   │   └── index.css
   ├── primitives/
   │   ├── Button/
   │   ├── Input/
   │   └── Text/
   └── layouts/
       ├── Stack/
       ├── Grid/
       └── Container/
   ```

4. **Create reset/normalize styles**

5. **Verify**: Confirm token file loads, base components render, a11y baseline met.

## Rules

- Tokens first. Never write a component without tokens defined.
- Accessibility checks on every component from the start.
- Document decisions in an ADR (use `/spec` if significant).
