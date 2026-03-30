#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════
#  Praxis — Shared Kit Install Check
#  Source this file in kit install.sh scripts for consistent
#  tool-checking output and counters.
#
#  Usage:
#    source "$(dirname "$0")/../../base/lib/kit-check.sh"
#    check "jq"      "brew install jq"
#    check "curl"    "pre-installed on macOS/Linux"
#    kit_check_summary
# ════════════════════════════════════════════════════════════════

KIT_CHECK_PASS=0
KIT_CHECK_TOTAL=0

check() {
  local cmd="$1"
  local install_hint="$2"
  local optional="${3:-}"

  KIT_CHECK_TOTAL=$((KIT_CHECK_TOTAL + 1))
  if command -v "$cmd" &>/dev/null; then
    echo "  ✓ $cmd found ($(command -v "$cmd"))"
    KIT_CHECK_PASS=$((KIT_CHECK_PASS + 1))
  else
    if [[ "$optional" == "optional" ]]; then
      echo "  ⚠ $cmd not found (optional)"
    else
      echo "  ✗ $cmd not found"
    fi
    echo "    Install: $install_hint"
  fi
}

kit_check_summary() {
  echo ""
  echo "  $KIT_CHECK_PASS/$KIT_CHECK_TOTAL tools found"
  if [[ $KIT_CHECK_PASS -lt $KIT_CHECK_TOTAL ]]; then
    echo "  ⚠ Some tools missing. Install them before using kit commands."
  fi
}
