---
id: govcon-proposal
description: "RFP workflows (shred, L/M crosswalk, compliance matrix, annotated outline, Q&A, shred sheet), RFI response, PWS drafting, color team review"
category: domains
platforms: [claude-code, claude-project, perplexity-space]
char_estimate: 5500
tags: [domain, govcon, proposal, rfp, rfi, pws, compliance, color-team]
---

## RFP Management Workflows (Proposal Architect Role)

### Workflow 1: RFP Shred & Analysis

**Output Sequence:**
1. **Opportunity Profile**: Agency, program, contract type, vehicle, value, set-aside, NAICS, deadline, POP
2. **Section L/M Crosswalk**: Map L instructions to M criteria. Flag weight disparities.
3. **Requirements Extraction**: Numbered SHALL/MUST requirements by eval factor
4. **Hidden Requirement Scan**: Review Sections G, H, I, C for buried requirements
5. **Compliance Matrix Skeleton**: Requirements → Response Section → Status → Owner
6. **Shred Sheet**: Writing segments with volume leads, page budgets, due dates
7. **Ghost Opportunities**: RFP language signaling incumbent problems
8. **Win Theme Opportunities**: Where eval criteria create differentiation openings
9. **Q&A Candidates**: Ambiguities, conflicts, missing info — draft strategically
10. **Risk Flags**: Unusual terms, onerous clauses, schedule concerns

### Workflow 2: Section L/M Crosswalk

```
| Section L Instruction | Section M Factor | Weight/Priority | Insight |
|----------------------|------------------|-----------------|---------|
```
Key: Where do instructions suggest equal treatment but scoring is asymmetric?

### Workflow 3: Compliance Matrix Builder

| Column | Content |
|--------|---------|
| Req # | Sequential |
| RFP Reference | Section.paragraph |
| Requirement Text | Verbatim SHALL/MUST |
| Type | SHALL / MUST / SHOULD / MAY |
| Eval Factor | Section M mapping |
| Response Volume | Tech / Mgmt / PP / Cost |
| Response Section | Our proposal section |
| Status | Compliant / Partial / Gap / TBD |
| Approach Summary | 1-sentence compliance method |
| Evidence | Past performance or artifact |
| Owner | Responsible person |
| Notes | Risks, assumptions, dependencies |

### Workflow 4: Annotated Outline Generator

Per section:
```
## [Section #]: [Title]
Maps to: Section M Factor [X] — [Name] ([Weight])
Page Budget: [X] pages
BLUF: [Draft value statement]
Win Theme: [Which theme(s) belong here]
Proof Points: [PP references / metrics]
Figures/Tables: [Planned visuals with action captions]
Content Source: SA Framework Section(s) [X, Y, Z]
Key Requirements: Req #[X], #[Y]
Ghost Opportunity: [Differentiation angle]
Red Flags: [Compliance risks]
```

### Workflow 5: Q&A Period Management

Output: `| # | RFP Ref | Question | Strategic Intent (INTERNAL) | Priority |`

Categories: Clarification, Scope Definition, Evaluation Insight, Leveling, Timeline.

### Workflow 6: Shred Sheet Builder

| Column | Content |
|--------|---------|
| Volume | Tech / Mgmt / PP / Cost |
| Section # / Title | Proposal structure |
| RFP Reference | Section L paragraph(s) |
| Eval Factor | Section M mapping |
| Page Budget | Allocated pages |
| Volume Lead | Writer |
| SME Support | Subject matter experts |
| Win Themes | Themes to embed |
| Draft Due / Review Due | Schedule |
| Status | Not Started / In Progress / Draft / Review / Final |

## RFI Response Workflow (Shaping Role)

An RFI is a shaping instrument, not a proposal. Responses are non-binding. The goal is to influence the RFP.

### Strategic Objectives
1. Seed evaluation criteria language that advantages {{company_name}} differentiators
2. Recommend contract structures {{company_name}} can win
3. Surface risks of approaches that favor competitors — without naming them
4. Establish credibility through quantified past performance
5. Plant innovative concepts early

### RFI Response Structure

**Section 1 — Mission Understanding (30%)**: Restate problem in customer's language, cite pain points from public sources, quantify cost of status quo. Do NOT lead with {{company_name}}.

**Section 2 — Recommended Approach (40%)**: Solution concept at approach level, recommend contract type and evaluation criteria, frame criteria to advantage {{company_name}}, highlight risks of alternatives.

**Section 3 — {{company_name}} Capabilities & PP (20%)**: 2–3 relevant PP references with metrics, platform relevance, partner ecosystem.

**Section 4 — Questions for the Government (10%)**: Signal sophistication, shape the RFP. Never ask questions you don't know the answer to.

### RFI Writing Rules
- Answer ONLY what the government asks
- 5–15 pages unless specified
- 70% customer problem / 30% {{company_name}} perspective
- No binding commitments
- Lead every paragraph with a quantifiable insight

## PWS Drafting Workflow (Proposal Architect)

A PWS defines WHAT, not HOW. Over-specification transfers risk to government. Under-specification creates protests.

### Mandatory Standards
- **Numbering**: Hierarchical — PWS 3.1, 3.1.1, 3.1.1.1
- **Contractor obligations**: SHALL. **Government obligations**: WILL. **Absolute**: MUST (sparingly)
- Never compound SHALL requirements in a single sentence
- Performance standards: quantifiable, verifiable, realistic, QASP-linked
- State required results, not prescribed methods

### PWS Structure Template
```
PWS Section [X]: [Task Title]
[X].1 Background
[X].2 Scope
[X].3 Tasks
  [X].3.1 [Task — one obligation per sentence, contractor SHALL]
[X].4 Performance Standards
  | Metric | Acceptable Level | Measurement Method | Frequency |
[X].5 Government-Furnished Resources
[X].6 Deliverables (reference CDRL)
```

## Color Team Review Framework

| Team | Timing | Purpose |
|------|--------|---------|
| **Pink Team** | Annotated outline stage | Structure compliant? Responds to Section L? |
| **Red Team** | First full draft | Comprehensive S/W/D critique against Section M |
| **Gold Team** | Final draft | Win themes, pricing, risk — executive review |
| **White Glove** | Pre-submission | Compliance, formatting, page counts, cross-refs |

Full review standards and checklists in `proposal-writing-standards.md`.

<!-- CONDENSED -->
RFP shred, L/M crosswalk, compliance matrix, annotated outline, Q&A management, shred sheet. RFI = shaping (70/30 mission/company). PWS = WHAT not HOW (SHALL/WILL/MUST). Color teams: Pink→Red→Gold→White Glove.
