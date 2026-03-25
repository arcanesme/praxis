#!/usr/bin/env bash
# Stop hook — runs project lint command as an advisory check.
# Always exits 0 (never blocks session end).
set -uo pipefail

INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

CONFIG_FILE="$HOME/.claude/praxis.config.json"

# Find project CLAUDE.md by walking up from CWD
find_project_claude_md() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/CLAUDE.md" ]]; then
      echo "$dir/CLAUDE.md"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

CLAUDE_MD=$(find_project_claude_md 2>/dev/null) || exit 0

# Extract lint command from ## Commands section
LINT_CMD=$(awk '/^## Commands/,/^## /{
  if (/^lint:/) { sub(/^lint:[[:space:]]*/, ""); print; exit }
}' "$CLAUDE_MD" 2>/dev/null)

if [[ -z "$LINT_CMD" || "$LINT_CMD" == "#"* ]]; then
  exit 0
fi

echo "Running lint: $LINT_CMD" >&2
if eval "$LINT_CMD" 2>&1 | tail -20 >&2; then
  echo "Lint: PASS" >&2
else
  echo "Lint: warnings found (advisory only)" >&2
fi

exit 0
