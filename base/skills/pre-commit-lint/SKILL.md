---
disable-model-invocation: true
description: Run lint, format, and type-check before commit
---

# /pre-commit-lint

Run project-configured verification checks before committing.

## Steps

1. **Detect project tools**:
   - Look for config files: `pyproject.toml`, `package.json`, `.eslintrc*`, `tsconfig.json`, etc.
   - Identify available checks: formatter, linter, type-checker

2. **Run checks in order**:
   1. **Formatter** — Prettier, Black, rustfmt, gofmt (auto-fix mode)
   2. **Linter** — ESLint, Ruff, clippy (report mode)
   3. **Type checker** — tsc, mypy, pyright (report mode)

3. **Report results**:
   ```
   PRE-COMMIT CHECK
   ━━━━━━━━━━━━━━━━
   Formatter:    PASS ✓ (Black)
   Linter:       FAIL ✗ (2 errors)
   Type checker: PASS ✓ (mypy)

   ERRORS:
   - src/app.py:42 — unused import
   - src/app.py:87 — undefined variable
   ```

4. **If errors found**: List each error with file and line. Do NOT auto-fix linter errors without confirmation.

5. **If all pass**: Confirm ready to commit.

## Rules

- Run formatter first (it may fix linter issues)
- Never skip a configured check
- Report all errors — don't hide them
- Do not commit if any check fails
