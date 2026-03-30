#!/usr/bin/env bash
# ═══════��════════════════════════════════════════════════════════
#  Praxis — Shared Output Helpers
#  Source this file instead of defining colors/helpers inline.
#
#  Usage:
#    source "$(dirname "$0")/../base/lib/output.sh"
#    # or with absolute path:
#    source "$HOME/.claude/lib/output.sh"
#
#  Safe to source multiple times — guards against redefinition.
# ════��═══════════════════════════════════════════════════════════

# ─── Colors (skip if already set) ───
RED="${RED:-\033[0;31m}"
GREEN="${GREEN:-\033[0;32m}"
YELLOW="${YELLOW:-\033[0;33m}"
CYAN="${CYAN:-\033[0;36m}"
BOLD="${BOLD:-\033[1m}"
DIM="${DIM:-\033[2m}"
NC="${NC:-\033[0m}"

# ─── Output helpers (skip if already defined) ───
if ! declare -f ok &>/dev/null; then
  ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fi
if ! declare -f warn &>/dev/null; then
  warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
fi
if ! declare -f fail &>/dev/null; then
  fail() { echo -e "  ${RED}✗${NC} $1"; }
fi
if ! declare -f step &>/dev/null; then
  step() { echo -e "\n${CYAN}${BOLD}$1${NC}"; }
fi
if ! declare -f dim &>/dev/null; then
  dim()  { echo -e "  ${DIM}$1${NC}"; }
fi
