#!/bin/bash
set -euo pipefail

echo "=== Praxis: Installing data kit ==="
echo ""

source "$(dirname "$0")/../../base/lib/kit-check.sh"

echo "Checking optional CLI tools..."
echo ""

check "psql"    "brew install postgresql  OR  apt-get install postgresql-client" "optional"
check "mysql"   "brew install mysql-client  OR  apt-get install mysql-client" "optional"
check "mongosh" "brew install mongosh  OR  https://www.mongodb.com/try/download/shell" "optional"
check "jq"      "brew install jq  OR  apt-get install jq"

kit_check_summary

echo ""
echo "Note: This kit uses Claude's built-in analysis for schema and query review."
echo "Database CLI tools are needed only for live query testing."
echo ""
echo "Commands available: /data:schema, /data:migration, /data:query"
echo ""
echo "=== data kit check complete ==="
echo "Activate with: /kit:data"
echo ""
