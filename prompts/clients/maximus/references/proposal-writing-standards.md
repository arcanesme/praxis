# Proposal Writing Standards — Knowledge Reference
## Maximus Federal Deal Solution Architect v9.1

---

## 1. Regulatory Foundation

### FAR Part 15 — Evaluation Standard

All proposals are evaluated under FAR Part 15 (Contracting by Negotiation). The evaluation standard is **best value**, which may be:
- **Lowest Price Technically Acceptable (LPTA)**: Technical pass/fail, then lowest price wins. Minimize risk language; maximize compliance evidence.
- **Best Value Trade-Off**: Technical merit weighed against price. Maximize discriminators; demonstrate superior value.
- **Highest Technically Rated with Fair and Reasonable Price**: Technical excellence paramount. Price must be fair but is secondary.

Always confirm the evaluation methodology from Section M before writing a single word.

### Uniform Contract Format (UCF) — Key Sections

| Section | Title | SA Relevance |
|---------|-------|-------------|
| **C** | Description/Specifications/SOW/PWS | The work. Every technical claim must trace to a C requirement. |
| **G** | Contract Administration Data | Reporting, invoicing, COR designation. Address in management approach. |
| **H** | Special Contract Requirements | Security clearances, organizational conflicts, small business goals. Must address each. |
| **I** | Contract Clauses | FAR/DFARS clauses. Compliance matrix must reference every applicable clause. |
| **J** | Attachments/Exhibits | CDRLs, labor categories, GFE/GFI lists. Map deliverables to these. |
| **K** | Representations and Certifications | Must be signed and current. Protest vector if missing. |
| **L** | Instructions, Conditions, and Notices | THE authority on proposal structure, page limits, format. Deviate at your peril. |
| **M** | Evaluation Factors | THE authority on what evaluators score. Every sentence should trace to an M factor. |

### Plain Writing Act of 2010

Federal writing must be clear, concise, and well-organized. This is not optional — it is law. Implications for proposals:
- Short sentences (target 15-22 words)
- Active voice
- Concrete language over abstractions
- Headers and lists for scanability
- No jargon without definition on first use

---

## 2. BLUF Standard (Bottom Line Up Front)

Every proposal paragraph, section introduction, and executive summary follows the BLUF structure.

### Structure

| Element | Purpose | Length |
|---------|---------|--------|
| **Lead** (BLUF sentence) | State the conclusion, recommendation, or key point first. | 1 sentence |
| **Body** | Provide evidence, rationale, and supporting detail. | 2-5 sentences |
| **Close** | Restate benefit to the customer or transition to next topic. | 1 sentence |

### Examples

**Wrong:**
> Our team has extensive experience in federal IT modernization spanning over 15 years. We have worked with numerous agencies including DHS, VA, and CMS. Based on this experience, we believe our approach to cloud migration will meet the agency's needs.

**Right:**
> Maximus will complete the cloud migration within 12 months, achieving FedRAMP High authorization by Month 9. This timeline is based on three comparable migrations (VA EHR, CMS MFASIS, DHS ATLAS) where we achieved authorization 30 days ahead of schedule. The agency gains an operational platform three months before the legacy system's end-of-life deadline.

---

## 3. FBP Standard (Feature–Benefit–Proof)

Every technical claim must contain all three elements. Missing elements weaken the evaluation score.

### Three Elements

| Element | Definition | Test |
|---------|-----------|------|
| **Feature** | What we do or provide — a capability, tool, process, or asset. | "Can the evaluator identify the specific offering?" |
| **Benefit** | Why it matters to the customer's mission — stated in their language, tied to their outcomes. | "Does this connect to an eval factor or mission KPI?" |
| **Proof** | Evidence it works — past performance, metrics, certifications, or demonstrated results. | "Would a skeptical evaluator accept this as evidence?" |

### Scoring Impact

| FBP Completeness | Likely Evaluator Perception | Score Impact |
|------------------|-----------------------------|-------------|
| Feature + Benefit + Proof | Credible, substantiated, differentiating | Strength or Significant Strength |
| Feature + Benefit (no Proof) | Promising but unsubstantiated | Neutral to minor Strength |
| Feature + Proof (no Benefit) | Capable but "so what?" | Neutral |
| Feature only | Brochureware | Weakness or ignored |
| Benefit only | Empty promise | Weakness |

### Examples by Level

**Feature only (weak):**
> Maximus uses an Agile development methodology.

**Feature + Benefit (better):**
> Maximus uses an Agile development methodology, enabling the agency to reprioritize work every two weeks in response to changing mission needs.

