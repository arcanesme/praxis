---
name: px-quality-gate
disable-model-invocation: true
description: "Code style and prose quality gate. Checks what linters cannot: naming, doc completeness, prose clarity, structural patterns. Integrated into px-verify as Step 1 item 5b. Also available standalone via /px-quality-gate."
---

# px-quality-gate — Style and Prose Quality Enforcement

## Purpose

Runs automated style checks against changed files. Catches issues that linters and
test suites do not: generic variable names, missing docstrings, prose quality,
structural violations, and import verification.

Integrated into `/px-verify` as Step 1 item 5b (after security scan, before functional check).
Also available standalone via `/px-quality-gate`.

## When It Fires

1. Automatically inside `/px-verify` after security scan
2. As the first step of `/px-ship`
3. On-demand via `/px-quality-gate` for ad-hoc checks

## Scope

Checks run against staged or changed files only (not the full codebase).
Use `/px-complexity-audit` for full codebase scans.

## Verdicts

- **BLOCK**: violation found — must fix before proceeding. Commit blocked.
- **WARN**: advisory issue found — commit allowed, fix recommended.
- **PASS**: all checks clear.

## Check Categories

### 1. Code Structure Checks

Run against all changed code files (exclude vendor/, node_modules/, .git/).

#### File size

```bash
for f in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(go|ts|tsx|js|jsx|py|rs|java|sh|sql)$'); do
  lines=$(wc -l < "$f")
  if [[ "$lines" -gt 300 ]]; then
    echo "BLOCK: $f is $lines lines (limit: 300). Split before committing."
  fi
done
```

#### TODO/FIXME/HACK detection

```bash
for f in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(go|ts|tsx|js|jsx|py|rs|java|sh|sql)$'); do
  hits=$(grep -nE 'TODO|FIXME|HACK' "$f" || true)
  if [[ -n "$hits" ]]; then
    echo "BLOCK: $f contains banned markers. Use QUALITY: with a ticket number instead."
    echo "$hits"
  fi
done
```

#### Nesting depth heuristic

```bash
for f in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(go|ts|tsx|js|jsx|py|rs|java)$'); do
  deep=$(grep -nE '^\s{16,}\S|^\t{4,}\S' "$f" || true)
  if [[ -n "$deep" ]]; then
    echo "WARN: $f may have deep nesting. Review these lines:"
    echo "$deep"
  fi
done
```

#### Generic variable names

```bash
git diff --cached -U0 | grep '^+' | grep -v '^+++' | \
  grep -oE '\b(data|result|info|temp|tmp|obj|val|item|stuff|thing|ret|res)\b' | \
  sort | uniq -c | sort -rn | head -10
```

If any appear 3+ times: WARN with suggestion to use domain-specific names.

#### Missing docstrings on new public functions

```bash
git diff --cached -U3 | grep -E '^\+.*(func |def |export function |export const .* = )' | \
  while read -r line; do
    echo "CHECK: verify doc comment exists for: $line"
  done
```

### 2. Prose Checks

Run against all changed markdown files.

#### AI fluff detection

```bash
FLUFF_PATTERN='leverage|utilize|facilitate|moving forward|going forward|at this point in time|comprehensive solution|robust solution|seamlessly|cutting-edge|best-in-class|in order to|due to the fact that|at the end of the day|synergy|holistic|empower|streamline'

for f in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.md$'); do
  hits=$(grep -inE "$FLUFF_PATTERN" "$f" || true)
  if [[ -n "$hits" ]]; then
    echo "BLOCK: $f contains fluff phrases. Remove or replace per writing-quality.md."
    echo "$hits"
  fi
done
```

#### Passive voice on decisions

```bash
for f in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.md$'); do
  hits=$(grep -inE '(it was decided|was implemented|was chosen|was selected|has been determined)' "$f" || true)
  if [[ -n "$hits" ]]; then
    echo "WARN: $f uses passive voice on decisions. Rewrite in active voice."
    echo "$hits"
  fi
done
```

#### Sentence length check

```bash
for f in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.md$'); do
  awk 'BEGIN{RS="[.!?]"} NF>30 {print NR": "NF" words: "$0}' "$f" | head -5
done
```

#### Unreplaced placeholders

```bash
for f in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.md$'); do
  hits=$(grep -nE '\{placeholder\}|\{TODO\}|\{TBD\}|\[INSERT\]|\[TBD\]|XXX' "$f" || true)
  if [[ -n "$hits" ]]; then
    echo "BLOCK: $f contains unreplaced placeholders."
    echo "$hits"
  fi
done
```

### 3. Context7 Import Check

```bash
NEW_IMPORTS=$(git diff --cached -U0 | grep -E '^\+.*(import |require\(|using |use )' | grep -v '^+++' | grep -v '^//\|^#')

if [[ -n "$NEW_IMPORTS" ]]; then
  echo "GATE: New external imports detected. Each requires a Context7 lookup:"
  echo "$NEW_IMPORTS"
  echo ""
  echo "Confirm each import was verified via Context7 in this session."
  echo "Internal packages (same repo/module) are excluded."
fi
```

## Output Format

```
━━━ QUALITY GATE ━━━━━━━━━━━━━━━━━━━
Code checks:   PASS | WARN | BLOCK
Prose checks:  PASS | WARN | BLOCK
Import check:  PASS | WARN | BLOCK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall:       PASS | WARN | BLOCK

Details:
  [BLOCK] services/auth.go: 342 lines (limit: 300)
  [BLOCK] docs/DESIGN-auth.md: contains "comprehensive solution" (fluff)
  [WARN]  handlers/login.go: possible deep nesting at line 47
  [PASS]  All other checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

- Any single BLOCK = overall BLOCK. Commit prevented.
- WARN-only = overall WARN. Commit allowed. Fix recommended.
- Gate re-runs on re-stage. Fix the issue, `git add`, gate runs again.
- Do NOT bypass the gate. There is no `--force` flag.
