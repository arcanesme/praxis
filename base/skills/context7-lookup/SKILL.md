---
name: context7-lookup
description: >
  Enforces the docs-first mandate from coding.md. Before implementing with
  any external library, framework, or API, use Context7 to retrieve current
  documentation. Activates when code references an external package, imports
  a third-party library, or calls an API that releases frequently.
---

# context7-lookup Skill

## When to Use

Before writing code that uses an external library, framework, or API:
1. Resolve the library ID: `resolve-library-id` with the package name
2. Query docs: `query-docs` with the resolved ID and your specific question
3. Proceed with implementation using verified signatures

## Flow

**Step 1 — Identify the library**
From the user's request or the code context, determine which library/API
needs documentation lookup.

**Step 2 — Resolve library ID**
Use the Context7 MCP tool `resolve-library-id`:
- Input: library name (e.g., "react", "express", "terraform azurerm")
- Output: resolved library ID for querying

**Step 3 — Query documentation**
Use the Context7 MCP tool `query-docs`:
- Input: resolved library ID + specific question about the method/API
- Output: current documentation with code examples

**Step 4 — Implement with verified signatures**
Use the documentation output as the authoritative source for:
- Method signatures and parameter types
- Constructor arguments
- Configuration options
- Return types and error cases

## When Context7 Is Unavailable

If the MCP server is not running or returns an error:
1. State that docs could not be verified
2. Flag the specific method/API as "unverified against current version"
3. Proceed with best-knowledge implementation but mark it for review

## What NOT to Look Up

- Standard library functions (built into the language)
- Patterns you've already verified in this session
- Internal project code (use `rg` instead)
