---
name: px-doc-lint
disable-model-invocation: true
description: "Fast structural markdown check. No subagent — pure pattern matching. Completes in under 5 seconds. Fires inside px-quality-gate for staged *.md files, or on-demand via /px-doc-lint."
---

# px-doc-lint — Fast Structural Markdown Check

## Purpose

Lightweight structural validation for markdown files. No subagent.
Pure pattern matching. Completes in under 5 seconds.
Use as a quick pre-save check or let px-quality-gate invoke it automatically.

## When It Fires

1. Automatically inside px-quality-gate for every staged `*.md` file
2. On-demand: `/px-doc-lint {filepath}`
3. On-demand batch: `/px-doc-lint {directory}` (all .md files in directory)

## Checks by Document Type

### All markdown files

```bash
# 1. Frontmatter check — if present, must be valid
head -1 "$f" | grep -q '^---$' && {
  awk '/^---$/{c++} c==2{found=1; exit} END{if(!found) print "BLOCK: unclosed frontmatter"}' "$f"
}

# 2. No trailing whitespace
grep -nE ' +$' "$f" && echo "WARN: trailing whitespace"

# 3. No consecutive blank lines (more than 2)
awk '/^$/{blank++; if(blank>2) print "WARN: line "NR": excessive blank lines"} /^.+$/{blank=0}' "$f"

# 4. Headers must increment by one level (no h1 -> h3 skip)
grep -E '^#{1,6} ' "$f" | awk '{
  level = length($0) - length(gensub(/^#+/, "", 1, $0)) - 1
  if (prev > 0 && level > prev + 1)
    print "WARN: header level skip at: "$0
  prev = level
}'

# 5. No empty headers
grep -nE '^#{1,6}\s*$' "$f" && echo "BLOCK: empty header"

# 6. Fluff kill list (same as px-quality-gate prose check)
grep -inE "$FLUFF_PATTERN" "$f" && echo "BLOCK: fluff phrases detected"
```

### Design docs (DESIGN-*.md, *-design.md)

```bash
for section in "## Problem" "## Decision" "## Tradeoffs" "## Acceptance Criteria"; do
  grep -q "$section" "$f" || echo "BLOCK: missing required section: $section"
done

tradeoff_count=$(awk '/## Tradeoffs/,/## /' "$f" | grep -c '^- ' || true)
if [[ "$tradeoff_count" -lt 2 ]]; then
  echo "BLOCK: Tradeoffs section needs at least 2 items (found: $tradeoff_count)"
fi
```

### ADRs (ADR-*.md)

```bash
for field in "Status:" "Date:" "## Context" "## Decision" "## Consequences"; do
  grep -q "$field" "$f" || echo "BLOCK: missing required field: $field"
done

status=$(grep -oE 'Status: .*' "$f" | head -1)
echo "$status" | grep -qE '(Proposed|Accepted|Deprecated|Superseded)' || \
  echo "BLOCK: invalid ADR status. Must be: Proposed | Accepted | Deprecated | Superseded by ADR-NNN"

grep -q '### Positive' "$f" || echo "BLOCK: missing Consequences > Positive"
grep -q '### Negative' "$f" || echo "BLOCK: missing Consequences > Negative"
```

### READMEs (README.md)

```bash
for section in "## Install\|## Setup" "## Run" "## Test"; do
  grep -qE "$section" "$f" || echo "BLOCK: missing required section matching: $section"
done

awk '/^```/,/^```/' "$f" | grep -E '\{placeholder\}|\{TODO\}|\{TBD\}' && \
  echo "BLOCK: placeholder found inside code block"
```

## Output Format

```
px-doc-lint: {filename}
Type: {Design Doc | ADR | README | General}
  [PASS] frontmatter valid
  [PASS] no trailing whitespace
  [BLOCK] missing required section: ## Tradeoffs
  [WARN] header level skip at: ### Details
Result: BLOCK (1 error, 1 warning)
```

## Performance Contract

- Single file: under 2 seconds
- Batch (10 files): under 5 seconds
- No network calls. No subagent. Pure grep/awk/sed.
