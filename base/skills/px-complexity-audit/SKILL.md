---
name: px-complexity-audit
disable-model-invocation: true
description: "Codebase debt scanner. Ranks files by complexity score (size, nesting, debt markers, generic names). Use at sprint start, before major features, or quarterly. Outputs heat map and refactor targets."
---

# px-complexity-audit — Codebase Debt Scanner

## Purpose

Scans the existing codebase for accumulated technical debt.
Outputs a ranked heat map of files needing attention.
Use before starting major feature work or at sprint boundaries.

## When To Use

1. Sprint start: identify cleanup targets before new work begins
2. Pre-feature: assess the health of files you are about to modify
3. Quarterly: full codebase scan, results written to vault
4. On-demand: `/px-complexity-audit {directory}` for targeted scan

## What It Scans

### File-level metrics

```bash
FILE_LINES=$(wc -l < "$f")
TODO_COUNT=$(grep -cE 'TODO|FIXME|HACK|QUALITY:' "$f" || echo 0)
FUNC_COUNT=$(grep -cE '(func |def |function |const .* = )' "$f" || echo 0)
DEEP_NEST=$(grep -cE '^\s{16,}\S|^\t{4,}\S' "$f" || echo 0)
GENERIC_NAMES=$(grep -oE '\b(data|result|info|temp|tmp|obj|val|item|stuff|thing|ret|res)\b' "$f" | wc -l || echo 0)
```

### Debt score formula

Each file receives a composite score (higher = more urgent):

```
debt_score = (
  (file_lines / 300 * 30)           +  # Over size limit: 30 points at 300 lines
  (todo_count * 10)                  +  # 10 points per debt marker
  (deep_nest_lines * 5)             +  # 5 points per deeply nested line
  (generic_name_count * 2)          +  # 2 points per generic name
  (longest_function / 30 * 20)         # Over function limit: 20 points at 30 lines
)
```

Thresholds:

- Score 0-20: CLEAN — no action needed
- Score 21-50: WATCH — consider cleanup if touching this file
- Score 51-80: REFACTOR — clean up before adding features
- Score 81+: CRITICAL — stop and refactor now

### Potential dead code detection

```bash
for func_name in $(grep -ohE '(func|def|function)\s+\w+' "$f" | awk '{print $2}'); do
  refs=$(rg -l "$func_name" --type-add 'code:*.{go,ts,py,js,rs,java}' -t code . | grep -v "$f" | wc -l || echo 0)
  if [[ "$refs" -eq 0 ]]; then
    echo "POTENTIAL_DEAD: $func_name in $f (0 external references)"
  fi
done
```

## Output Format

### Heat Map (terminal output)

```
━━━ COMPLEXITY AUDIT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Scanned: 47 files | CLEAN: 31 | WATCH: 9 | REFACTOR: 5 | CRIT: 2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TOP 5 REFACTOR TARGETS

 Rank | File                        | Score | Primary Issue
 ─────┼─────────────────────────────┼───────┼────────────────────
  1   | services/auth/handler.go    |  94   | 342 lines, 4 TODOs
  2   | services/billing/calc.py    |  87   | 60-line function
  3   | handlers/api/v2/users.ts    |  73   | 5-level nesting
  4   | lib/cache/redis.go          |  58   | 12 generic names
  5   | cmd/worker/process.go       |  52   | 3 TODOs, 280 lines

Estimated effort: ~4 hours for top 5
```

### Effort estimation heuristic

| Action | Estimated time |
| ------ | -------------- |
| Split a 300+ line file | 30-45 min |
| Extract a 30+ line function | 15-20 min |
| Flatten deep nesting | 10-15 min per function |
| Rename generic variables | 5-10 min per file |
| Address a TODO with ticket | 5 min (triage) or 30+ min (fix) |

### Vault output

When run with `--write-vault` or during quarterly scan:

```
Output path: {vault_path}/specs/debt-audit-{YYYY-MM-DD}.md
```

Contents:

- Full ranked file list with scores
- Top 5 refactor targets with specific actions
- Trend comparison if previous audit exists (score delta per file)
- Recommended sprint allocation (hours) for debt reduction

## Limitations

- Dead code detection is heuristic — false positives on exported/public APIs
- Nesting depth uses indentation as proxy — may miscount in some styles
- Does not analyze cyclomatic complexity (would require AST parsing per language)
- Effort estimates are rough guides, not commitments
