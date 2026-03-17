#!/bin/bash
set -euo pipefail

# ════════════════════════════════════════════════════════════════
#  Praxis — MCP Server Onboarding
#  Configures cross-cutting MCP servers for Claude Code.
#  Can be sourced (install.sh) or run standalone.
#
#  Servers:
#    context7    — live library docs (free, no key)
#    perplexity  — AI web search (requires API key)
#    github      — repo operations (requires PAT)
#
#  Usage:
#    bash scripts/onboard-mcp.sh [context7|perplexity|github|all]
#    source scripts/onboard-mcp.sh  # then call functions directly
# ════════════════════════════════════════════════════════════════

# ─── Constants (match install.sh when sourced) ───
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
CONFIG_FILE="${CONFIG_FILE:-$CLAUDE_DIR/praxis.config.json}"

# ─── Colors (safe defaults if not already set) ───
RED="${RED:-\033[0;31m}"
GREEN="${GREEN:-\033[0;32m}"
YELLOW="${YELLOW:-\033[0;33m}"
CYAN="${CYAN:-\033[0;36m}"
BOLD="${BOLD:-\033[1m}"
NC="${NC:-\033[0m}"

# ─── Output helpers (no-op if already defined by install.sh) ───
if ! declare -f ok &>/dev/null; then
  ok()   { echo -e "  $GREEN✓$NC $1"; }
fi
if ! declare -f warn &>/dev/null; then
  warn() { echo -e "  $YELLOW⚠$NC $1"; }
fi
if ! declare -f fail &>/dev/null; then
  fail() { echo -e "  $RED✗$NC $1"; }
fi

# ═══════════════════════════════════════════
# Utilities
# ═══════════════════════════════════════════

mcp_server_exists() {
  local name="$1"
  claude mcp list 2>/dev/null | grep -q "$name"
}

open_url() {
  local url="$1"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    open "$url" 2>/dev/null || echo "  Open: $url"
  elif command -v xdg-open &>/dev/null; then
    xdg-open "$url" 2>/dev/null || echo "  Open: $url"
  else
    echo "  Open: $url"
  fi
}

update_mcp_status() {
  local key="$1"
  local val="$2"
  if [[ -f "$CONFIG_FILE" ]] && command -v jq &>/dev/null; then
    local tmp="$CONFIG_FILE.tmp"
    jq --arg k "$key" --arg v "$val" '.[$k] = $v' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
  fi
}

# ═══════════════════════════════════════════
# Server: Context7 — live library docs
# ═══════════════════════════════════════════

onboard_context7() {
  echo -e "  ${BOLD}Context7${NC} — live library/API documentation"

  # Check if running as Claude Code plugin (settings.json)
  local settings_file="$CLAUDE_DIR/settings.json"
  if [[ -f "$settings_file" ]] && command -v jq &>/dev/null; then
    if jq -e '.enabledPlugins // [] | map(select(contains("context7"))) | length > 0' "$settings_file" &>/dev/null; then
      ok "Context7 already active as Claude Code plugin (skipping MCP)"
      update_mcp_status "context7_status" "plugin"
      return 0
    fi
  fi

  # Check if already registered as MCP server
  if mcp_server_exists "context7"; then
    ok "Context7 MCP already registered"
    update_mcp_status "context7_status" "configured"
    return 0
  fi

  # Configure
  echo "  Registering Context7 MCP server..."
  if claude mcp add context7 -s user -- npx -y @upstash/context7-mcp 2>/dev/null; then
    # Verify
    if mcp_server_exists "context7"; then
      ok "Context7 MCP registered"
      update_mcp_status "context7_status" "configured"
    else
      warn "Context7 registered but not showing in mcp list"
      update_mcp_status "context7_status" "unverified"
    fi
  else
    fail "Context7 registration failed"
    echo "    Run manually: claude mcp add context7 -s user -- npx -y @upstash/context7-mcp"
    update_mcp_status "context7_status" "failed"
    return 1
  fi
}

