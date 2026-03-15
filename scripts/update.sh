#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Praxis Update ==="
echo ""

cd "$REPO_DIR"

echo "Pulling latest changes…"
git pull origin main

echo ""
echo "Re-running installer…"
bash "${REPO_DIR}/install.sh"

echo ""
echo "=== Update complete ==="
