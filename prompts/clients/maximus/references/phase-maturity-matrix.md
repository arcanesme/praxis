# Phase Maturity Matrix — Knowledge Reference
## Maximus Federal Deal Solution Architect v9.1

---

## Gate Definitions

| Gate | Meaning | Action |
|------|---------|--------|
| **Pass** | All section ratings GREEN for the current phase. Proceed to next phase. | Advance capture phase. |
| **Conditional Pass** | No RED ratings; 1-3 YELLOW ratings with documented remediation plans and owners. | Advance with tracking. Review remediation at next gate. |
| **No Pass** | Any RED rating, or 4+ YELLOW ratings. | Halt phase advancement. Remediate all RED to YELLOW minimum; reduce YELLOW count below 4. Re-gate within 2 weeks. |
| **Stop & Reset** | 3+ RED ratings across different sections, or any single RED persisting across 2 consecutive gates. | Escalate to capture lead. Reassess bid/no-bid. Reset capture plan if continuing. |

---

## Section I: Customer, Mission & Value

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Agency identified; 2+ pain points validated from public sources; strategic priorities named | Agency identified but pain points unvalidated; no public source intelligence | Customer unknown or mission unclear |
| **Early Capture** | All Shaping + pain points confirmed through engagement; stakeholder map drafted; mission KPIs identified | Shaping met but no direct engagement; stakeholder map incomplete | Pain points still unvalidated; no stakeholder visibility |
| **Mid Capture** | Complete pain point inventory with sources; customer outcome KPIs defined; acquisition strategy confirmed | Most pain points documented; 1-2 KPIs undefined | Pain points incomplete; no acquisition clarity |
| **Pre-Proposal** | Full mission narrative proposal-ready; KPIs in eval factor language; all 5 evaluator personas addressed | Narrative drafted but not proposal-ready; 1-2 personas unaddressed | No proposal-ready narrative; eval factor alignment missing |
| **Pre-Submission** | Narrative stress-tested in Red Team; all personas addressed; zero vague claims | Minor refinements needed post-Red Team | Narrative failed Red Team |
| **Orals** | 60-second BLUF polished; Q&A prep complete for all anticipated questions | BLUF drafted but not rehearsed | No BLUF; Q&A not prepped |

---

## Section II: Overall Architecture

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Solution hypothesis documented; approach defined; platform fit assessed | Hypothesis vague; no platform mapping | No hypothesis; no concept |
| **Early Capture** | OV-1 concept drafted; key components identified; TRL assessed | OV-1 sketched but incomplete; TRL unassessed | No architecture concept |
| **Mid Capture** | OV-1 complete; logical architecture drafted; integration points named; trade-offs documented; TRLs 6+ | OV-1 complete but logical view missing; 1 TRL below 6 | OV-1 missing; no integration mapping |
| **Pre-Proposal** | All views complete; trade-off analysis for all decisions; TRL 7+; architecture traceable to RFP | All present but 1-2 views incomplete | Any view missing; TRL below 6 without mitigation plan |
| **Pre-Submission** | Submission-quality diagrams; Red Team findings resolved | Minor polish needed on diagrams | Red Team findings unresolved |
| **Orals** | Can explain at 3 levels (executive, technical, operational) | 2 of 3 levels prepared | Cannot explain without notes |

---

## Section III: Processes & Approach

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Approach hypothesis documented; methodology candidates identified; team capability mapped to approach | Approach concept exists but methodology not yet selected | No approach concept; no methodology candidates |
| **Early Capture** | Named methodology selected with tailoring rationale; key processes identified; team certifications confirmed | Methodology selected but tailoring rationale weak; 1-2 certifications pending | No methodology selected; team capability gaps unaddressed |
| **Mid Capture** | Full process hierarchy (Approach→Framework→Methodology→Process) documented; ceremonies defined; quality gates identified; process KPIs mapped to mission outcomes | Process hierarchy mostly complete; 1-2 ceremonies undefined | Process hierarchy incomplete; no connection between processes and outcomes |
| **Pre-Proposal** | All processes proposal-ready with FBP narratives; process diagrams complete; staffing aligned to process roles; all eval factors traceable to process descriptions | Processes documented but FBP narratives weak; 1-2 diagrams missing | Processes not proposal-ready; eval factor traceability missing |
| **Pre-Submission** | Red Team validated all process claims; no unsupported assertions; past performance evidence linked to each process | Minor process narrative refinements needed | Process claims unsupported; Red Team flagged gaps |
| **Orals** | Can walk through any process end-to-end with real examples; prepared for "show me" questions | Most processes rehearsed; 1-2 weak on examples | Cannot demonstrate processes without reading |

---

