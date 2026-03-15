---
disable-model-invocation: true
description: Bootstrap a new project with vault entry, CLAUDE.md, .gitignore, claude-progress.json
---

# /scaffold-new

Bootstrap a brand-new project into the Praxis harness.

## Input (collect in one prompt)

- **Project name** (kebab-case)
- **Project type** (code | architecture | content)
- **Tech stack** (languages, frameworks, services)
- **Repo path** (absolute path to project root)

## Steps

1. **Read config**: Load `vault_path` from `~/.claude/praxis.config.json`

2. **Create vault entry**:
   - Directory: `{vault_path}/01_Projects/Work/_active/{project-name}/`
   - Subdirectories: `specs/`, `notes/`
   - Files:
     - `notes/learnings.md` — from `references/vault-learnings-template.md`
     - `claude-progress.json` — from `references/claude-progress-template.json`

3. **Create project files**:
   - `CLAUDE.md` — project-specific Claude Code instructions (reference praxis context)
   - `.gitignore` — from `references/gitignore-template.txt`, adapted for detected stack
   - `claude-progress.json` — copy in project root
   - `.claude/rules/` — create directory for project-specific rules

4. **Detect stack and add scoped rules**:
   - If Python detected: add Python-specific rules
   - If JavaScript/TypeScript detected: add JS/TS-specific rules
   - If Terraform detected: note that base terraform.md will auto-load

5. **Verify**:
   - Confirm all files created
   - Confirm vault entry exists
   - Print summary of what was scaffolded

## Rules

- Never hardcode vault paths — always read from config
- All input collected in a single prompt (single-reply intake)
- Idempotent: re-running on an existing project should not overwrite existing files
