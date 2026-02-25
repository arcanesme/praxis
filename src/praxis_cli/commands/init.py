"""praxis init — scaffold PRAXIS protocol into the current project."""

import importlib.resources
import shutil
from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel

from praxis_cli.utils.config import load_config
from praxis_cli.utils.sync import sync_all

console = Console()


def get_template(name: str) -> str:
    """Read an embedded template file."""
    templates = importlib.resources.files("praxis_cli") / "templates"
    return (templates / name).read_text(encoding="utf-8")


@click.command()
@click.option(
    "--force", is_flag=True, help="Overwrite existing PRAXIS files if they exist."
)
@click.option(
    "--skip-bootstrap",
    is_flag=True,
    help="Scaffold files only, skip generating tool-specific configs.",
)
def init(force: bool, skip_bootstrap: bool):
    """Initialize PRAXIS protocol in the current project.

    Creates PRAXIS.md, praxis/ directory with commands and verification config,
    then generates tool-specific files (CLAUDE.md, AGENTS.md).
    """
    root = Path.cwd()

    # Check for existing
    if (root / "PRAXIS.md").exists() and not force:
        console.print(
            "[yellow]⚠ PRAXIS.md already exists.[/yellow] Use --force to overwrite."
        )
        raise SystemExit(1)

    console.print(Panel("🏛  PRAXIS Init", style="bold blue"))
    console.print()

    # Create directory structure
    dirs = [
        root / "praxis" / "commands",
        root / "praxis" / "context",
        root / "praxis" / "tracks",
    ]
    for d in dirs:
        d.mkdir(parents=True, exist_ok=True)
        console.print(f"  📁 {d.relative_to(root)}/")

    # Write gitkeep
    gitkeep = root / "praxis" / "tracks" / ".gitkeep"
    gitkeep.touch()

    # Write PRAXIS.md
    praxis_md = get_template("PRAXIS.md")
    (root / "PRAXIS.md").write_text(praxis_md)
    console.print("  📄 PRAXIS.md")

    # Write verification.md
    verification_md = get_template("verification.md")
    (root / "praxis" / "verification.md").write_text(verification_md)
    console.print("  📄 praxis/verification.md")

    # Write command files
    templates = importlib.resources.files("praxis_cli") / "templates" / "commands"
    for cmd_template in sorted(templates.iterdir()):
        if cmd_template.name.endswith(".md"):
            content = cmd_template.read_text(encoding="utf-8")
            dest = root / "praxis" / "commands" / cmd_template.name
            dest.write_text(content)
            console.print(f"  📄 praxis/commands/{cmd_template.name}")

    console.print()

    # Bootstrap tool-specific files
    if not skip_bootstrap:
        console.print("[bold]Generating tool-specific files...[/bold]")
        results = sync_all(root)
        for tool, files in results.items():
            for f in files:
                console.print(f"  ✅ {f} [dim]({tool})[/dim]")
        console.print()

    # Summary
    console.print(
        Panel(
            "[bold green]✅ PRAXIS initialized.[/bold green]\n\n"
            "Next steps:\n"
            "  1. Run [bold]praxis config[/bold] to set global preferences\n"
            "  2. Run [bold]praxis doctor[/bold] to validate setup\n"
            "  3. Open your AI tool and run [bold]setup[/bold] to configure project context",
            title="Done",
            style="green",
        )
    )
