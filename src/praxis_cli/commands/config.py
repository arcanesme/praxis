"""praxis config — set global preferences and sync to tool configs."""

import click
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

from praxis_cli.utils.config import (
    load_config,
    save_config,
    ensure_config_dir,
    CONFIG_FILE,
)
from praxis_cli.utils.sync import sync_global_claude

console = Console()


@click.command()
@click.option("--show", is_flag=True, help="Show current configuration.")
@click.option(
    "--reset", is_flag=True, help="Reset to default configuration."
)
@click.option("--set", "set_values", multiple=True, help="Set a config value: key=value")
@click.option(
    "--sync", "do_sync", is_flag=True, help="Sync config to global tool files (~/.claude/CLAUDE.md, etc)."
)
def config(show: bool, reset: bool, set_values: tuple, do_sync: bool):
    """Manage global PRAXIS preferences.

    Config lives at ~/.praxis/config.toml and syncs to tool-specific
    instruction files across all AI coding tools.

    \b
    Examples:
      praxis config --show
      praxis config --set global.always_ask_questions=true
      praxis config --sync
      praxis config --reset
    """
    # Default action: interactive setup if no flags
    if not show and not reset and not set_values and not do_sync:
        _interactive_config()
        return

    if show:
        _show_config()
        return

    if reset:
        from praxis_cli.utils.config import DEFAULT_CONFIG

        save_config(DEFAULT_CONFIG.copy())
        console.print("[green]✅ Config reset to defaults.[/green]")
        console.print(f"   {CONFIG_FILE}")
        return

    if set_values:
        cfg = load_config()
        for kv in set_values:
            if "=" not in kv:
                console.print(f"[red]❌ Invalid format: {kv}[/red] (use key=value)")
                continue
            key, value = kv.split("=", 1)
            # Parse booleans
            if value.lower() in ("true", "yes", "1"):
                value = True
            elif value.lower() in ("false", "no", "0"):
                value = False

            parts = key.split(".")
            current = cfg
            for part in parts[:-1]:
                if part not in current:
                    current[part] = {}
                current = current[part]
            current[parts[-1]] = value
            console.print(f"  ✅ {key} = {value}")
        save_config(cfg)
        console.print(f"\n   Saved to {CONFIG_FILE}")
        return

    if do_sync:
        _sync_global()
        return


def _show_config():
    """Display current configuration."""
    cfg = load_config()

    table = Table(title="PRAXIS Global Config", show_header=True)
    table.add_column("Setting", style="bold")
    table.add_column("Value")

    def flatten(d: dict, prefix: str = ""):
        for k, v in d.items():
            full_key = f"{prefix}.{k}" if prefix else k
            if isinstance(v, dict):
                flatten(v, full_key)
            else:
                style = "green" if v is True else "red" if v is False else ""
                table.add_row(full_key, str(v), style=style)

    flatten(cfg)
    console.print(table)
    console.print(f"\n[dim]Config file: {CONFIG_FILE}[/dim]")


def _interactive_config():
    """Walk through config interactively."""
    console.print(Panel("🏛  PRAXIS Config", style="bold blue"))
    console.print()

    cfg = load_config()

    # Global behavior
    console.print("[bold]Global Behavior[/bold]")
    cfg["global"]["always_ask_questions"] = click.confirm(
        "  Always ask clarifying questions before building?",
        default=cfg.get("global", {}).get("always_ask_questions", True),
    )
    cfg["global"]["include_recommendations"] = click.confirm(
        "  Include recommendations in every set of options?",
        default=cfg.get("global", {}).get("include_recommendations", True),
    )

    console.print()

    # Tool enablement
    console.print("[bold]AI Tools[/bold]")
    cfg["tools"]["claude_code"] = click.confirm(
        "  Enable Claude Code?",
        default=cfg.get("tools", {}).get("claude_code", True),
    )
    cfg["tools"]["openai_codex"] = click.confirm(
        "  Enable OpenAI Codex?",
        default=cfg.get("tools", {}).get("openai_codex", True),
    )

    console.print()

    # Defaults
    console.print("[bold]Defaults[/bold]")
    cfg["defaults"]["phase_gate"] = click.confirm(
        "  Stop at phase boundaries for review?",
        default=cfg.get("defaults", {}).get("phase_gate", True),
    )

    console.print()

    # Save
    save_config(cfg)
    console.print(f"[green]✅ Config saved to {CONFIG_FILE}[/green]")

    # Sync
    if click.confirm("\nSync to global tool configs now?", default=True):
        _sync_global()


def _sync_global():
    """Sync config to global tool instruction files."""
    console.print("[bold]Syncing global configs...[/bold]")

    cfg = load_config()

    if cfg.get("tools", {}).get("claude_code", True):
        path = sync_global_claude()
        console.print(f"  ✅ {path}")

    # Future: sync to ~/.codex/ when it supports global configs

    console.print("[green]✅ Global sync complete.[/green]")
