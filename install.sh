#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CONFIG_FILE="${CLAUDE_DIR}/praxis.config.json"

echo "=== Praxis Installer ==="
echo ""

# Ensure ~/.claude exists
mkdir -p "${CLAUDE_DIR}"

# ── Symlink base assets ──────────────────────────────────────────────

symlink() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "$current" = "$src" ]; then
      echo "  ✓ ${dst} (already linked)"
      return
    fi
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "  ⚠ ${dst} exists and is not a symlink — skipping (back up manually)"
    return
  fi
  ln -s "$src" "$dst"
  echo "  → ${dst}"
}

echo "Linking base assets into ${CLAUDE_DIR}/ …"
symlink "${SCRIPT_DIR}/base/CLAUDE.md"  "${CLAUDE_DIR}/CLAUDE.md"
symlink "${SCRIPT_DIR}/base/rules"      "${CLAUDE_DIR}/rules"
symlink "${SCRIPT_DIR}/base/commands"   "${CLAUDE_DIR}/commands"
symlink "${SCRIPT_DIR}/base/skills"     "${CLAUDE_DIR}/skills"
echo ""

# ── Obsidian vault path ──────────────────────────────────────────────

if [ -f "$CONFIG_FILE" ]; then
  echo "Config already exists: ${CONFIG_FILE}"
  echo "  To reconfigure, delete it and re-run install.sh"
else
  read -rp "Obsidian vault path (e.g. ~/Documents/Obsidian): " vault_input

  # Expand ~ manually
  vault_path="${vault_input/#\~/$HOME}"

  if [ ! -d "$vault_path" ]; then
    echo "  ⚠ Directory does not exist: ${vault_path}"
    echo "  Writing config anyway — create the directory before using vault features."
  fi

  cat > "$CONFIG_FILE" <<EOF
{
  "vault_path": "${vault_path}"
}
EOF
  echo "  ✓ Wrote ${CONFIG_FILE}"
fi

echo ""
echo "=== Done ==="
echo "Run 'source ~/.bashrc' or restart your shell."
echo "To activate a kit: /kit:web-designer"
