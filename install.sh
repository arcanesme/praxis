#!/usr/bin/env bash
set -euo pipefail

# ════════════════════════════════════════════════════════════════
#  Praxis — Full Bootstrap
#  Clone repo → run this → start working
#  macOS and Linux. Installs all dependencies, links into ~/.claude/,
#  configures vault path, installs kits.
#
#  Install paths:
#    npx: npx praxis-harness → clones to ~/.praxis → runs this script
#    manual: git clone ... && cd praxis && bash install.sh
# ════════════════════════════════════════════════════════════════

PRAXIS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CONFIG_FILE="$CLAUDE_DIR/praxis.config.json"
LOG_FILE="$PRAXIS_DIR/.install.log"

# ─── Colors & output helpers ───
source "$PRAXIS_DIR/base/lib/output.sh"

# ─── Log everything ───
exec > >(tee -a "$LOG_FILE") 2>&1
echo "--- Install started $(date -u +"%Y-%m-%dT%H:%M:%SZ") ---"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Praxis — Bootstrap                      ║${NC}"
echo -e "${BOLD}║  Practice, not just study.               ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# ═══════════════════════════════════════════
# Phase 1: Prerequisites
# ═══════════════════════════════════════════
step "Phase 1: Prerequisites"

# ─── Platform detection ───
detect_platform() {
  case "$(uname -s)" in
    Darwin)
      PLATFORM="darwin"
      PKG_INSTALL="brew install"
      NODE_PKG="node"
      ;;
    Linux)
      PLATFORM="linux"
      if command -v apt-get &>/dev/null; then
        PKG_INSTALL="sudo apt-get install -y"
        NODE_PKG="nodejs"
      elif command -v dnf &>/dev/null; then
        PKG_INSTALL="sudo dnf install -y"
        NODE_PKG="nodejs"
      elif command -v yum &>/dev/null; then
        PKG_INSTALL="sudo yum install -y"
        NODE_PKG="nodejs"
      else
        fail "Linux detected but no supported package manager found (apt-get, dnf, yum)."
        exit 1
      fi
      ;;
    *)
      fail "Unsupported platform: $(uname -s). Praxis supports macOS and Linux."
      exit 1
      ;;
  esac
}

detect_platform
ok "$PLATFORM detected"

# ─── Create ~/.praxis/ secure directory ───
if [[ ! -d "$HOME/.praxis" ]]; then
  mkdir -p "$HOME/.praxis"
  chmod 700 "$HOME/.praxis"
  ok "Created $HOME/.praxis/ (secure storage)"
else
  ok "$HOME/.praxis/ exists"
fi

