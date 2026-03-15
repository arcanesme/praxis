#!/usr/bin/env bash
set -euo pipefail

echo "=== Web Designer Kit — MCP Setup ==="
echo ""

# Register 21st-magic MCP server
claude mcp add 21st-magic npx -- -y @21st-dev/magic@latest

echo ""
echo "✓ 21st-magic MCP server registered"
echo "Activate the kit with: /kit:web-designer"
