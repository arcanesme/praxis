#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"

echo "=== Praxis Uninstaller ==="
echo ""

remove_link() {
  local path="$1"
  if [ -L "$path" ]; then
    rm "$path"
    echo "  ✗ Removed ${path}"
  elif [ -e "$path" ]; then
    echo "  ⚠ ${path} is not a symlink — skipping"
  else
    echo "  · ${path} not found — nothing to do"
  fi
}

remove_link "${CLAUDE_DIR}/CLAUDE.md"
remove_link "${CLAUDE_DIR}/rules"
remove_link "${CLAUDE_DIR}/commands"
remove_link "${CLAUDE_DIR}/skills"

echo ""
echo "Config file preserved: ${CLAUDE_DIR}/praxis.config.json"
echo "Delete it manually if you want a clean slate."
echo ""
echo "=== Done ==="
