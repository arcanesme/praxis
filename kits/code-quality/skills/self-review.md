# Self-Review — AI Quality Review Protocol

This skill is invoked by the post-commit hook to review changed code.
It produces structured JSON output consumed by the gate and logged to .last-ai-review.json.

## Invocation
You will be given a list of changed files and their diffs.
Review them against the checks in configs/checks-registry.json.
Focus on: over-engineering (checks 40-49), code smells (50-61), structural quality (62-70),
performance patterns (78-83), and documentation (84-87).
Security checks (1-17) are handled by the deterministic gate — do not duplicate them here
unless you identify a logic-level vulnerability that pattern matching cannot catch (check 10, 11, 12).

## Output Schema — REQUIRED FORMAT
Output ONLY valid JSON. No prose. No markdown. No explanation outside the JSON.

```json
{
  "reviewed_at": "ISO8601 timestamp",
  "files_reviewed": ["list of files"],
  "findings": [
    {
      "file": "relative/path/to/file.ts",
      "line": 42,
      "check_id": 40,
      "category": "over-engineering",
      "severity": "HIGH",
      "title": "One-line description of the finding",
      "description": "2-3 sentences explaining why this is a problem in this specific context.",
      "evidence": "The specific code pattern that triggered this finding.",
      "suggested_fix": "Concrete action: what to change, how, and why it improves the code."
    }
  ],
  "metrics": {
    "functions_over_30_lines": 0,
    "nesting_depth_violations": 0,
    "missing_docstrings": 0,
    "test_coverage_gaps": 0
  },
  "gate_recommendation": "pass",
  "summary": "One sentence summary. X findings (Y critical, Z high, W medium)."
}
```

## Gate Recommendation Rules
- "block" → any CRITICAL finding present
- "warn"  → HIGH findings present, no CRITICAL
- "pass"  → only MEDIUM/LOW findings, or no findings

## Quality Bar
Do not flag style preferences as findings.
Do not flag things that are correct but that you would do differently.
Only flag things where the code is objectively harder to understand, maintain, or extend
than a simpler alternative would be.
A finding without a specific suggested_fix is not complete — do not emit it.
