#!/bin/bash
set -euo pipefail

echo "=== Praxis: Installing security kit ==="
echo ""

PASS=0
TOTAL=0

check() {
  TOTAL=$((TOTAL + 1))
  if command -v "$1" &>/dev/null; then
    echo "  ✓ $1 found ($(command -v "$1"))"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $1 not found (optional)"
    echo "    Install: $2"
  fi
}

echo "Checking optional CLI tools..."
echo ""

check "trivy"     "brew install trivy  OR  https://aquasecurity.github.io/trivy"
check "deepsource" "curl -fsSL https://cli.deepsource.com/install | sh"
check "rg"        "brew install ripgrep  OR  apt-get install ripgrep"

echo ""
echo "  $PASS/$TOTAL tools found"
echo ""

echo "Note: This kit uses Claude's built-in analysis for most checks."
echo "External tools enhance scanning but are not required."
echo ""
echo "Commands available: /security:threat-model, /security:iam-review, /security:audit"
echo ""
echo "=== security kit check complete ==="
echo "Activate with: /kit:security"
echo ""
