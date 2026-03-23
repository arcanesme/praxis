#!/usr/bin/env bash
# PreCompact hook — writes minimal checkpoint to vault before context compaction.
# Always exits 0 (advisory, never blocks compaction).
set -uo pipefail

CONFIG_FILE="$HOME/.claude/praxis.config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  exit 0
fi

VAULT_PATH=$(jq -r '.vault_path // empty' "$CONFIG_FILE" 2>/dev/null)
if [[ -z "$VAULT_PATH" || ! -d "$VAULT_PATH" ]]; then
  exit 0
fi

PLANS_DIR="$VAULT_PATH/plans"
mkdir -p "$PLANS_DIR"

DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
CHECKPOINT_FILE="$PLANS_DIR/$DATE-compact-checkpoint.md"

BRANCH=$(git --no-pager rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git --no-pager log --oneline -1 2>/dev/null || echo "no commits")
PROJECT_DIR=$(basename "$PWD")

STATUS_FILE="$VAULT_PATH/status.md"
PROGRESS_FILE="$VAULT_PATH/claude-progress.json"

CURRENT_PLAN="none"
LOOP_POSITION="unknown"
if [[ -f "$STATUS_FILE" ]]; then
  CURRENT_PLAN=$(grep "^current_plan:" "$STATUS_FILE" | sed 's/current_plan: *//' | head -1)
  LOOP_POSITION=$(grep "^loop_position:" "$STATUS_FILE" | sed 's/loop_position: *//' | head -1)
  [[ -z "$CURRENT_PLAN" ]] && CURRENT_PLAN="none"
  [[ -z "$LOOP_POSITION" ]] && LOOP_POSITION="unknown"
fi

cat > "$CHECKPOINT_FILE" <<EOF
---
tags: [checkpoint, compact]
date: $DATE
source: agent
---
# Compact Checkpoint — $TIMESTAMP

## Working Directory
$PWD

## Git State
- Branch: $BRANCH
- Last commit: $LAST_COMMIT

## Active Plan
$CURRENT_PLAN

## Loop Position
$LOOP_POSITION

## Note
This checkpoint was auto-written by the PreCompact hook.
Read this file after compaction to restore context.
EOF

echo "Vault checkpoint written: $CHECKPOINT_FILE" >&2
exit 0
