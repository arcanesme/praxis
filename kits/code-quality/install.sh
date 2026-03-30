#!/bin/bash
set -euo pipefail

echo "Installing code-quality kit dependencies..."

# Detect OS
OS=$(uname -s)

# OpenGrep (Semgrep fork, free SAST)
if ! command -v opengrep &>/dev/null; then
  pip install opengrep --quiet
  echo "  opengrep installed"
fi

# TruffleHog (secrets scanner)
if ! command -v trufflehog &>/dev/null; then
  if [[ "$OS" == "Darwin" ]]; then
    brew install trufflesecurity/trufflehog/trufflehog --quiet
  else
    curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
  fi
  echo "  trufflehog installed"
fi

# OSV-Scanner (dependency vulnerability scanner, Google)
if ! command -v osv-scanner &>/dev/null; then
  go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest
  echo "  osv-scanner installed"
fi

# Checkov (IaC scanner)
if ! command -v checkov &>/dev/null; then
  pip install checkov --quiet
  echo "  checkov installed"
fi

# jq (JSON processing in hooks)
if ! command -v jq &>/dev/null; then
  if [[ "$OS" == "Darwin" ]]; then
    brew install jq --quiet
  else
    apt-get install -y jq --quiet
  fi
  echo "  jq installed"
fi

# Install git hooks into current repo
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
HOOKS_DIR="$REPO_ROOT/.git/hooks"
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$KIT_DIR/hooks/pre-push.sh" "$HOOKS_DIR/pre-push"
chmod +x "$HOOKS_DIR/pre-push"
echo "  pre-push hook installed"

cp "$KIT_DIR/hooks/post-commit.sh" "$HOOKS_DIR/post-commit"
chmod +x "$HOOKS_DIR/post-commit"
echo "  post-commit hook installed"

# Generate baseline for existing repo
echo "  Generating quality baseline for existing codebase..."
bash "$KIT_DIR/hooks/generate-baseline.sh"

echo ""
echo "  code-quality kit installed successfully"
echo "   Pre-push gate: active (SAST + Secrets + SCA + IaC)"
echo "   AI review: active on commit (over-engineering, smells, structure)"
echo "   Baseline: .quality-baseline.json (commit this file)"
