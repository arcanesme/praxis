#!/bin/bash
set -euo pipefail

echo "=== Praxis: Installing web-designer kit ==="
echo ""

# Skills
echo "Installing npm skills..."

SKILLS=(
  "nextlevelbuilder/ui-ux-pro-max-skill@ui-ux-pro-max"
  "shadcn-ui/ui@skills"
  "web-accessibility"
  "ibelick/ui-skills"
  "vercel/web-design-guidelines"
)

for skill in "${SKILLS[@]}"; do
  echo "  Installing $skill..."
  if npx skills add "$skill" -g -y 2>/dev/null; then
    echo "  ✓ $skill"
  else
    echo "  ⚠ $skill failed — install manually: npx skills add $skill -g -y"
  fi
done

echo ""

# MCP Servers
echo "Registering MCP servers..."
if claude mcp add 21st-magic npx -- -y @21st-dev/magic@latest 2>/dev/null; then
  echo "  ✓ 21st-magic MCP server registered"
else
  echo "  ⚠ 21st-magic registration failed — run manually:"
  echo "    claude mcp add 21st-magic npx -- -y @21st-dev/magic@latest"
fi

echo ""
echo "=== web-designer kit installed ==="
echo "Activate with: /kit:web-designer"
echo ""
