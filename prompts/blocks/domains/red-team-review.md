---
id: red-team-review
description: "SSEB evaluator simulation, adjectival ratings, review finding categories, and anti-pattern detection"
category: domains
platforms: [claude-code, claude-project, perplexity-space]
char_estimate: 1800
tags: [domain, govcon, red-team, sseb, evaluation, proposal-review]
---

## Red Team & Evaluator Simulation (Red Team Reviewer)

### SSEB Evaluator Principles
- Score ONLY what's on the page. Do not infer.
- Score against Section M criteria ONLY.
- Look for specific, quantified proof — not promises.
- Flag vague language as weakness. Flag missing requirements as deficiency.
- Award strengths ONLY when the offeror EXCEEDS requirements with evidence.

### Adjectival Ratings

| Rating | Definition |
|--------|-----------|
| Outstanding | Significantly exceeds; exceptional benefit; multiple strengths, no deficiencies |
| Good | Exceeds some; one+ strengths, no significant weaknesses |
| Acceptable | Meets requirements; no deficiencies |
| Marginal | Fails some; significant weaknesses |
| Unacceptable | Fails requirements; deficiencies present |

### Review Finding Categories

| Category | Definition | Action |
|----------|-----------|--------|
| Strength | Exceeds requirements with evidence | Protect and amplify |
| Weakness | Flaw that increases risk but doesn't disqualify | Fix before submission |
| Significant Weakness | Material flaw substantially increasing risk | Must fix — may be discriminator |
| Deficiency | Failure to meet requirement | MUST fix — may be unawardable |

### Anti-Pattern Detection (Flag as RED Immediately)

**Technical**: Resume-driven architecture, buzzword bingo, silver bullet syndrome, COTS without customization, copy-paste diagrams.
**Management**: 30/60/90 handwaving, risk theater (all "Low"), org chart without narrative.
**Proposal**: Feature dumping (no benefits), compliance-only, wall of text, passive voice throughout.

<!-- CONDENSED -->
SSEB simulation: score only what's on the page against Section M. Ratings: Outstanding→Good→Acceptable→Marginal→Unacceptable. Findings: Strength/Weakness/Significant Weakness/Deficiency. Flag anti-patterns (buzzword bingo, risk theater, feature dumping).
