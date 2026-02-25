"""praxis bootstrap — regenerate tool-specific files from PRAXIS.md."""

from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel

from praxis_cli.utils.project import find_project_root, is_praxis_project
from praxis_cli.utils.sync import sync_all

console = Console()


@click.command()
@click.option("--claude", is_flag=True, help="Only regenerate Claude Code files.")
@click.option("--codex", is_flag=True, help="Only regenerate OpenAI Codex files.")
def bootstrap(claude: bool, codex: bool):
    """Regenerate tool-specific files from PRAXIS.md.

    Generates CLAUDE.md, AGENTS.md, .claude/commands/,
    and the GitHub Action from the current PRAXIS.md and global config.

    Run this after updating PRAXIS.md or praxis/commands/.
    """
    root = find_project_root()
    if root is None or not is_praxis_project():
        console.print("[red]❌ Not in a PRAXIS project.[/red] Run 'praxis init' first.")
        raise SystemExit(1)

    console.print(Panel("🏛  PRAXIS Bootstrap", style="bold blue"))
    console.print()

    # If specific flags, only sync those
    if claude or codex:
        from praxis_cli.utils.sync import (
            sync_claude_code,
            sync_openai_codex,
        )

        if claude:
            files = sync_claude_code(root)
            for f in files:
                console.print(f"  ✅ {f} [dim](Claude Code)[/dim]")
        if codex:
            files = sync_openai_codex(root)
            for f in files:
                console.print(f"  ✅ {f} [dim](OpenAI Codex)[/dim]")
    else:
        results = sync_all(root)
        for tool, files in results.items():
            for f in files:
                console.print(f"  ✅ {f} [dim]({tool})[/dim]")

    console.print()
    console.print("[green]✅ Bootstrap complete.[/green]")
