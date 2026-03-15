---
description: Azure resource naming, ARM/Bicep patterns, best practices
paths:
  - "**/azure*"
  - "**/az*"
  - "**/*.bicep"
  - "**/arm-templates/**"
---

# Azure

## Naming Convention

Follow the Cloud Adoption Framework naming convention:
`{resource-type}-{workload}-{environment}-{region}-{instance}`

Examples:
- `rg-myapp-prod-eastus-001`
- `st-myapp-prod-eastus-001`
- `app-myapp-prod-eastus-001`

## Bicep / ARM

- Prefer Bicep over raw ARM templates.
- Use modules for reusable components.
- Parameterize environment-specific values.
- Use `@description()` decorator on all parameters.

## Security

- Use Managed Identities over service principals where possible.
- Enable Azure Defender / Microsoft Defender for Cloud.
- Use Private Endpoints for PaaS services.
- Key Vault for all secrets, certificates, and keys.

## Tagging

Required tags on all resources:
- `Environment` (dev, staging, prod)
- `Owner` (team or individual)
- `Project` (project name)
- `CostCenter` (billing code)
