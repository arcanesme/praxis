#!/usr/bin/env bash
# PreToolUse hook — blocks Write/Edit if file contains secret patterns.
# Exit 0 = allow, Exit 2 = block with message.
set -euo pipefail

# Claude Code passes tool input as JSON via stdin for PreToolUse hooks
INPUT=$(cat)

# Extract file_path from the JSON input (works for Write, Edit tools)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Scan the file for secret patterns
SECRET_PATTERN='(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36,}|pplx-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|Bearer [A-Za-z0-9+/]{20,}|DefaultEndpointsProtocol|AccountKey=)'

if rg -q "$SECRET_PATTERN" "$FILE_PATH" 2>/dev/null; then
  MATCHES=$(rg -n "$SECRET_PATTERN" "$FILE_PATH" 2>/dev/null | head -5)
  echo "BLOCKED: Potential secret detected in $FILE_PATH" >&2
  echo "$MATCHES" >&2
  echo "Remove the secret before proceeding." >&2
  exit 2
fi

exit 0
