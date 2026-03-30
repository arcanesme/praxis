#!/usr/bin/env bash
# praxis-preflight.sh — "Ready to build" gate
# Phase 1 is hard-blocking (exit 1). Phases 2-5 produce warnings only.
# Also implements: set-key subcommand for secret management.
set -euo pipefail

# ─── Colors ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
WARN=0
BLOCK=0
PRAXIS_DIR="$HOME/.praxis"
SECRETS_FILE="$PRAXIS_DIR/secrets"
REPORT_FILE="$PRAXIS_DIR/preflight-report.json"

ok()   { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; WARN=$((WARN + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; BLOCK=$((BLOCK + 1)); }
step() { echo -e "\n${CYAN}${BOLD}$1${NC}"; }

# ═══════════════════════════════════════════
# Subcommand: set-key
# ═══════════════════════════════════════════
if [[ "${1:-}" == "set-key" ]]; then
  KEY="${2:-}"
  VALUE="${3:-}"
  if [[ -z "$KEY" || -z "$VALUE" ]]; then
    echo "Usage: praxis-preflight.sh set-key KEY VALUE"
    echo "Example: praxis-preflight.sh set-key PERPLEXITY_API_KEY pplx-..."
    exit 1
  fi

  # Create secure directory
  mkdir -p "$PRAXIS_DIR"
  chmod 700 "$PRAXIS_DIR"

  # Create or update secrets file
  if [[ -f "$SECRETS_FILE" ]]; then
    # Remove existing key line
    grep -v "^${KEY}=" "$SECRETS_FILE" > "${SECRETS_FILE}.tmp" 2>/dev/null || true
    mv "${SECRETS_FILE}.tmp" "$SECRETS_FILE"
  fi

  echo "${KEY}=${VALUE}" >> "$SECRETS_FILE"
  chmod 600 "$SECRETS_FILE"

  MASKED="${VALUE:0:8}********"
  echo -e "${GREEN}✓${NC} Stored $KEY (${MASKED})"
  exit 0
fi

# ═══════════════════════════════════════════
# Load secrets from file if it exists
# ═══════════════════════════════════════════
load_secrets() {
  if [[ -f "$SECRETS_FILE" ]]; then
    while IFS='=' read -r key value; do
      [[ -z "$key" || "$key" == \#* ]] && continue
      export "$key=$value" 2>/dev/null || true
    done < "$SECRETS_FILE"
  fi
}

# ═══════════════════════════════════════════
# Version comparison helper
# ═══════════════════════════════════════════
version_gte() {
  # Returns 0 if $1 >= $2
  printf '%s\n%s' "$2" "$1" | sort -V -C 2>/dev/null
}

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Praxis Preflight Check                  ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"

load_secrets

# ═══════════════════════════════════════════
# Phase 1: BLOCKING — hard exit if any fail
# ═══════════════════════════════════════════
step "Phase 1: Required (blocking)"

# Claude auth
if claude auth status &>/dev/null 2>&1; then
  ok "Claude Code authenticated"
else
  fail "Claude Code not authenticated"
  echo -e "    Fix: ${CYAN}claude auth login${NC}"
fi

# Node.js >= 18
if command -v node &>/dev/null; then
  NODE_VER=$(node --version 2>/dev/null | sed 's/^v//')
  if version_gte "$NODE_VER" "18.0.0"; then
    ok "Node.js $NODE_VER (>= 18 required)"
  else
    fail "Node.js $NODE_VER is below minimum 18.0.0"
    echo -e "    Fix: ${CYAN}brew install node${NC}"
  fi
else
  fail "Node.js not found"
  echo -e "    Fix: ${CYAN}brew install node${NC}"
fi

# jq
if command -v jq &>/dev/null; then
  ok "jq $(jq --version 2>/dev/null | sed 's/^jq-//' || echo 'installed')"
else
  fail "jq not found"
  echo -e "    Fix: ${CYAN}brew install jq${NC}"
fi

# git config
GIT_NAME=$(git config --global user.name 2>/dev/null || true)
GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)
if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
  ok "Git identity: $GIT_NAME <$GIT_EMAIL>"
else
  if [[ -z "$GIT_NAME" ]]; then
    fail "git config user.name not set"
    echo -e "    Fix: ${CYAN}git config --global user.name \"Your Name\"${NC}"
  fi
  if [[ -z "$GIT_EMAIL" ]]; then
    fail "git config user.email not set"
    echo -e "    Fix: ${CYAN}git config --global user.email \"you@example.com\"${NC}"
  fi
fi

# Check if Phase 1 failed
if [[ $BLOCK -gt 0 ]]; then
  echo ""
  echo -e "  ${RED}${BOLD}PREFLIGHT FAILED${NC} — fix $BLOCK blocking issue(s) above"
  # Write report even on failure
  mkdir -p "$PRAXIS_DIR" 2>/dev/null || true
  jq -nc \
    --argjson pass "$PASS" \
    --argjson warn "$WARN" \
    --argjson block "$BLOCK" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg status "failed" \
    '{timestamp: $ts, status: $status, pass: $pass, warn: $warn, block: $block}' \
    > "$REPORT_FILE" 2>/dev/null || true
  exit 1
fi

# ═══════════════════════════════════════════
# Phase 2: GitHub Auth
# ═══════════════════════════════════════════
step "Phase 2: GitHub authentication"

if gh auth status &>/dev/null 2>&1; then
  ok "GitHub CLI authenticated"
  # Auto-populate GITHUB_TOKEN
  GH_TOKEN=$(gh auth token 2>/dev/null || true)
  if [[ -n "$GH_TOKEN" ]]; then
    mkdir -p "$PRAXIS_DIR"
    chmod 700 "$PRAXIS_DIR"
    if [[ -f "$SECRETS_FILE" ]]; then
      grep -v "^GITHUB_TOKEN=" "$SECRETS_FILE" > "${SECRETS_FILE}.tmp" 2>/dev/null || true
      mv "${SECRETS_FILE}.tmp" "$SECRETS_FILE"
    fi
    echo "GITHUB_TOKEN=${GH_TOKEN}" >> "$SECRETS_FILE"
    chmod 600 "$SECRETS_FILE"
    ok "GITHUB_TOKEN auto-populated from gh auth"
    export GITHUB_TOKEN="$GH_TOKEN"
  fi
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  ok "GITHUB_TOKEN found in environment"
else
  warn "GitHub not authenticated — github-mcp feature disabled"
  echo -e "    Fix: ${CYAN}gh auth login${NC}"
fi

# ═══════════════════════════════════════════
# Phase 3: Optional keys
# ═══════════════════════════════════════════
step "Phase 3: Optional API keys"

# PERPLEXITY_API_KEY
if [[ -n "${PERPLEXITY_API_KEY:-}" ]]; then
  if [[ "$PERPLEXITY_API_KEY" == pplx-* ]]; then
    MASKED="${PERPLEXITY_API_KEY:0:8}********"
    ok "PERPLEXITY_API_KEY ($MASKED) — live-research enabled"
  else
    warn "PERPLEXITY_API_KEY set but doesn't start with pplx-"
  fi
else
  warn "PERPLEXITY_API_KEY not set — live research via Sonar disabled"
  echo -e "    Get key: ${CYAN}https://www.perplexity.ai/settings/api${NC}"
  echo -e "    Set:     ${CYAN}praxis-preflight.sh set-key PERPLEXITY_API_KEY pplx-...${NC}"
fi

# OBSIDIAN_VAULT
VAULT_PATH="${OBSIDIAN_VAULT:-}"
if [[ -z "$VAULT_PATH" ]]; then
  # Try to read from praxis.config.json
  CONFIG_FILE="$HOME/.claude/praxis.config.json"
  if [[ -f "$CONFIG_FILE" ]]; then
    VAULT_PATH=$(jq -r '.vault_path // empty' "$CONFIG_FILE" 2>/dev/null || true)
  fi
fi

if [[ -n "$VAULT_PATH" && -d "$VAULT_PATH" ]]; then
  ok "Vault: $VAULT_PATH"
else
  warn "No Obsidian vault configured — long-term memory disabled"
  echo -e "    Set: ${CYAN}praxis-preflight.sh set-key OBSIDIAN_VAULT /path/to/vault${NC}"
fi

# ═══════════════════════════════════════════
# Phase 4: MCP servers
# ═══════════════════════════════════════════
step "Phase 4: MCP servers"

if command -v claude &>/dev/null; then
  MCP_LIST=$(claude mcp list 2>/dev/null || true)

  # Context7 (always expected)
  if echo "$MCP_LIST" | grep -q "context7"; then
    ok "context7 MCP registered (live docs)"
  else
    warn "context7 MCP not registered"
    echo -e "    Fix: ${CYAN}bash scripts/onboard-mcp.sh context7${NC}"
  fi

  # GitHub MCP (if token available)
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    if echo "$MCP_LIST" | grep -q "github"; then
      ok "github MCP registered"
    else
      warn "github MCP not registered (token available)"
      echo -e "    Fix: ${CYAN}bash scripts/onboard-mcp.sh github${NC}"
    fi
  fi

  # Perplexity MCP (if key available)
  if [[ -n "${PERPLEXITY_API_KEY:-}" ]]; then
    if echo "$MCP_LIST" | grep -qi "perplexity"; then
      ok "perplexity MCP registered (live research)"
    else
      warn "perplexity MCP not registered (key available)"
      echo -e "    Fix: ${CYAN}bash scripts/onboard-mcp.sh perplexity${NC}"
    fi
  fi
else
  warn "claude CLI not available — cannot check MCP servers"
fi

# ═══════════════════════════════════════════
# Phase 5: Optional tools + hooks
# ═══════════════════════════════════════════
step "Phase 5: Optional tools & hooks"

# Optional security tools
for tool in trufflehog gitleaks osv-scanner; do
  if command -v "$tool" &>/dev/null; then
    ok "$tool available"
  else
    warn "$tool not installed — enhanced scanning unavailable"
  fi
done

# Check hook scripts exist and are executable
HOOKS_DIR="$HOME/.claude/hooks"
REQUIRED_HOOKS=(secret-scan.sh file-guard.sh identity-check.sh credential-guard.sh session-data-collect.sh)
for hook in "${REQUIRED_HOOKS[@]}"; do
  if [[ -x "$HOOKS_DIR/$hook" ]] || [[ -L "$HOOKS_DIR/$hook" ]]; then
    ok "Hook: $hook"
  else
    warn "Hook missing or not executable: $hook"
  fi
done

# ═══════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Pass:     ${GREEN}${BOLD}$PASS${NC}"
echo -e "  Warnings: ${YELLOW}${BOLD}$WARN${NC}"
echo -e "  Blocking: ${RED}${BOLD}$BLOCK${NC}"

if [[ $BLOCK -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}✓ Praxis ready to build${NC}"
else
  echo -e "  ${RED}${BOLD}PREFLIGHT FAILED — fix blocking issues above${NC}"
fi
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Write JSON report
mkdir -p "$PRAXIS_DIR" 2>/dev/null || true
chmod 700 "$PRAXIS_DIR" 2>/dev/null || true

STATUS="passed"
[[ $BLOCK -gt 0 ]] && STATUS="failed"
[[ $WARN -gt 0 && $BLOCK -eq 0 ]] && STATUS="passed_with_warnings"

if command -v jq &>/dev/null; then
  jq -nc \
    --argjson pass "$PASS" \
    --argjson warn "$WARN" \
    --argjson block "$BLOCK" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg status "$STATUS" \
    '{timestamp: $ts, status: $status, pass: $pass, warn: $warn, block: $block}' \
    > "$REPORT_FILE" 2>/dev/null || true
fi

[[ $BLOCK -gt 0 ]] && exit 1
exit 0
