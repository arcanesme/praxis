# Coding Rules
<!-- Universal — applies to ALL code regardless of language or stack -->
<!-- No paths: scoping — loads for every coding session -->

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

---

## Conventions — WARN on violation

### Context7 usage
- Use slash syntax for precision: append `use context7 /library-id` to the prompt.
  This skips the library-matching step and retrieves docs directly.
- For version-specific questions include the version in the prompt.

### Code quality
- Functions do one thing. If you are writing "and" in a function description,
  split it into two functions.
- Variable names describe what they contain: `subscriptionIds` not `ids`,
  `retryDelayMs` not `delay`.
- Delete dead code. Commented-out code belongs in git history, not in files.

### Testing and verification
- Never say "this should work" — demonstrate it. Show output, log line, or test result.
- Scripts that modify resources must have a dry-run or preview step before live run.

### Documentation
- Comments explain WHY, not WHAT. If the comment describes what the code does,
  rewrite the code to be self-describing instead.
- Update docs and comments when changing logic. Stale comments actively mislead.

---

## Verification Commands

```bash
# Verify Context7 MCP is active
claude mcp list | grep context7

# Check for hardcoded credential patterns in staged files
git diff --staged | grep -iE "(password|secret|token|key)\s*=\s*['\"][^'\"$]"

# Find TODO/FIXME left in staged files
git diff --staged | grep -E "(TODO|FIXME|HACK|XXX)"
```

---

## Removal Condition
Permanent. Remove only if a dedicated AI coding assistant replaces Claude Code
entirely and handles doc lookup automatically without instruction.
