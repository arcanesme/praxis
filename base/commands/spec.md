Generate a specification for the requested work.

## Instructions

Before writing ANY code, generate a spec using this structure:

### WHAT
Describe what will be built or changed. Be specific about scope.

### DONE-WHEN
List measurable, verifiable success criteria. Each criterion must be testable.

### CONSTRAINTS
Technical, timeline, compliance, or resource limitations.

### NON-GOALS
Explicitly list what is OUT of scope. This prevents scope creep.

## Process

1. Ask clarifying questions if the request is ambiguous
2. Draft the spec using the structure above
3. Present for human approval
4. Do NOT proceed to implementation until the spec is approved

## Output Format

```markdown
---
track: {track-name}
type: {code|architecture|content}
status: DRAFT
created: {YYYY-MM-DD}
---

# {Title}

## WHAT
{description}

## DONE-WHEN
- [ ] {criterion 1}
- [ ] {criterion 2}

## CONSTRAINTS
- {constraint}

## NON-GOALS
- {non-goal}
```

Save to the project's track directory if one exists. Otherwise present inline.
