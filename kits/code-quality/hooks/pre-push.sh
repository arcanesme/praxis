#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
KIT_DIR="$REPO_ROOT/.claude/kits/code-quality"
CONFIG="$KIT_DIR/configs/thresholds.json"
BASELINE="$REPO_ROOT/.quality-baseline.json"
TMP="/tmp/praxis-quality-$$"
mkdir -p "$TMP"

# Safe jq wrapper: validates JSON before querying; returns fallback on parse failure
# and logs a warning so gate operators know a scan produced bad output.
safe_jq() {
  local query="$1"
  local file="$2"
  local fallback="${3:-0}"
  if [[ ! -s "$file" ]]; then
    echo "$fallback"
    return
  fi
  if ! jq empty "$file" 2>/dev/null; then
    echo "  ⚠ WARNING: $file is not valid JSON — treating as scan failure" >&2
    GATE_WARNINGS+=("PARSE: $(basename "$file") produced invalid output")
    echo "$fallback"
    return
  fi
  jq -r "$query" "$file" 2>/dev/null || echo "$fallback"
}

echo ""
echo "Praxis Code Quality Gate"
echo "------------------------"

# Get changed files only (diff-scoped scanning)
CHANGED=$(git diff --name-only origin/HEAD...HEAD 2>/dev/null || git diff --name-only HEAD~1...HEAD 2>/dev/null || echo "")
if [[ -z "$CHANGED" ]]; then
  echo "  No changed files detected — skipping gate"
  exit 0
fi

# Write changed files by type
echo "$CHANGED" | grep -E '\.(py|js|ts|jsx|tsx|go|rb|java|php|cs)$' > "$TMP/code-files.txt" || true
echo "$CHANGED" | grep -E '\.(tf|tfvars|yaml|yml|json|template)$' > "$TMP/iac-files.txt" || true

GATE_FAILURES=()
GATE_WARNINGS=()

# -- SAST (OpenGrep) --
if [[ -s "$TMP/code-files.txt" ]]; then
  echo "  SAST scan (OpenGrep)..."
  FILES=$(cat "$TMP/code-files.txt" | tr '\n' ' ')
  opengrep scan --config auto --json $FILES > "$TMP/sast.json" 2>/dev/null || true

  CRITICAL=$(safe_jq '[.results[] | select(.extra.severity == "ERROR")] | length' "$TMP/sast.json")
  HIGH=$(safe_jq '[.results[] | select(.extra.severity == "WARNING")] | length' "$TMP/sast.json")

  [[ "$CRITICAL" -gt 0 ]] && GATE_FAILURES+=("SAST: $CRITICAL critical findings")
  [[ "$HIGH" -gt 0 ]]     && GATE_WARNINGS+=("SAST: $HIGH high findings")
  echo "     Critical: $CRITICAL  High: $HIGH"
fi &
SAST_PID=$!

# -- SECRETS (TruffleHog) --
echo "  Secrets scan (TruffleHog)..."
trufflehog git file://. --since-commit HEAD~1 --only-verified --json > "$TMP/secrets.json" 2>/dev/null || true
if [[ -s "$TMP/secrets.json" ]]; then
  SECRETS=$(jq -s 'length' "$TMP/secrets.json" 2>/dev/null || echo 0)
else
  SECRETS=0
fi
[[ "$SECRETS" -gt 0 ]] && GATE_FAILURES+=("SECRETS: $SECRETS verified secrets found")
echo "     Verified secrets: $SECRETS" &
SECRETS_PID=$!

# -- SCA (OSV-Scanner) --
echo "  Dependency scan (OSV-Scanner)..."
osv-scanner scan --format json "$REPO_ROOT" > "$TMP/sca.json" 2>/dev/null || true
SCA_CRITICAL=$(safe_jq '[.vulns[]? | select(.database_specific.severity? == "CRITICAL")] | length' "$TMP/sca.json")
SCA_HIGH=$(safe_jq '[.vulns[]? | select(.database_specific.severity? == "HIGH")] | length' "$TMP/sca.json")
[[ "$SCA_CRITICAL" -gt 0 ]] && GATE_FAILURES+=("SCA: $SCA_CRITICAL critical CVEs in dependencies")
[[ "$SCA_HIGH" -gt 0 ]]     && GATE_WARNINGS+=("SCA: $SCA_HIGH high CVEs in dependencies")
echo "     Critical CVEs: $SCA_CRITICAL  High CVEs: $SCA_HIGH" &
SCA_PID=$!

# -- IaC (Checkov) --
if [[ -s "$TMP/iac-files.txt" ]]; then
  echo "  IaC scan (Checkov)..."
  checkov -d "$REPO_ROOT" --output json --quiet --compact 2>/dev/null > "$TMP/iac.json" || true
  IaC_FAIL=$(safe_jq '.results.failed_checks | length' "$TMP/iac.json")
  [[ "$IaC_FAIL" -gt 0 ]] && GATE_WARNINGS+=("IaC: $IaC_FAIL policy violations")
  echo "     Policy violations: $IaC_FAIL"
fi &
IaC_PID=$!

# Wait for all parallel scans
wait $SAST_PID $SECRETS_PID $SCA_PID $IaC_PID 2>/dev/null || true

# -- COVERAGE --
COVERAGE_THRESHOLD=$(safe_jq '.coverage.line_min' "$CONFIG" 80)
if [[ -f "$REPO_ROOT/coverage/coverage-summary.json" ]]; then
  COVERAGE=$(safe_jq '.total.lines.pct' "$REPO_ROOT/coverage/coverage-summary.json" 100)
  BELOW=$(echo "$COVERAGE < $COVERAGE_THRESHOLD" | bc -l 2>/dev/null || echo 0)
  [[ "$BELOW" == "1" ]] && GATE_WARNINGS+=("COVERAGE: ${COVERAGE}% below threshold ${COVERAGE_THRESHOLD}%")
  echo "  Coverage: ${COVERAGE}% (threshold: ${COVERAGE_THRESHOLD}%)"
fi

# -- EVALUATE GATE --
echo ""
echo "------------------------"

if [[ ${#GATE_WARNINGS[@]} -gt 0 ]]; then
  echo "Warnings:"
  for w in "${GATE_WARNINGS[@]}"; do echo "   $w"; done
fi

if [[ ${#GATE_FAILURES[@]} -gt 0 ]]; then
  echo "Gate BLOCKED:"
  for f in "${GATE_FAILURES[@]}"; do echo "   $f"; done
  echo ""
  echo "Fix the above before pushing. Run: /kit:code-quality review"
  rm -rf "$TMP"
  exit 1
fi

echo "Gate passed — push proceeding"
rm -rf "$TMP"
exit 0
