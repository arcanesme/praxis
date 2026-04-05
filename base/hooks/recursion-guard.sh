#!/usr/bin/env bash
# recursion-guard.sh — PreToolUse hook (all matchers)
# Detects repetitive tool invocations and blocks infinite loops.
# Tracks per-session state in /tmp. Lightweight — sub-millisecond.
# Exit 0 = allow (with optional warning), Exit 2 = block.
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)

# ── Configuration ──
WARN_SAME_CMD=5
BLOCK_SAME_CMD=8
WARN_SAME_FILE=15
BLOCK_SAME_FILE=25

# ── State file scoped to session ──
STATE_FILE="/tmp/praxis-recursion-${PPID}.json"

# Initialize state if missing
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"commands":{},"files":{}}' > "$STATE_FILE"
fi

# ── Extract key based on tool type ──
case "$TOOL_NAME" in
  Bash)
    KEY=$(echo "$INPUT" | jq -r '.tool_input.command // "unknown"' 2>/dev/null)
    CATEGORY="commands"
    WARN_THRESHOLD=$WARN_SAME_CMD
    BLOCK_THRESHOLD=$BLOCK_SAME_CMD
    ;;
  Write|Edit|MultiEdit)
    KEY=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // "unknown"' 2>/dev/null)
    CATEGORY="files"
    WARN_THRESHOLD=$WARN_SAME_FILE
    BLOCK_THRESHOLD=$BLOCK_SAME_FILE
    ;;
  *)
    # Other tools: track but with higher thresholds
    KEY=$(echo "$INPUT" | jq -r '.tool_input | tostring' 2>/dev/null | head -c 200)
    CATEGORY="commands"
    WARN_THRESHOLD=$WARN_SAME_CMD
    BLOCK_THRESHOLD=$BLOCK_SAME_CMD
    ;;
esac

# Truncate key to prevent state file bloat
KEY="${KEY:0:300}"

# ── Increment counter ──
# Use a hash of the key for safe JSON field names
if command -v md5sum &>/dev/null; then
  KEY_HASH=$(echo -n "$KEY" | md5sum | cut -d' ' -f1)
elif command -v md5 &>/dev/null; then
  KEY_HASH=$(echo -n "$KEY" | md5 -q)
else
  KEY_HASH="${KEY:0:32}"
fi

COUNT=$(jq -r --arg cat "$CATEGORY" --arg key "$KEY_HASH" \
  '.[$cat][$key] // 0' "$STATE_FILE" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))

# shellcheck disable=SC2015  # intentional: if jq or mv fails, fall through silently
jq --arg cat "$CATEGORY" --arg key "$KEY_HASH" --argjson count "$COUNT" \
  '.[$cat][$key] = $count' "$STATE_FILE" > "${STATE_FILE}.tmp" 2>/dev/null \
  && mv "${STATE_FILE}.tmp" "$STATE_FILE" 2>/dev/null || true

# ── Check thresholds ──
if [[ $COUNT -ge $BLOCK_THRESHOLD ]]; then
  echo "BLOCKED: Repetition detected — $TOOL_NAME invoked $COUNT times with same input." >&2
  echo "This looks like an infinite loop. Stop and reassess your approach." >&2
  echo "Threshold: $BLOCK_THRESHOLD for $CATEGORY." >&2
  exit 2
fi

if [[ $COUNT -ge $WARN_THRESHOLD ]]; then
  echo "WARNING: $TOOL_NAME invoked $COUNT times with same input (block at $BLOCK_THRESHOLD)." >&2
  echo "Consider whether you are in a loop." >&2
fi

exit 0
