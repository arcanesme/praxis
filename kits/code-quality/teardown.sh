#!/bin/bash
set -euo pipefail

echo "Removing code-quality kit hooks..."

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
HOOKS_DIR="$REPO_ROOT/.git/hooks"

[ -f "$HOOKS_DIR/pre-push" ] && rm "$HOOKS_DIR/pre-push" && echo "  pre-push hook removed"
[ -f "$HOOKS_DIR/post-commit" ] && rm "$HOOKS_DIR/post-commit" && echo "  post-commit hook removed"

echo ""
echo "Note: CLI tools (opengrep, trufflehog, osv-scanner, checkov) are system-level"
echo "and not managed by this kit."
echo ""
echo "To fully remove:"
echo "  1. Remove /kit:code-quality from any project CLAUDE.md"
echo "  2. Delete this directory: rm -rf ~/.claude/kits/code-quality"
echo "  3. Optionally remove .quality-baseline.json from your repo"
echo ""
echo "code-quality kit removed"
