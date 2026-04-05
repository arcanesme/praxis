# ECS Limited — Azure Zero Trust

## Overview
Solutions architect supporting ECS Limited's Azure Commercial Zero Trust security engagement. Brownfield Azure environment (50-100+ apps, 50-100 VMs) targeting SOC 2 Type 2 compliance as the primary goal.

## Identity
- **Type**: Work
- **Git profile**: work
- **Client**: ECS Limited

## Tech Stack
- Azure Commercial (Entra ID, Conditional Access, PIM, Firewall, NSGs, Private Link, Defender for Cloud, Sentinel, Key Vault, WAF/App Gateway)
- Terraform / Bicep for IaC
- Azure DevOps pipelines

## Commands
```bash
dev:    N/A
test:   N/A
lint:   N/A
build:  N/A
format: N/A
```

## Domain Context

### Security Model
- **Tiered network**: User → Web → App/API → Data. Deny-all default.
- **Uncontrolled devices**: All devices untrusted. PAW for admin only.
- **Environment parity**: Dev = staging = prod for security controls.
- **No trusted clients**: All apps treated as publicly available.

### Engagement Status
- Discovery complete. Currently Phase 2 (130 tasks, 4 sub-phases)
- 35 tracked risks (11 critical, 16 high, 8 medium). 718 discovery findings.
- Key work packages: SIEM, PIM, segmentation, WAF, Conditional Access, Azure Policy, NHI governance, app remediation, 9 policies, SOC 2 readiness

### Compliance Targets
- **Primary**: SOC 2 Type 2 (AICPA TSC 2017 + 2022 Points of Focus)
- **Secondary**: ISO 27001:2022 (aligned where controls overlap)
- Azure Commercial (not GovCloud)

## Verification
- Map checklist items to SOC 2 TSC and ISO 27001:2022 controls
- Validate tiered network rules deny lateral movement
- Confirm Defender for Cloud + Sentinel deployed before segmentation

## Conventions
- **Commits**: conventional commits (feat:, fix:, docs:, refactor:, chore:)
- **Branches**: `feat/description` or `fix/description`
- Architecture decisions documented as ADRs
- 93 checklist items: 84 contractor-delivered, 9 internal
