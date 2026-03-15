# Code Quality — Rules
# Scope: All projects, all sessions

## Code Standards
- Prefer functional programming in greenfield code; classes only for connectors/interfaces.
  Follow existing project conventions in established codebases.
- Write pure functions — only modify return values, never inputs or global state.
- Strict typing everywhere: function signatures, variables, collections.
- Check if logic already exists before writing new code (`rg` to search).
- No flag parameters that switch behavior — write separate functions.
- All imports at the top of the file.
- Follow DRY, KISS, YAGNI.

## Error Handling (CRITICAL)
- ALWAYS raise errors explicitly. NEVER silently ignore them.
- Use specific error types with clear, actionable messages.
- No empty catch blocks. No fallback defaults unless explicitly asked.
- Error messages MUST include context: request params, response body, status codes.
- Use structured logging fields, not string interpolation.
- External calls: retries with exponential backoff + warnings, then raise last error.
- Validate response shape, not just status code — a 200 with error body is a silent failure.

## Testing Standards
- Write tests for ALL new code in production paths.
- Spike/prototype carve-out: skip tests only if explicitly marked spike/prototype.
  Flag test debt in `status.md` under `## Test Debt`.
- Run tests before marking any task complete.
- Mock external dependencies only — never mock the code under test.
- Test edge cases and error paths, not just happy paths.
- If existing tests break: fix them. Do not claim they are unrelated.

## Dependency Management
Before adding any new package:
1. Search first — check if functionality exists in codebase or stdlib (`rg`).
2. Evaluate: maintenance status, last publish, open issues, bus factor.
3. Minimize surface area — implement yourself if you only need one function.
4. Pin versions — exact versions in lockfiles. No floating ranges in production deps.
5. New production dependency requires explicit approval.

## Documentation
- Code is primary documentation — clear naming, types, docstrings.
- Keep docs in docstrings of the functions they describe.
- Separate docs files only when concepts can't be expressed in code.
- Store knowledge as current state, not changelogs.
- Obsidian-compatible frontmatter on all markdown files:
  ```yaml
  ---
  created: YYYY-MM-DD
  status: draft|active|completed
  tags: [relevant, tags]
  source: agent
  ---
  ```

## Tool Preferences
- Use Read/Edit/Write tools instead of cat/sed/echo.
- Use `rg` (ripgrep) for searching code, not grep.
- Use `git --no-pager` for all git commands.
- Use subagents for context-heavy research and code review.
- Non-interactive commands only — no interactive prompts.
- Prefer MCP tools for current documentation (context7, Playwright).