# ═══════════════════════════════════════════
# Server: Perplexity — AI web search
# ═══════════════════════════════════════════

onboard_perplexity() {
  echo -e "  ${BOLD}Perplexity${NC} — AI-powered web search"

  # Check if already registered
  if mcp_server_exists "perplexity"; then
    echo -e "  Perplexity MCP is already registered."
    read -p "  Reconfigure? [y/N] " RECONFIG
    if [[ ! "${RECONFIG:-N}" =~ ^[Yy]$ ]]; then
      ok "Perplexity MCP — keeping existing config"
      return 0
    fi
    echo "  Removing existing config..."
    claude mcp remove perplexity 2>/dev/null || true
  fi

  # Acquire API key
  echo ""
  echo "  You need a Perplexity API key (starts with pplx-)."
  echo "  Opening API settings page..."
  open_url "https://www.perplexity.ai/settings/api"
  echo ""
  read -s -p "  Paste your Perplexity API key: " PPLX_KEY
  echo ""

  if [[ -z "$PPLX_KEY" ]]; then
    warn "No key entered — skipping Perplexity"
    update_mcp_status "perplexity_status" "skipped"
    return 0
  fi

  # Validate prefix
  if [[ ! "$PPLX_KEY" =~ ^pplx- ]]; then
    warn "Key doesn't start with 'pplx-' — this may not be a valid Perplexity key"
    read -p "  Continue anyway? [y/N] " CONTINUE
    if [[ ! "${CONTINUE:-N}" =~ ^[Yy]$ ]]; then
      unset PPLX_KEY
      update_mcp_status "perplexity_status" "skipped"
      return 0
    fi
  fi

  # Verify key with API
  echo "  Verifying API key..."
  local http_code
  local curl_fmt='%{http_code}'
  http_code=$(curl -s -o /dev/null -w "$curl_fmt" \
    -X POST "https://api.perplexity.ai/chat/completions" \
    -H "Authorization: Bearer $PPLX_KEY" \
    -H "Content-Type: application/json" \
    -d '{"model":"sonar","messages":[{"role":"user","content":"ping"}],"max_tokens":1}' \
    2>/dev/null || echo "000")

  if [[ "$http_code" == "200" ]]; then
    ok "API key verified"
  elif [[ "$http_code" == "000" ]]; then
    warn "Could not reach Perplexity API (network issue?) — proceeding anyway"
  else
    warn "API returned HTTP $http_code — key may be invalid"
    read -p "  Continue with this key? [y/N] " CONTINUE
    if [[ ! "${CONTINUE:-N}" =~ ^[Yy]$ ]]; then
      unset PPLX_KEY
      update_mcp_status "perplexity_status" "skipped"
      return 0
    fi
  fi

  # Configure
  echo "  Registering Perplexity MCP server..."
  if claude mcp add perplexity -s user -e PERPLEXITY_API_KEY="$PPLX_KEY" -- npx -y @pplx/mcp-server 2>/dev/null; then
    if mcp_server_exists "perplexity"; then
      ok "Perplexity MCP registered"
      update_mcp_status "perplexity_status" "configured"
    else
      warn "Perplexity registered but not showing in mcp list"
      update_mcp_status "perplexity_status" "unverified"
    fi
  else
    fail "Perplexity registration failed"
    echo "    Run manually: claude mcp add perplexity -s user -e PERPLEXITY_API_KEY=\"\$KEY\" -- npx -y @pplx/mcp-server"
    update_mcp_status "perplexity_status" "failed"
  fi

  # Clear key from memory
  unset PPLX_KEY
}

# ═══════════════════════════════════════════
# Server: GitHub — repo operations
# ═══════════════════════════════════════════

