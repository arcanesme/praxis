#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
CONFIG_FILE="$CLAUDE_DIR/praxis.config.json"

PRAXIS_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$PRAXIS_DIR/base/lib/output.sh"

echo ""
echo -e "${BOLD}Praxis — Uninstall${NC}"
echo ""

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "No Praxis installation found."
  exit 0
fi

REPO_PATH=$(jq -r '.repo_path' "$CONFIG_FILE")
VAULT_PATH=$(jq -r '.vault_path' "$CONFIG_FILE")

echo "This will:"
echo "  • Remove all Praxis symlinks from $CLAUDE_DIR"
echo "  • Remove praxis.config.json"
echo ""
echo "This will NOT:"
echo "  • Delete the repo at $REPO_PATH"
echo "  • Delete vault templates at $VAULT_PATH"
echo "  • Uninstall any Claude Code plugins"
echo "  • Remove any non-Praxis files from $CLAUDE_DIR"
echo ""
read -p "Continue? [y/N] " CONFIRM
if [[ ! "${CONFIRM:-N}" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "Removing symlinks..."

if [[ -L "$CLAUDE_DIR/CLAUDE.md" ]]; then
  rm "$CLAUDE_DIR/CLAUDE.md"
  echo -e "  ${GREEN}✓${NC} CLAUDE.md"
fi

if [[ -L "$CLAUDE_DIR/kits" ]]; then
  rm "$CLAUDE_DIR/kits"
  echo -e "  ${GREEN}✓${NC} kits/"
fi

RULES_REMOVED=0
if [[ -d "$CLAUDE_DIR/rules" ]]; then
  while IFS= read -r -d '' link; do
    rm "$link"
    RULES_REMOVED=$((RULES_REMOVED + 1))
  done < <(find "$CLAUDE_DIR/rules" -type l -print0 2>/dev/null)
fi
echo -e "  ${GREEN}✓${NC} $RULES_REMOVED rule symlinks"

CMDS_REMOVED=0
if [[ -d "$CLAUDE_DIR/commands" ]]; then
  while IFS= read -r -d '' link; do
    rm "$link"
    CMDS_REMOVED=$((CMDS_REMOVED + 1))
  done < <(find "$CLAUDE_DIR/commands" -type l -print0 2>/dev/null)
fi
echo -e "  ${GREEN}✓${NC} $CMDS_REMOVED command symlinks"

SKILLS_REMOVED=0
if [[ -d "$CLAUDE_DIR/skills" ]]; then
  while IFS= read -r -d '' link; do
    rm "$link"
    SKILLS_REMOVED=$((SKILLS_REMOVED + 1))
  done < <(find "$CLAUDE_DIR/skills" -maxdepth 1 -type l -print0 2>/dev/null)
fi
echo -e "  ${GREEN}✓${NC} $SKILLS_REMOVED skill symlinks"

rm "$CONFIG_FILE"
echo -e "  ${GREEN}✓${NC} praxis.config.json"

echo ""
echo -e "${GREEN}${BOLD}Praxis uninstalled.${NC}"
echo "  Repo preserved at: $REPO_PATH"
echo "  To reinstall: cd $REPO_PATH && ./install.sh"
echo ""
