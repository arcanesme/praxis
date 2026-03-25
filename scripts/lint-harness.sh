#!/bin/bash
set -euo pipefail

# ════════════════════════════════════════════════════════════════
#  Praxis — Harness Content Lint
#  Validates frontmatter, placeholders, registry consistency, syntax
# ════════════════════════════════════════════════════════════════

REPO_PATH="${1:-$(cd "$(dirname "$0")/.." && pwd)}"

ERRORS=0
WARNINGS=0

error() {
  echo "  ✗ ERROR: $1"
  ERRORS=$((ERRORS + 1))
}

warn() {
  echo "  ⚠ WARN:  $1"
  WARNINGS=$((WARNINGS + 1))
}

ok() {
  echo "  ✓ $1"
}

echo "Praxis Harness Lint"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Repo: $REPO_PATH"

# ─── 1. Command frontmatter ───
echo ""
echo "Commands (description: field):"
if [[ -d "$REPO_PATH/base/commands" ]]; then
  for cmd in "$REPO_PATH"/base/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    fname=$(basename "$cmd")
    if head -5 "$cmd" | grep -q "^description:"; then
      ok "$fname"
    else
      error "$fname missing description: in frontmatter"
    fi
  done
fi

# ─── 2. Skill frontmatter ───
echo ""
echo "Skills (name:, description:):"
if [[ -d "$REPO_PATH/base/skills" ]]; then
  for skill_dir in "$REPO_PATH"/base/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_file" ]]; then
      error "skills/$skill_name/ missing SKILL.md"
      continue
    fi
    # Check required frontmatter fields (within first 10 lines)
    header=$(head -10 "$skill_file")
    missing=""
    echo "$header" | grep -q "^name:" || missing="$missing name:"
    echo "$header" | grep -q "^description:" || missing="$missing description:"
    if [[ -z "$missing" ]]; then
      # Note auto-invocable skills (no disable-model-invocation)
      if echo "$header" | grep -q "^disable-model-invocation:"; then
        ok "skills/$skill_name"
      else
        ok "skills/$skill_name (auto-invocable)"
      fi
    else
      error "skills/$skill_name SKILL.md missing:$missing"
    fi
  done
fi

# ─── 3. Kit frontmatter ───
echo ""
echo "Kits (name:, version:, description:, activation:, skills_chain:):"
if [[ -d "$REPO_PATH/kits" ]]; then
  for kit_dir in "$REPO_PATH"/kits/*/; do
    [[ -d "$kit_dir" ]] || continue
    kit_name=$(basename "$kit_dir")
    kit_file="$kit_dir/KIT.md"
    if [[ ! -f "$kit_file" ]]; then
      error "kits/$kit_name/ missing KIT.md"
      continue
    fi
    header=$(head -15 "$kit_file")
    missing=""
    echo "$header" | grep -q "^name:" || missing="$missing name:"
    echo "$header" | grep -q "^version:" || missing="$missing version:"
    echo "$header" | grep -q "^description:" || missing="$missing description:"
    echo "$header" | grep -q "^activation:" || missing="$missing activation:"
    echo "$header" | grep -q "^skills_chain:" || missing="$missing skills_chain:"
    if [[ -z "$missing" ]]; then
      ok "kits/$kit_name"
    else
      error "kits/$kit_name KIT.md missing:$missing"
    fi
  done
fi

# ─── 4. Placeholder scan ───
echo ""
echo "Placeholder scan ({placeholder} patterns):"
PLACEHOLDER_FOUND=0
# Scan base/, kits/, docs/, scripts/ — exclude templates/ and */references/
# Also exclude HTML comments and fenced code blocks
while IFS= read -r file; do
  [[ -f "$file" ]] || continue
  # Skip templates, references, and configs directories
  [[ "$file" == *"/templates/"* ]] && continue
  [[ "$file" == *"/references/"* ]] && continue
  [[ "$file" == *"/configs/"* ]] && continue

  # Strip fenced code blocks (including indented), HTML comments,
  # lines with inline backticks, and shell comments/echo lines
  matches=$(sed -E \
    -e '/^[[:space:]]*```/,/^[[:space:]]*```/d' \
    -e '/<!--/,/-->/d' \
    "$file" \
    | grep -nE '\{[a-zA-Z_][a-zA-Z0-9_-]*\}' \
    | grep -vE '`[^`]*\{[^}]+\}[^`]*`' \
    | grep -vE '^[0-9]+:\s*#' \
    | grep -vE '^[0-9]+:\s*echo ' \
    | grep -vE '\{vault_path\}|\{today_date\}|\{project-slug\}|\{YYYY-MM-DD\}|\{kebab-title\}|\{date\}|\{[nN]\}|\{1-line\}|\{ISO timestamp\}|\{repo_root\}|\{identity_email\}|\{stack\}|\{placeholder\}|\{placeholders\}|\{http_code\}' \
    || true)
  if [[ -n "$matches" ]]; then
    rel_path="${file#"$REPO_PATH"/}"
    while IFS= read -r match; do
      error "$rel_path:$match"
      PLACEHOLDER_FOUND=$((PLACEHOLDER_FOUND + 1))
    done <<< "$matches"
  fi
