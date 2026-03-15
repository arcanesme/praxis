---
description: PowerShell coding style, error handling, module patterns
paths:
  - "**/*.ps1"
  - "**/*.psm1"
  - "**/*.psd1"
---

# PowerShell

## Style

- Use approved verbs: `Get-`, `Set-`, `New-`, `Remove-`, `Invoke-`.
- PascalCase for functions, cmdlets, and parameters.
- Use full parameter names in scripts (no aliases).
- `$ErrorActionPreference = 'Stop'` at the top of scripts.

## Error Handling

- Use `try/catch/finally` for operations that can fail.
- Use `-ErrorAction Stop` on cmdlets that default to `Continue`.
- Log errors with `Write-Error` or structured logging — never `Write-Host` for errors.

## Modules

- One function per file, dot-sourced from the module.
- Export only public functions in `.psd1`.
- Include `#Requires -Version` and `#Requires -Modules` where applicable.

## Security

- Never store credentials in plain text. Use `Get-Credential` or secret managers.
- Use `SecureString` for sensitive parameters.
- Sign scripts in production environments.
- Validate all external input with parameter validation attributes.