**Full FBP (strongest):**
> Maximus uses an Agile development methodology (Feature), enabling the agency to reprioritize work every two weeks in response to changing mission needs (Benefit). On the CMS MFASIS program, this approach reduced time-to-deployment for priority changes from 90 days to 14 days, earning an Exceptional CPARS rating for schedule performance (Proof).

---

## 4. Grammar Rules

### Active Voice

Active voice is mandatory. Passive voice obscures who is responsible — a fatal flaw in proposals where evaluators assess your commitment.

| Passive (Wrong) | Active (Right) |
|-----------------|----------------|
| The system will be deployed by our team | Maximus deploys the system |
| Requirements will be gathered during Phase 1 | Maximus gathers requirements during Phase 1 |
| Testing is performed on a weekly basis | Maximus tests weekly |
| The transition plan was developed | Maximus developed the transition plan |
| Issues are escalated to the PM | The delivery lead escalates issues to the PM |
| The architecture has been designed to support | Maximus designed the architecture to support |

### SHALL → WILL Mapping

| In the RFP (Government language) | In the Proposal (Offeror language) |
|-----------------------------------|------------------------------------|
| The contractor **shall** provide... | Maximus **will** provide... |
| The contractor **shall** ensure... | Maximus **ensures**... (present tense for established processes) |
| The contractor **shall not**... | Maximus **does not** and **will not**... |

Never use "shall" in a proposal — it is the Government's directive word. The offeror's word is "will" (commitment) or present tense (established capability).

### Tense Discipline

| Tense | Use For | Example |
|-------|---------|---------|
| **Present** | Current capabilities, established processes, existing assets | "Maximus operates a FedRAMP High cloud environment" |
| **Future** | Commitments specific to this contract | "Maximus will deploy the initial operating capability within 90 days" |
| **Past** | Past performance evidence | "On the VA EHR program, Maximus reduced processing time by 40%" |

Never mix tenses within a single FBP statement. Feature (present), Benefit (present/future), Proof (past).

### Sentence Length

| Metric | Target | Maximum |
|--------|--------|---------|
| Average sentence length | 15-22 words | — |
| Maximum single sentence | — | 35 words |
| Paragraph length | 3-5 sentences | 7 sentences |

If a sentence exceeds 35 words, split it. No exceptions. Evaluators skim — long sentences get misread or skipped.

---

## 5. Tone — 70/30 Rule

**70% Mission / 30% Maximus.** Every page should talk more about the customer's mission, outcomes, and challenges than about Maximus's capabilities.

### Why

Evaluators are mission owners. They care about their problem being solved, not about your company's history. Lead with their mission. Support with your capability.

**Wrong (Maximus-heavy):**
> Maximus is a leading provider of federal IT services with over 45 years of experience. Our team of 35,000 professionals delivers innovative solutions across federal, state, and local government.

**Right (Mission-first):**
> The agency's enrollment processing backlog affects 2.3 million beneficiaries waiting for eligibility determinations. Maximus reduces this backlog by 60% within 6 months using automated eligibility workflows proven on 3 comparable programs.

### Evaluator Persona Calibration

| Persona | Cares About | Write To Them By |
|---------|-------------|-------------------|
| **Mission Owner** | Outcomes, KPIs, mission impact, timeline to value | Leading with mission outcomes; quantifying impact in their metrics |
| **Technical Authority** | Architecture soundness, integration risk, scalability, standards compliance | Providing architecture detail, trade-off rationale, TRL evidence |
| **Acquisition Professional** | Compliance, cost realism, protest risk, past performance relevance | Ensuring compliance matrix completeness; matching Section L exactly |
| **End User** | Usability, training, transition disruption, day-to-day workflow | Describing user experience; showing transition plan minimizes disruption |
| **Budget Authority** | Cost efficiency, ROI, should-cost alignment, price realism | Connecting technical approach to cost drivers; showing value per dollar |

---

## 6. Banned Language

### Buzzword Replacement Table

| Banned Term | Why | Replace With |
|-------------|-----|-------------|
| robust | Vague; no measurable meaning | State the specific capability: "handles 10,000 concurrent users" |
| world-class | Unsubstantiated superlative | Cite the specific ranking, certification, or metric |
| proven track record | Cliché; evaluators discount it | Cite the specific program, metric, and CPARS rating |
| cutting-edge | Meaningless without context | Name the specific technology and its TRL |
| seamless | Nothing is seamless; evaluators know this | Describe the specific integration approach and testing |
| leverage | Corporate jargon | "use," "apply," "build on" |
| synergy | Corporate jargon | Describe the specific combined capability |
| holistic | Vague | Describe what specifically is included |
| unique understanding | Unprovable claim | Describe the specific insight and its source |
| best-of-breed | Unsubstantiated comparison | Name the specific tool and why it was selected |
| state-of-the-art | Undefinable | Cite the standard, version, or specification |
| industry-leading | Unsubstantiated | Cite the ranking or market position data |
| turnkey | Oversimplification | Describe the specific implementation and timeline |
| deep bench | Vague staffing claim | State the number of qualified staff and their certifications |
| thought leadership | Self-congratulatory | Cite the specific publication, patent, or contribution |

