Generate an implementation plan for an approved spec.

## Prerequisites

An approved spec must exist. If no spec has been approved, respond:
"No approved spec found. Run /spec first."

## Instructions

1. Read the approved spec
2. Break the work into phases with clear boundaries
3. Each phase should be completable and verifiable independently
4. Include verification steps at the end of each phase
5. Add a CHECKPOINT gate between phases

## Output Format

```markdown
---
track: {track-name}
current_phase: 1
total_phases: {n}
---

# {Title} — Implementation Plan

## Phase 1: {Phase Name}

- [ ] Task description
- [ ] Task description
- [ ] Run verification

**CHECKPOINT — Stop for review before Phase 2**

## Phase 2: {Phase Name}

- [ ] Task description
- [ ] Run verification

**CHECKPOINT — Stop for review before Phase 3**

## Phase {n}: Finalize

- [ ] Final validation against spec success criteria
- [ ] Run full verification
- [ ] Update spec status to COMPLETED if all criteria met
```

## Rules

- Keep phases small enough to review in one sitting
- Every phase ends with verification
- Never skip checkpoints
- If a phase reveals new scope, create a new spec — don't expand the plan
