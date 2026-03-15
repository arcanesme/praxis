Create a new UI component through the full lifecycle.

## Instructions

1. **Collect requirements** (single prompt):
   - Component name
   - Purpose and use cases
   - Variants (sizes, colors, states)
   - Props interface

2. **Design phase**:
   - Define the component API (props, events, slots/children)
   - List all states: default, hover, focus, active, disabled, loading, error
   - Identify design tokens needed
   - Check if 21st-magic MCP can provide reference designs

3. **Build phase**:
   - Create component file following project conventions
   - Use design tokens — no raw values
   - Implement all identified states
   - Add ARIA attributes and keyboard handling

4. **Test phase**:
   - Visual: render all variants and states
   - A11y: keyboard navigation, screen reader, contrast
   - Responsive: test at all breakpoints
   - Edge cases: long text, missing props, empty states

5. **Document phase**:
   - Props table with types, defaults, descriptions
   - Usage examples for each variant
   - A11y notes (keyboard shortcuts, ARIA roles)
   - Add to Storybook / component catalog if available

## Rules

- Every component passes a11y checks before completion
- Use semantic HTML as the foundation
- Commit with `[web]` prefix
- Run `/pre-commit-lint` before committing
