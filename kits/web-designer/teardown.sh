#!/usr/bin/env bash
set -euo pipefail

echo "=== Praxis: Removing web-designer kit dependencies ==="
echo ""
echo "Note: This removes npm skills. MCP servers persist globally"
echo "and must be removed manually via: claude mcp remove 21st-magic"
echo ""

SKILLS=(
  "nextlevelbuilder/ui-ux-pro-max-skill@ui-ux-pro-max"
  "shadcn-ui/ui@skills"
  "web-accessibility"
  "ibelick/ui-skills"
  "vercel/web-design-guidelines"
)

for skill in "${SKILLS[@]}"; do
  echo "  Removing $skill..."
  npx skills remove "$skill" -g 2>/dev/null || echo "  ⚠ $skill not found or already removed"
done

echo ""
echo "=== web-designer kit dependencies removed ==="
echo "To also remove MCP server: claude mcp remove 21st-magic"
echo ""
