"""Sync PRAXIS config to tool-specific instruction files."""

import json
import shutil
from pathlib import Path

from praxis_cli.constants import (
    COMMAND_FILES,
    SLASH_COMMANDS,
    build_global_rules,
)
from praxis_cli.utils.config import load_config


def _build_claude_hooks(cfg: dict) -> dict:
    """Build Claude Code hooks from PRAXIS verification config.

    Maps enabled verification tools to PostToolUse hooks that fire
    after Claude Code edits or writes files. Tests are excluded
    (too slow for per-edit; use `praxis verify` instead).

    Returns a dict suitable for merging into .claude/settings.json,
    or an empty dict if no checks are enabled.
    """
    verification = cfg.get("verification", {})
    hooks = []

    for name in ("formatter", "linter", "type_checker", "security_scanner"):
        check = verification.get(name, {})
        if not isinstance(check, dict):
            continue
        if not check.get("enabled") or not check.get("command"):
            continue

        hooks.append({
            "type": "command",
            "command": check["command"],
            "timeout": 30,
        })

    if not hooks:
        return {}

    return {
        "hooks": {
            "PostToolUse": [
                {
                    "matcher": "Edit|Write",
                    "hooks": hooks,
                }
            ]
        }
    }


def sync_claude_code(root: Path) -> list[str]:
    """Generate CLAUDE.md, .claude/commands/, and .claude/settings.json for Claude Code."""
    generated = []
    cfg = load_config()

    rules = build_global_rules(cfg)

    claude_md = "# Project Instructions\n\n"
    claude_md += "Read and follow the PRAXIS Protocol defined in PRAXIS.md.\n"
    claude_md += "All specs, plans, and context live in the praxis/ directory.\n\n"
    claude_md += "## PRAXIS Commands\n"
    for cmd in SLASH_COMMANDS:
        claude_md += f"- {cmd}\n"
    claude_md += "\n## Global Rules\n"
    claude_md += "- Never write code without an approved spec and plan.\n"
    if cfg.get("defaults", {}).get("phase_gate", True):
        claude_md += "- Stop at phase checkpoints for human review.\n"
    else:
        claude_md += "- Phase checkpoints are informational — continue unless the user stops you.\n"
    claude_md += "- Run verify at every checkpoint and before PRs.\n"
    claude_md += "- Read praxis/context/ before starting any task.\n"
    for rule in rules:
        claude_md += f"{rule}\n"

    # Verification hooks note
    verification = cfg.get("verification", {})
    any_hooks = any(
        isinstance(v, dict) and v.get("enabled")
        for v in verification.values()
    )
    if any_hooks:
        claude_md += "\n## Verification Hooks\n"
        claude_md += "Post-edit hooks are configured in .claude/settings.json.\n"
        claude_md += "They run automatically after you edit/write files: format, lint, type check, security scan.\n"
        claude_md += "Run `praxis verify --full` for comprehensive checks including tests.\n"

    (root / "CLAUDE.md").write_text(claude_md)
    generated.append("CLAUDE.md")

    # .claude/commands/
    commands_src = root / "praxis" / "commands"
    commands_dst = root / ".claude" / "commands"
    if commands_src.exists():
        commands_dst.mkdir(parents=True, exist_ok=True)
        for cmd_file in commands_src.glob("*.md"):
            shutil.copy2(cmd_file, commands_dst / cmd_file.name)
        generated.append(".claude/commands/")

    # .claude/settings.json (hooks from verification config)
    hooks_config = _build_claude_hooks(cfg)
    if hooks_config:
        settings_dir = root / ".claude"
        settings_dir.mkdir(parents=True, exist_ok=True)
        settings_path = settings_dir / "settings.json"

        # Merge with existing settings to preserve user customizations
        existing = {}
        if settings_path.exists():
            try:
                existing = json.loads(settings_path.read_text())
            except (json.JSONDecodeError, OSError):
                existing = {}

        existing["hooks"] = hooks_config["hooks"]
        settings_path.write_text(json.dumps(existing, indent=2) + "\n")
        generated.append(".claude/settings.json")

    return generated


def sync_openai_codex(root: Path) -> list[str]:
    """Generate AGENTS.md for OpenAI Codex."""
    cfg = load_config()
    generated = []

    rules = build_global_rules(cfg)

    # Build command map from COMMAND_FILES
    command_map = {}
    for f in COMMAND_FILES:
        name = f.removesuffix(".md")
        command_map[f"praxis {name}"] = f"praxis/commands/{f}"

    agents_md = "# Project Instructions\n\n"
    agents_md += "Read and follow the PRAXIS Protocol defined in PRAXIS.md.\n"
    agents_md += "All specs, plans, and context live in the praxis/ directory.\n\n"
    agents_md += "## PRAXIS Commands\n"
    agents_md += "When I say one of the following, read the corresponding file and follow it exactly:\n\n"
    for trigger, path in command_map.items():
        agents_md += f'- "{trigger}" → {path}\n'
    agents_md += "\n## Global Rules\n"
    agents_md += "- Never write code without an approved spec and plan.\n"
    agents_md += "- Stop at phase checkpoints for human review.\n"
    agents_md += "- Run verify at every checkpoint and before PRs.\n"
    agents_md += "- Read praxis/context/ before starting any task.\n"
    for rule in rules:
        agents_md += f"{rule}\n"
    (root / "AGENTS.md").write_text(agents_md)
    generated.append("AGENTS.md")

    return generated


def sync_global_claude() -> Path:
    """Generate global ~/.claude/CLAUDE.md from PRAXIS config."""
    cfg = load_config()
    claude_dir = Path.home() / ".claude"
    claude_dir.mkdir(parents=True, exist_ok=True)

    rules = build_global_rules(cfg)

    content = "# Global Rules\n\n"
    content += "## Requirements Gathering\n"
    for rule in rules:
        content += f"{rule}\n"
    if cfg.get("global", {}).get("always_ask_questions", True):
        content += "- Never assume scope, format, audience, or priorities — gather requirements first.\n"
        content += "- Present options as structured choices when the decision is bounded (2-4 options).\n"
    content += "- Use open-ended questions only when the answer is truly freeform.\n"
    content += "\n## PRAXIS Protocol\n"
    content += "If a project contains a PRAXIS.md file, read and follow it.\n"
    content += "All praxis commands are defined in praxis/commands/ — read the corresponding file when invoked.\n"

    output = claude_dir / "CLAUDE.md"
    output.write_text(content)
    return output


def sync_all(root: Path) -> dict[str, list[str]]:
    """Sync all tool-specific files."""
    cfg = load_config()
    results = {}

    if cfg.get("tools", {}).get("claude_code", True):
        results["Claude Code"] = sync_claude_code(root)
    if cfg.get("tools", {}).get("openai_codex", True):
        results["OpenAI Codex"] = sync_openai_codex(root)

    return results
