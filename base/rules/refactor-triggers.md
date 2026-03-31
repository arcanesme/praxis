# Refactor Triggers — Pre-Check Protocol
# Scope: All code modifications
# Always active during code generation
# Cross-reference: code-quality.md defines the hard limits (30 lines, 3 nesting,
#   4 params, 300-line files, no TODO/FIXME). This file defines WHEN and HOW
#   to refactor — not the thresholds themselves.

## Invariants — BLOCK on violation

### Before touching any existing file
Check the file against `code-quality.md` hard limits before adding code.
If the file already violates limits:
1. Do NOT add new code to it
2. Refactor the file to compliance first
3. THEN make the intended change
4. Commit the refactor separately from the feature

This is mandatory. Adding to an already-broken file compounds debt exponentially.

### Commit refactor separately from feature
- Refactoring commits use `refactor(scope):` prefix
- Feature commits use `feat(scope):` prefix
- Never mix structural changes and behavior changes in one commit
- Rationale: reviewers cannot distinguish "moved code" from "changed behavior" in a mixed diff

### Copy-paste detection
If you find yourself copying 3+ lines from elsewhere in the same codebase: stop.
Extract a shared function in a common location.
Duplication is the root of divergent behavior bugs.

## Conventions — WARN on violation

### The QUALITY comment convention
When you encounter a known violation in code you are NOT tasked with fixing:
```
// QUALITY: function exceeds 30 lines — refactor tracked in #123
```

Rules for QUALITY comments:
- QUALITY: is the ONLY allowed debt marker. `TODO`, `FIXME`, and `HACK` are banned (see `code-quality.md`).
- Every QUALITY comment MUST include a tracking reference (issue number, ADR, or ticket).
- QUALITY comments are allowed in commits — unlike TODO/FIXME which are not.
- A QUALITY comment is NOT a license to defer indefinitely. It is a documented acknowledgment.

### Refactor vs rewrite decision gate
- **Refactor** (preferred): same behavior, improved structure. Small, safe, incremental.
- **Rewrite**: new behavior or complete structural replacement.

If >50% of a file needs changing during a feature task:
1. Stop. Do not incrementally refactor to the point of a full rewrite.
2. File an issue for the rewrite.
3. Complete the minimum viable refactor for the current feature.
4. Propose the rewrite as a separate milestone with its own plan.

Never rewrite during a feature task without an explicit plan.

## Removal Condition
Remove when automated refactoring tools (e.g., language-specific AST transforms)
handle pre-check validation and commit separation automatically.
