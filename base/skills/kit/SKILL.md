---
name: kit
disable-model-invocation: true
description: Activate or deactivate a domain AI-Kit. Use /kit:web-designer to activate, /kit:off to deactivate, /kit:list to show installed kits.
---

You are managing AI-Kit activation.

## /kit:list
List all installed kits by reading `~/.claude/kits/*/KIT.md` manifests.
Print a table:
```
  Kit              Status    Domain
  web-designer     inactive  Design system → components → accessibility → lint
```
If `~/.claude/praxis.config.json` has `installed_kits`, cross-reference to show install status.

## /kit:<name> (activate)

1. Check if `~/.claude/kits/<name>/KIT.md` exists. If not: report "Kit not found. Run /kit:list."
2. Read `KIT.md` manifest to get skills_chain, rules, and mcp_servers.
3. **Idempotency check**: If this kit is already active in the current session, report "Kit already active" and do nothing.
4. Print the skills chain:
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     AI-Kit activated: web-designer
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

     Skills chain:
     1. Design system init  → ui-ux-pro-max, design-system-patterns
     2. Component build     → frontend-design, shadcn-ui, 21st.dev MCP
     3. Audit               → web-accessibility, ui-skills
     4. Final lint           → web-design-guidelines

     Domain rules loaded: web-design.md
     MCP servers: 21st-magic

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
5. Load the kit's rules from `~/.claude/kits/<name>/rules/`.
6. Note: MCP servers registered via `claude mcp add` persist globally. The kit activation confirms they are available but does not re-register.

## /kit:off (deactivate)

1. Report which kit is being deactivated.
2. Unload kit-specific rules from the active context.
3. Note: MCP servers persist globally — they are not unregistered on deactivation.
4. Print: `✓ Kit deactivated. Praxis base workflow still active.`

## /kit:update <name>

1. Run `~/.claude/kits/<name>/install.sh` to pull latest skill versions.
2. Update `installed_kits` in `~/.claude/praxis.config.json`.
3. Report results.

## Error Handling

| Condition | Action |
|-----------|--------|
| Kit not found | Report available kits from /kit:list |
| Kit dependencies not installed | Suggest running `~/.claude/kits/<name>/install.sh` |
| Double activation | No-op — report already active |
| KIT.md malformed | Report parse error, do not activate |
