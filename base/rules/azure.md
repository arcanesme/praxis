---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.bicep"
  - "**/*.azcli"
  - "**/azure-*"
  - "**/arm-*"
---
# Azure Rules
<!-- Scope: Azure infrastructure work -->
<!-- CUSTOMIZE: Add engagement-specific naming, tags, and subscription rules -->

## Invariants — BLOCK on violation

### Naming
- Resource names MUST follow the engagement naming convention before any deployment.
  <!-- CUSTOMIZE: Define your naming standard per engagement -->
  <!-- Example: `{project}-{env}-{region}-{resource_type}` -->
- Never use default Azure-generated names (e.g., `resource-group-1`, `vnet-eastus`).

### Mandatory Tags
<!-- CUSTOMIZE: Define required tags per engagement -->
<!-- Example: Every resource must include `project`, `environment`, `owner` -->
- Never deploy or script a resource block missing required tags. Add them first.

### Subscription Boundaries
- Never reference resources across subscription boundaries without explicit cross-subscription
  peering or private endpoint design.
- Never suggest moving a resource across subscriptions without first checking:
  Recovery Services Vault compatibility, private endpoint re-registration,
  NSG rule updates, and RBAC re-assignment.

### Identity and RBAC
- Never recommend Owner or Contributor at subscription scope as a permanent assignment.
- Never suggest disabling MFA for any account, service principal, or managed identity.
- Managed Identity is preferred over Service Principal for Azure-native workloads.
- RBAC changes to production subscriptions must be documented in `specs/` before implementation.

### Network Security
- Never recommend NSG rules with `source: Any` and `destination: Any`.
- Private Endpoints are the default for PaaS data services (Storage, SQL, Key Vault).
  Public endpoints require explicit justification written to `specs/`.

### Secrets and Credentials
- Never output real connection strings, SAS tokens, storage keys, or client secrets.
- Key Vault is the required secret store. Hard-coded credentials in any artifact = BLOCK.
- Certificate-based auth over password-based for service principals.

---

## Conventions — WARN on violation

### Cost Awareness
- Flag any change estimated to increase monthly cost by >5%.
- Flag when a stable workload is a good Reserved Instance candidate (>1 year, predictable).

### Defender and Monitoring
- Defender for Cloud recommendations rated HIGH or CRITICAL: note in `status.md`.
- Confirm Log Analytics workspace exists before suggesting new diagnostic settings.

### Documentation
- Architecture decisions affecting subscription design, network topology, or identity model
  belong in `specs/` as an ADR.

---

## Verification Commands
```bash
# Audit missing mandatory tags across a resource group
az resource list -g <rg-name> \
  --query "[?tags.project == null].[name,type]" -o table

# Find any-any NSG rules
az network nsg list \
  --query "[].securityRules[?sourceAddressPrefix=='*' && destinationAddressPrefix=='*'].[name]" -o table

# Verify no public endpoints on storage accounts
az storage account list -g <rg-name> \
  --query "[?publicNetworkAccess!='Disabled'].[name,publicNetworkAccess]" -o table

# Check Owner/Contributor at subscription scope
az role assignment list --scope /subscriptions/<sub-id> \
  --query "[?roleDefinitionName=='Owner' || roleDefinitionName=='Contributor'].[principalName,roleDefinitionName]" -o table
```

---

## Removal Condition
Remove or archive when no active Azure engagements remain in the project registry.
