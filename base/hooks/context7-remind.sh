#!/usr/bin/env bash
# context7-remind.sh — PostToolUse hook
# Scans written/edited files for external import statements.
# Reminds Claude to verify via Context7 if new imports are detected.
# PostToolUse hooks always exit 0 — this is a reminder, not a gate.
set -euo pipefail

trap 'exit 0' ERR

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Only scan code files where imports are meaningful
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) LANG="js" ;;
  *.py)                               LANG="py" ;;
  *.go)                               LANG="go" ;;
  *.rs)                               LANG="rs" ;;
  *.java)                             LANG="java" ;;
  *.cs)                               LANG="cs" ;;
  *)                                  exit 0 ;;
esac

# Build import pattern per language
case "$LANG" in
  js)   PATTERN="^import .+ from ['\"]|require\(['\"]" ;;
  py)   PATTERN="^import |^from .+ import " ;;
  go)   PATTERN="^import |^\t\"" ;;
  rs)   PATTERN="^use [a-z]" ;;
  java) PATTERN="^import " ;;
  cs)   PATTERN="^using " ;;
esac

# Extract external imports (skip relative/internal)
IMPORTS=$(grep -E "$PATTERN" "$FILE_PATH" 2>/dev/null || true)

if [[ -z "$IMPORTS" ]]; then
  exit 0
fi

# Filter out internal/relative imports
EXTERNAL=""
while IFS= read -r line; do
  case "$LANG" in
    js)
      # Skip relative imports (./  ../)
      if echo "$line" | grep -qE "from ['\"]\."; then continue; fi
      ;;
    py)
      # Skip relative imports (from . import, from .. import)
      if echo "$line" | grep -qE "^from \."; then continue; fi
      ;;
    go)
      # Skip stdlib (no dots in path) — external modules have dots (github.com, etc.)
      if ! echo "$line" | grep -qE '\"[a-z]+\.[a-z]'; then continue; fi
      ;;
    rs)
      # Skip std/crate/self/super
      if echo "$line" | grep -qE "^use (std|crate|self|super)::"; then continue; fi
      ;;
    java|cs)
      # Skip java.*/javax.*/System.*
      if echo "$line" | grep -qE "^(import|using) (java\.|javax\.|System\.)"; then continue; fi
      ;;
  esac
  EXTERNAL="${EXTERNAL}${line}\n"
done <<< "$IMPORTS"

if [[ -z "$EXTERNAL" ]]; then
  exit 0
fi

# Count unique external packages
PKG_COUNT=$(echo -e "$EXTERNAL" | grep -c '.' 2>/dev/null || echo "0")

echo "CONTEXT7-REMIND: $FILE_PATH contains $PKG_COUNT external import(s). Verify each was looked up via Context7 (resolve-library-id → get-library-docs) this session. If not: do it now before proceeding." >&2
exit 0
