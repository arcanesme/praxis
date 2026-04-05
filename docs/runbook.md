# Praxis Runbook

Operational troubleshooting guide. Each section follows Symptom / Cause / Fix format.

## Daily Workflow

The standard Praxis workflow for feature work:

1. **Start session**: `/standup` — reads status.md, surfaces stale state, orients you
2. **Frame the problem**: `/discuss` — conversational problem framing, SPEC synthesis, scope guard
3. **Plan the work**: `/plan` — milestones with dependencies, write to vault
4. **Execute milestones**: `/execute` — one milestone at a time, file-group isolation
5. **Verify each milestone**: `/verify` — test/lint/typecheck/build, stop-and-fix
6. **End session**: `/session-retro` — learnings, rule proposals, progress update

For pure bugfixes: skip the full loop, use `/debug` directly.
For code review: use `/review` at any point.

## Context Rot Recovery

**Symptom**: Claude repeats earlier mistakes, forgets decisions, gives inconsistent answers.

**Cause**: Conversation context has degraded from length or compaction.

**Fix (mild rot — still coherent)**:
```
/context-reset
```
Reloads CLAUDE.md, status.md, and active plan from vault. Use when Claude seems
slightly confused but the session is otherwise productive.

**Fix (severe rot — multiple corrections needed)**:
```
/session-retro
/clear
```
Run retro to capture learnings, then start a fresh session. The vault preserves
all state — nothing is lost.

**Fix (new session)**:
Start a new Claude Code session. The SessionStart hook auto-loads agenda.md.
Read the active plan to resume where you left off.

## Vault Recovery

### Obsidian CLI Fails

**Symptom**: `obsidian search` returns errors or "command not found".

**Cause**: Obsidian is not running, or CLI is not enabled.

**Fix**:
1. Open Obsidian
2. Enable CLI: Settings > General > Command line interface (toggle on)
3. Verify: `obsidian --help`

If the command is still not found, ensure `/Applications/Obsidian.app/Contents/MacOS/` is in your PATH.

### Status.md Stale

**Symptom**: `/standup` warns that status.md is N days stale.

**Cause**: Previous session did not run `/session-retro`, or vault writes failed.

**Fix**:
1. Run `/standup` to see current state
2. Manually update status.md if needed — set `last_updated:` to today

## Kit Troubleshooting

### Kit Not Found

**Symptom**: `/kit:name` says the kit does not exist.

**Cause**: Symlinks not created (new kit added after initial install).

**Fix**:
```bash
bash scripts/update.sh
# or re-run install:
./install.sh
```

Verify kits are linked:
```bash
ls -la ~/.claude/kits/
```

### MCP Server Not Connecting

**Symptom**: Kit MCP server commands fail or return connection errors.

**Cause**: MCP server not registered or package not installed.

**Fix**:
```bash
# Check registered MCP servers
claude mcp list

# Re-register if missing (check kit KIT.md for exact command)
claude mcp add server-name npx -- -y @scope/package@latest
```

## Install Troubleshooting

### Obsidian CLI Not Found After Install

**Symptom**: `command -v obsidian` returns nothing after running install.sh.

**Cause**: Obsidian CLI not enabled, or Obsidian not installed.

**Fix**:
1. Install Obsidian from <https://obsidian.md>
2. Open Obsidian > Settings > General > Command line interface (toggle on)
3. Verify: `obsidian --help`

### Vault Path Wrong

**Symptom**: Commands fail with "vault not found" or write to wrong location.

**Cause**: `praxis.config.json` has incorrect `vault_path`.

**Fix**:
```bash
# Check current config
cat ~/.claude/praxis.config.json | jq '.vault_path'

# Edit directly
jq '.vault_path = "/correct/path"' ~/.claude/praxis.config.json > /tmp/pc.json \
  && mv /tmp/pc.json ~/.claude/praxis.config.json
```

### Broken Symlinks

**Symptom**: Commands or rules fail to load, health check reports broken links.

**Cause**: Repo moved, files deleted, or partial install.

**Fix**:
```bash
# Diagnose
bash scripts/health-check.sh

# Fix by re-running install
./install.sh
```

The install script uses `ln -sf` (force) so it will repair broken symlinks automatically.
