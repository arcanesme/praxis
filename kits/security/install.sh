#!/usr/bin/env bash
set -euo pipefail

echo "=== Praxis: Installing security kit ==="
echo ""

source "$(dirname "$0")/../../base/lib/kit-check.sh"

echo "Checking optional CLI tools..."
echo ""

check "trivy"     "brew install trivy  OR  https://aquasecurity.github.io/trivy" "optional"
check "deepsource" "curl -fsSL https://cli.deepsource.com/install | sh" "optional"
check "rg"        "brew install ripgrep  OR  apt-get install ripgrep"

kit_check_summary

echo ""
echo "Note: This kit uses Claude's built-in analysis for most checks."
echo "External tools enhance scanning but are not required."
echo ""
echo "Commands available: /security:threat-model, /security:iam-review, /security:audit"
echo ""
echo "=== security kit check complete ==="
echo "Activate with: /kit:security"
echo ""
