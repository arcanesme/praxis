#!/usr/bin/env bash
set -euo pipefail
# Triggers Claude AI self-review after commit
# This is advisory — does not block, surfaces findings for next commit

REPO_ROOT=$(git rev-parse --show-toplevel)
REVIEW_OUTPUT="$REPO_ROOT/.last-ai-review.json"

# Only run if Claude Code CLI is available
if ! command -v claude &>/dev/null; then
  exit 0
fi

CHANGED=$(git diff --name-only HEAD~1...HEAD 2>/dev/null | head -20)
if [[ -z "$CHANGED" ]]; then
  exit 0
fi

echo "AI quality review running in background..."

# Run Claude self-review as background subagent
claude --print --no-interactive \
  "Review the following changed files against the self-verify protocol in base/skills/self-verify.md.
   Output ONLY valid JSON matching the schema in kits/code-quality/skills/self-review.md.
   Changed files: $CHANGED" \
  > "$REVIEW_OUTPUT" 2>/dev/null &

echo "   Results will be in .last-ai-review.json"
exit 0
