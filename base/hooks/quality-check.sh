#!/usr/bin/env bash
# quality-check.sh — PostToolUse hook (merged format + lint + typecheck)
# Detects stack from file extension. Formats, lints, type-checks.
# Always exits 0 (PostToolUse cannot hard-block).
# Emits JSON feedback for Claude self-correction.
set -uo pipefail

INPUT=$(cat)

# Guard: skip if stop hook is active (prevent infinite loop)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"
BASENAME=$(basename "$FILE_PATH")
ISSUES=()

# ── FORMAT ──────────────────────────────────────────────
case "$EXT" in
  go)
    if command -v goimports &>/dev/null; then
      goimports -w "$FILE_PATH" 2>/dev/null
    elif command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null
    fi
    ;;
  tf|tfvars)
    if command -v terraform &>/dev/null; then
      terraform fmt "$FILE_PATH" 2>/dev/null
    fi
    ;;
  sh|bash)
    if command -v shfmt &>/dev/null; then
      shfmt -i 2 -ci -bn -w "$FILE_PATH" 2>/dev/null
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null
    fi
    ;;
  json)
    if command -v jq &>/dev/null; then
      TMP=$(mktemp)
      if jq . "$FILE_PATH" > "$TMP" 2>/dev/null; then
        mv "$TMP" "$FILE_PATH"
      else
        rm -f "$TMP"
      fi
    fi
    ;;
  toml)
    if command -v taplo &>/dev/null; then
      taplo format "$FILE_PATH" 2>/dev/null
    fi
    ;;
  js|jsx|ts|tsx)
    if command -v biome &>/dev/null; then
      biome format --write "$FILE_PATH" 2>/dev/null
    elif command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null
    fi
    ;;
  md)
    if command -v prettier &>/dev/null; then
      prettier --write --prose-wrap always "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

# ── LINT ────────────────────────────────────────────────
case "$EXT" in
  go)
    if command -v go &>/dev/null; then
      LINT_OUT=$(go vet "$FILE_PATH" 2>&1) || true
      if [ -n "$LINT_OUT" ]; then
        ISSUES+=("go vet: $LINT_OUT")
      fi
    fi
    ;;
  tf|tfvars)
    if command -v tflint &>/dev/null; then
      LINT_OUT=$(tflint --filter="$FILE_PATH" 2>&1) || true
      if [ -n "$LINT_OUT" ]; then
        ISSUES+=("tflint: $LINT_OUT")
      fi
    fi
    ;;
  sh|bash)
    if command -v shellcheck &>/dev/null; then
      LINT_OUT=$(shellcheck -f gcc "$FILE_PATH" 2>&1) || true
      if [ -n "$LINT_OUT" ]; then
        ISSUES+=("shellcheck: $LINT_OUT")
      fi
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      LINT_OUT=$(ruff check --fix "$FILE_PATH" 2>&1) || true
      if [ -n "$LINT_OUT" ] && ! echo "$LINT_OUT" | grep -q "All checks passed"; then
        ISSUES+=("ruff: $LINT_OUT")
      fi
    fi
    ;;
  md)
    # Markdown linting handled by markdownlint if available
    if command -v markdownlint &>/dev/null; then
      LINT_OUT=$(markdownlint "$FILE_PATH" 2>&1) || true
      if [ -n "$LINT_OUT" ]; then
        ISSUES+=("markdownlint: $LINT_OUT")
      fi
    fi
    ;;
  js|jsx|ts|tsx)
    if command -v biome &>/dev/null; then
      LINT_OUT=$(biome lint "$FILE_PATH" 2>&1) || true
      if [ -n "$LINT_OUT" ] && ! echo "$LINT_OUT" | grep -q "No diagnostics"; then
        ISSUES+=("biome: $LINT_OUT")
      fi
    fi
    ;;
  rs)
    if command -v cargo &>/dev/null; then
      DIR=$(dirname "$FILE_PATH")
      # Walk up to find Cargo.toml for crate context
      CRATE_DIR="$DIR"
      while [ "$CRATE_DIR" != "/" ] && [ ! -f "$CRATE_DIR/Cargo.toml" ]; do
        CRATE_DIR=$(dirname "$CRATE_DIR")
      done
      if [ -f "$CRATE_DIR/Cargo.toml" ]; then
        LINT_OUT=$(cd "$CRATE_DIR" && cargo clippy --quiet -- -D warnings 2>&1) || true
        if [ -n "$LINT_OUT" ]; then
          ISSUES+=("clippy: $LINT_OUT")
        fi
      fi
    fi
    ;;
  yml|yaml)
    if command -v yamllint &>/dev/null; then
      LINT_OUT=$(yamllint -f parsable "$FILE_PATH" 2>&1) || true
      if [ -n "$LINT_OUT" ]; then
        ISSUES+=("yamllint: $LINT_OUT")
      fi
    fi
    ;;
esac

# ── LINT (Dockerfile special case) ─────────────────────
if [ "$BASENAME" = "Dockerfile" ] || echo "$BASENAME" | grep -qE "^Dockerfile\."; then
  if command -v hadolint &>/dev/null; then
    LINT_OUT=$(hadolint "$FILE_PATH" 2>&1) || true
    if [ -n "$LINT_OUT" ]; then
      ISSUES+=("hadolint: $LINT_OUT")
    fi
  fi
fi

# ── TYPECHECK ───────────────────────────────────────────
case "$EXT" in
  go)
    if command -v go &>/dev/null; then
      DIR=$(dirname "$FILE_PATH")
      TC_OUT=$(cd "$DIR" && go build ./... 2>&1) || true
      if [ -n "$TC_OUT" ]; then
        ISSUES+=("go build: $TC_OUT")
      fi
    fi
    ;;
  bicep)
    if command -v az &>/dev/null; then
      TC_OUT=$(az bicep build --file "$FILE_PATH" 2>&1) || true
      if echo "$TC_OUT" | grep -qi "error"; then
        ISSUES+=("bicep build: $TC_OUT")
      fi
    fi
    ;;
esac

# ── EMIT RESULT ─────────────────────────────────────────
if [ ${#ISSUES[@]} -eq 0 ]; then
  echo '{"decision":"pass","reason":""}'
else
  # Truncate to avoid flooding context window
  COMBINED=$(printf '%s\n' "${ISSUES[@]}" | head -30)
  # Escape for JSON
  ESCAPED=$(echo "$COMBINED" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":$ESCAPED}"
fi

exit 0
