#!/usr/bin/env bash
# PreToolUse hook — blocks git commit if email doesn't match expected identity.
# Reads expected emails from praxis.config.json identity section.
# Exit 0 = allow, Exit 2 = block with message.
set -euo pipefail

INPUT=$(cat)

# Only fire on Bash tool calls that contain "git commit"
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if [[ -z "$COMMAND" ]] || ! echo "$COMMAND" | grep -q "git commit"; then
  exit 0
fi

# Read identity config
CONFIG="$HOME/.claude/praxis.config.json"
if [[ ! -f "$CONFIG" ]]; then
  exit 0
fi

CWD=$(pwd)
ACTUAL_EMAIL=$(git --no-pager config user.email 2>/dev/null || echo "")

# Check work path match
WORK_PATH=$(jq -r '.identity.work.path_match // empty' "$CONFIG" 2>/dev/null)
WORK_EMAIL=$(jq -r '.identity.work.email // empty' "$CONFIG" 2>/dev/null)
PERSONAL_PATH=$(jq -r '.identity.personal.path_match // empty' "$CONFIG" 2>/dev/null)
PERSONAL_EMAIL=$(jq -r '.identity.personal.email // empty' "$CONFIG" 2>/dev/null)

EXPECTED_EMAIL=""
if [[ -n "$WORK_PATH" ]] && echo "$CWD" | grep -q "$WORK_PATH"; then
  EXPECTED_EMAIL="$WORK_EMAIL"
elif [[ -n "$PERSONAL_PATH" ]] && echo "$CWD" | grep -q "$PERSONAL_PATH"; then
  EXPECTED_EMAIL="$PERSONAL_EMAIL"
else
  # Unknown path — allow but warn
  echo "WARNING: CWD $CWD does not match known identity paths." >&2
  exit 0
fi

if [[ -n "$EXPECTED_EMAIL" && "$ACTUAL_EMAIL" != "$EXPECTED_EMAIL" ]]; then
  echo "BLOCKED: Git identity mismatch." >&2
  echo "  Expected: $EXPECTED_EMAIL" >&2
  echo "  Actual:   $ACTUAL_EMAIL" >&2
  echo "  CWD:      $CWD" >&2
  # Check if includeIf is configured and suggest fix
  if git config --global --get-regexp 'includeIf' &>/dev/null; then
    echo "  Note: includeIf is configured in ~/.gitconfig — verify CWD matches an includeIf path." >&2
  else
    echo "  Fix: git config --local user.email \"$EXPECTED_EMAIL\"" >&2
  fi
  exit 2
fi

exit 0