## Section IV: Artifacts & Deliverables

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Expected deliverable types identified from acquisition research; sample artifacts inventoried from prior work | Deliverable types assumed but not validated against acquisition strategy | No deliverable inventory; no samples identified |
| **Early Capture** | CDRLs/deliverables mapped from draft requirements; sample artifacts updated for relevance; quality standards defined | CDRL mapping started but incomplete; samples exist but need updating | No CDRL mapping; no relevant samples |
| **Mid Capture** | Full CDRL matrix with format, frequency, and acceptance criteria; template library ready; DID compliance verified | CDRL matrix mostly complete; 1-2 templates missing | CDRL matrix incomplete; no templates; DID compliance unknown |
| **Pre-Proposal** | All deliverable descriptions proposal-ready; sample pages/excerpts prepared; delivery schedule aligned to WBS | Descriptions drafted but not proposal-ready; schedule partially aligned | Deliverable descriptions missing; no schedule alignment |
| **Pre-Submission** | Deliverable descriptions stress-tested in Red Team; compliance matrix complete; all DID references verified | Minor refinements needed | Red Team flagged deliverable gaps; compliance matrix incomplete |
| **Orals** | Can present sample deliverables and explain quality process | Samples prepared but presentation not rehearsed | No samples; cannot discuss quality process |

---

## Section V: Program Planning & Transition

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Transition complexity assessed; hot-start concept identified; incumbent analysis complete | Transition acknowledged but not assessed; incumbent unknown | No transition planning; incumbent not researched |
| **Early Capture** | 30/60/90-day concept drafted; staffing ramp plan outlined; governance model identified; key risks flagged | 30/60/90 concept exists but staffing plan incomplete; governance model vague | No transition concept; no staffing plan |
| **Mid Capture** | Full transition plan with milestones; staffing model with names/roles; governance charter drafted; Day-1 readiness checklist started; incumbent transition risks mitigated | Transition plan mostly complete; 1-2 staffing gaps; governance charter in draft | Transition plan incomplete; staffing model missing; no governance concept |
| **Pre-Proposal** | Transition plan proposal-ready; all milestones with acceptance criteria; staffing model with resumes; governance charter complete; Day-1 processes defined | Plan drafted but not proposal-ready; 1-2 resumes pending | Transition plan not proposal-ready; staffing gaps >20% |
| **Pre-Submission** | Red Team validated transition plan; all claims evidence-backed; phase-in schedule realistic per evaluator feedback | Minor refinements needed | Red Team flagged unrealistic timeline or staffing gaps |
| **Orals** | Can walk through Day 1 morning; prepared for "what if incumbent doesn't cooperate" questions | Day 1 walkthrough prepared but not rehearsed | Cannot articulate Day 1 plan |

---

## Section VI: Assumptions

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Key assumptions documented; sources identified for validation; high-impact assumptions flagged | Assumptions listed but not categorized by impact | No assumptions documented |
| **Early Capture** | Assumptions categorized (requirements, technical, operational, resource, schedule); validation plan for each; customer engagement planned to confirm top assumptions | Assumptions categorized but validation plan incomplete; no customer validation planned | Assumptions uncategorized; no validation plan |
| **Mid Capture** | 80%+ assumptions validated or converted to requirements/risks; remaining assumptions have clear owners and deadlines; customer-confirmed assumptions documented with source | 60-80% validated; some assumptions without owners | <60% validated; no tracking of validation status |
| **Pre-Proposal** | All proposal-impacting assumptions validated or explicitly stated with mitigation; assumption register proposal-ready | Most validated; 1-2 high-impact assumptions still open | High-impact assumptions unvalidated; no assumption register |
| **Pre-Submission** | Zero unvalidated high-impact assumptions; all stated assumptions defensible in protest scenario | 1 medium-impact assumption still open with mitigation | Unvalidated assumptions that affect pricing or approach |
| **Orals** | Can defend every stated assumption with evidence | Most assumptions defensible; 1-2 require additional context | Cannot defend key assumptions |

---

