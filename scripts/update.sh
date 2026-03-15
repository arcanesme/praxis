#!/bin/bash
set -euo pipefail

# Pull latest and re-run install to pick up new files
CONFIG_FILE="$HOME/.claude/praxis.config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "No Praxis installation found. Run install.sh first."
  exit 1
fi

REPO_PATH=$(jq -r '.repo_path' "$CONFIG_FILE")

echo "Updating Praxis from $REPO_PATH..."
cd "$REPO_PATH"
git pull origin main

# Re-run install to create new symlinks
./install.sh

echo "✓ Updated"
