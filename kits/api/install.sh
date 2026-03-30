#!/bin/bash
set -euo pipefail

echo "=== Praxis: Installing api kit ==="
echo ""

source "$(dirname "$0")/../../base/lib/kit-check.sh"

echo "Checking optional CLI tools..."
echo ""

check "jq"      "brew install jq  OR  apt-get install jq"
check "curl"    "pre-installed on macOS/Linux"

kit_check_summary

echo ""
echo "Note: This kit uses Claude's built-in analysis capabilities."
echo "No external API linting tools required."
echo ""
echo "Commands available: /api:spec, /api:review, /api:contract"
echo ""
echo "=== api kit check complete ==="
echo "Activate with: /kit:api"
echo ""