done < <(find "$REPO_PATH/base" "$REPO_PATH/docs" "$REPO_PATH/scripts" -name "*.md" -o -name "*.sh" 2>/dev/null; find "$REPO_PATH/kits" -name "*.md" -o -name "*.sh" 2>/dev/null)

if [[ $PLACEHOLDER_FOUND -eq 0 ]]; then
  ok "No unreplaced placeholders found"
fi

# ─── 5. Rules registry consistency ───
echo ""
echo "Rules registry (CLAUDE.md references vs disk):"
if [[ -f "$REPO_PATH/base/CLAUDE.md" ]]; then
  # Extract rule filenames from CLAUDE.md registry tables
  rule_refs=$(grep -oE '~/.claude/rules/[a-zA-Z0-9_-]+\.md' "$REPO_PATH/base/CLAUDE.md" \
    | sed 's|~/.claude/rules/||' | sort -u)
  for rule_file in $rule_refs; do
    if [[ -f "$REPO_PATH/base/rules/$rule_file" ]]; then
      ok "rules/$rule_file exists"
    else
      error "CLAUDE.md references rules/$rule_file but file not found"
    fi
  done
fi

# ─── 6. Shell script syntax ───
echo ""
echo "Shell syntax (bash -n):"
while IFS= read -r script; do
  [[ -f "$script" ]] || continue
  fname="${script#"$REPO_PATH"/}"
  if bash -n "$script" 2>/dev/null; then
    ok "$fname"
  else
    error "$fname has syntax errors"
  fi
done < <(find "$REPO_PATH" -maxdepth 1 -name "*.sh" 2>/dev/null; find "$REPO_PATH/scripts" -name "*.sh" 2>/dev/null; find "$REPO_PATH/kits" -name "*.sh" 2>/dev/null)

# ─── 7. Template content warnings ───
echo ""
echo "Template content warnings:"
for check_file in "$REPO_PATH/base/rules/git-workflow.md" "$REPO_PATH/base/rules/profile.md"; do
  if [[ -f "$check_file" ]]; then
    fname="${check_file#"$REPO_PATH"/}"
    if grep -qiE "you@company\.com|Your Name" "$check_file"; then
      warn "$fname contains uncustomized template values (you@company.com or Your Name)"
    else
      ok "$fname — no template placeholders"
    fi
  fi
done

# ─── Summary ───
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
if [[ $ERRORS -gt 0 ]]; then
  echo "  FAILED — fix errors above"
  exit 1
else
  if [[ $WARNINGS -gt 0 ]]; then
    echo "  PASSED with warnings"
  else
    echo "  PASSED — all clean"
  fi
  exit 0
fi
