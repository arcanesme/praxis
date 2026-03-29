---
name: px-deliberate
disable-model-invocation: true
description: "Multi-perspective architectural decision making with structured scoring matrix. Use for decisions with multiple valid approaches and hidden trade-offs."
---

# /deliberate — Structured Decision Analysis

Runs structured deliberation on a technical decision: enumerate options, evaluate against criteria, surface hidden trade-offs, recommend with explicit reasoning.

## When to Use
- Architectural decisions with lasting consequences
- Technology selection (framework, database, hosting)
- When `/duel` results in a close match (≤2 point gap)
- Design trade-offs where "it depends" is the honest answer

## Step 1 — Frame the Decision

Extract from the user's request:
- **Decision**: What specific choice needs to be made
- **Context**: Why this decision is being made now
- **Constraints**: Budget, timeline, team skills, compliance, existing architecture
- **Stakeholders**: Who is affected by this decision

## Step 2 — Enumerate Options

Generate at least 3 options:
1. The user's preferred approach (if stated)
2. The most straightforward alternative
3. "Do nothing" or "defer" (if applicable)
4. Any less-visible options discovered during analysis

Each option gets a one-paragraph summary of the approach.

## Step 3 — Define Evaluation Criteria

Use defaults unless the user specifies custom criteria:

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Complexity | 1x | Implementation and ongoing cognitive load |
| Risk | 2x | What can go wrong, blast radius, reversibility |
| Reversibility | 1x | How hard is it to undo this choice later |
| Time to implement | 1x | Calendar time to production-ready |
| Maintenance burden | 1.5x | Ongoing cost after initial implementation |

Weights are multipliers on the 0–4 raw score.

## Step 4 — Score and Analyze

For each option, score each criterion 0–4:

| | Option A | Option B | Option C |
|---|---------|---------|---------|
| Complexity (1x) | | | |
| Risk (2x) | | | |
| Reversibility (1x) | | | |
| Time (1x) | | | |
| Maintenance (1.5x) | | | |
| **Weighted Total** | | | |

For each option that involves an external dependency:
- Run Context7 `resolve-library-id` to verify it exists and get current docs
- If Perplexity Sonar is available: run CVE check with `sonar-pro` model
- Factor findings into the Risk and Maintenance scores

## Step 5 — Sonar-Enhanced Synthesis (if available)

If the Perplexity MCP server is registered:
- Use `perplexity_reason` with `model: sonar-reasoning` for the synthesis step
- Query: "Compare [Option A] vs [Option B] for [decision context] — trade-offs, risks, industry precedent"
- Incorporate cited findings into the recommendation

If Perplexity is unavailable: proceed with standard reasoning. Note the limitation.

## Step 6 — Recommend

Present:
1. **Recommended option** with the highest weighted score
2. **Key trade-off**: The single most important thing being sacrificed
3. **Dissent**: The strongest argument against the recommendation
4. **Reversal trigger**: Under what conditions should this decision be revisited

## Step 7 — Write ADR to Vault

Read `vault_path` from `~/.claude/praxis.config.json`.
If available, write to `{vault_path}/specs/decision-{YYYY-MM-DD}-{slug}.md`:

```yaml
---
tags: [adr, decision]
date: YYYY-MM-DD
source: agent
status: proposed
---
```

Follow the ADR format:
- **Context**: Why this decision was needed
- **Options Considered**: Summary of each with score
- **Decision**: The recommended option
- **Consequences**: What changes as a result
- **Reversal Trigger**: When to revisit
