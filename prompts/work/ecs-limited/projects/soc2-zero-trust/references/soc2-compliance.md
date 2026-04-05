---
domain: soc2-compliance
generated: 2026-04-05
source: perplexity-research
---

# SOC 2 Compliance — Reference Guide

## Key Concepts & Terminology
- **SOC 2**: Service Organization Control 2 — audit framework developed by AICPA for service organizations handling customer data
- **Trust Services Criteria (TSC)**: Five categories that define the scope of a SOC 2 audit
  - **Security** (Common Criteria) — mandatory for all SOC 2 reports; protects against unauthorized access
  - **Availability** — system uptime and operational commitments
  - **Processing Integrity** — accurate, complete, timely processing
  - **Confidentiality** — protection of restricted information
  - **Privacy** — personal data collection, use, retention, disclosure, disposal
- **Type I Report**: Evaluates control design at a single point in time (1-3 month timeline)
- **Type II Report**: Evaluates control design AND operating effectiveness over 3-12 months (6-12+ month timeline)
- **Controls**: Policies, procedures, and safeguards mapped to TSC — typically 60-150 control points in a Type II audit
- **Points of Focus**: Updated in 2022 AICPA SOC 2 Audit Guide — provide clarity on risks, technologies, and vulnerabilities

## Current Standards & Frameworks
- **AICPA TSC Framework**: 2017 base criteria, 2022 revised Points of Focus (effective through 2026)
- **2022 Revisions**: Clarified risk assessments (CC1.3/CC1.5 for privacy, CC2.1-2.3 for data management), disclosures on risks/technologies. No core TSC changes.
- **2025-2026 Trends**: Greater emphasis on zero-trust, vendor risk (CC9.2), continuous monitoring, AI/cloud threat vectors
- **Confidentiality criteria** now included in 64.4% of reports (up from 34%)
- **Cross-framework alignment**: SOC 2 commonly mapped to ISO 27001, HIPAA, CMMC

## Best Practices
- Treat compliance as an ongoing operation, not a one-time project
- Start with Type I, then progress to Type II for enterprise credibility
- Scope additional TSC criteria based on specific risks (e.g., Privacy for PII, Availability for SLA-bound services)
- Automate evidence collection: logs, access reviews, patching records, incident records
- Maintain an audit calendar with monthly, quarterly, and annual review cadences
- Inventory all subservice providers and maintain vendor risk assessments (CC9.2)
- Use compliance platforms for workflow automation and continuous monitoring

## Audit Preparation Workflow
1. **Gap Analysis & Scoping** (2-4 weeks): Review TSC against current systems, identify control gaps
2. **Control Implementation** (3-9 months): Deploy MFA, change management, risk assessments, vendor inventory, backups/DR
3. **Internal Testing**: Vulnerability scans, penetration tests, access reviews
4. **Evidence Collection**: Automate log gathering, access reviews, patching records; maintain audit trail
5. **Type I Audit** (4-8 weeks): Point-in-time assessment of control design
6. **Type II Observation Period** (3-12 months): Demonstrate operating effectiveness
7. **Type II Audit** (6-10 weeks after observation): Final assessment and report

## Control Categories (Common Criteria)
- CC1: Control environment (governance, oversight, accountability)
- CC2: Communication and information (data management, internal/external communication)
- CC3: Risk assessment (risk identification, analysis, mitigation)
- CC4: Monitoring activities (ongoing evaluation, deficiency remediation)
- CC5: Control activities (policies, technology controls, deployment)
- CC6: Logical and physical access (authentication, authorization, access management)
- CC7: System operations (detection, incident management, recovery)
- CC8: Change management (change authorization, testing, deployment)
- CC9: Risk mitigation (vendor management, business continuity)

## Sources
- AICPA SOC 2 Audit Guide (2022 revision)
- Konfirmity: SOC 2 changes in 2026
- Sprinto: SOC 2 updates
- Secureframe: Trust Services Criteria guide
