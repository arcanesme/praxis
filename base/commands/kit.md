Activate or deactivate an AI-Kit.

## Usage

- `/kit:web-designer` — Activate the web-designer kit
- `/kit:off` — Deactivate the current kit

## Instructions

### Activation (`/kit:<name>`)

1. Check if the kit exists in the praxis repo's `kits/` directory
2. Read the kit's `KIT.md` for activation instructions
3. Load the kit's rules into the current session context
4. Register the kit's commands
5. If the kit has an `install.sh`, note any required MCP setup
6. Confirm activation with a summary of what was loaded

### Deactivation (`/kit:off`)

1. Unload kit-specific rules from session context
2. Unregister kit-specific commands
3. Confirm deactivation

## Rules

- Kit activation is **idempotent**: activating twice = same result as once
- Only one kit can be active at a time
- Kit rules extend (never override) base rules
- If a kit requires MCP servers, instruct the user to run the kit's `install.sh`

## Available Kits

| Kit | Description |
|-----|-------------|
| `web-designer` | Design system initialization, component lifecycle, a11y, responsive design |
