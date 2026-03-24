#!/usr/bin/env bash
# Stop hook — collects structured session data and stages it for the Stop prompt.
# Always exits 0 (advisory, never blocks session end).
set -uo pipefail

CONFIG_FILE="$HOME/.claude/praxis.config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  exit 0
fi

VAULT_PATH=$(jq -r '.vault_path // empty' "$CONFIG_FILE" 2>/dev/null)
if [[ -z "$VAULT_PATH" || ! -d "$VAULT_PATH" ]]; then
  exit 0
fi

DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Git state (fail gracefully if not in a repo)
BRANCH=$(git --no-pager rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git --no-pager log --oneline -1 2>/dev/null || echo "no commits")
RECENT_COMMITS=$(git --no-pager log --oneline -5 2>/dev/null || echo "")
FILES_CHANGED=$(git --no-pager diff --stat HEAD~5..HEAD --stat-count=50 2>/dev/null | tail -1 || echo "unknown")
DIRTY=$(git --no-pager status --porcelain 2>/dev/null | head -20)

# Vault state
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

# Project detection
PROJECT_DIR=$(basename "$PWD")

# Write staging JSON for the Stop prompt to consume
STAGING_FILE="$VAULT_PATH/.session-staging.json"

cat > "$STAGING_FILE" <<STAGING_EOF
{
  "timestamp": "$TIMESTAMP",
  "date": "$DATE",
  "project": "$PROJECT_DIR",
  "cwd": "$PWD",
  "git": {
    "branch": "$BRANCH",
    "last_commit": "$LAST_COMMIT",
    "dirty": $(if [[ -n "$DIRTY" ]]; then echo "true"; else echo "false"; fi)
  },
  "vault": {
    "current_plan": "$CURRENT_PLAN",
    "loop_position": "$LOOP_POSITION"
  },
  "recent_commits": $(echo "$RECENT_COMMITS" | jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo '[]'),
  "files_changed_summary": "$FILES_CHANGED"
}
STAGING_EOF

echo "Session data staged: $STAGING_FILE" >&2

# Update claude-progress.json if jq is available
if command -v jq &>/dev/null && [[ -f "$PROGRESS_FILE" ]]; then
  TMP_FILE=$(mktemp)
  jq --arg ts "$TIMESTAMP" \
     --arg date "$DATE" \
     --arg branch "$BRANCH" \
     --arg commit "$LAST_COMMIT" \
     --arg source "hook" \
     '.last_session = $ts |
      .sessions += [{
        "date": $date,
        "branch": $branch,
        "last_commit": $commit,
        "source": $source
      }]' "$PROGRESS_FILE" > "$TMP_FILE" 2>/dev/null

  if [[ $? -eq 0 && -s "$TMP_FILE" ]]; then
    mv "$TMP_FILE" "$PROGRESS_FILE"
    echo "claude-progress.json updated" >&2
  else
    rm -f "$TMP_FILE"
  fi
fi

exit 0
