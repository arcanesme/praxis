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

## Verification Commands
```bash
terraform fmt -recursive -check
terraform validate
rg 'source\s*=\s*"\.\.\/environments' modules/
rg '^resource "' environments/
```
