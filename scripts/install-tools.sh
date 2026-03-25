#!/usr/bin/env bash
# install-tools.sh — Install Phase 1 quality tools
# Usage: bash scripts/install-tools.sh [--all | --go | --terraform | --core]
set -euo pipefail

INSTALL_GO=false
INSTALL_TF=false
INSTALL_CORE=true

for arg in "$@"; do
  case "$arg" in
    --all) INSTALL_GO=true; INSTALL_TF=true ;;
    --go) INSTALL_GO=true ;;
    --terraform) INSTALL_TF=true ;;
    --core) ;;
  esac
done

# Auto-detect if no flags
if [ $# -eq 0 ]; then
  command -v go &>/dev/null && INSTALL_GO=true
  command -v terraform &>/dev/null && INSTALL_TF=true
fi

echo "=== Praxis Quality Tools — Phase 1 ==="
echo "Core: always | Go: $INSTALL_GO | Terraform: $INSTALL_TF"
echo ""

# ── Detect package manager ──
if command -v brew &>/dev/null; then
  PKG="brew"
elif command -v apt-get &>/dev/null; then
  PKG="apt"
else
  echo "ERROR: Neither brew nor apt found. Install tools manually."
  exit 1
fi

install_brew() { brew install "$@" 2>/dev/null || true; }
install_npm()  { npm install -g "$@" 2>/dev/null || true; }
install_pip()  { pip install "$@" 2>/dev/null || pip install --break-system-packages "$@" 2>/dev/null || true; }
install_go()   { go install "$@" 2>/dev/null || true; }

# ── Core (always) ──
echo "── Installing core tools ──"
if [ "$PKG" = "brew" ]; then
  install_brew shellcheck shfmt jq vale gitleaks
else
  sudo apt-get update -qq
  sudo apt-get install -y -qq shellcheck jq
  install_go mvdan.cc/sh/v3/cmd/shfmt@latest
  echo "NOTE: Install vale and gitleaks manually (see https://vale.sh/docs/install)"
fi
install_npm markdownlint-cli @commitlint/cli @commitlint/config-conventional
install_pip semgrep yamllint

# ── Go stack ──
if $INSTALL_GO; then
  echo ""
  echo "── Installing Go quality tools ──"
  install_go golang.org/x/tools/cmd/goimports@latest
  install_go golang.org/x/vuln/cmd/govulncheck@latest
  if [ "$PKG" = "brew" ]; then
    install_brew golangci-lint
  else
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" 2>/dev/null || true
  fi
fi

# ── Terraform/Azure stack ──
if $INSTALL_TF; then
  echo ""
  echo "── Installing Terraform quality tools ──"
  if [ "$PKG" = "brew" ]; then
    install_brew tflint trivy infracost
  else
    echo "NOTE: Install tflint, trivy, infracost manually for Linux"
  fi
fi

# ── Docker (lightweight — always if docker present) ──
if command -v docker &>/dev/null; then
  echo ""
  echo "── Installing container tools ──"
  if [ "$PKG" = "brew" ]; then
    install_brew hadolint
  fi
fi

# ── Vale setup (sync packages + copy Praxis rules) ──
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALE_CONFIG_DIR="$SCRIPT_DIR/../base/configs/vale"
if command -v vale &>/dev/null && [ -f "$VALE_CONFIG_DIR/.vale.ini" ]; then
  echo ""
  echo "── Setting up Vale prose linter ──"
  (cd "$VALE_CONFIG_DIR" && vale sync 2>/dev/null || true)
  if [ -d "$VALE_CONFIG_DIR/Praxis" ] && [ -d "$VALE_CONFIG_DIR/.vale-styles" ]; then
    cp -R "$VALE_CONFIG_DIR/Praxis" "$VALE_CONFIG_DIR/.vale-styles/Praxis"
    echo "  Praxis rules copied to .vale-styles/"
  fi
fi

# ── VS Code extensions ──
if command -v code &>/dev/null; then
  echo ""
  echo "── Installing VS Code extensions ──"
  CORE_EXTENSIONS=(
    chrischinchilla.vale-vscode
    timonwong.shellcheck
    editorconfig.editorconfig
    davidanson.vscode-markdownlint
  )
  for ext in "${CORE_EXTENSIONS[@]}"; do
    code --install-extension "$ext" --force 2>/dev/null && printf "  ✓ %s\n" "$ext" || printf "  ✗ %s\n" "$ext"
  done

  # Stack-conditional extensions
  $INSTALL_GO && code --install-extension golang.go --force 2>/dev/null && echo "  ✓ golang.go" || true
  $INSTALL_TF && code --install-extension hashicorp.terraform --force 2>/dev/null && echo "  ✓ hashicorp.terraform" || true
  command -v docker &>/dev/null && code --install-extension exiasr.hadolint --force 2>/dev/null && echo "  ✓ exiasr.hadolint" || true
else
  echo ""
  echo "  ⚠ VS Code 'code' CLI not on PATH — skipping extension install"
  echo "    Fix: In VS Code, Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
fi

echo ""
echo "=== Done. Run 'bash scripts/install-tools.sh --all' to install all stacks. ==="
echo ""
echo "Installed tools:"
for tool in shellcheck shfmt jq vale gitleaks goimports golangci-lint govulncheck tflint trivy infracost hadolint semgrep yamllint markdownlint commitlint; do
  if command -v "$tool" &>/dev/null; then
    printf "  ✓ %s\n" "$tool"
  else
    printf "  ✗ %s (not found)\n" "$tool"
  fi
done
