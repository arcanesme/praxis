---
id: scorecard-output
description: "Scorecard template, gate review output template, and verdict thresholds for maturity assessments"
category: formats
platforms: [claude-code, claude-project, perplexity-space]
char_estimate: 1600
tags: [format, govcon, scorecard, gate-review, template]
---

## Scorecard Template (Always Use in Scoring Mode)

```
| # | Section | Phase Score | Proposal-Ready Gap | Top Action |
|---|---------|-------------|-------------------|------------|
| I | Customer & Mission | [R/Y/G] | [gap] | [action] |
| II | Architecture | [R/Y/G] | [gap] | [action] |
| III | Processes & Approach | [R/Y/G] | [gap] | [action] |
| IV | Artifacts & Deliverables | [R/Y/G] | [gap] | [action] |
| V | Program Planning & Transition | [R/Y/G] | [gap] | [action] |
| VI | Assumptions | [R/Y/G] | [gap] | [action] |
| VII | Risks | [R/Y/G] | [gap] | [action] |
| VIII | Dependencies | [R/Y/G] | [gap] | [action] |
| IX | Cybersecurity | [R/Y/G] | [gap] | [action] |
| X | Cost Drivers | [R/Y/G] | [gap] | [action] |
| XI | Cross-Cutting & Competitive | [R/Y/G] | [gap] | [action] |

PAMASI STAGE: [Stage] — Evidence: [brief rationale]
PHASE VERDICT: [On Track / Needs Work / Off Track] for [Phase Name]
PROPOSAL-READY ESTIMATE: [X of 11] sections GREEN at Pre-Proposal today
NEXT GATE: [Gate Name] — [Target Date] — [What must be GREEN]
```

**Verdict Thresholds**: On Track = 8+ GREEN, 0 RED. Needs Work = 5–7 GREEN or RED with remediation path. Off Track = <5 GREEN or RED with no resolution.

## Gate Review Output

```
GATE VERDICT: [Pass / Conditional Pass / No Pass / Stop & Reset]

Conditional Pass Definition: All critical sections GREEN; 1–2 sections YELLOW with
documented owner and resolution date ≤ 2 weeks. No RED sections permitted.

ACTION REGISTER:
| Finding | Section | Owner | Due Date | Success Criteria | Evidence |
|---------|---------|-------|----------|-----------------|----------|

NEXT GATE CRITERIA: What must be GREEN, by when, with what evidence
```

<!-- CONDENSED -->
11-section scorecard (R/Y/G) + PAMASI stage + phase verdict (On Track/Needs Work/Off Track). Gate verdicts: Pass/Conditional/No Pass/Stop & Reset.
