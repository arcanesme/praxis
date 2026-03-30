# Coding — Universal Rules
<!-- Universal — applies to ALL code regardless of language or stack -->

---

## Invariants — BLOCK on violation

### Documentation lookup before implementation
- Before implementing anything that uses an external library, framework, or API:
  use Context7 to get current docs. Training data has a cutoff. Context7 does not.
- Never suggest a method, constructor, or API signature from memory for a library
  that releases frequently. Look it up first via Context7.
- If Context7 is unavailable: state that docs could not be verified and flag the
  specific method/API as "unverified against current version."

### Tool preferences
- Use Read/Edit/Write tools instead of cat/sed/echo.
- Use `rg` (ripgrep) for searching code, not grep.
- Use `git --no-pager` for all git commands.
- Use subagents for context-heavy research and code review.
- Non-interactive commands only — no interactive prompts.
- Prefer MCP tools for current documentation (context7).
- YAML frontmatter on all markdown files.

---

## Quality Architecture

Code quality is enforced proactively, not reactively:
- **Layer 1 (Principles)**: `code-excellence.md`, `engineering-judgment.md` — shape reasoning
- **Layer 2 (Constraints)**: `code-quality.md` — hard limits during generation
- **Layer 3 (Verification)**: `/px-self-verify` — prove correctness before commit
- **Safety net**: DeepSource (cloud) — comprehensive analysis on push

Detailed rules: error handling, naming, testing, dependencies, simplicity, and
judgment live in those files. This file covers only what they do not:
Context7 mandate, tool preferences, and verification commands.

---

## Verification Commands

Single-file:
- `go vet <file>` / `shellcheck <file>` / `hadolint Dockerfile` / `markdownlint <file>.md`

Project-level:
- `deepsource issues --path <file>` — query DeepSource findings
- `deepsource repo status` — repo analysis status
- `govulncheck ./...`
- `trivy config .`

```bash
# Verify Context7 MCP is active
claude mcp list | grep context7

# Check for hardcoded credential patterns in staged files
git diff --staged | grep -iE "(password|secret|token|key)\s*=\s*['\"][^'\"$]"

# Find TODO/FIXME left in staged files
git diff --staged | grep -E "(TODO|FIXME|HACK|XXX)"
```

---

## Removal Condition
Permanent. Remove only if a dedicated AI coding assistant replaces Claude Code
entirely and handles all enforcement automatically without instruction.
