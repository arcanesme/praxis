"""praxis doctor — validate PRAXIS setup across project and global config."""

import json
import shutil
from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

from praxis_cli.utils.config import CONFIG_FILE, load_config
from praxis_cli.utils.project import find_project_root, get_context_dir, get_commands_dir

console = Console()


@click.command()
def doctor():
    """Validate PRAXIS setup — check project files, global config, and tool sync.

    Runs checks for:
    - Global config exists and is valid
    - Project has PRAXIS.md and required directories
    - Context files are present
    - Command files are present and synced
    - Tool-specific files are generated and current
    - Verification tools are installed
    """
    console.print(Panel("🏛  PRAXIS Doctor", style="bold blue"))
    console.print()

    checks: list[tuple[str, bool, str]] = []

    # ── Global checks ──────────────────────────────
    console.print("[bold]Global[/bold]")

    # Config file
    config_exists = CONFIG_FILE.exists()
    checks.append(("Global config (~/.praxis/config.toml)", config_exists, "Run: praxis config"))
    _print_check("Config file", config_exists)

    # Global CLAUDE.md
    global_claude = Path.home() / ".claude" / "CLAUDE.md"
    claude_global_exists = global_claude.exists()
    claude_global_has_praxis = False
    if claude_global_exists:
        content = global_claude.read_text()
        claude_global_has_praxis = "PRAXIS" in content
    checks.append(
        ("Global ~/.claude/CLAUDE.md with PRAXIS rules", claude_global_has_praxis,
         "Run: praxis config --sync")
    )
    _print_check("~/.claude/CLAUDE.md", claude_global_has_praxis)

    console.print()

    # ── Project checks ─────────────────────────────
    console.print("[bold]Project[/bold]")

    root = find_project_root()
    if root is None:
        _print_check("Project root found", False)
        console.print("  [dim]Not in a git repo or PRAXIS project[/dim]")
        _print_summary(checks)
        return

    _print_check("Project root", True, str(root))

    # PRAXIS.md
    praxis_exists = (root / "PRAXIS.md").exists()
    checks.append(("PRAXIS.md", praxis_exists, "Run: praxis init"))
    _print_check("PRAXIS.md", praxis_exists)

    if not praxis_exists:
        console.print("  [dim]Run 'praxis init' to scaffold this project[/dim]")
        _print_summary(checks)
        return

    # Context files
    context_dir = get_context_dir(root)
    context_files = ["product.md", "techstack.md", "workflow.md", "guidelines.md"]
    for cf in context_files:
        exists = (context_dir / cf).exists()
        checks.append((f"praxis/context/{cf}", exists, "Run setup command in your AI tool"))
        _print_check(f"context/{cf}", exists)

    # Verification
    verification_exists = (root / "praxis" / "verification.md").exists()
    checks.append(("praxis/verification.md", verification_exists, "Run: praxis init"))
    _print_check("verification.md", verification_exists)

    # Command files
    commands_dir = get_commands_dir(root)
    expected_commands = [
        "setup.md", "new-track.md", "implement.md", "review.md", "status.md",
        "verify.md", "commit-push-pr.md", "simplify.md", "sync-context.md", "deploy-preview.md",
    ]
    commands_ok = True
    for cmd in expected_commands:
        if not (commands_dir / cmd).exists():
            commands_ok = False
            break
    checks.append(("All command files present", commands_ok, "Run: praxis init --force"))
    _print_check(f"Commands ({len(expected_commands)} files)", commands_ok)

    console.print()

    # ── Tool sync checks ───────────────────────────
    console.print("[bold]Tool Sync[/bold]")

    cfg = load_config()

    # Claude Code
    if cfg.get("tools", {}).get("claude_code", True):
        claude_md = (root / "CLAUDE.md").exists()
        claude_cmds = (root / ".claude" / "commands").exists()
        checks.append(("CLAUDE.md", claude_md, "Run: praxis bootstrap"))
        checks.append((".claude/commands/", claude_cmds, "Run: praxis bootstrap"))
        _print_check("CLAUDE.md", claude_md)
        _print_check(".claude/commands/", claude_cmds)

        # Check for hooks if verification tools are configured
        verification_cfg = cfg.get("verification", {})
        any_enabled = any(
            isinstance(v, dict) and v.get("enabled")
            for v in verification_cfg.values()
        )
        if any_enabled:
            settings_path = root / ".claude" / "settings.json"
            has_hooks = False
            if settings_path.exists():
                try:
                    settings_data = json.loads(settings_path.read_text())
                    has_hooks = bool(settings_data.get("hooks", {}).get("PostToolUse"))
                except (json.JSONDecodeError, OSError):
                    pass
            checks.append((".claude/settings.json (hooks)", has_hooks, "Run: praxis bootstrap"))
            _print_check(".claude/settings.json (hooks)", has_hooks)

    # OpenAI Codex
    if cfg.get("tools", {}).get("openai_codex", True):
        agents_md = (root / "AGENTS.md").exists()
        checks.append(("AGENTS.md", agents_md, "Run: praxis bootstrap"))
        _print_check("AGENTS.md", agents_md)

    console.print()

    # ── Verification tools ─────────────────────────
    console.print("[bold]Verification Tools[/bold]")

    verification_cfg = cfg.get("verification", {})
    any_configured = False
    for name, check in verification_cfg.items():
        if not isinstance(check, dict) or not check.get("enabled"):
            continue
        any_configured = True
        command = check.get("command", "")
        tool_bin = command.split()[0] if command else ""
        found = shutil.which(tool_bin) is not None if tool_bin else False
        label = f"{check.get('tool', name)} ({command})"
        checks.append((label, found, f"Install {tool_bin} or update config"))
        _print_check(label, found)

    if not any_configured:
        _print_check("Verification tools configured", False, "Run: praxis config", required=False)

    # Always check for gh CLI
    gh_found = shutil.which("gh") is not None
    _print_check("gh (GitHub CLI)", gh_found, required=False)

    console.print()

    # ── Summary ────────────────────────────────────
    _print_summary(checks)


def _print_check(name: str, passed: bool, detail: str = "", required: bool = True):
    """Print a single check result."""
    if passed:
        icon = "✅"
        style = ""
    elif required:
        icon = "❌"
        style = "red"
    else:
        icon = "⚪"
        style = "dim"

    line = f"  {icon} {name}"
    if detail:
        line += f" [dim]({detail})[/dim]"
    console.print(line, style=style)


def _print_summary(checks: list[tuple[str, bool, str]]):
    """Print summary with action items for failures."""
    passed = sum(1 for _, ok, _ in checks if ok)
    total = len(checks)
    failed = [(name, fix) for name, ok, fix in checks if not ok]

    if not failed:
        console.print(
            Panel(
                f"[bold green]✅ All {total} checks passed.[/bold green]",
                title="Health Check",
                style="green",
            )
        )
    else:
        table = Table(title="Action Items", show_header=True)
        table.add_column("Issue", style="red")
        table.add_column("Fix")
        for name, fix in failed:
            table.add_row(name, fix)

        console.print(
            Panel(
                f"[bold yellow]⚠ {passed}/{total} checks passed. {len(failed)} need attention.[/bold yellow]",
                title="Health Check",
                style="yellow",
            )
        )
        console.print(table)
