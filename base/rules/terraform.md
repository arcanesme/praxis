---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.tfplan"
---
# Terraform — Rules
# Scope: Projects with .tf files

## Invariants (BLOCK on violation)

### State Management
- Remote state ONLY — no local state files ever committed.
- Backend config must not contain secrets — use environment variables or Key Vault refs.
- State locking required — never disable lock without explicit reason + approval.
- `terraform plan` must be reviewed before every `apply`. No blind applies.

### Layer Boundaries (enforce with rg checks)
- `modules/` → MUST NOT reference `../environments/` directly
  Check: `rg 'source\s*=\s*"\.\.\/environments' modules/`
- `environments/` → MUST NOT contain resource definitions, only variable calls
  Check: `rg '^resource "' environments/`
- On violation: BLOCK commit. Hard stop.

### Formatting
- `terraform fmt -recursive` must pass before any commit touching .tf files.
- `terraform validate` must pass.

## Conventions (WARN on violation)

### Naming
- Resources: `{project}-{env}-{resource_type}-{purpose}`
- Variables: snake_case
- Outputs: snake_case, descriptive
- Modules: kebab-case directory names

### Provider
- Pin provider versions exactly — no `~>` in production
- Managed identity preferred over service principal where possible
- Tag all resources: `project`, `environment`, `owner`, `created_by = "terraform"`

### Security scanning
- Run `trivy config .` before committing infrastructure changes.
- If trivy is not installed: warn, do not block. (tfsec is deprecated — use trivy.)

### Cost Awareness
Before proposing any Azure resource, state the estimated SKU and monthly cost.
Prefer B-series (burstable) over D/E-series unless workload justifies it.
Infracost runs on every commit — cost surprises are treated as bugs.

## Verification Commands
```bash
terraform fmt -recursive -check
terraform validate
trivy config --severity HIGH,CRITICAL .
rg 'source\s*=\s*"\.\.\/environments' modules/
rg '^resource "' environments/
```
