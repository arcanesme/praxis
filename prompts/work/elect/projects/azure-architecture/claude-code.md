# ELECT — Azure Architecture

## Overview
Enterprise Architect for the Virginia Department of Elections (ELECT). Produces ADRs, design documents, solution designs, and architecture assessments aligned with VITA standards and Azure Well-Architected Framework.

## Identity
- **Type**: Work
- **Git profile**: work
- **Client**: Virginia Department of Elections (ELECT)

## Tech Stack
- Azure (Landing Zones, Entra ID, Conditional Access, PIM, Key Vault, AI Foundry)
- Terraform / Bicep for IaC
- Azure DevOps

## Commands
```bash
dev:    N/A
test:   N/A
lint:   N/A
build:  N/A
format: N/A
```

## Domain Context

### VITA Standards
- **EA200**: Enterprise Architecture Policy — IT investment decisions
- **EA225**: Enterprise Architecture Standard — technology roadmaps, approved tech lists
- **EA300**: Cloud Based Hosting Services Policy
- **SEC530**: Information Security Standard — cybersecurity baseline
- **EO 30**: AI Governance — mandatory AI Registry, approval workflow, annual recertification

### Azure Frameworks
- Well-Architected Framework (5 pillars): Reliability, Security, Cost, Operational Excellence, Performance
- Cloud Adoption Framework (7 methodologies): Strategy, Plan, Ready, Adopt, Govern, Secure, Manage

### ELECT Systems
- VERIS: statewide voter registration database (133 registrars)
- ePollTab: electronic pollbook for day-of-election processing
- NTT DATA: managed services partner for Azure modernization

### Governance Bodies
- AIGF: Architecture & Innovation Governance Forum
- ORCA: policy review application
- Archer: GRC platform for security assessments

## Verification
- Architecture decisions trace to business requirements or compliance obligations
- VITA policy references cite specific documents (EA200, EA225, SEC530)
- Distinguish VITA-mandated requirements from Azure best-practice recommendations

## Conventions
- **Commits**: conventional commits (feat:, fix:, docs:, refactor:, chore:)
- **Branches**: `feat/description` or `fix/description`
- ADRs for all architecture decisions affecting subscription design, network topology, or identity model
