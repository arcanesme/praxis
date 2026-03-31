#!/usr/bin/env bash
# dep-audit.sh — PostToolUse:Write|Edit|MultiEdit hook
# Runs dependency vulnerability checks when manifest files are modified.
# Always exits 0 (advisory only — PostToolUse cannot hard-block).
set -euo pipefail
trap 'exit 0' ERR

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
DIR=$(dirname "$FILE_PATH")
AUDIT_RESULT=""
ECOSYSTEM=""

case "$BASENAME" in
  package.json)
    ECOSYSTEM="npm"
    if command -v npm &>/dev/null && [[ -f "$DIR/package-lock.json" || -f "$DIR/node_modules/.package-lock.json" ]]; then
      # npm audit exits non-zero when vulnerabilities exist — capture output regardless
      AUDIT_RESULT=$(cd "$DIR" && npm audit --audit-level=high --json 2>/dev/null) || {
        if [[ -n "$AUDIT_RESULT" ]]; then
          : # non-zero with output = vulnerabilities found (expected)
        else
          echo "DEP-AUDIT (npm): audit command failed" >&2
        fi
      }
    fi
    ;;
  go.mod)
    ECOSYSTEM="go"
    if command -v govulncheck &>/dev/null; then
      AUDIT_RESULT=$(cd "$DIR" && govulncheck -json ./... 2>/dev/null) || {
        [[ -z "$AUDIT_RESULT" ]] && echo "DEP-AUDIT (go): govulncheck failed" >&2
      }
    elif command -v go &>/dev/null; then
      AUDIT_RESULT=$(cd "$DIR" && go list -m -json all 2>/dev/null | head -c 5000) || AUDIT_RESULT=""
    fi
    ;;
  requirements.txt|pyproject.toml)
    ECOSYSTEM="python"
    if command -v pip-audit &>/dev/null; then
      AUDIT_RESULT=$(cd "$DIR" && pip-audit --format=json 2>/dev/null) || {
        [[ -z "$AUDIT_RESULT" ]] && echo "DEP-AUDIT (python): pip-audit failed" >&2
      }
    fi
    ;;
  Cargo.toml)
    ECOSYSTEM="rust"
    if command -v cargo-audit &>/dev/null; then
      AUDIT_RESULT=$(cd "$DIR" && cargo audit --json 2>/dev/null) || {
        [[ -z "$AUDIT_RESULT" ]] && echo "DEP-AUDIT (rust): cargo-audit failed" >&2
      }
    fi
    ;;
  *)
    # Not a dependency manifest — skip silently
    exit 0
    ;;
esac

if [[ -z "$ECOSYSTEM" ]]; then
  exit 0
fi

# ── Parse results and warn on critical findings ──
CRITICAL_COUNT=0
HIGH_COUNT=0

if [[ -n "$AUDIT_RESULT" ]]; then
  case "$ECOSYSTEM" in
    npm)
      CRITICAL_COUNT=$(echo "$AUDIT_RESULT" | jq -r '.metadata.vulnerabilities.critical // 0' 2>/dev/null || echo "0")
      HIGH_COUNT=$(echo "$AUDIT_RESULT" | jq -r '.metadata.vulnerabilities.high // 0' 2>/dev/null || echo "0")
      ;;
    python)
      VULN_COUNT=$(echo "$AUDIT_RESULT" | jq -r 'length // 0' 2>/dev/null || echo "0")
      if [[ "$VULN_COUNT" -gt 0 ]]; then
        CRITICAL_COUNT="$VULN_COUNT"
      fi
      ;;
    rust|go)
      # For cargo-audit and govulncheck, count any findings as high
      if echo "$AUDIT_RESULT" | jq -e '.vulnerabilities // .findings // empty' &>/dev/null 2>&1; then
        HIGH_COUNT=1
      fi
      ;;
  esac
fi

# ── Report findings ──
if [[ "$CRITICAL_COUNT" -gt 0 ]]; then
  echo "DEP-AUDIT ($ECOSYSTEM): $CRITICAL_COUNT CRITICAL vulnerabilities found in $BASENAME" >&2
  echo "Run '/freshness' for a full audit report." >&2
fi

if [[ "$HIGH_COUNT" -gt 0 ]]; then
  echo "DEP-AUDIT ($ECOSYSTEM): $HIGH_COUNT HIGH vulnerabilities found in $BASENAME" >&2
fi

# ── Write audit result to ~/.praxis/ ──
PRAXIS_DIR="$HOME/.praxis"
if [[ -d "$PRAXIS_DIR" ]] && command -v jq &>/dev/null; then
  jq -nc \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg ecosystem "$ECOSYSTEM" \
    --arg file "$FILE_PATH" \
    --argjson critical "${CRITICAL_COUNT:-0}" \
    --argjson high "${HIGH_COUNT:-0}" \
    '{timestamp: $ts, ecosystem: $ecosystem, file: $file, critical: $critical, high: $high}' \
    > "$PRAXIS_DIR/dep-audit-latest.json" 2>/dev/null || true
fi

exit 0
