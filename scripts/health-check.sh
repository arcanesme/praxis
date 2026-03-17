#!/bin/bash
set -euo pipefail

# ════════════════════════════════════════════════════════════════
#  Praxis — Health Check
#  Verifies install integrity: symlinks, config, tools, base layer
# ════════════════════════════════════════════════════════════════

CLAUDE_DIR="$HOME/.claude"
CONFIG_FILE="$CLAUDE_DIR/praxis.config.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PRAXIS_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0
FAIL=0
TOTAL=0

check() {
  TOTAL=$((TOTAL + 1))
  if eval "$1" 2>/dev/null; then
    echo "  ✓ $2"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $2"
    FAIL=$((FAIL + 1))
  fi
}

echo "Praxis Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── CLAUDE.md symlink ───
echo ""
echo "Core:"
check "[[ -e '$CLAUDE_DIR/CLAUDE.md' ]]" "CLAUDE.md installed"

# ─── Rules symlinks ───
echo ""
echo "Rules:"
if [[ -d "$PRAXIS_DIR/base/rules" ]]; then
  for rule in "$PRAXIS_DIR"/base/rules/*.md; do
    [[ -f "$rule" ]] || continue
    fname=$(basename "$rule")
    check "[[ -e '$CLAUDE_DIR/rules/$fname' ]]" "rules/$fname installed"
  done
fi

# ─── Commands symlinks ───
echo ""
echo "Commands:"
if [[ -d "$PRAXIS_DIR/base/commands" ]]; then
  for cmd in "$PRAXIS_DIR"/base/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    fname=$(basename "$cmd")
    check "[[ -e '$CLAUDE_DIR/commands/$fname' ]]" "commands/$fname installed"
  done
fi

# ─── Skills symlinks ───
echo ""
echo "Skills:"
if [[ -d "$PRAXIS_DIR/base/skills" ]]; then
  for skill_dir in "$PRAXIS_DIR"/base/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    check "[[ -e '$CLAUDE_DIR/skills/$skill_name' ]]" "skills/$skill_name installed"
  done
fi

# ─── Kits symlink ───
echo ""
echo "Kits:"
check "[[ -e '$CLAUDE_DIR/kits' ]]" "kits directory installed"

# ─── Config ───
echo ""
echo "Config:"
check "[[ -f '$CONFIG_FILE' ]]" "praxis.config.json exists"

if [[ -f "$CONFIG_FILE" ]]; then
  VAULT_PATH=$(jq -r '.vault_path // empty' "$CONFIG_FILE" 2>/dev/null)
  if [[ -n "$VAULT_PATH" ]]; then
    check "[[ -d '$VAULT_PATH' ]]" "vault_path ($VAULT_PATH) is a real directory"
  else
    TOTAL=$((TOTAL + 1))
    echo "  ✗ vault_path not set in config"
    FAIL=$((FAIL + 1))
  fi
fi

# ─── Required tools (conditional on backend) ───
echo ""
echo "Tools:"
VAULT_BACKEND=""
if [[ -f "$CONFIG_FILE" ]]; then
  VAULT_BACKEND=$(jq -r '.vault_backend // "obsidian"' "$CONFIG_FILE" 2>/dev/null)
fi
if [[ "$VAULT_BACKEND" == "obsidian" || "$VAULT_BACKEND" == "logseq" ]]; then
  check "command -v qmd" "qmd available"
else
  check "command -v rg" "ripgrep available"
fi
check "command -v node" "node available"
check "command -v claude" "claude available"
check "command -v jq" "jq available"

# ─── MCP Servers (warn only) ───
echo ""
echo "MCP Servers:"
if command -v claude &>/dev/null; then
  MCP_LIST=$(claude mcp list 2>/dev/null || true)
  for server in context7 perplexity github; do
    TOTAL=$((TOTAL + 1))
    if echo "$MCP_LIST" | grep -q "$server"; then
      echo "  ✓ $server registered"
      PASS=$((PASS + 1))
    else
      echo "  ⚠ $server not registered (optional)"
      PASS=$((PASS + 1))  # optional = pass either way
    fi
  done
else
  echo "  ⚠ claude CLI not available — cannot check MCP servers"
fi

# ─── Broken symlinks (relevant for git-clone/symlink installs) ───
echo ""
echo "Symlink integrity:"
BROKEN=0
for dir in "$CLAUDE_DIR/rules" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills"; do
  if [[ -d "$dir" ]]; then
    while IFS= read -r link; do
      if [[ -L "$link" && ! -e "$link" ]]; then
        echo "  ✗ Broken symlink: $link"
        BROKEN=$((BROKEN + 1))
      fi
    done < <(find "$dir" -maxdepth 1 -type l 2>/dev/null)
  fi
done

TOTAL=$((TOTAL + 1))
if [[ $BROKEN -eq 0 ]]; then
  echo "  ✓ No broken symlinks"
  PASS=$((PASS + 1))
else
  echo "  ✗ $BROKEN broken symlink(s) found"
  FAIL=$((FAIL + 1))
fi

# ─── Summary ───
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: $PASS/$TOTAL passed"
if [[ $FAIL -gt 0 ]]; then
  echo "  $FAIL check(s) failed"
  exit 1
else
  echo "  All checks passed"
  exit 0
fi
