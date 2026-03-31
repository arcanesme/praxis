#!/usr/bin/env bash
set -euo pipefail

# ════════════════════════════════════════════════════════════════
#  Praxis — Update
#  Pull latest, re-run install, update kit dependencies
# ════════════════════════════════════════════════════════════════

CONFIG_FILE="$HOME/.claude/praxis.config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "No Praxis installation found. Run install.sh first."
  exit 1
fi

REPO_PATH=$(jq -r '.repo_path' "$CONFIG_FILE")

if [[ ! -d "$REPO_PATH" ]]; then
  echo "Praxis repo not found at $REPO_PATH. Check praxis.config.json."
  exit 1
fi

# ─── Check for uncommitted changes ───
cd "$REPO_PATH"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "⚠ Uncommitted changes in $REPO_PATH"
  echo "  Stash or commit before updating."
  read -p "  Continue anyway? [y/N] " CONTINUE
  if [[ ! "${CONTINUE:-N}" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# ─── Pull latest ───
echo "Pulling latest from origin..."
git pull origin main

# ─── Re-run install to pick up new symlinks ───
echo ""
echo "Re-running install.sh..."
./install.sh

# ─── Update kit dependencies ───
echo ""
echo "Checking kit dependencies..."
for kit_dir in "$REPO_PATH"/kits/*/; do
  [[ -d "$kit_dir" ]] || continue
  kit_name=$(basename "$kit_dir")

  if [[ -f "$kit_dir/install.sh" ]]; then
    read -p "Update $kit_name dependencies? [Y/n] " UPDATE_KIT
    if [[ "${UPDATE_KIT:-Y}" =~ ^[Yy]$ ]]; then
      echo "  Updating $kit_name..."
      bash "$kit_dir/install.sh" || echo "  ⚠ $kit_name update had errors"
    fi
  fi
done

# ─── Verify key tools ───
echo ""
echo "Verifying tools..."
command -v obsidian &>/dev/null && echo "  ✓ Obsidian CLI available" || echo "  ✗ Obsidian CLI not found"
command -v claude &>/dev/null && echo "  ✓ claude available" || echo "  ✗ claude not found"
command -v node &>/dev/null && echo "  ✓ node available" || echo "  ✗ node not found"

if [[ -f "$REPO_PATH/scripts/health-check.sh" ]]; then
  echo ""
  echo "Running health check..."
  bash "$REPO_PATH/scripts/health-check.sh" || echo "  ⚠ Health check had failures"
fi

if [[ -f "$REPO_PATH/scripts/lint-harness.sh" ]]; then
  echo ""
  echo "Running content lint..."
  bash "$REPO_PATH/scripts/lint-harness.sh" "$REPO_PATH" || echo "  ⚠ Lint had failures"
fi

echo ""
echo "✓ Praxis updated"
