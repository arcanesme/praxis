# Code Quality — Rules
# Scope: All projects, all sessions
# Complements `coding.md` with structural quality thresholds.

## Invariants — BLOCK on violation

### No deep nesting
- Conditionals nested >3 levels deep must be refactored (extract function, early return, guard clause).
- Applies to if/else, try/catch, loops, and match/switch statements.

### Cyclomatic complexity
- Functions with cyclomatic complexity >15: BLOCK. Refactor before commit.
- Measure by counting decision points (if, else if, for, while, case, &&, ||, catch).

### Public function documentation
- All public functions and methods must have doc comments.
- Doc comments describe intent and constraints, not implementation.
- Internal/private helpers: doc comments optional, but name must be self-describing.

### No commented-out code
- No commented-out code blocks in committed files.
- Dead code belongs in git history, not in source files.
- `// TODO:` and `// FIXME:` are annotations, not commented-out code — these are allowed.

---

## Conventions — WARN on violation

### Complexity awareness
- Cyclomatic complexity >10: WARN. Consider splitting the function.
- Functions longer than 50 lines: review for single-responsibility violation.

### No magic numbers
- No magic numbers without a named constant and a comment explaining the value.
- Exception: 0, 1, -1, and values obvious from immediate context (e.g., `array.length - 1`).

### Single responsibility
- Each function does one thing. If the description requires "and", split it.
- Each file has one primary concern. Utility grab-bags indicate missing abstractions.

### No hardcoded environment values
- No hardcoded URLs, ports, hostnames, or credentials specific to an environment.
- Use environment variables, config files, or parameter injection.
- Cross-ref: `coding.md` — No hardcoded values invariant.

---

## Verification Commands

```bash
# Find deeply nested blocks (rough heuristic — look for 4+ indent levels)
rg '^\s{16,}(if|for|while|try)' --type-add 'code:*.{ts,js,py,go,rs}' -t code

# Find commented-out code blocks (multi-line)
rg '^\s*//\s*(const|let|var|function|class|import|return|if|for)' --type-add 'code:*.{ts,js}' -t code
rg '^\s*#\s*(def |class |import |return |if |for )' -t py

# Find magic numbers in staged files
git diff --staged | grep -E '[^0-9][2-9][0-9]{2,}[^0-9]' | grep -v 'const\|#\|//'
```

---

## Removal Condition
Permanent. Structural quality thresholds apply regardless of project or language.
