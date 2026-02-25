"""praxis verify — run configured verification checks."""

import shutil
import subprocess
from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel

from praxis_cli.constants import CHECK_LABELS, QUICK_CHECKS
from praxis_cli.utils.config import load_config
from praxis_cli.utils.project import find_project_root

console = Console()


@click.command()
@click.option("--full", is_flag=True, help="Run all enabled checks (default: quick mode).")
@click.option("--check", "check_name", type=str, default=None,
              help="Run a single check (formatter, linter, type_checker, security_scanner, tests).")
def verify(full: bool, check_name: str | None):
    """Run verification checks configured in ~/.praxis/config.toml.

    Quick mode (default): formatter + linter only.
    Full mode (--full): all enabled checks including type checker, security, tests.

    \b
    Examples:
      praxis verify              # quick mode
      praxis verify --full       # all checks
      praxis verify --check linter
    """
    root = find_project_root()
    if root is None:
        console.print("[red]Not in a PRAXIS project.[/red] Run 'praxis init' first.")
        raise SystemExit(1)

    cfg = load_config()
    verification = cfg.get("verification", {})

    # Determine mode
    if full:
        mode = "full"
    elif check_name:
        mode = "single"
    else:
        mode = "quick"

    console.print(Panel(f"🏛  PRAXIS Verify — {mode} mode", style="bold blue"))
    console.print()

    # Determine which checks to run
    if check_name:
        if check_name not in verification:
            console.print(f"[red]Unknown check: {check_name}[/red]")
            console.print(f"Available: {', '.join(CHECK_LABELS.keys())}")
            raise SystemExit(1)
        checks_to_run = {check_name: verification.get(check_name, {})}
    elif mode == "full":
        checks_to_run = verification
    else:
        checks_to_run = {k: verification.get(k, {}) for k in QUICK_CHECKS}

    results = []
    for name, check_cfg in checks_to_run.items():
        if not isinstance(check_cfg, dict):
            continue

        label = CHECK_LABELS.get(name, name)
        enabled = check_cfg.get("enabled", False)
        command = check_cfg.get("command")

        if not enabled or not command:
            _print_result(label, "SKIP")
            results.append((label, "skip"))
            continue

        # Check tool binary exists
        tool_bin = command.split()[0]
        if not shutil.which(tool_bin):
            _print_result(label, "MISSING", f"{tool_bin} not found in PATH")
            results.append((label, "fail"))
            continue

        _print_running(label, command)
        try:
            result = subprocess.run(
                command, shell=True, cwd=root,
                capture_output=True, text=True, timeout=300,
            )
            if result.returncode == 0:
                _print_result(label, "PASS")
                results.append((label, "pass"))
            else:
                output = (result.stdout + result.stderr).strip()
                if len(output) > 500:
                    output = output[:500] + "\n... (truncated)"
                _print_result(label, "FAIL", output)
                results.append((label, "fail"))
        except subprocess.TimeoutExpired:
            _print_result(label, "FAIL", "Command timed out after 300s")
            results.append((label, "fail"))

    # Summary
    console.print()
    passed = sum(1 for _, s in results if s == "pass")
    failed = sum(1 for _, s in results if s == "fail")
    skipped = sum(1 for _, s in results if s == "skip")

    if failed == 0 and passed > 0:
        console.print(
            Panel(
                f"[bold green]✅ All passed[/bold green] ({passed} passed, {skipped} skipped)",
                title="Result", style="green",
            )
        )
    elif failed > 0:
        console.print(
            Panel(
                f"[bold red]❌ {failed} failed[/bold red], {passed} passed, {skipped} skipped",
                title="Result", style="red",
            )
        )
        raise SystemExit(1)
    else:
        console.print(
            Panel(
                "[bold yellow]⚠ No checks ran.[/bold yellow]\n"
                "Configure verification tools: praxis config",
                title="Result", style="yellow",
            )
        )


def _print_running(label: str, command: str):
    """Print a running check."""
    console.print(f"  ⏳ {label}: [dim]{command}[/dim]")


def _print_result(label: str, status: str, detail: str = ""):
    """Print a single check result."""
    icons = {
        "PASS": "✅",
        "FAIL": "❌",
        "SKIP": "⏭",
        "MISSING": "⚠",
    }
    icon = icons.get(status, "?")
    console.print(f"  {icon} {label}: {status}")
    if detail:
        for line in detail.split("\n")[:10]:
            console.print(f"     [dim]{line}[/dim]")
