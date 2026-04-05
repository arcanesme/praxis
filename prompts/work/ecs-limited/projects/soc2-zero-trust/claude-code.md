# ECS Limited — Azure Zero Trust

## Overview
Solutions architect supporting ECS Limited's Azure Zero Trust security engagement. Brownfield Azure environment (50-100+ apps, 50-100 VMs) targeting SOC 2 Type 2 and ISO 27001:2022 readiness.

## Identity
- **Type**: Work
- **Git profile**: work
- **Client**: ECS Limited

## Tech Stack
- Azure (Entra ID, Conditional Access, PIM, Firewall, NSGs, Private Link, Defender for Cloud, Sentinel, Key Vault)
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

### Engagement Phases
- Phase 1 — Discovery: flow logs, dependency mapping (2-4 weeks)
- Phase 2 — Zero Trust Implementation: segmentation, SIEM, access controls (months)
- Phase 3 — Future architecture decisions

### Compliance Targets
- SOC 2 Type 2 (AICPA TSC 2017 + 2022 Points of Focus)
- ISO 27001:2022

### Critical Risks
R-01 (segmentation outages), R-05 (trusted-client apps), R-07 (env parity gaps), R-22 (dev team adaptation), R-26 (service disruption), R-28 (no detection during transition)

## Verification
- Map checklist items to SOC 2 TSC and ISO 27001:2022 controls
- Validate tiered network rules deny lateral movement
- Confirm Defender for Cloud + Sentinel deployed before segmentation

## Conventions
- **Commits**: conventional commits (feat:, fix:, docs:, refactor:, chore:)
- **Branches**: `feat/description` or `fix/description`
- Architecture decisions documented as ADRs
- 93 checklist items: 84 contractor-delivered, 9 internal
