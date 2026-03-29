---
name: px-research
disable-model-invocation: true
description: "Live documentation + security research pipeline. Chains Context7 (docs) and Perplexity Sonar (CVEs, versions, maintenance) into a single structured report."
---

# /research <package-or-topic>

Full live documentation + security research pipeline chaining both MCP tools.

## When to Use
- Before adding any new dependency to a project
- When evaluating a library or framework for adoption
- When a dependency has a reported vulnerability
- When comparing alternatives for a technology choice
- Whenever Context7 alone doesn't provide enough context

## Step 1 — Context7 Resolve

Use the Context7 MCP tool `resolve-library-id`:
- Input: the package or library name from the user's request
- Output: the Context7 library ID

If Context7 returns no results: note it and proceed to Step 3 (Sonar will fetch docs).

## Step 2 — Context7 Docs

Use the Context7 MCP tool `get-library-docs`:
- Input: resolved library ID + the specific topic or API being investigated
- Output: current official documentation

Extract and note:
- Current API surface relevant to the task
- Any deprecation notices
- Configuration requirements

## Step 3 — Sonar Version Verification

Use `perplexity_search` (model: `sonar` for speed):
- Query: `"[package] npm latest version site:npmjs.com OR site:github.com"`
- Extract: version number, release date, changelog highlights
- Output: "Verified: [package]@[version] released [date]"

If Context7 had no index for this library:
- Query: `"[package] official documentation site:docs.[domain] OR site:github.com"`
- Use the returned URL as the documentation source
- State: "Context7 had no index — sourced from [URL] via Sonar"

## Step 4 — Sonar CVE Check

Use `perplexity_search` (model: `sonar-pro` for citation quality):

Two queries:
1. **Recent (last 30 days)**: `"[package] CVE vulnerability critical"` with `search_recency_filter: "month"`
2. **Baseline (last 12 months)**: `"[package] CVE vulnerability 2025 2026 site:github.com/advisories"`

Extract: CVE IDs, severity (CVSS), affected versions, patch availability.

## Step 5 — Sonar Maintenance Check

Use `perplexity_search` (model: `sonar` for speed):
- Query: `"[package] last commit release 2025 2026 archived"`
- Extract: last commit date, last release date, repository status, contributor count

## Step 6 — Produce Report

Output in this exact format:

```
## Research: [package]

**Verified version**: X.Y.Z (released YYYY-MM-DD)
**Documentation source**: Context7 / [library-id] | Sonar / [URL]
**CVEs (12mo)**: [count] — [highest severity]
**Maintenance**: Active / Slow / Archived (last commit: YYYY-MM-DD)
**Recommendation**: USE / USE WITH CAUTION / AVOID

### Recommendation Rationale
[1-3 sentences explaining the recommendation]

### API Notes (from live docs)
[Relevant API surface, configuration, or usage patterns from Context7/Sonar docs]

### Sources
- [Citation URL 1]
- [Citation URL 2]
```

**Evidence gate**: All Sonar citation URLs must appear in the Sources section. No unattributed claims.

### Recommendation criteria:
- **USE**: Current version, no critical CVEs, actively maintained, >1000 weekly downloads
- **USE WITH CAUTION**: Minor CVEs or outdated but maintained, or low download count with justification
- **AVOID**: Critical unpatched CVE, archived/unmaintained, or known supply chain risk. Always suggest an alternative.

## Degraded Mode

If Perplexity MCP is unavailable:
- Run Context7 steps only (Steps 1-2)
- Mark version, CVE, and maintenance as: "unverified — Sonar unavailable"
- Recommend the user run `/research` again after configuring Perplexity

If Context7 is also unavailable:
- State: "Neither Context7 nor Perplexity available — cannot verify documentation"
- Do NOT fall back to training data silently
- Flag the output as unverified