onboard_github() {
  echo -e "  ${BOLD}GitHub${NC} — repo operations, PRs, issues, code search"

  # Check if already registered
  if mcp_server_exists "github"; then
    echo -e "  GitHub MCP is already registered."
    read -p "  Reconfigure? [y/N] " RECONFIG
    if [[ ! "${RECONFIG:-N}" =~ ^[Yy]$ ]]; then
      ok "GitHub MCP — keeping existing config"
      return 0
    fi
    echo "  Removing existing config..."
    claude mcp remove github 2>/dev/null || true
  fi

  # Acquire PAT
  echo ""
  echo "  You need a GitHub Personal Access Token (starts with ghp_ or github_pat_)."
  echo "  Opening GitHub token settings..."
  open_url "https://github.com/settings/tokens"
  echo ""
  read -s -p "  Paste your GitHub PAT: " GH_TOKEN
  echo ""

  if [[ -z "$GH_TOKEN" ]]; then
    warn "No token entered — skipping GitHub"
    update_mcp_status "github_mcp_status" "skipped"
    return 0
  fi

  # Validate prefix
  if [[ ! "$GH_TOKEN" =~ ^(ghp_|github_pat_) ]]; then
    warn "Token doesn't start with 'ghp_' or 'github_pat_' — this may not be a valid PAT"
    read -p "  Continue anyway? [y/N] " CONTINUE
    if [[ ! "${CONTINUE:-N}" =~ ^[Yy]$ ]]; then
      unset GH_TOKEN
      update_mcp_status "github_mcp_status" "skipped"
      return 0
    fi
  fi

  # Verify token
  echo "  Verifying GitHub token..."
  local gh_user
  gh_user=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
    "https://api.github.com/user" 2>/dev/null | jq -r '.login // empty' 2>/dev/null || echo "")

  if [[ -n "$gh_user" ]]; then
    ok "Authenticated as: $gh_user"
  else
    warn "Could not verify token — proceeding anyway"
  fi

  # Configure
  echo "  Registering GitHub MCP server..."
  if claude mcp add github -s user -e GITHUB_PERSONAL_ACCESS_TOKEN="$GH_TOKEN" -- npx -y @modelcontextprotocol/server-github 2>/dev/null; then
    if mcp_server_exists "github"; then
      ok "GitHub MCP registered"
      update_mcp_status "github_mcp_status" "configured"
    else
      warn "GitHub registered but not showing in mcp list"
      update_mcp_status "github_mcp_status" "unverified"
    fi
  else
    fail "GitHub registration failed"
    echo "    Run manually: claude mcp add github -s user -e GITHUB_PERSONAL_ACCESS_TOKEN=\"\$TOKEN\" -- npx -y @modelcontextprotocol/server-github"
    update_mcp_status "github_mcp_status" "failed"
  fi

  # Clear token from memory
  unset GH_TOKEN
}

# ═══════════════════════════════════════════
# Entrypoint (standalone mode only)
# ═══════════════════════════════════════════

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  TARGET="${1:-all}"

  echo ""
  echo -e "${BOLD}Praxis — MCP Server Onboarding${NC}"
  echo ""

  if ! command -v claude &>/dev/null; then
    fail "Claude Code CLI not found. Install it first: npm install -g @anthropic-ai/claude-code"
    exit 1
  fi

  case "$TARGET" in
    context7)
      onboard_context7
      ;;
    perplexity)
      onboard_perplexity
      ;;
    github)
      onboard_github
      ;;
    all)
      onboard_context7
      echo ""
      read -p "  Set up Perplexity? [y/N] " DO_PPLX
      [[ "${DO_PPLX:-N}" =~ ^[Yy]$ ]] && onboard_perplexity
      echo ""
      read -p "  Set up GitHub MCP? [y/N] " DO_GH
      [[ "${DO_GH:-N}" =~ ^[Yy]$ ]] && onboard_github
      ;;
    *)
      echo "Usage: bash scripts/onboard-mcp.sh [context7|perplexity|github|all]"
      exit 1
      ;;
  esac

  echo ""
  echo -e "${BOLD}Current MCP servers:${NC}"
  claude mcp list 2>/dev/null || echo "  (none)"
  echo ""
fi
