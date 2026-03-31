#!/usr/bin/env bash
# Run once on kit install to snapshot existing violations
# Pre-push hook only blocks on NET NEW violations above this baseline

REPO_ROOT=$(git rev-parse --show-toplevel)
BASELINE="$REPO_ROOT/.quality-baseline.json"

echo "Scanning codebase for baseline..."

opengrep scan --config auto --json "$REPO_ROOT" 2>/dev/null > /tmp/baseline-sast.json || echo '{"results":[]}' > /tmp/baseline-sast.json
osv-scanner scan --format json "$REPO_ROOT" 2>/dev/null > /tmp/baseline-sca.json || echo '{"vulns":[]}' > /tmp/baseline-sca.json

SAST_COUNT=$(jq '.results | length' /tmp/baseline-sast.json 2>/dev/null || echo 0)
SCA_COUNT=$(jq '.vulns | length' /tmp/baseline-sca.json 2>/dev/null || echo 0)

jq -n \
  --argjson sast "$SAST_COUNT" \
  --argjson sca "$SCA_COUNT" \
  --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{
    generated_at: $date,
    note: "Baseline snapshot. Gate only fires on violations exceeding these counts.",
    sast_violations: $sast,
    sca_vulnerabilities: $sca
  }' > "$BASELINE"

echo "  Baseline written to .quality-baseline.json"
echo "   SAST violations: $SAST_COUNT"
echo "   SCA vulnerabilities: $SCA_COUNT"
echo "   Commit this file to your repository."
