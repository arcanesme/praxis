#!/usr/bin/env bash
set -euo pipefail

echo "=== Praxis: Removing infrastructure kit ==="
echo ""
echo "This kit has no npm skills or MCP servers to remove."
echo "CLI tools (az, terraform, tflint) are system-level and not managed by this kit."
echo ""
echo "To fully remove:"
echo "  1. Remove /kit:infrastructure from any project CLAUDE.md '## Active kit' sections"
echo "  2. Delete this directory: rm -rf ~/.claude/kits/infrastructure"
echo ""
echo "=== infrastructure kit removed ==="
echo ""
