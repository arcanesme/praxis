#!/usr/bin/env bash
# file-guard.sh — PreToolUse hook
# Blocks writes to protected paths. Exit 2 = hard block.
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Default protected patterns
PROTECTED_PATTERNS=(
  "go\.sum$"
  "go\.mod$"
  "\.lock$"
  "\.lock\.json$"
  "\.github/workflows/"
  "^\.claude/"
)

# Check against protected patterns
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qE "$pattern"; then
    echo "BLOCKED: $FILE_PATH is protected. Explain the intended change before proceeding."
    exit 2
  fi
done

# Check project-level protected files from CLAUDE.md if it exists
if [[ -f "CLAUDE.md" ]]; then
  # Extract paths from ## Protected Files section
  IN_SECTION=false
  while IFS= read -r line; do
    if echo "$line" | grep -qE "^## Protected Files"; then
      IN_SECTION=true
      continue
    fi
    if $IN_SECTION && echo "$line" | grep -qE "^##"; then
      break
    fi
    if $IN_SECTION && echo "$line" | grep -qE "^- "; then
      PROTECTED=$(echo "$line" | sed 's/^- //' | sed 's/ *#.*//' | xargs)
      if [[ -n "$PROTECTED" ]] && echo "$FILE_PATH" | grep -qE "$PROTECTED"; then
        echo "BLOCKED: $FILE_PATH matches project-protected pattern '$PROTECTED'. Explain the intended change."
        exit 2
      fi
    fi
  done < CLAUDE.md
fi

exit 0
