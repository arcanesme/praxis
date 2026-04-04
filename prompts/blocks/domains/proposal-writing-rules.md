---
id: proposal-writing-rules
description: "8 core writing rules, quality controls, cross-reference & traceability, approach hierarchy"
category: domains
platforms: [claude-code, claude-project, perplexity-space]
char_estimate: 2400
tags: [domain, govcon, proposal, writing, quality, traceability]
---

## Proposal Writing Standards (Summary)

Full standards in `proposal-writing-standards.md`. Core rules enforced at all times:

- **BLUF**: Every paragraph leads with its conclusion. Value in the first sentence or evaluators won't score it.
- **FBP**: Every claim has Feature → Benefit → Proof. A claim without all three is an assertion. Evaluators cannot credit assertions.
- **Active Voice**: Always. The actor is always named. Passive voice reads as ambiguity.
- **SHALL → WILL**: Respond to SHALL/MUST with "{{company_name}} will" — never hedging language.
- **70/30 Rule**: 70% government mission / 30% {{company_name}} solution. Never lead with company credentials.
- **Banned phrases**: No "robust," "world-class," "proven track record," "cutting-edge," "seamless," "leverage," "synergy." See knowledge file for full list and replacements.
- **Action captions**: Every figure/table caption conveys value, not just labels.

## Quality Controls (Self-Check Before Every Output)

1. **"So What?"** — Connected to a scored evaluation factor?
2. **"Proof"** — Replace every vague adjective with a metric or PP reference.
3. **"Traceability"** — Every claim traces to a requirement; every risk to a mitigation.
4. **"Differentiation"** — Opportunity to ghost competition here?
5. **"TRL Check"** — Proposed technology at appropriate readiness level?
6. **"BLUF Check"** — Every paragraph leads with value?
7. **"FBP Check"** — Every claim has all three elements?
8. **"Active Voice Check"** — Actor always named?

## Cross-Reference & Traceability Rules

- Risk (VII) → Assumption (VI) or Dependency (VIII)
- Cost Driver (X) → Technical Decision (II) or Process Choice (III)
- Assumption (VI) → Owner + validation plan, or escalated as Risk (VII)
- Architecture Decision (II) → Customer Requirement or Pain Point (I)
- Artifact (IV) → Evaluation Factor (XI)
- Cyber Control (IX) → Compliance Requirement (I or XI) + Architecture Layer (II)

## Approach → Framework → Methodology → Process Hierarchy

Strictly enforce. Never conflate levels.

```
APPROACH (Strategic Philosophy — "What is our direction?")
  ↓ informs
FRAMEWORK (Structural Scaffold — "What structure?")
  ↓ instantiated by
METHODOLOGY (Systematic Method — "How systematically?")
  ↓ implemented as
PROCESS (Repeatable Steps — "What specific steps?")
```

**Red Flags**: "Our methodology is risk-based" → WRONG (risk-based = approach). "Our approach is Scrum" → WRONG (Scrum = methodology). Flag and correct immediately.

<!-- CONDENSED -->
BLUF every paragraph. FBP every claim. Active voice, SHALL→WILL, 70/30 mission/company. Ban "robust/world-class/seamless/leverage/synergy." Hierarchy: Approach→Framework→Methodology→Process (never conflate).
