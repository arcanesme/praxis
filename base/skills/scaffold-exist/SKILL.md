---
disable-model-invocation: true
description: Retrofit the Praxis harness onto an existing project
---

# /scaffold-exist

Wire an existing project into the Praxis harness without disrupting its current structure.

## Input (collect in one prompt)

- **Project name** (kebab-case)
- **Repo path** (absolute path to project root)

## Steps

1. **Read config**: Load `vault_path` from `~/.claude/praxis.config.json`

2. **Detect existing structure**:
   - Check for existing `CLAUDE.md`, `.claude/`, `.gitignore`
   - Identify tech stack from file extensions, config files, package manifests
   - Note any existing CI/CD, testing, linting setup

3. **Create vault entry** (if not exists):
   - Directory: `{vault_path}/01_Projects/Work/_active/{project-name}/`
   - Subdirectories: `specs/`, `notes/`
   - Files: `notes/learnings.md`, `claude-progress.json`

4. **Wire harness files** (skip existing):
   - `CLAUDE.md` — append praxis context if file exists, create if not
   - `claude-progress.json` — create in project root
   - `.claude/rules/` — create directory for project-specific rules
   - `.gitignore` — append praxis entries if file exists

5. **Verify**:
   - Confirm all harness files present
   - Confirm vault entry exists
   - Print summary of what was added vs. what was skipped

## Rules

- Never overwrite existing files — append or skip
- Never hardcode vault paths
- All input collected in a single prompt
- Idempotent: safe to run multiple times
