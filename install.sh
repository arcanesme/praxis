#!/bin/bash
set -euo pipefail

# ════════════════════════════════════════════════════════════════
#  Praxis — Full Bootstrap
#  Clone repo → run this → start working
#  macOS only. Installs all dependencies, links into ~/.claude/,
#  configures vault path, installs kits.
# ════════════════════════════════════════════════════════════════

PRAXIS_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CONFIG_FILE="$CLAUDE_DIR/praxis.config.json"
LOG_FILE="$PRAXIS_DIR/.install.log"

# ─── Colors ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
step() { echo -e "\n${CYAN}${BOLD}$1${NC}"; }

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

if [[ "$(uname)" != "Darwin" ]]; then
  fail "This installer supports macOS only."
  exit 1
fi
ok "macOS detected"

if ! command -v brew &>/dev/null; then
  echo "  Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  ok "Homebrew found"
fi

if ! command -v jq &>/dev/null; then
  echo "  Installing jq..."
  brew install jq
  ok "jq installed"
else
  ok "jq found"
fi

if ! command -v node &>/dev/null; then
  echo "  Installing Node.js..."
  brew install node
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

if [[ -f "$CONFIG_FILE" ]]; then
  EXISTING_VAULT=$(jq -r '.vault_path // empty' "$CONFIG_FILE" 2>/dev/null)
  if [[ -n "$EXISTING_VAULT" && -d "$EXISTING_VAULT" ]]; then
    echo -e "  Existing vault: ${BOLD}$EXISTING_VAULT${NC}"
    read -p "  Keep this path? [Y/n] " KEEP_VAULT
    if [[ "${KEEP_VAULT:-Y}" =~ ^[Yy]$ ]]; then
      VAULT_PATH="$EXISTING_VAULT"
    fi
  fi
fi

if [[ -z "$VAULT_PATH" ]]; then
  echo ""
  echo "  Where is your Obsidian vault?"
  echo "  This is the root folder containing your vault."
  echo ""

  DETECTED=""
  for CANDIDATE in \
    "$HOME/Documents/Obsidian" \
    "$HOME/Obsidian" \
    "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents" \
    "$HOME/Documents/Vault"; do
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
    read -p "  Vault path: " VAULT_PATH
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

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
fi

ok "Vault: $VAULT_PATH"

# ═══════════════════════════════════════════
# Phase 3: Link Base Layer
# ═══════════════════════════════════════════
step "Phase 3: Linking base layer into ~/.claude/"

mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/rules"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills"

# CLAUDE.md
ln -sf "$PRAXIS_DIR/base/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
ok "CLAUDE.md linked"

# Rules
RULES_LINKED=0
if [[ -d "$PRAXIS_DIR/base/rules" ]]; then
  for rule in "$PRAXIS_DIR"/base/rules/*.md; do
    [[ -f "$rule" ]] || continue
    fname=$(basename "$rule")
    ln -sf "$rule" "$CLAUDE_DIR/rules/$fname"
    RULES_LINKED=$((RULES_LINKED + 1))
  done
fi
ok "$RULES_LINKED rules linked"

# Commands
CMDS_LINKED=0
if [[ -d "$PRAXIS_DIR/base/commands" ]]; then
  for cmd in "$PRAXIS_DIR"/base/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    fname=$(basename "$cmd")
    ln -sf "$cmd" "$CLAUDE_DIR/commands/$fname"
    CMDS_LINKED=$((CMDS_LINKED + 1))
  done
fi
ok "$CMDS_LINKED commands linked"

# Skills
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

# ═══════════════════════════════════════════
# Phase 4: Install Universal Tools
# ═══════════════════════════════════════════
step "Phase 4: Installing universal tools"

echo "  Installing GSD (Get Shit Done)..."
if npx get-shit-done-cc --claude --global 2>>"$LOG_FILE"; then
  ok "GSD installed"
else
  warn "GSD auto-install failed. Install manually:"
  echo "    npx get-shit-done-cc --claude --global"
fi

mkdir -p "$HOME/bin"
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  warn "~/bin is not in your PATH. Add to your shell profile:"
  echo '    export PATH="$HOME/bin:$PATH"'
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

if [[ -f "$CONFIG_FILE" ]]; then
  jq --arg vp "$VAULT_PATH" \
     --arg rp "$PRAXIS_DIR" \
     --arg now "$NOW" \
     --argjson kits "$KITS_JSON" \
    '.vault_path = $vp | .repo_path = $rp | .installed_kits = $kits | .updated_at = $now' \
    "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
else
  cat > "$CONFIG_FILE" <<EOF
{
  "version": "1.0.0",
  "vault_path": "$VAULT_PATH",
  "repo_path": "$PRAXIS_DIR",
  "installed_kits": $KITS_JSON,
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
  TOTAL=$((TOTAL + 1))
  if eval "$1" &>/dev/null; then
    ok "$2"
    PASS=$((PASS + 1))
  else
    fail "$2"
  fi
}

verify "[[ -L '$CLAUDE_DIR/CLAUDE.md' ]]"           "CLAUDE.md symlinked"
verify "[[ -d '$CLAUDE_DIR/rules' ]]"                "Rules directory exists"
verify "[[ -L '$CLAUDE_DIR/kits' ]]"                 "Kits directory symlinked"
verify "[[ -f '$CONFIG_FILE' ]]"                     "Config file exists"
verify "jq -e '.vault_path' '$CONFIG_FILE'"          "Vault path in config"
verify "[[ -d '$VAULT_PATH' ]]"                      "Vault directory accessible"
verify "command -v claude"                           "Claude Code CLI available"
verify "command -v node"                             "Node.js available"
verify "command -v jq"                               "jq available"

echo ""
echo -e "  Checks: ${BOLD}$PASS/$TOTAL passed${NC}"

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
echo -e "  ${CYAN}# Superpowers (quality enforcement)${NC}"
echo "  /plugin marketplace add obra/superpowers-marketplace"
echo "  /plugin install superpowers@superpowers-marketplace"
echo ""
echo -e "  ${CYAN}# Ralph (autonomous execution)${NC}"
echo "  /plugin marketplace add snarktank/ralph"
echo "  /plugin install ralph-skills@ralph-marketplace"
echo ""
echo -e "  ${CYAN}# Verify everything loaded${NC}"
echo "  /help"
echo ""
echo "  You should see GSD commands (/gsd:*), Superpowers"
echo "  commands (/superpowers:*), and kit command (/kit:*)."
echo ""
echo -e "${GREEN}${BOLD}  Then: /kit:list to see available kits.${NC}"
echo ""
