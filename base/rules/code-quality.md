---
description: Simplicity, no over-engineering, YAGNI
---

# Code Quality

## Simplicity

- The right amount of complexity is the minimum needed for the current task.
- Three similar lines of code is better than a premature abstraction.
- Don't add features, refactor code, or make "improvements" beyond what was asked.

## YAGNI (You Aren't Gonna Need It)

- Don't design for hypothetical future requirements.
- Don't add error handling for scenarios that can't happen.
- Don't create helpers or utilities for one-time operations.
- Don't add feature flags or backwards-compatibility shims when you can just change the code.

## No Over-Engineering

- A bug fix doesn't need surrounding code cleaned up.
- A simple feature doesn't need extra configurability.
- Don't add docstrings, comments, or type annotations to code you didn't change.
- Only add comments where the logic isn't self-evident.

## Clean Up

- Don't leave dead code. If it's unused, delete it completely.
- No backwards-compatibility hacks: renaming unused `_vars`, re-exporting types, adding `// removed` comments.
- If you remove something, remove it fully — no tombstones.
