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

# ── Quality state snapshot (survives compaction) ──
LINT_STATE="unknown"
TEST_STATE="unknown"

if [ -f "go.mod" ] && command -v golangci-lint &>/dev/null; then
  LINT_COUNT=$(golangci-lint run ./... 2>&1 | grep -c "^" || true)
  if [ "$LINT_COUNT" -eq 0 ]; then
    LINT_STATE="clean"
  else
    LINT_STATE="$LINT_COUNT findings"
  fi
fi

if [ -f "go.mod" ] && command -v go &>/dev/null; then
  if go test ./... -short 2>&1 | grep -q "^ok"; then
    TEST_STATE="passing"
  else
    TEST_STATE="failing"
  fi
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

## Quality State
- Lint: $LINT_STATE
- Tests: $TEST_STATE

## Note
This checkpoint was auto-written by the PreCompact hook.
Read this file after compaction to restore context.
EOF

echo "Vault checkpoint written: $CHECKPOINT_FILE" >&2

# Update claude-progress.json if jq is available
if command -v jq &>/dev/null && [[ -f "$PROGRESS_FILE" ]]; then
  TMP_FILE=$(mktemp)
  jq --arg ts "$TIMESTAMP" \
     --arg date "$DATE" \
     --arg branch "$BRANCH" \
     --arg commit "$LAST_COMMIT" \
     '.last_session = $ts |
      .sessions += [{
        "date": $date,
        "branch": $branch,
        "last_commit": $commit,
        "source": "compact"
      }]' "$PROGRESS_FILE" > "$TMP_FILE" 2>/dev/null

  if [[ $? -eq 0 && -s "$TMP_FILE" ]]; then
    mv "$TMP_FILE" "$PROGRESS_FILE"
    echo "claude-progress.json updated (compact)" >&2
  else
    rm -f "$TMP_FILE"
  fi
fi

exit 0
