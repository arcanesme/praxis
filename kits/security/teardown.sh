#!/usr/bin/env bash
set -euo pipefail

echo "=== Praxis: Removing security kit ==="
echo ""
echo "This kit has no npm skills or MCP servers to remove."
echo "CLI tools (trivy, deepsource) are system-level and not managed by this kit."
echo ""
echo "To fully remove:"
echo "  1. Remove /kit:security from any project CLAUDE.md '## Active kit' sections"
echo "  2. Delete this directory: rm -rf ~/.claude/kits/security"
echo ""
echo "=== security kit removed ==="
echo ""
