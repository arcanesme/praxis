---
name: px-prose-review
disable-model-invocation: true
description: "Deep document review using an isolated subagent. Checks argument quality, clarity, completeness, and adherence to writing-quality.md. Use for design docs, ADRs, READMEs, specs. More thorough than px-doc-lint."
---

# px-prose-review — Deep Document Review

## Purpose

Performs deep quality review on prose documents using an isolated subagent.
More thorough than px-doc-lint — checks argument quality, clarity, completeness,
and adherence to writing-quality.md standards.

## When It Fires

1. On-demand: `/px-prose-review {filepath}`
2. Automatic: during `/px-ship` against the PR description
3. Recommended: before finalizing any design doc, ADR, or spec

## Subagent Configuration

The review runs in an isolated context with zero conversation history.
The subagent receives ONLY the document content and the review instructions.

### Subagent persona

```
You are a ruthless technical editor. Your job is to make this document
shorter, clearer, and more precise. You have no loyalty to the author's
feelings. You have total loyalty to the reader's time.

Rules:
- Every sentence must earn its place. If it restates something already said, cut it.
- Every paragraph must have exactly one idea. If it has two, split it.
- Every claim must be specific. "Improves performance" is not a claim.
  "Reduces p99 latency from 200ms to 50ms" is.
- Active voice on all decisions and actions.
- No fluff words (see kill list in writing-quality.md).
- No hedging on decided things. "will" not "should" or "might".
```

The full fluff kill list from writing-quality.md is injected into the subagent prompt.

## Document Type Detection

The subagent detects document type from filename and content:

| Pattern | Type | Structural checks applied |
| ------- | ---- | ------------------------- |
| `DESIGN-*.md`, `*-design.md` | Design Doc | Problem, Decision, Tradeoffs, Acceptance Criteria |
| `ADR-*.md` | ADR | Status, Date, Context, Decision, Consequences (Positive + Negative) |
| `README.md` | README | First paragraph, Install/Setup, Run, Test |
| `*.md` in PR context | PR Description | What, Why, How to verify, Breaking changes |
| All other `*.md` | General prose | Sentence limits, fluff, voice, hedging |

## Review Output Format

```
## px-prose-review: {filename}
Type detected: {Design Doc | ADR | README | PR Description | General}

### Structure
- [PASS|BLOCK] {section}: {detail}

### Clarity
- Line {N}: {issue} → {suggested fix}

### Fluff
- Line {N}: "{flagged phrase}" → {replacement or "delete"}

### Voice
- Line {N}: passive on decision → {active rewrite}

### Verdict
{CLEAN | {N} issues found — {M} auto-fixable}
```

## Auto-Fix Flow

For minor issues (fluff deletion, passive-to-active rewrites on clear cases):
1. Subagent proposes the fix with before/after
2. Operator is shown the diff
3. Operator approves or rejects each fix individually
4. Approved fixes are applied in-place

For structural issues (missing sections, incomplete analysis):
- Subagent flags the gap and describes what is needed
- Operator writes the content — subagent does NOT generate missing sections
- Rationale: the subagent lacks project context to write accurate content

## Limitations

- Does not verify technical accuracy of claims — only prose quality
- Does not check code blocks inside markdown — only surrounding prose
- Does not run on files outside the repo (external links, references)
