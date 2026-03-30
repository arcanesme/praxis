# Code Quality — Active Constraints

These rules are active during code generation. They are not reviewed after writing —
they shape what gets written in the first place.

## Before writing any function
State in a single-line comment what this function does.
If you cannot write the comment in one sentence, split the function first.
The function name must be derivable from that comment.

## Hard limits — never violate without explicit documented exception
- No function exceeds 30 lines of logic (blank lines and comments excluded)
- No block nesting deeper than 3 levels
- No function with more than 4 parameters — use an options/config object beyond 4
- No class with more than 5 public methods — split the class first
- No file with more than 300 lines — split the module first
- No `TODO` or `FIXME` committed — resolve inline or create a tracked issue with link in comment

## Before introducing any abstraction (interface, base class, factory, wrapper)
Identify exactly 2 or more existing concrete use cases that require it.
They must exist in the current codebase, not in anticipated future requirements.
If only 1 use case exists, inline the logic and do not create the abstraction.

## Before adding any new dependency
- Verify the standard library does not provide equivalent functionality
- Verify the package has had a commit within the last 6 months
- Pin to exact version in package manifest
- Add a comment above the import explaining why this dependency was chosen over alternatives

## On every new public function or method
Write the JSDoc/docstring before writing the implementation.
The docstring must include: what it does, what each parameter is, what it returns, what it throws.
If you cannot write the docstring, you do not yet understand what you are building.

## On error handling — no exceptions
- Every async function has explicit error handling (try/catch or .catch() or Result type)
- Every function that receives external input validates type, range, and format before use
- Every thrown error has a message that identifies: what failed, why it failed, what the caller should do
- Errors are never caught and silently ignored — log at minimum, re-throw if unhandled

## On tests
- New public functions require tests before the PR is considered complete
- Tests assert behavior (outputs and side effects), not implementation (which internal functions were called)
- Each test covers exactly one scenario — no multi-scenario tests
- Test files mirror source file structure — `src/auth/login.ts` → `tests/auth/login.test.ts`

## On comments
Write comments that explain WHY, not WHAT.
Delete any comment that restates what the code already says.
Write comments that capture: non-obvious decisions, external constraints, known limitations.

## On naming
- No single-letter variables except loop indices (`i`, `j`, `k`) in tight loops of ≤5 lines
- No abbreviations unless they are universally understood domain terms (`id`, `url`, `api`)
- No generic names: `data`, `info`, `temp`, `result`, `obj`, `val`, `res`, `thing`, `stuff`
- Rename before committing. Names do not get "cleaned up later."