## Section VII: Risks

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Top 5 risks identified from opportunity research; risk categories established; initial probability/impact assessed | Risks acknowledged but not formally identified; no categorization | No risk identification |
| **Early Capture** | Risk register started with 10+ entries; risk owners assigned; mitigation strategies drafted for top risks; risk burn-down approach defined | Risk register started but <10 entries; owners not assigned for all | No risk register; risks discussed informally only |
| **Mid Capture** | Full risk register with probability, impact, mitigation, owner, and trigger; risk interdependencies mapped; cost/schedule reserves linked to risks; monthly risk review cadence established | Risk register mostly complete; 1-2 risks without full mitigation plans; reserves not yet linked | Risk register incomplete; no mitigation plans; no reserves |
| **Pre-Proposal** | Risk register proposal-ready; all mitigations have evidence from past performance; risk narrative demonstrates proactive management; residual risks acceptable | Register complete but evidence weak for 1-2 mitigations; narrative needs strengthening | Risk register not proposal-ready; mitigations lack evidence |
| **Pre-Submission** | Red Team validated risk approach; no unaddressed risk concerns; risk language calibrated (neither overconfident nor alarmist) | Minor calibration needed on risk language | Red Team flagged unaddressed risks or unrealistic mitigations |
| **Orals** | Can discuss risk trade-offs fluently; prepared for "what keeps you up at night" questions | Most risks rehearsed; 1-2 areas need deeper preparation | Cannot discuss risks without reading register |

---

## Section VIII: Dependencies

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Key dependencies identified (internal, customer, external); dependency categories established | Dependencies acknowledged but not catalogued | No dependency identification |
| **Early Capture** | Dependency register started; internal/customer/external/technical/schedule dependencies categorized; owners assigned; critical path dependencies flagged | Register started but categorization incomplete; owners not fully assigned | No dependency register; dependencies tracked ad hoc |
| **Mid Capture** | Full dependency register with type, owner, status, and impact if unmet; customer dependencies communicated to customer; vendor dependencies under contract or LOI; schedule dependencies reflected in IMS | Register mostly complete; 1-2 customer dependencies not yet communicated; vendor dependencies in negotiation | Register incomplete; customer dependencies not communicated; vendor dependencies unaddressed |
| **Pre-Proposal** | All dependencies proposal-ready; management approach for each dependency documented; contingency plans for critical dependencies; dependency language reviewed for protest risk | Dependencies documented but management approach weak for 1-2; contingency gaps | Dependencies not proposal-ready; no contingency plans |
| **Pre-Submission** | Red Team validated dependency approach; no unrealistic dependency assumptions; all vendor commitments in writing | Minor refinements needed | Red Team flagged unrealistic dependencies; vendor commitments missing |
| **Orals** | Can explain dependency management approach and contingencies for any dependency | Most prepared; 1-2 dependencies need deeper contingency articulation | Cannot explain dependency management coherently |

---

## Section IX: Cybersecurity

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Security requirements identified from public sources; compliance framework (FedRAMP, FISMA, NIST) assessed; ZTA relevance evaluated | Security requirements assumed but not validated | No security assessment |
| **Early Capture** | Security architecture concept drafted; ATO strategy identified; supply chain risk approach defined; ICAM concept outlined | Security concept exists but ATO strategy vague; supply chain not addressed | No security architecture concept |
| **Mid Capture** | Security architecture aligned to NIST 800-53/171; ZTA roadmap drafted; supply chain risk management plan complete; continuous monitoring approach defined; data classification scheme established | Architecture mostly aligned; ZTA roadmap in draft; 1-2 areas incomplete | Architecture not aligned to NIST; no ZTA consideration; no supply chain plan |
| **Pre-Proposal** | Full cybersecurity narrative proposal-ready; all controls mapped to requirements; ATO timeline realistic; incident response plan outlined; security staffing identified | Narrative drafted but not proposal-ready; 1-2 control mappings incomplete | Cybersecurity narrative missing; ATO timeline unrealistic |
| **Pre-Submission** | Red Team validated security approach; no compliance gaps; security language precise and defensible | Minor refinements needed | Red Team flagged compliance gaps or unrealistic ATO claims |
| **Orals** | Can discuss security architecture at any depth; prepared for ZTA, supply chain, and incident response questions | Most areas prepared; 1-2 need deeper rehearsal | Cannot discuss security without reference materials |

---

## Section X: Cost Drivers

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Major cost categories identified; ROM developed; IGCE range estimated from market research | Cost categories listed but no ROM | No cost analysis |
| **Early Capture** | Cost model structure defined; labor categories mapped; direct/indirect cost drivers identified; basis of estimate started; make/buy decisions documented | Cost model started but labor categories incomplete; BOE not started | No cost model; no labor category mapping |
| **Mid Capture** | Full cost model with labor, materials, subs, ODCs; BOE complete for all cost elements; cost-to-technical traceability established; price-to-win analysis underway; cost risks quantified | Cost model mostly complete; BOE gaps for 1-2 elements; price-to-win not started | Cost model incomplete; no BOE; no price-to-win analysis |
| **Pre-Proposal** | Cost volume proposal-ready; all rates verified; subcontractor pricing confirmed; cost narrative explains value proposition; cost realism defensible | Cost volume drafted but 1-2 pricing elements unconfirmed; narrative needs strengthening | Cost volume not proposal-ready; pricing unverified |
| **Pre-Submission** | Red Team validated cost approach; price competitive per PTW; no cost realism concerns; all representations accurate | Minor adjustments needed post-Red Team | Red Team flagged cost realism issues or uncompetitive pricing |
| **Orals** | Can defend pricing and explain cost-value relationship at any level | Most areas prepared; 1-2 cost elements need deeper justification | Cannot defend pricing without spreadsheets |