### Banned Hedge Words

Never use these — they signal uncertainty to evaluators:
- "We believe" → State the fact or commitment directly
- "We hope to" → "Maximus will"
- "We plan to" → "Maximus will" (if committed) or remove (if not)
- "We feel that" → State the evidence
- "Arguably" → Remove entirely
- "Potentially" → Quantify the probability or remove
- "Roughly" / "Approximately" → Use a specific number or range
- "In our opinion" → Cite the evidence instead

### Banned Filler Phrases

Remove on sight — they add no information:
- "It is important to note that" → Delete; state the point directly
- "As previously mentioned" → Delete; either the reader remembers or re-state concisely
- "In today's rapidly changing environment" → Delete entirely
- "At the end of the day" → Delete entirely
- "It goes without saying" → Then don't say it. Delete.
- "As a matter of fact" → Delete; state the fact
- "In order to" → "To"
- "Due to the fact that" → "Because"
- "At this point in time" → "Now" or "Currently"
- "On a daily basis" → "Daily"

---

## 7. Document-Type Rules

### Technical Volume Structure

| Level | Element | Purpose |
|-------|---------|---------|
| **1** | Volume title | Matches Section L volume name exactly |
| **2** | Section | Major eval factor (e.g., "Technical Approach") |
| **3** | Subsection | Sub-factor or major topic area |
| **4** | Paragraph group | Specific requirement or capability |
| **5** | FBP block | Individual Feature–Benefit–Proof statement |

Every Level 2 heading opens with a BLUF paragraph. Every Level 4+ block contains at least one complete FBP.

### RFI Response Format

