#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
CONFIG_FILE="$CLAUDE_DIR/praxis.config.json"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

PRAXIS_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS_CONFIG="$PRAXIS_DIR/base/hooks/settings-hooks.json"
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
  for rule in "$PRAXIS_DIR"/base/rules/*.md; do
    [[ -f "$rule" ]] || continue
    fname=$(basename "$rule")
    target="$CLAUDE_DIR/rules/$fname"
    if [[ -L "$target" || "$fname" == "profile.md" || "$fname" == "git-workflow.md" ]]; then
      if [[ -e "$target" || -L "$target" ]]; then
        rm -f "$target"
        RULES_REMOVED=$((RULES_REMOVED + 1))
      fi
    fi
  done
fi
echo -e "  ${GREEN}✓${NC} $RULES_REMOVED Praxis rule files"

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
  for skill_dir in "$PRAXIS_DIR"/base/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    target="$CLAUDE_DIR/skills/$skill_name"
    if [[ -L "$target" ]]; then
      rm "$target"
      SKILLS_REMOVED=$((SKILLS_REMOVED + 1))
    fi
  done
fi
echo -e "  ${GREEN}✓${NC} $SKILLS_REMOVED skill symlinks"

HOOKS_REMOVED=0
if [[ -d "$CLAUDE_DIR/hooks" ]]; then
  for hook in "$PRAXIS_DIR"/base/hooks/*.sh; do
    [[ -f "$hook" ]] || continue
    fname=$(basename "$hook")
    target="$CLAUDE_DIR/hooks/$fname"
    if [[ -L "$target" ]]; then
      rm "$target"
      HOOKS_REMOVED=$((HOOKS_REMOVED + 1))
    fi
  done
fi
echo -e "  ${GREEN}✓${NC} $HOOKS_REMOVED hook symlinks"

if [[ -L "$CLAUDE_DIR/configs" ]]; then
  rm "$CLAUDE_DIR/configs"
  echo -e "  ${GREEN}✓${NC} configs/"
fi

if [[ -f "$SETTINGS_FILE" && -f "$HOOKS_CONFIG" ]]; then
  if jq --slurpfile praxis "$HOOKS_CONFIG" '
      ($praxis[0].hooks | [.. | .command? // empty] | map(select(length > 0))) as $commands
      | if (.hooks | type) == "object" then
          .hooks |= with_entries(
          .value |= (
              map(
                if (.hooks | type) == "array" then
                  .hooks |= map(select(.command as $cmd | ($commands | index($cmd) | not)))
                else
                  .
                end
              )
              | map(select(((.hooks // []) | length) > 0))
            )
          )
          | .hooks |= with_entries(select(.value | length > 0))
          | if (.hooks | length) == 0 then del(.hooks) else . end
        else
          .
        end
    ' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"; then
    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo -e "  ${GREEN}✓${NC} settings.json hook entries"
  else
    rm -f "$SETTINGS_FILE.tmp"
    echo -e "  ${YELLOW}⚠${NC} Could not clean Praxis hooks from settings.json"
  fi
fi

rm "$CONFIG_FILE"
echo -e "  ${GREEN}✓${NC} praxis.config.json"

echo ""
echo -e "${GREEN}${BOLD}Praxis uninstalled.${NC}"
echo "  Repo preserved at: $REPO_PATH"
echo "  To reinstall: cd $REPO_PATH && ./install.sh"
echo ""
