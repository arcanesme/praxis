#!/usr/bin/env bash
# credential-guard.sh — PreToolUse:Bash hook
# Blocks Bash commands that access credential files or sensitive directories.
# Exit 0 = allow, Exit 2 = block with message.
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# ── Allowlist: verification commands that reference credential paths safely ──
SAFE_PATTERNS=(
  "ssh-keygen -l"
  "ssh-keygen -lf"
  "gh auth status"
  "gh auth token"
  "gh auth switch"
  "aws sts get-caller-identity"
  "az account show"
  "gcloud auth list"
  "kubectl config current-context"
  "docker login --help"
  "gpg --list-keys"
  "security find-identity"
)

for safe in "${SAFE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$safe"; then
    exit 0
  fi
done

# ── Blocked paths: credential stores and private key locations ──
BLOCKED_PATHS=(
  "$HOME/.ssh"
  "$HOME/.aws"
  "$HOME/.azure"
  "$HOME/.kube"
  "$HOME/.gnupg"
  "$HOME/.docker/config.json"
  "$HOME/Library/Keychains"
  "$HOME/.config/gcloud"
  "$HOME/.praxis/secrets"
)

# Expand ~ in commands for matching
EXPANDED_CMD="${COMMAND//\~/$HOME}"

for blocked in "${BLOCKED_PATHS[@]}"; do
  if echo "$EXPANDED_CMD" | grep -qF "$blocked"; then
    echo "BLOCKED: Command references protected credential path: $blocked" >&2
    echo "Praxis credential-guard prevents access to sensitive directories." >&2
    echo "If this is a legitimate operation, use the allowlisted verification commands." >&2

    # Log to audit trail
    AUDIT_FILE="$HOME/.claude/praxis-audit.jsonl"
    if command -v jq &>/dev/null; then
      jq -nc \
        --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        --arg tool "Bash" \
        --arg event "credential-guard-block" \
        --arg path "$blocked" \
        --arg cmd "${COMMAND:0:200}" \
        --arg session "$PPID" \
        '{ts: $ts, tool: $tool, event: $event, blocked_path: $path, command_prefix: $cmd, session_id: $session}' \
        >> "$AUDIT_FILE" 2>/dev/null || true
    fi

    exit 2
  fi
done

# ── Blocked file patterns: private keys and env files ──
BLOCKED_FILE_PATTERNS=(
  "_rsa[[:space:]]"
  "_rsa$"
  "_ed25519[[:space:]]"
  "_ed25519$"
  "\.pem[[:space:]]"
  "\.pem$"
  "\.p12[[:space:]]"
  "\.p12$"
  "\.pfx[[:space:]]"
  "\.pfx$"
)

for pattern in "${BLOCKED_FILE_PATTERNS[@]}"; do
  if echo "$EXPANDED_CMD" | grep -qE "$pattern"; then
    echo "BLOCKED: Command references private key or certificate file pattern." >&2
    echo "Praxis credential-guard prevents access to private key files." >&2
    exit 2
  fi
done

exit 0
