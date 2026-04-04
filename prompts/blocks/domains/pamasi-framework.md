---
id: pamasi-framework
description: "PAMASI maturity model (6 stages), 11-section assessment framework, gate expectations by phase"
category: domains
platforms: [claude-code, claude-project, perplexity-space]
char_estimate: 3200
tags: [domain, govcon, pamasi, maturity, framework, assessment, gate-review]
---

## The 11-Section Framework

Every solution is assessed across these 11 sections. Full question bank is in `maturity-questions.md`.

| # | Section | Core Question | Eval Factor |
|---|---------|---------------|-------------|
| I | Customer, Mission & Value | Who is the customer, what outcomes matter? | Understanding |
| II | Overall Architecture | Does the architecture fit mission and scale? | Technical Design |
| III | Processes & Approach | Are Approach→Framework→Methodology→Process coherent? | Methodology |
| IV | Artifacts & Deliverables | Do we have proof? Diagrams, RTMs, BOEs? | Evidence |
| V | Program Planning & Transition | Day 1 ready? 30/60/90 credible? | Transition |
| VI | Assumptions | Documented, validated, or flagged? | Risk Awareness |
| VII | Risks | Quantified with mitigations? | Risk Management |
| VIII | Dependencies | Internal, customer, external tracked? | Planning |
| IX | Cybersecurity | ZTA, ATO path, supply chain security? | Security |
| X | Cost Drivers | Identified, justified, competitive? | Cost/Price |
| XI | Cross-Cutting & Competitive | What makes us win? What ghosts competition? | Discriminators |

## PAMASI Maturity Model

Every solution is placed on the PAMASI scale. This is the primary maturity indicator in gate reviews and TRRs.

| Stage | Definition | Evidence Required |
|-------|-----------|------------------|
| **P — Problem** | Customer pain points, mission context, and success criteria documented and validated from authoritative sources | Validated pain points (GAO/IG/direct engagement), stakeholder map, mission KPIs identified |
| **A — Approach** | Strategic philosophy and guiding principles defined; differentiated from competitors at a philosophical level | Approach statement, differentiation rationale, customer alignment confirmed |
| **M — Methodology** | Systematic delivery method selected, tailored, and traceable to customer requirements | Methodology documented, tailoring rationale stated, team certified or trained |
| **A — Assets** | Reusable platforms, tools, accelerators, past performance, and partner capabilities identified and mapped | Asset inventory, PP relevance table, partner RACI, platform deployment evidence |
| **S — Solution** | Complete integrated solution designed across all architecture layers with trade-offs documented | OV-1 complete, all architecture views present, RTM started, TRLs confirmed |
| **I — Implementation** | Transition plan, staffing model, governance, and operational readiness fully defined | 30/60/90 plan, staffing model, governance charter, Day-1 processes documented |

### Gate Expectation by Phase
- Shaping → P stage minimum; A stage targeted
- Mid Capture → A–M stage
- Pre-Proposal → S stage minimum
- Pre-Submission → I stage

## Knowledge Files

Upload these alongside this system prompt in Claude Projects:

| File | Purpose | When Referenced |
|------|---------|----------------|
| `maturity-questions.md` | 1,000+ assessment questions across all 11 sections | Scoring, TRR, gate reviews |
| `phase-maturity-matrix.md` | Per-section, per-phase GREEN/YELLOW/RED criteria | Phase-aware scoring, gate verdicts |
| `proposal-writing-standards.md` | BLUF, FBP, grammar, banned phrases, document-type rules, SA checklist | All written outputs |

<!-- CONDENSED -->
11-section assessment (Customer/Architecture/Process/Artifacts/Planning/Assumptions/Risks/Dependencies/Cyber/Cost/Competitive). PAMASI maturity: P→A→M→A→S→I. Gates: Shaping=P, Mid Capture=A-M, Pre-Proposal=S, Pre-Submission=I.
