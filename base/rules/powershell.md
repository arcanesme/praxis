---
paths:
  - "**/*.ps1"
  - "**/*.psm1"
  - "**/*.psd1"
---
# PowerShell — Rules
# Scope: Projects with *.ps1 files
# Runtime: PowerShell 7+ required. PSScriptAnalyzer required for lint.

## Invariants (BLOCK on violation)

### Error Handling
- Every script MUST begin with: `Set-StrictMode -Version Latest`
- Every script MUST begin with: `$ErrorActionPreference = 'Stop'`
- No bare `catch {}` blocks — every catch must either re-throw or log + re-throw.
- No `-ErrorAction SilentlyContinue` without an explicit comment explaining why.

### Secrets
- No hardcoded credentials, connection strings, or tokens in any .ps1 file.
- Key Vault references preferred: `Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName`
- Never log sensitive values — mask before `Write-Host` or `Write-Output`.

## Conventions (WARN on violation)

### Naming
- Functions: `Verb-Noun` format, approved PowerShell verbs only.
- Variables: `$PascalCase` for script-scope, `$camelCase` for local loop vars.
- Parameters: `$PascalCase`, always typed.
- Files: `Verb-Noun.ps1` matching the primary function name.

### Structure
Every script must have:
```powershell
#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    One-line description.
.DESCRIPTION
    Full description.
.PARAMETER ParamName
    Description.
.EXAMPLE
    ./Script-Name.ps1 -Param Value
#>
param(
    [Parameter(Mandatory)]
    [string]$RequiredParam
)
```

### Output
- Use `Write-Host` for human-readable progress (goes to host, not pipeline).
- Use `Write-Output` or `return` for pipeline data.
- Use `Write-Warning` for non-fatal issues.
- Use `Write-Error` or `throw` for fatal issues — never silently continue.
- Structured output: return `[PSCustomObject]` for data, not formatted strings.

## Verification Commands
```powershell
# PSScriptAnalyzer lint (if installed)
Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning,Error

# Check for SilentlyContinue without comments
rg "SilentlyContinue" --glob "*.ps1" .

# Check for missing StrictMode
rg -L "Set-StrictMode" --glob "*.ps1" .
```
