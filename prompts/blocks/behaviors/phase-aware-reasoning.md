---
id: phase-aware-reasoning
description: "Phase detection logic, phase-aware maturity scoring, scoring calibration, and phase-deferred concept"
category: behaviors
platforms: [claude-code, claude-project, perplexity-space]
char_estimate: 2200
tags: [behavior, phase, scoring, maturity, capture, govcon]
---

## Phase Detection Logic

**MANDATORY**: Determine capture phase before scoring. GREEN means "on track for THIS phase" — not "ready for proposal submission."

| Signal | Phase |
|--------|-------|
| No RFP released; intelligence gathering | **Shaping** |
| Active RFI / Sources Sought / Industry Day | **Shaping** |
| RFP released; building solution | **Mid Capture** |
| Writing proposal volumes | **Pre-Proposal** |
| Final review before submission | **Pre-Submission** |
| Preparing oral presentations | **Orals** |

For detailed per-section, per-phase GREEN/YELLOW/RED criteria, read `phase-maturity-matrix.md`.

## Scoring Calibration by Phase

| Phase | Standard | Pass Criteria |
|-------|----------|---------------|
| Shaping | Intelligence & positioning readiness | I + XI GREEN |
| Early Capture | Concepts & direction | I, II, III, IX, XI GREEN |
| Mid Capture | Design & planning maturity | All 11 GREEN at mid-capture level |
| Pre-Proposal | Full proposal-ready criteria | All 11 GREEN at proposal level |
| Pre-Submission | Proposal-ready + Red Team resolved | All GREEN or Conditional, zero deficiencies |
| Orals | Presentation-specific criteria | I, II, V, XI polished; Q&A matrix complete |

## Phase-Deferred Concept

Use `Phase-Deferred` when a proof artifact is not expected at the current phase. A Phase-Deferred item is not a gap — it is a planned future deliverable tracked against the gate timeline.

<!-- CONDENSED -->
Detect capture phase (Shaping→Mid Capture→Pre-Proposal→Pre-Submission→Orals) before scoring. GREEN = on track for THIS phase. Phase-Deferred = not yet expected, not a gap.
