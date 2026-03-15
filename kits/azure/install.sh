#!/usr/bin/env bash
set -euo pipefail

echo "=== Azure Kit — MCP Setup ==="
echo ""

# ── Flag parsing ─────────────────────────────────────────────────────────

ADO_ORG="${AZURE_DEVOPS_ORG:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org)       ADO_ORG="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: bash install.sh [options]"
      echo ""
      echo "Options:"
      echo "  --org <name>    Azure DevOps organization name (or AZURE_DEVOPS_ORG env var)"
      echo "  --help, -h      Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if ! command -v claude &>/dev/null; then
  echo "  ⚠ 'claude' CLI not found — install Claude Code first."
  exit 1
fi

# ── Azure DevOps MCP (official Microsoft) ────────────────────────────────

if [ -n "$ADO_ORG" ]; then
  if claude mcp add azure-devops --scope user -- npx -y @azure-devops/mcp "$ADO_ORG" 2>/dev/null; then
    echo "  ✓ azure-devops MCP registered (org: ${ADO_ORG})"
  else
    echo "  ⚠ azure-devops MCP registration failed"
    echo "    Register manually: claude mcp add azure-devops --scope user -- npx -y @azure-devops/mcp ${ADO_ORG}"
  fi
else
  echo "  ⊘ azure-devops MCP skipped (no org — use --org or AZURE_DEVOPS_ORG)"
fi

# ── Azure Resource MCP ───────────────────────────────────────────────────

if claude mcp add azure-mcp --scope user -- npx -y azure-mcp 2>/dev/null; then
  echo "  ✓ azure-mcp MCP registered"
else
  echo "  ⚠ azure-mcp MCP registration failed"
  echo "    Register manually: claude mcp add azure-mcp --scope user -- npx -y azure-mcp"
fi

echo ""
echo "=== Done ==="
echo "Activate the kit with: /kit:azure"
echo ""
echo "Note: Azure DevOps MCP requires Node.js >= 20 and triggers browser auth on first use."
echo "      Azure Resource MCP uses your local Azure CLI credentials (az login)."
