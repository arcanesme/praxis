#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p base/rules
mkdir -p base/commands
mkdir -p base/skills/scaffold-new/references
mkdir -p base/skills/scaffold-exist
mkdir -p base/skills/pre-commit-lint
mkdir -p base/skills/session-retro
mkdir -p base/skills/vault-gc
mkdir -p kits/web-designer/rules
mkdir -p kits/web-designer/commands
mkdir -p templates
mkdir -p scripts
mkdir -p docs

echo "✓ All directories created"
ls -R --color=never 2>/dev/null || find . -not -path './.git/*' -not -name '.DS_Store' | sort