---

## Section XI: Cross-Cutting & Competitive

| Phase | GREEN | YELLOW | RED |
|-------|-------|--------|-----|
| **Shaping** | Competitive landscape mapped; 3+ competitors identified with strengths/weaknesses; Maximus differentiators articulated; win themes drafted | Competitors identified but analysis shallow; differentiators vague | No competitive analysis; no differentiators |
| **Early Capture** | Win themes validated against eval factors; ghost strategies for top 2 competitors; teaming strategy defined; competitive pricing intelligence gathered | Win themes drafted but not validated; ghost strategies incomplete; teaming in discussion | No win themes; no ghost strategies; no teaming strategy |
| **Mid Capture** | Full competitive matrix; win themes embedded in all technical narratives; teaming agreements signed; innovation differentiators quantified; solution maturity advantage documented | Competitive matrix mostly complete; 1-2 win themes not yet embedded; teaming agreements in draft | Competitive matrix incomplete; win themes disconnected from narratives; no teaming agreements |
| **Pre-Proposal** | All cross-cutting elements proposal-ready; competitive positioning clear in every section; teaming partner contributions integrated; innovation claims evidence-backed | Most elements ready; 1-2 sections lack competitive positioning | Cross-cutting elements not proposal-ready; competitive positioning absent |
| **Pre-Submission** | Red Team confirmed competitive positioning; no unsubstantiated claims; protest risk minimized | Minor positioning refinements needed | Red Team flagged weak competitive positioning or protest risks |
| **Orals** | Can articulate why Maximus wins without disparaging competitors; prepared for "why not [competitor]" questions | Most competitive positioning rehearsed; 1-2 areas need preparation | Cannot articulate competitive advantage |

---

## PAMASI Stage Evidence Requirements

| Stage | Focus | Evidence Required | Completion Criteria |
|-------|-------|-------------------|---------------------|
| **P — Problem** | Validated pain points, stakeholder map, mission KPIs | Customer engagement notes; public source intelligence; stakeholder analysis; mission outcome metrics | Complete when you can answer: "What problem are we solving, for whom, measured how?" |
| **A — Approach** | One-sentence approach statement, differentiation rationale, cultural fit assessment | Approach statement document; competitive analysis; cultural alignment assessment; eval factor mapping | Complete when you can explain in 30 seconds why Maximus's approach is different. |
| **M — Methodology** | Named methodology with tailoring rationale, team certifications, ceremonies defined | Methodology selection memo; tailoring rationale; certification matrix; ceremony calendar; RACI for methodology roles | Complete when the team can describe their daily work tracing back to the approach statement. |
| **A — Assets** | Platforms mapped, 2+ past performance references, partner RACI, hot-start assets identified | Platform capability matrix; PP reference sheets; partner agreements with RACI; hot-start asset inventory; reuse analysis | Complete when you can answer: "What do we bring to Day 1?" |
| **S — Solution** | OV-1 complete, all architecture views, RTM started, TRLs confirmed | OV-1 diagram; logical/physical views; integration architecture; RTM draft; TRL assessment for all components | Complete when an evaluator can understand how the solution solves the stated problem. |
| **I — Implementation** | 30/60/90-day plan, staffing model, governance charter, Day-1 processes defined | Transition plan; staffing plan with names; governance charter; Day-1 process runbook; risk register with mitigations | Complete when you can answer: "What happens Day 1 morning?" |

---

## Protest Risk Checklist

Review before every submission. Any item checked YES is a protest vector requiring remediation.

| # | Risk Item | YES/NO | Remediation Owner | Status |
|---|-----------|--------|-------------------|--------|
| 1 | Proposal structure deviates from Section L instructions | | | |
| 2 | Page limits exceeded in any volume | | | |
| 3 | Compliance matrix misses one or more SHALL/MUST requirements | | | |
| 4 | Competitor names appear in any proposal volume | | | |
| 5 | Past performance references contain classified or proprietary information | | | |
| 6 | Teaming arrangements not properly disclosed per solicitation requirements | | | |
| 7 | Price significantly below or above IGCE without documented justification | | | |
| 8 | Key personnel do not meet minimum qualification requirements in Section L | | | |
| 9 | Requirements in Sections G, H, I, or C not addressed in technical volume | | | |
| 10 | Unsigned certifications or representations in Section K | | | |
