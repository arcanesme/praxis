# Coding — Universal Rules
<!-- Universal — applies to ALL code regardless of language or stack -->
<!-- Merged from coding.md + code-quality.md -->

---

## Invariants — BLOCK on violation

### Documentation lookup before implementation
- Before implementing anything that uses an external library, framework, or API:
  use Context7 to get current docs. Training data has a cutoff. Context7 does not.
- Append "use context7" to any prompt involving a library not personally verified as current.
- Never suggest a method, constructor, or API signature from memory for a library
  that releases frequently. Look it up first via Context7.
- If Context7 is unavailable: state that docs could not be verified and flag the
  specific method/API as "unverified against current version."

### Error handling
- Never silently swallow exceptions. Every catch block must either re-throw,
  log with context, or return a typed error.
- No empty catch blocks. No fallback defaults unless explicitly asked.
- Error messages MUST include context: request params, response body, status codes.
- Use structured logging fields, not string interpolation.
- External calls: retries with exponential backoff + warnings, then raise last error.
- Validate response shape, not just status code — a 200 with error body is a silent failure.
- Every function that can fail must have an explicit failure path.
- Validate inputs at the boundary. Never assume callers pass correct data.

### No hardcoded values
- No credentials, tokens, connection strings, or API keys inline. Ever.
  Use environment variables, Key Vault references, or parameter files.
- No hardcoded paths specific to one machine. Use relative paths or env-derived roots.
- No magic numbers without a named constant and a comment explaining the value.

### State and side effects
- Pure functions where possible. If a function mutates state, its name must signal that.
- Never mutate input parameters. Return new values.
- Write pure functions — only modify return values, never inputs or global state.

### Typing
- Strict typing everywhere: function signatures, variables, collections.
- No implicit `any` or untyped parameters in typed languages.

### No flag parameters
- Never write a function with a boolean/enum parameter that switches behavior.
  Write separate named functions instead.

### Dead code
- Delete dead code. Do not comment it out.
  Commented-out code belongs in git history, not in files.
- Check if logic already exists before writing new code: `rg` to search first.

---

## Conventions — WARN on violation

### Code structure
- Functions do one thing. If you are writing "and" in a function description,
  split it into two functions.
- Prefer functional programming in greenfield code; classes only for connectors/interfaces.
  Follow existing project conventions in established codebases.
- All imports at the top of the file.
- Follow DRY, KISS, YAGNI.

### Naming
- Variable names describe what they contain: `subscriptionIds` not `ids`,
  `retryDelayMs` not `delay`.
- Functions: verb-noun format. Name signals intent and side effects.

### Testing
- Write tests for ALL new code in production paths.
- Spike/prototype carve-out: skip tests only if explicitly marked spike/prototype.
  Flag test debt in `status.md` under `## Test Debt`.
- Run tests before marking any task complete.
- Mock external dependencies only — never mock the code under test.
- Test edge cases and error paths, not just happy paths.
- If existing tests break: fix them. Do not claim they are unrelated.
- Never say "this should work" — demonstrate it with output, log line, or test result.

### Dependency management
Before adding any new package:
1. Search first — check if functionality exists in codebase or stdlib (`rg`).
2. Evaluate: maintenance status, last publish, open issues, bus factor.
3. Minimize surface area — implement yourself if you only need one function.
4. Pin versions — exact versions in lockfiles. No floating ranges in production deps.
5. New production dependency requires explicit approval.

### Documentation
- Comments explain WHY, not WHAT. If the comment describes what the code does,
  rewrite the code to be self-describing instead.
- Update docs and comments when changing logic. Stale comments actively mislead.
- Code is primary documentation — clear naming, types, docstrings.
- Obsidian-compatible frontmatter on all markdown files:
  ```yaml
  ---
  created: YYYY-MM-DD
  status: draft|active|completed
  tags: [relevant, tags]
  source: agent
  ---
  ```

### Scripts
- Scripts that modify resources must have a dry-run or preview step before live run.

### Tool preferences
- Use Read/Edit/Write tools instead of cat/sed/echo.
- Use `rg` (ripgrep) for searching code, not grep.
- Use `git --no-pager` for all git commands.
- Use subagents for context-heavy research and code review.
- Non-interactive commands only — no interactive prompts.
- Prefer MCP tools for current documentation (context7, Playwright).

---

## Verification Commands

```bash
# Verify Context7 MCP is active
claude mcp list | grep context7

# Check for hardcoded credential patterns in staged files
git diff --staged | grep -iE "(password|secret|token|key)\s*=\s*['\"][^'\"$]"

# Find TODO/FIXME left in staged files
git diff --staged | grep -E "(TODO|FIXME|HACK|XXX)"

# Find commented-out code blocks (language-agnostic)
git diff --staged | grep -E "^\+\s*(#|//|--|\*)\s*(def |function |class |var |const |let )"

# Check for untyped any in TypeScript staged files
git diff --staged -- '*.ts' | grep -E ": any"
```

---

## Removal Condition
Permanent. Remove only if a dedicated AI coding assistant replaces Claude Code
entirely and handles all enforcement automatically without instruction.