1. **Restate the question** (1 sentence, paraphrased to show understanding)
2. **Direct answer** (1-3 sentences, BLUF)
3. **Supporting detail** (as needed, with FBP where applicable)
4. **Differentiator** (if the question allows — what makes Maximus's answer different)

Keep RFI responses concise. The Government is gathering market intelligence, not evaluating proposals.

### PWS Standards

When writing or reviewing a Performance Work Statement:
- Requirements use "shall" (mandatory) or "may" (optional) — never "should" or "will"
- Each requirement is individually testable and measurable
- Performance standards have explicit Acceptable Quality Levels (AQLs)
- No requirements that duplicate FAR/DFARS clauses

### Past Performance — STAR Structure

| Element | Content | Length |
|---------|---------|--------|
| **Situation** | Contract name, agency, period, value, scope summary | 2-3 sentences |
| **Task** | Specific challenge or requirement relevant to the current pursuit | 1-2 sentences |
| **Action** | What Maximus specifically did (active voice, specific methods) | 2-4 sentences |
| **Result** | Quantified outcome with metrics; CPARS rating if available | 1-2 sentences |

---

## 8. Color Team Standards

### Team Definitions

| Team | Purpose | Reviewers | Timing |
|------|---------|-----------|--------|
| **Pink Team** | Architecture and outline review. Is the story right? | Capture lead, SA, SMEs | After outline, before drafting |
| **Red Team** | Full draft review simulating evaluator perspective. Scored. | Independent reviewers (not authors), at least 1 former government evaluator if possible | After first complete draft |
| **Gold Team** | Executive review of final draft. Win strategy alignment check. | Capture executive, BD lead, pricing lead | After Red Team revisions |
| **White Glove** | Compliance, formatting, and production review. Zero defects. | Production team, contracts, compliance | 48-72 hours before submission |

### Pass Criteria

| Team | Pass | Conditional | Fail |
|------|------|-------------|------|
| **Pink** | Story arc clear; outline addresses all eval factors; win themes present | Story needs refinement; minor eval factor gaps | No clear story; major eval factor gaps |
| **Red** | No Significant Weaknesses or Deficiencies; all findings addressable in revision cycle | 1-2 Weaknesses with clear fix path | Any Deficiency; Weaknesses that require architectural change |
| **Gold** | Win strategy evident; executive confident in submission | Minor strategy refinements needed | Executive not confident; major strategy gaps |
| **White Glove** | Zero compliance defects; all formatting correct; production-ready | Minor formatting issues fixable in <4 hours | Compliance defects; missing sections; wrong format |

### Red Team Output Format

Red Team findings use the S/W/SW/D framework:

| Rating | Definition | Proposal Impact |
|--------|-----------|----------------|
| **S — Strength** | Exceeds requirements; provides meaningful advantage | Maintain; amplify in executive summary |
| **W — Weakness** | Deficiency that could reduce score but is correctable | Must fix in revision cycle |
| **SW — Significant Weakness** | Material failure to meet a requirement; could result in lower adjectival rating | Must fix; may require architectural change |
| **D — Deficiency** | Failure to meet a requirement that is not correctable without fundamental restructuring | Stop. Escalate. May require re-baseline. |

---

## 9. TRL Reference (Technology Readiness Level)

| TRL | Definition | Proposal Implication | Rating |
|-----|-----------|---------------------|--------|
| **1** | Basic principles observed | Do not propose; research only | RED |
| **2** | Technology concept formulated | Do not propose; too immature | RED |
| **3** | Experimental proof of concept | Do not propose for production use | RED |
| **4** | Technology validated in lab | Propose only with significant risk mitigation and customer awareness | RED |
| **5** | Technology validated in relevant environment | Propose with risk mitigation plan; flag to customer | YELLOW |
| **6** | Technology demonstrated in relevant environment | Acceptable with documented maturation plan | YELLOW |
| **7** | System prototype demonstrated in operational environment | Acceptable; document remaining maturation steps | GREEN |
| **8** | System complete and qualified | Ready for proposal; cite qualification evidence | GREEN |
| **9** | System proven in operational environment | Ideal; cite operational metrics as proof points | GREEN |

For any component below TRL 7, the proposal must include a maturation plan with milestones, cost, and risk.

---

## 10. CPARS Rating Scale

| Rating | Definition | Proposal Citation Format |
|--------|-----------|------------------------|
| **Exceptional** | Performance exceeded most contractual requirements with zero quality issues | "Received an Exceptional CPARS rating for [specific area], with the evaluator noting: '[direct quote if available]'" |
| **Very Good** | Performance exceeded some contractual requirements with no significant quality issues | "Received a Very Good CPARS rating for [area], reflecting consistent above-standard delivery" |
| **Satisfactory** | Performance met contractual requirements | "Met all contractual requirements per CPARS evaluation" (use carefully — does not differentiate) |
| **Marginal** | Performance did not meet some contractual requirements | Do not cite. Address the underlying issue in risk management narrative if the contract is relevant. |
| **Unsatisfactory** | Performance did not meet most contractual requirements | Do not cite. If the contract is relevant, address corrective actions taken. |

---

## 11. SA Writing Checklist

Run before submitting any section for color team review.

### Gate 1: Compliance

- [ ] Every SHALL/MUST requirement in Sections C, G, H, I has a traceable response
- [ ] Proposal structure matches Section L instructions exactly
- [ ] Page limits verified for every volume
- [ ] All CDRLs/deliverables from Section J addressed
- [ ] Representations and certifications (Section K) complete and signed
- [ ] Font, margin, and formatting requirements met per Section L
- [ ] Cross-references accurate (no "see Section X" pointing to wrong section)

### Gate 2: Architecture Narrative

- [ ] OV-1 present and readable at arm's length
- [ ] All architecture views complete and consistent with each other
- [ ] Every component has a TRL assessment (all TRL 7+ or mitigation plan documented)
- [ ] Integration points explicitly identified with interface descriptions
- [ ] Trade-off analysis documented for every major architecture decision
- [ ] Architecture traces to requirements (RTM started or complete)
- [ ] Security architecture addresses FedRAMP/FISMA/NIST requirements

### Gate 3: Writing Quality

- [ ] Every paragraph opens with BLUF
- [ ] Every technical claim has complete FBP (Feature, Benefit, Proof)
- [ ] Active voice throughout (no passive voice without justification)
- [ ] No banned buzzwords, hedge words, or filler phrases
- [ ] Sentence length: average 15-22 words, none exceeds 35
- [ ] 70/30 rule: mission language exceeds Maximus language on every page
- [ ] No vague quantifiers ("many," "significant," "various") — all claims specific

### Gate 4: Evidence Quality

- [ ] Every past performance citation includes program name, agency, value, and timeframe
- [ ] CPARS ratings cited with specific evaluation area
- [ ] Metrics are specific and verifiable (not "improved performance" but "reduced processing time by 40%")
- [ ] No unsubstantiated claims of "first," "only," "best," or "leading"
- [ ] All certifications current and verifiable
- [ ] Partner/subcontractor capabilities substantiated with their past performance, not just Maximus's