# ─── Homebrew (macOS only) ───
if [[ "$PLATFORM" == "darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
      export HOMEBREW_PREFIX="/opt/homebrew"
      export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
      export HOMEBREW_REPOSITORY="/opt/homebrew"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    fi
    ok "Homebrew installed"
  else
    ok "Homebrew found"
  fi
fi

if ! command -v jq &>/dev/null; then
  echo "  Installing jq..."
  $PKG_INSTALL jq
  ok "jq installed"
else
  ok "jq found"
fi

if ! command -v node &>/dev/null; then
  echo "  Installing Node.js..."
  $PKG_INSTALL $NODE_PKG
  ok "Node.js installed"
else
  NODE_VERSION=$(node -v)
  ok "Node.js found ($NODE_VERSION)"
fi

if ! command -v npm &>/dev/null; then
  fail "npm not found despite Node.js being installed."
  exit 1
fi
ok "npm found"

if ! command -v claude &>/dev/null; then
  echo "  Installing Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code
  if command -v claude &>/dev/null; then
    ok "Claude Code CLI installed"
  else
    fail "Claude Code CLI install failed. Run manually: npm install -g @anthropic-ai/claude-code"
    exit 1
  fi
else
  ok "Claude Code CLI found"
fi

# ═══════════════════════════════════════════
# Phase 2: Vault Configuration
# ═══════════════════════════════════════════
step "Phase 2: Vault Configuration"

VAULT_PATH=""
VAULT_BACKEND=""

# ─── Check existing config ───
if [[ -f "$CONFIG_FILE" ]]; then
  EXISTING_VAULT=$(jq -r '.vault_path // empty' "$CONFIG_FILE" 2>/dev/null)
  # shellcheck disable=SC2034  # EXISTING_BACKEND reserved for vault re-config prompts
  EXISTING_BACKEND=$(jq -r '.vault_backend // empty' "$CONFIG_FILE" 2>/dev/null)
  if [[ -n "$EXISTING_VAULT" && -d "$EXISTING_VAULT" ]]; then
    echo -e "  Existing vault: ${BOLD}$EXISTING_VAULT${NC}"
    read -p "  Keep this configuration? [Y/n] " KEEP_VAULT
    if [[ "${KEEP_VAULT:-Y}" =~ ^[Yy]$ ]]; then
      VAULT_PATH="$EXISTING_VAULT"
      VAULT_BACKEND="obsidian"
    fi
  fi
fi

# ─── Detect or prompt for vault backend and path ───
if [[ -z "$VAULT_PATH" ]]; then
  # Try to detect Obsidian
  OBSIDIAN_DETECTED=false
  if [[ "$PLATFORM" == "darwin" && -d "/Applications/Obsidian.app" ]]; then
    OBSIDIAN_DETECTED=true
  elif [[ "$PLATFORM" == "linux" ]]; then
    if command -v obsidian &>/dev/null || \
       flatpak list 2>/dev/null | grep -qi obsidian || \
       snap list 2>/dev/null | grep -qi obsidian; then
      OBSIDIAN_DETECTED=true
    fi
  fi

  VAULT_BACKEND="obsidian"

  if [[ "$OBSIDIAN_DETECTED" == true ]]; then
    echo ""
    echo -e "  ${GREEN}Obsidian detected.${NC}"
  else
    echo ""
    warn "Obsidian not detected. Install Obsidian and enable the CLI."
  fi

  # Auto-detect vault path
  DETECTED=""
  CANDIDATES=(
    "$HOME/Documents/Obsidian"
    "$HOME/Obsidian"
    "$HOME/Documents/Vault"
  )
  if [[ "$PLATFORM" == "darwin" ]]; then
    CANDIDATES+=("$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents")
  fi
  for CANDIDATE in "${CANDIDATES[@]}"; do
    if [[ -d "$CANDIDATE" ]]; then
      DETECTED="$CANDIDATE"
      break
    fi
  done

  if [[ -n "$DETECTED" ]]; then
    echo -e "  Detected vault at: ${BOLD}$DETECTED${NC}"
    read -p "  Use this path? [Y/n] " USE_DETECTED
    if [[ "${USE_DETECTED:-Y}" =~ ^[Yy]$ ]]; then
      VAULT_PATH="$DETECTED"
    fi
  fi

  if [[ -z "$VAULT_PATH" ]]; then
    read -p "  Obsidian vault path: " VAULT_PATH
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"
  fi

  # Validate path exists or create it
  if [[ ! -d "$VAULT_PATH" ]]; then
    warn "Directory does not exist: $VAULT_PATH"
    read -p "  Create it? [y/N] " CREATE_VAULT
    if [[ "${CREATE_VAULT:-N}" =~ ^[Yy]$ ]]; then
      mkdir -p "$VAULT_PATH"
      ok "Created: $VAULT_PATH"
    else
      fail "Aborting. Create the directory first, then re-run install.sh"
      exit 1
    fi
  fi
fi

ok "Vault: $VAULT_PATH (backend: $VAULT_BACKEND)"

# ═══════════════════════════════════════════
# Phase 2b: Identity Configuration
# ═══════════════════════════════════════════
step "Phase 2b: Identity configuration"

# Read existing identity from config if available
if [[ -f "$CONFIG_FILE" ]]; then
  IDENTITY_NAME=$(jq -r '.identity.name // empty' "$CONFIG_FILE" 2>/dev/null)
  IDENTITY_ROLE=$(jq -r '.identity.role // empty' "$CONFIG_FILE" 2>/dev/null)
  IDENTITY_DOMAINS=$(jq -r '.identity.domains // empty' "$CONFIG_FILE" 2>/dev/null)
  WORK_EMAIL=$(jq -r '.identity.work.email // empty' "$CONFIG_FILE" 2>/dev/null)
  WORK_PATH_MATCH=$(jq -r '.identity.work.path_match // empty' "$CONFIG_FILE" 2>/dev/null)
  WORK_GITCONFIG=$(jq -r '.identity.work.gitconfig // empty' "$CONFIG_FILE" 2>/dev/null)
  WORK_SSH_KEY=$(jq -r '.identity.work.ssh_key // empty' "$CONFIG_FILE" 2>/dev/null)
  PERSONAL_EMAIL=$(jq -r '.identity.personal.email // empty' "$CONFIG_FILE" 2>/dev/null)
  PERSONAL_PATH_MATCH=$(jq -r '.identity.personal.path_match // empty' "$CONFIG_FILE" 2>/dev/null)
  PERSONAL_GITCONFIG=$(jq -r '.identity.personal.gitconfig // empty' "$CONFIG_FILE" 2>/dev/null)
  PERSONAL_SSH_KEY=$(jq -r '.identity.personal.ssh_key // empty' "$CONFIG_FILE" 2>/dev/null)
fi

if [[ -n "${IDENTITY_NAME:-}" ]]; then
  echo -e "  Existing identity found: ${BOLD}$IDENTITY_NAME${NC}"
  read -p "  Keep existing identity? [Y/n] " KEEP_IDENTITY
  if [[ "${KEEP_IDENTITY:-Y}" =~ ^[Yy]$ ]]; then
    ok "Identity preserved from existing config"
  else
    IDENTITY_NAME=""
  fi
fi

if [[ -z "${IDENTITY_NAME:-}" ]]; then
  echo ""
  echo -e "  ${BOLD}Configure your identity${NC} (stored in ~/.claude/praxis.config.json — never committed)"
  echo ""
  read -p "  Your name: " IDENTITY_NAME
  read -p "  Your role (e.g., Solutions Architect): " IDENTITY_ROLE
  read -p "  Focus domains (e.g., cloud, security, DevOps): " IDENTITY_DOMAINS
  echo ""
  echo -e "  ${BOLD}Work identity${NC}"
  read -p "  Work email: " WORK_EMAIL
  read -p "  Work path match (e.g., Projects/Work): " WORK_PATH_MATCH
  read -p "  Work gitconfig path [~/.gitconfig-work]: " WORK_GITCONFIG
  WORK_GITCONFIG="${WORK_GITCONFIG:-~/.gitconfig-work}"
  read -p "  Work SSH key [~/.ssh/id_ed25519_work]: " WORK_SSH_KEY
  WORK_SSH_KEY="${WORK_SSH_KEY:-~/.ssh/id_ed25519_work}"
  echo ""
  echo -e "  ${BOLD}Personal identity${NC}"
  read -p "  Personal email: " PERSONAL_EMAIL
  read -p "  Personal path match (e.g., Projects/Personal): " PERSONAL_PATH_MATCH
  read -p "  Personal gitconfig path [~/.gitconfig-personal]: " PERSONAL_GITCONFIG
  PERSONAL_GITCONFIG="${PERSONAL_GITCONFIG:-~/.gitconfig-personal}"
  read -p "  Personal SSH key [~/.ssh/id_ed25519]: " PERSONAL_SSH_KEY
  PERSONAL_SSH_KEY="${PERSONAL_SSH_KEY:-~/.ssh/id_ed25519}"
  ok "Identity configured"
fi

# Template generation function — substitutes {identity.*} placeholders from collected values
generate_from_template() {
  local template="$1"
  local output="$2"
  local content
  content=$(cat "$template")

  # Replace all identity placeholders
  content="${content//\{identity.name\}/${IDENTITY_NAME:-Your Name}}"
  content="${content//\{identity.role\}/${IDENTITY_ROLE:-Your Role}}"
  content="${content//\{identity.domains\}/${IDENTITY_DOMAINS:-your domains}}"
  content="${content//\{identity.work.email\}/${WORK_EMAIL:-you@company.com}}"
  content="${content//\{identity.work.path_match\}/${WORK_PATH_MATCH:-Projects/Work}}"
  content="${content//\{identity.work.gitconfig\}/${WORK_GITCONFIG:-~/.gitconfig-work}}"
  content="${content//\{identity.work.ssh_key\}/${WORK_SSH_KEY:-~/.ssh/id_ed25519_work}}"
  content="${content//\{identity.personal.email\}/${PERSONAL_EMAIL:-you@personal.com}}"
  content="${content//\{identity.personal.path_match\}/${PERSONAL_PATH_MATCH:-Projects/Personal}}"
  content="${content//\{identity.personal.gitconfig\}/${PERSONAL_GITCONFIG:-~/.gitconfig-personal}}"
  content="${content//\{identity.personal.ssh_key\}/${PERSONAL_SSH_KEY:-~/.ssh/id_ed25519}}"

  echo "$content" > "$output"
}

# ═══════════════════════════════════════════
# Phase 3: Link Base Layer
# ═══════════════════════════════════════════
step "Phase 3: Linking base layer into ~/.claude/"

mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/rules"
mkdir -p "$CLAUDE_DIR/skills"

# CLAUDE.md
ln -sf "$PRAXIS_DIR/base/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
ok "CLAUDE.md linked"

# Rules — symlink most, generate identity-bearing files from templates
RULES_LINKED=0
RULES_GENERATED=0
if [[ -d "$PRAXIS_DIR/base/rules" ]]; then
  for rule in "$PRAXIS_DIR"/base/rules/*.md; do
    [[ -f "$rule" ]] || continue
    fname=$(basename "$rule")
    case "$fname" in
      profile.md|git-workflow.md)
        # Generate from template with identity values
        generate_from_template "$rule" "$CLAUDE_DIR/rules/$fname"
        RULES_GENERATED=$((RULES_GENERATED + 1))
        ;;
      *)
        ln -sf "$rule" "$CLAUDE_DIR/rules/$fname"
        RULES_LINKED=$((RULES_LINKED + 1))
        ;;
    esac
  done
fi
ok "$RULES_LINKED rules linked, $RULES_GENERATED generated from templates"

# Skills (commands are now consolidated into skills)
SKILLS_LINKED=0
if [[ -d "$PRAXIS_DIR/base/skills" ]]; then
  for skill_dir in "$PRAXIS_DIR"/base/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    ln -sf "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
    SKILLS_LINKED=$((SKILLS_LINKED + 1))
  done
fi
ok "$SKILLS_LINKED skills linked"

# Kits
ln -sf "$PRAXIS_DIR/kits" "$CLAUDE_DIR/kits"
ok "Kits directory linked"

# Hooks
HOOKS_LINKED=0
mkdir -p "$CLAUDE_DIR/hooks"
if [[ -d "$PRAXIS_DIR/base/hooks" ]]; then
  for hook in "$PRAXIS_DIR"/base/hooks/*.sh; do
    [[ -f "$hook" ]] || continue
    fname=$(basename "$hook")
    ln -sf "$hook" "$CLAUDE_DIR/hooks/$fname"
    HOOKS_LINKED=$((HOOKS_LINKED + 1))
  done
fi
ok "$HOOKS_LINKED hooks linked"

# Configs (linter reference configs)
if [[ -d "$PRAXIS_DIR/base/configs" ]]; then
  ln -sf "$PRAXIS_DIR/base/configs" "$CLAUDE_DIR/configs"
  ok "Configs directory linked"
fi

# Merge hook configuration into settings.json
HOOKS_CONFIG="$PRAXIS_DIR/base/hooks/settings-hooks.json"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [[ -f "$HOOKS_CONFIG" ]]; then
  if [[ -f "$SETTINGS_FILE" ]]; then
    # Merge hooks key into existing settings (preserves other settings)
    jq -s '.[0] * .[1]' "$SETTINGS_FILE" "$HOOKS_CONFIG" > "${SETTINGS_FILE}.tmp" \
      && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
    ok "Hook configuration merged into settings.json"
  else
    cp "$HOOKS_CONFIG" "$SETTINGS_FILE"
    ok "Hook configuration created in settings.json"
  fi
fi

# Orphan cleanup
for orphan in obsidian.md code-quality.md security.md communication.md architecture.md; do
  if [[ -e "$CLAUDE_DIR/rules/$orphan" ]]; then
    rm -f "$CLAUDE_DIR/rules/$orphan"
    ok "Removed legacy $orphan"
  fi
done

# ═══════════════════════════════════════════
# Phase 4: Install Universal Tools
# ═══════════════════════════════════════════
step "Phase 4: Installing universal tools"


if command -v obsidian &>/dev/null; then
  ok "Obsidian CLI available"
  # Detect vault name and store in config
  VAULT_NAME=$(obsidian vaults verbose 2>/dev/null | head -1 | cut -f1)
  if [[ -n "$VAULT_NAME" ]]; then
    ok "Vault detected: $VAULT_NAME"
    # Add vault_name to config
    if [[ -f "$CONFIG_FILE" ]]; then
      jq --arg vn "$VAULT_NAME" '.vault_name = $vn' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
  else
    warn "Could not detect vault name. Add vault_name to ~/.claude/praxis.config.json manually."
  fi
else
  warn "Obsidian CLI not found. Enable it in Obsidian Settings > General > Command line interface."
fi

mkdir -p "$HOME/bin"
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  warn "$HOME/bin is not in your PATH. Add to your shell profile:"
  echo '    export PATH="$HOME/bin:$PATH"'
fi

# ═══════════════════════════════════════════
# Phase 4b: MCP Servers (optional)
# ═══════════════════════════════════════════
step "Phase 4b: MCP Servers (optional)"

if [[ -f "$PRAXIS_DIR/scripts/onboard-mcp.sh" ]]; then
  echo "  MCP servers extend Claude Code with external capabilities:"
  echo "    • Context7    — live docs lookup (free, no API key)"
  echo "    • Perplexity  — AI web search (requires API key)"
  echo "    • GitHub      — repo operations (requires PAT)"
  echo ""
  read -p "  Set up MCP servers now? [Y/n] " SETUP_MCP
  if [[ "${SETUP_MCP:-Y}" =~ ^[Yy]$ ]]; then
    source "$PRAXIS_DIR/scripts/onboard-mcp.sh"
    onboard_context7          # auto, no key needed
    echo ""
    read -p "  Set up Perplexity? [y/N] " DO_PPLX
    [[ "${DO_PPLX:-N}" =~ ^[Yy]$ ]] && onboard_perplexity
    echo ""
    read -p "  Set up GitHub MCP? [y/N] " DO_GH
    [[ "${DO_GH:-N}" =~ ^[Yy]$ ]] && onboard_github
  else
    echo "  Run later: bash $PRAXIS_DIR/scripts/onboard-mcp.sh all"
  fi
fi

# ═══════════════════════════════════════════
# Phase 4c: Quality Tools (optional)
# ═══════════════════════════════════════════
step "Phase 4c: Quality tools (optional)"

echo "  Quality tools enhance Praxis linting:"
echo "    • shellcheck  — shell script linter"
echo "    • commitlint  — commit message format"
echo ""
read -rp "  Install quality tools? [y/N] " INSTALL_TOOLS
if [[ "${INSTALL_TOOLS:-N}" =~ ^[Yy] ]]; then
  if [[ -f "$PRAXIS_DIR/scripts/install-tools.sh" ]]; then
    bash "$PRAXIS_DIR/scripts/install-tools.sh"
  else
    warn "install-tools.sh not found — skipping"
  fi
else
  echo "  Run later: bash $PRAXIS_DIR/scripts/install-tools.sh"
fi

# ═══════════════════════════════════════════
# Phase 5: Install Kit Dependencies
# ═══════════════════════════════════════════
step "Phase 5: Kit dependencies"

KITS_DIR="$PRAXIS_DIR/kits"
INSTALLED_KITS=()

if [[ -d "$KITS_DIR" ]]; then
  for kit_dir in "$KITS_DIR"/*/; do
    [[ -d "$kit_dir" ]] || continue
    kit_name=$(basename "$kit_dir")

    if [[ -f "$kit_dir/install.sh" ]]; then
      echo -e "  Found kit: ${BOLD}$kit_name${NC}"
      read -p "  Install $kit_name dependencies? [Y/n] " INSTALL_KIT
      if [[ "${INSTALL_KIT:-Y}" =~ ^[Yy]$ ]]; then
        echo "  Installing $kit_name..."
        if bash "$kit_dir/install.sh" 2>>"$LOG_FILE"; then
          ok "$kit_name dependencies installed"
          INSTALLED_KITS+=("$kit_name")
        else
          warn "$kit_name install had errors. Check $LOG_FILE"
        fi
      else
        echo "  Skipped. Install later: $kit_dir/install.sh"
      fi
    fi
  done
fi

if [[ ${#INSTALLED_KITS[@]} -eq 0 ]]; then
  echo "  No kits installed (none available yet or all skipped)"
fi

# ═══════════════════════════════════════════
# Phase 6: Vault Templates
# ═══════════════════════════════════════════
step "Phase 6: Vault setup"

if [[ -d "$PRAXIS_DIR/templates" ]] && [[ -n "$(ls -A "$PRAXIS_DIR/templates" 2>/dev/null)" ]]; then
  read -p "  Copy vault templates to $VAULT_PATH/04_Templates/? [Y/n] " COPY_TEMPLATES
  if [[ "${COPY_TEMPLATES:-Y}" =~ ^[Yy]$ ]]; then
    mkdir -p "$VAULT_PATH/04_Templates"
    cp -n "$PRAXIS_DIR"/templates/* "$VAULT_PATH/04_Templates/" 2>/dev/null || true
    ok "Templates copied (existing files preserved)"
  fi
else
  echo "  No templates to copy"
fi

# ═══════════════════════════════════════════
# Phase 7: Write Config
# ═══════════════════════════════════════════
step "Phase 7: Writing config"

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
KITS_JSON=$(printf '%s\n' "${INSTALLED_KITS[@]:-}" | jq -R . | jq -s .)

PRAXIS_VERSION=$(node -p "require('$PRAXIS_DIR/package.json').version" 2>/dev/null || echo "unknown")

# Build identity JSON block
IDENTITY_JSON=$(cat <<IEOF
{
  "name": "${IDENTITY_NAME:-}",
  "role": "${IDENTITY_ROLE:-}",
  "domains": "${IDENTITY_DOMAINS:-}",
  "work": {
    "email": "${WORK_EMAIL:-}",
    "path_match": "${WORK_PATH_MATCH:-}",
    "gitconfig": "${WORK_GITCONFIG:-}",
    "ssh_key": "${WORK_SSH_KEY:-}"
  },
  "personal": {
    "email": "${PERSONAL_EMAIL:-}",
    "path_match": "${PERSONAL_PATH_MATCH:-}",
    "gitconfig": "${PERSONAL_GITCONFIG:-}",
    "ssh_key": "${PERSONAL_SSH_KEY:-}"
  }
}
IEOF
)

if [[ -f "$CONFIG_FILE" ]]; then
  jq --arg vp "$VAULT_PATH" \
     --arg rp "$PRAXIS_DIR" \
     --arg vb "$VAULT_BACKEND" \
     --arg ver "$PRAXIS_VERSION" \
     --arg now "$NOW" \
     --argjson kits "$KITS_JSON" \
     --argjson identity "$IDENTITY_JSON" \
    '.vault_path = $vp | .vault_backend = $vb | .repo_path = $rp | .version = $ver | .installed_kits = $kits | .identity = $identity | .updated_at = $now' \
    "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
else
  cat > "$CONFIG_FILE" <<EOF
{
  "version": "$PRAXIS_VERSION",
  "vault_path": "$VAULT_PATH",
  "vault_backend": "$VAULT_BACKEND",
  "repo_path": "$PRAXIS_DIR",
  "installed_kits": $KITS_JSON,
  "identity": $IDENTITY_JSON,
  "installed_at": "$NOW",
  "updated_at": "$NOW"
}
EOF
fi

ok "Config: $CONFIG_FILE"

# ═══════════════════════════════════════════
# Phase 8: Verification
# ═══════════════════════════════════════════
step "Phase 8: Verification"

PASS=0
TOTAL=0

verify() {
  local label="$2"
  TOTAL=$((TOTAL + 1))
  if "$@" &>/dev/null; then
    ok "$label"
    PASS=$((PASS + 1))
  else
    fail "$label"
  fi
}

check_link()   { [[ -L "$1" ]]; }
check_dir()    { [[ -d "$1" ]]; }
check_file()   { [[ -f "$1" ]]; }
check_jq()     { jq -e "$1" "$2" >/dev/null 2>&1; }
check_cmd()    { command -v "$1" &>/dev/null; }

verify check_link "$CLAUDE_DIR/CLAUDE.md"            "CLAUDE.md symlinked"
verify check_dir  "$CLAUDE_DIR/rules"                "Rules directory exists"
verify check_dir  "$CLAUDE_DIR/skills"               "Skills directory exists"
verify check_link "$CLAUDE_DIR/kits"                 "Kits directory symlinked"
verify check_dir  "$CLAUDE_DIR/hooks"                "Hooks directory exists"
verify check_file "$CLAUDE_DIR/settings.json"        "Settings with hooks configured"
verify check_file "$CONFIG_FILE"                     "Config file exists"
verify check_jq   '.vault_path' "$CONFIG_FILE"       "Vault path in config"
verify check_jq   '.identity.name' "$CONFIG_FILE"    "Identity configured"
verify check_dir  "$VAULT_PATH"                      "Vault directory accessible"
verify check_cmd  claude                             "Claude Code CLI available"
verify check_cmd  node                               "Node.js available"
verify check_cmd  jq                                 "jq available"

echo ""
echo -e "  Checks: ${BOLD}$PASS/$TOTAL passed${NC}"

# MCP status (warn only, not counted as failures)
echo ""
echo "  MCP Servers:"
if command -v claude &>/dev/null; then
  MCP_LIST=$(claude mcp list 2>/dev/null || true)
  for srv in context7 github; do
    if echo "$MCP_LIST" | grep -q "$srv"; then
      ok "$srv MCP registered"
    else
      warn "$srv MCP — not configured (run: bash scripts/onboard-mcp.sh $srv)"
    fi
  done
else
  warn "claude CLI not available — cannot check MCP servers"
fi

if [[ -f "$PRAXIS_DIR/scripts/health-check.sh" ]]; then
  echo ""
  step "Running health check..."
  bash "$PRAXIS_DIR/scripts/health-check.sh" || warn "Health check had failures — review above"
fi

if [[ -x "$PRAXIS_DIR/bin/praxis-preflight.sh" ]]; then
  echo ""
  step "Running preflight check..."
  bash "$PRAXIS_DIR/bin/praxis-preflight.sh" || warn "Preflight had blocking failures — run 'praxis doctor' to review"
fi

# ═══════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Bootstrap complete                      ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Repo:    ${BOLD}$PRAXIS_DIR${NC}"
echo -e "  Claude:  ${BOLD}$CLAUDE_DIR${NC}"
echo -e "  Vault:   ${BOLD}$VAULT_PATH${NC}"
echo -e "  Config:  ${BOLD}$CONFIG_FILE${NC}"
echo -e "  Log:     ${BOLD}$LOG_FILE${NC}"

echo ""
echo -e "${YELLOW}${BOLD}Manual steps remaining:${NC}"
echo ""
echo "  Open Claude Code and run these commands:"
echo ""
echo -e "  ${CYAN}# Verify everything loaded${NC}"
echo "  /help"
echo ""
echo "  You should see Praxis skills (/px-discuss, /px-plan, /px-execute, /px-verify, /px-ship, /px-kit:*)."
echo ""
echo -e "${GREEN}${BOLD}  Then: /px-kit:list to see available kits.${NC}"
echo ""
echo -e "  ${YELLOW}Note:${NC} Identity is stored in ${BOLD}~/.claude/praxis.config.json${NC} (never committed)."
echo "  Re-run install.sh to update identity or sync to a new machine."
echo ""
