# Self-Verification Protocol

Run this protocol after completing any function, class, or module.
Do not commit until all applicable checks pass.
This is not a suggestion — it is the final step of writing code.

## Output Format
Report results as:
```json
{
  "unit": "function/class/module name",
  "checks_run": 24,
  "checks_passed": 24,
  "checks_failed": 0,
  "failures": [],
  "gate": "pass"
}
```
If gate is "fail", list each failure with file, line, and fix_required.

---

## CORRECTNESS CHECKS

- [ ] **Happy path**: Trace the code with normal, expected input. Does output match the function name's promise exactly?
- [ ] **Empty/null input**: What happens with empty string, empty array, null, undefined, zero? Is each case handled explicitly?
- [ ] **Boundary values**: What happens at min, max, exactly-at-limit? Are off-by-one errors possible?
- [ ] **All return paths**: Does every code path that can be reached have an explicit return? Is there a path that falls through to undefined?
- [ ] **Side effect inventory**: List every side effect this function has. Are all of them documented in the name or comment?
- [ ] **Concurrent safety**: If this function is called twice simultaneously, can state be corrupted? Are shared resources protected?

## SIMPLICITY CHECKS

- [ ] **Line count**: Function body ≤ 30 lines of logic. If over — split before committing.
- [ ] **Nesting depth**: No block nested deeper than 3 levels. If over — extract or invert conditions.
- [ ] **Parameter count**: ≤ 4 parameters. If over — use an options object.
- [ ] **Single responsibility**: Can you describe what this function does in one sentence without using "and"? If not — split it.
- [ ] **Dead code**: Is there any code path that can never be reached? Remove it.
- [ ] **Used-once abstractions**: Is there an interface, class, or helper that has exactly one implementation or caller? Inline it.
- [ ] **Speculative code**: Is there any code handling a case that doesn't exist yet in the actual requirements? Remove it.

## NAMING CHECKS

- [ ] **Function name matches behavior**: Does the function name describe exactly what it does, including side effects?
- [ ] **Variable names are nouns**: Do all variables describe what they contain, not what they are used for?
- [ ] **No generic names**: Are there any variables named `data`, `info`, `temp`, `result`, `obj`, `val`, `res`, `err`? Rename them.
- [ ] **Boolean names are assertions**: Are booleans named `isX`, `hasX`, `canX`, `shouldX`?

## SECURITY CHECKS (run when function touches user input or external data)

- [ ] **Input validation**: Is every value from user input or external APIs validated (type, range, format) before use?
- [ ] **Parameterized queries**: If this function touches a database, are all queries parameterized? No string concatenation into SQL.
- [ ] **No secrets in code**: Are any API keys, passwords, tokens, or credentials hardcoded? Move to environment variables.
- [ ] **No sensitive data in logs**: Are passwords, tokens, PII, or session data excluded from all log statements?
- [ ] **Error messages**: Do error messages returned to callers omit internal implementation details, stack traces, or system paths?
- [ ] **Auth checks**: If this function handles a request, is the caller's identity and permission verified before processing?

## COMPLETENESS CHECKS

- [ ] **Happy path test exists**: Is there a test that verifies correct output for normal input?
- [ ] **Failure path test exists**: Is there a test that verifies correct behavior when the function fails or receives invalid input?
- [ ] **Edge case tests exist**: Are the boundary values and null/empty cases identified above covered by tests?
- [ ] **Test names are documentation**: Does each test name describe the specific scenario and expected outcome precisely?
- [ ] **Docstring is accurate**: Does the docstring/comment describe what the code actually does today (not what it used to do or was planned to do)?

## INTEGRATION CHECKS

- [ ] **No broken existing tests**: Do all tests in the affected modules still pass?
- [ ] **Public API contract**: Does the function signature and return type match what existing callers expect?
- [ ] **No new circular dependencies**: Does this change introduce any import cycle between modules?
- [ ] **Dependency hygiene**: Were any new dependencies added? If yes — are they pinned to exact version and documented?

---

## Gate Policy
- Any CORRECTNESS or SECURITY failure → **hard block**. Fix before proceeding.
- Any SIMPLICITY or NAMING failure → **soft block**. Fix unless there is a documented exception.
- Any COMPLETENESS or INTEGRATION failure → **warn**. Fix before PR, not just before commit.
