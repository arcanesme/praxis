"""praxis setup — guided walkthrough from zero to running."""

from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel

from praxis_cli.utils.config import CONFIG_FILE
from praxis_cli.commands.config import _interactive_config
from praxis_cli.commands.init import init as init_cmd
from praxis_cli.commands.doctor import doctor as doctor_cmd

console = Console()


@click.command()
@click.option("--force", is_flag=True, help="Re-run all steps even if already configured.")
@click.pass_context
def setup(ctx, force: bool):
    """Walk through PRAXIS setup from start to finish.

    Guides you through global config, project initialization, and
    validation in one flow. State-aware — skips steps already done.
    """
    console.print()
    console.print(
        Panel(
            "[bold]PRAXIS[/bold] — Disciplined action protocol for AI-assisted development.\n\n"
            "This walkthrough will guide you through:\n"
            "  [bold]1.[/bold] Global preferences (AI tools, behavior, verification)\n"
            "  [bold]2.[/bold] Project initialization (scaffold files and tool configs)\n"
            "  [bold]3.[/bold] Validation (check everything is wired up)\n"
            "  [bold]4.[/bold] Next steps (what to do in your AI tool)",
            title="Setup",
            style="bold blue",
        )
    )
    console.print()

    # ── Step 1: Global Config ───────────────────────
    console.print("[bold]Step 1 of 4: Global Config[/bold]")
    console.print("[dim]Preferences stored at ~/.praxis/config.toml[/dim]")
    console.print()

    if CONFIG_FILE.exists() and not force:
        console.print("  Global config already exists.")
        if click.confirm("  Reconfigure?", default=False):
            _interactive_config()
        else:
            console.print("  Skipping.")
    else:
        _interactive_config()

    console.print()

    # ── Step 2: Project Init ────────────────────────
    console.print("[bold]Step 2 of 4: Project Init[/bold]")
    console.print("[dim]Scaffolds PRAXIS.md, commands, and tool-specific files in this directory[/dim]")
    console.print()

    root = Path.cwd()
    git_dir = root / ".git"
    praxis_md = root / "PRAXIS.md"

    if not git_dir.exists():
        console.print("  [yellow]This directory is not a git repository.[/yellow]")
        console.print("  Run [bold]git init[/bold] first, then re-run [bold]praxis setup[/bold].")
        console.print()
        return

    if praxis_md.exists() and not force:
        console.print(f"  PRAXIS.md already exists in {root.name}/")
        if click.confirm("  Reinitialize? (overwrites existing files)", default=False):
            ctx.invoke(init_cmd, force=True, skip_bootstrap=False)
        else:
            console.print("  Skipping.")
    else:
        ctx.invoke(init_cmd, force=force, skip_bootstrap=False)

    console.print()

    # ── Step 3: Doctor ──────────────────────────────
    console.print("[bold]Step 3 of 4: Validation[/bold]")
    console.print("[dim]Checking that everything is wired up correctly[/dim]")
    console.print()

    ctx.invoke(doctor_cmd)

    console.print()

    # ── Step 4: Next Steps ──────────────────────────
    console.print(
        Panel(
            "[bold green]Setup complete![/bold green]\n\n"
            "What to do next:\n\n"
            "  [bold]1.[/bold] Open your AI tool (Claude Code, Codex) in this project\n"
            "  [bold]2.[/bold] Run the [bold]/setup[/bold] command to configure project context\n"
            "  [bold]3.[/bold] Create your first track: [bold]/new-track[/bold]\n\n"
            "Useful commands:\n"
            "  [bold]praxis status[/bold]    Show track progress\n"
            "  [bold]praxis verify[/bold]    Run verification checks\n"
            "  [bold]praxis doctor[/bold]    Re-validate setup\n"
            "  [bold]praxis config[/bold]    Update global preferences",
            title="Next Steps",
            style="green",
        )
    )
