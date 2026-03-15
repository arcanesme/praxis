---
description: Terraform conventions, state management, module patterns
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/terraform/**"
---

# Terraform

## Structure

- One module per logical resource group.
- Separate `variables.tf`, `outputs.tf`, `main.tf`, `providers.tf`.
- Use `terraform.tfvars` for environment-specific values. Never commit secrets.

## Naming

- Resources: `snake_case` with descriptive names.
- Variables: `snake_case`, include `description` and `type`.
- Outputs: `snake_case`, include `description`.

## State

- Remote state only (S3, Azure Blob, GCS). Never local state in shared environments.
- State locking enabled. Never manually edit state files.
- Use `terraform plan` before every `apply`.

## Modules

- Pin module versions. Use version constraints.
- Document module inputs/outputs in README.
- Keep modules focused — one responsibility per module.

## Security

- No inline credentials. Use IAM roles, managed identities, or secret managers.
- Enable encryption at rest and in transit by default.
- Use `checkov` or `tfsec` for static analysis.
