# MCP Server Reference

MCP (Model Context Protocol) servers extend Claude Code with external capabilities.
Praxis manages them via `claude mcp add` (CLI scope, not Desktop config).

## Servers

| Server | Package | API Key | Default | Purpose |
|--------|---------|---------|---------|---------|
| context7 | `@upstash/context7-mcp` | None | Auto | Live library/API docs |
| perplexity | `@pplx/mcp-server` | `PERPLEXITY_API_KEY` (pplx-*) | Opt-in | AI web search |
| github | `@modelcontextprotocol/server-github` | `GITHUB_PERSONAL_ACCESS_TOKEN` (ghp_*/github_pat_*) | Opt-in | PRs, issues, code search |

## Management Commands

```bash
# Install all (interactive)
bash scripts/onboard-mcp.sh all

# Install a specific server
bash scripts/onboard-mcp.sh context7
bash scripts/onboard-mcp.sh perplexity
bash scripts/onboard-mcp.sh github

# Check registered servers
claude mcp list

# Remove a server
claude mcp remove <name>
```

## Security Model

- API keys are passed to `claude mcp add -e` and stored in Claude Code's internal config.
- Keys are **never** written to `praxis.config.json` — only status strings (`configured`, `skipped`, `failed`).
- Key input uses `read -s` (hidden from terminal and `.install.log`).
- Key variables are `unset` immediately after use.
- The `pplx-` prefix is included in the pre-commit secret scan regex.

## Adding a New Server

Follow this 5-step contract in `scripts/onboard-mcp.sh`:

1. **Detect** — Check `claude mcp list` for existing registration. Offer reconfigure or skip.
2. **Acquire** — Prompt for API key with `read -s`. Open browser to key management page.
3. **Verify** — Validate key prefix and test against the live API.
4. **Configure** — `claude mcp add <name> -s user -e KEY=VALUE -- npx -y <package>`
5. **Track** — `update_mcp_status "<key>" "configured"` in praxis.config.json.

## Context7: Plugin vs MCP

Context7 can run as either a Claude Code plugin (via `settings.json` → `enabledPlugins`)
or as an MCP server. The onboard script detects the plugin first and skips MCP registration
if the plugin is already active. Both provide the same functionality.

## Troubleshooting

```bash
# Server registered but not responding
claude mcp remove <name>
bash scripts/onboard-mcp.sh <name>

# Check health
bash scripts/health-check.sh

# Verify a specific server
claude mcp list | grep <name>
```
