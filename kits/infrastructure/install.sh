#!/bin/bash
set -euo pipefail

echo "=== Praxis: Installing infrastructure kit ==="
echo ""

source "$(dirname "$0")/../../base/lib/kit-check.sh"

echo "Checking required CLI tools..."
echo ""

check "az"        "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
check "terraform"  "https://developer.hashicorp.com/terraform/install"
check "tflint"     "brew install tflint  OR  https://github.com/terraform-linters/tflint"
check "jq"         "brew install jq  OR  apt-get install jq"

kit_check_summary

echo ""
echo "Note: Skills chain phases are status: planned."
echo "Commands available: /infra:plan, /infra:apply, /infra:drift, /infra:compliance"
echo ""
echo "=== infrastructure kit check complete ==="
echo "Activate with: /kit:infrastructure"
echo ""
