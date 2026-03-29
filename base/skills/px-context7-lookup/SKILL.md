---
name: px-context7-lookup
description: "Enforces the docs-first mandate from coding.md. Before implementing with any external library, framework, or API, use Context7 to retrieve current documentation. Activates when code references an external package, imports a third-party library, or calls an API that releases frequently."
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
- Input: library name (for example: `react`, `express`, `Terraform azurerm`)
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

## Perplexity Sonar Fallback

When Context7 returns no results or insufficient results for a library:
1. Use `perplexity_search` with query: `"[library] official documentation site:docs.[domain] OR site:github.com"`
2. Use the returned URL and content as the documentation source
3. State in output: "Context7 had no index for [library] — sourced from [URL] via Sonar"

When Context7 is completely unavailable (MCP server not running):
1. State that docs could not be verified via Context7
2. Fall back to Perplexity Sonar for documentation lookup if available
3. If both are unavailable: flag the specific method/API as "unverified against current version"
4. Proceed with best-knowledge implementation but mark it for review

For comprehensive research including CVEs, version verification, and maintenance status,
use `/research <package>` instead — it chains both tools into a full audit.

See `~/.claude/rules/live-docs-required.md` for the complete Context7 + Perplexity protocol.

## What NOT to Look Up

- Standard library functions (built into the language)
- Patterns you've already verified in this session
- Internal project code (use `rg` instead)
