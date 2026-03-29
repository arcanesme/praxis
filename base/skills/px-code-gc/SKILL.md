---
name: px-code-gc
disable-model-invocation: true
description: "Detect code entropy in the current repo: dead code, test debt, stale TODOs, oversized functions, commented-out blocks, unused deps. Two modes: lightweight (called by session-retro) and full audit (manual /code-gc). Never auto-deletes or auto-fixes."
---

# code-gc Skill

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`.
Detect current project by matching CWD to `local_path` in vault `_index.md`.

## Two Modes

| Mode | Trigger | Scope | Output |
|------|---------|-------|--------|
| **Lightweight** | Called by `session-retro` Phase 6b | TODOs + test debt delta only | One line or silence |
| **Full Audit** | Manual `/code-gc` | All 6 entropy checks | Prioritized report, offer to write vault |

---

## Mode A — Lightweight (session-retro)

Run only these two checks against the current session's diff:

```bash
# New TODOs/FIXMEs introduced this session
git diff HEAD -- '*.ts' '*.py' '*.go' '*.js' '*.rs' '*.rb' | \
  grep "^+" | grep -cE "(TODO|FIXME|HACK|XXX)"

# Production files touched without corresponding test file touched
git diff --name-only HEAD | grep -vE "(test|spec|__tests__|_test)" | \
  grep -E "\.(ts|py|go|js|rs|rb)$"
```

Output rules:
- 0 TODOs added, test files touched: **silent**
- TODOs added OR prod files touched without tests: `⚠ code-gc: {n} TODOs added, {n} prod files touched without tests`
- Never block. Exit 0 always.

---

## Mode B — Full Audit

### Check 1: Dead Code
```bash
# TODOs/FIXMEs with age
rg "(TODO|FIXME|HACK|XXX)" --line-number --glob "!*.lock" . | head -50
# For each hit: git blame to get age

# Commented-out code blocks (language-agnostic)
rg --multiline "(^\s*(#|//|--)\s*(def |function |class |const |let |var |func ))"
```
Flag:
- CRITICAL: TODO older than 90 days in a production path
- HIGH: Commented-out function/class definition
- MEDIUM: TODO 30–90 days old

### Check 2: Test Debt
```bash
# Find production source files
find . -type f \( -name '*.ts' -o -name '*.py' -o -name '*.go' -o -name '*.js' \) \
  -not -path '*/test*' -not -path '*/spec*' -not -path '*/node_modules*' \
  -not -path '*/__tests__*'

# For each: check if a corresponding test file exists
# ts: src/foo.ts → check src/foo.test.ts, src/foo.spec.ts, test/foo.test.ts
# py: foo.py → check test_foo.py, tests/test_foo.py
# go: foo.go → check foo_test.go
```
Flag:
- CRITICAL: Production file with no test file, NOT marked spike/prototype in status.md
- MEDIUM: Production file with no test, IS marked spike (test debt acknowledged)

Also check `status.md` for `## Test Debt` section — report any items there that
have been stale for >30 days.

### Check 3: Oversized Functions
```bash
# Count lines between function definitions (approximate)
# TypeScript/JavaScript
rg --line-number "^(export\s+)?(async\s+)?function |^\s+(async\s+)?[a-zA-Z]+\s*\(" \
  --glob '*.ts' --glob '*.js'
# Python
rg --line-number "^def |^    def " --glob '*.py'
# Go
rg --line-number "^func " --glob '*.go'
```
For each match: count lines to next same-indent definition.
Flag:
- HIGH: >100 lines
- MEDIUM: 50–100 lines

### Check 4: Unused Dependencies
```bash
# Node/npm
if [ -f package.json ]; then
  # declared deps vs. actual imports
  node_deps=$(jq -r '.dependencies // {} | keys[]' package.json 2>/dev/null)
  for dep in $node_deps; do
    rg "require\(['\"]}$dep|from ['\"]$dep" --quiet || echo "UNUSED: $dep"
  done
fi

# Python
if [ -f requirements.txt ]; then
  while read pkg; do
    name=$(echo $pkg | sed 's/[>=<].*//' | tr '[:upper:]' '[:lower:]')
    rg -i "import $name|from $name" --quiet || echo "UNUSED: $pkg"
  done < requirements.txt
fi

# Go
if [ -f go.mod ]; then
  go mod tidy -e 2>&1 | grep "^unused"
fi
```
Flag:
- MEDIUM: Declared dependency with no import found

### Check 5: Orphan Files
```bash
# Files not touched in >180 days in an active project
git log --diff-filter=M --name-only --format="" --since="180 days ago" | sort -u > /tmp/recent_files
find . -type f \( -name '*.ts' -o -name '*.py' -o -name '*.go' \) \
  -not -path '*/node_modules*' > /tmp/all_source
comm -23 <(sort /tmp/all_source) /tmp/recent_files
```
Flag:
- MEDIUM: Source file not touched in 180+ days in an active project

### Check 6: Stale Comments
```bash
# Comments on lines adjacent to recently changed code that are >90 days old
# For each comment line in staged/recent changes:
git log --since='90 days ago' --diff-filter=M -p -- '*.ts' '*.py' '*.go' | \
  grep "^+.*(//)|(#)" | head -20
```
Flag:
- LOW: Comments that describe WHAT the code does (heuristic match against adjacent code)

---

## Report Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CODE GC — {project-slug}  {today_date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CRITICAL ({n})
  ✗ [test-debt] src/auth/login.ts — production path, 0 tests, not marked spike
  ✗ [dead-code] utils/legacy.ts — TODO age 94 days (line 88)

HIGH ({n})
  ✗ [oversized] api/handler.go:ProcessRequest — 143 lines
  ✗ [commented-code] services/payment.py:44 — commented-out function definition

MEDIUM ({n})
  ⚠ [todo-debt] 14 TODOs — oldest: 47 days (billing/invoice.ts:88)
  ⚠ [unused-dep] "lodash" declared in package.json, never imported
  ⚠ [orphan-file] src/utils/old-formatter.ts — not touched 210 days

LOW ({n})
  — [stale-comment] api/routes.ts:22 — comment describes WHAT not WHY

CLEAN
  ✓ Test coverage: all production paths have tests
  ✓ No commented-out code blocks
  ✓ All deps used

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {n} findings  |  {n} clean
  code-gc never auto-fixes — act on findings manually
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After report, offer:
1. Write findings to `{vault_path}/specs/code-gc-{YYYY-MM-DD}.md`
2. Add CRITICAL + HIGH items as tasks to `{vault_path}/tasks.md`
3. Address a specific finding now

Do NOT auto-remediate. Always ask first.

---

## Error Handling

| Condition | Action |
|-----------|--------|
| Not a git repo | STOP. Report — code-gc requires git history for age detection |
| No source files found | Report clean, note stack not detected |
| Dep check tool missing | Skip that check, note in report |
| `go mod tidy` fails | Skip Go dep check, note in report |
| Project not in vault | Run checks, skip vault write offer |

---

## Removal Condition
Remove when static analysis tooling (Semgrep, SonarQube, or equivalent) is wired
into the pre-commit hook and covers all six entropy categories with automated reporting.
