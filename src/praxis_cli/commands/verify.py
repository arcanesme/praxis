"""praxis verify — run project verification checks from praxis/verification.md."""

from __future__ import annotations

import re
import subprocess
from pathlib import Path

import click
from rich.console import Console
from rich.table import Table

from praxis_cli.utils.config import load_config

console = Console()

_MODE_TO_CHECKS = {
    "quick": {"formatter", "linter"},
    "full": {"formatter", "linter", "type_checker", "security", "tests", "custom_checks"},
    "pr": {"formatter", "linter", "type_checker", "security", "tests", "custom_checks"},
}


def _coerce_value(raw: str):
    value = raw.strip().strip('"').strip("'")
    lowered = value.lower()
    if lowered in {"true", "yes"}:
        return True
    if lowered in {"false", "no"}:
        return False
    if lowered in {"null", "none", ""}:
        return None
    return value


def _parse_verification_config(path: Path) -> dict[str, dict]:
    content = path.read_text(encoding="utf-8")
    checks: dict[str, dict] = {}

    pattern = re.compile(r"###\s+([^\n]+)\n```yaml\n(.*?)```", re.DOTALL)
    for heading, block in pattern.findall(content):
        key = heading.strip().lower().replace(" ", "_")
        parsed: dict[str, object] = {}
        if heading.strip().lower() == "custom checks":
            custom_checks: list[dict[str, str]] = []
            current_check: dict[str, str] | None = None
            for line in block.splitlines():
                stripped = line.strip()
                if not stripped or stripped.startswith("#"):
                    continue

                if stripped.startswith("- "):
                    if current_check and current_check.get("command"):
                        custom_checks.append(current_check)
                    current_check = {}
                    entry = stripped[2:].strip()
                    if entry and ":" in entry:
                        k, _, v = entry.partition(":")
                        parsed_value = _coerce_value(v)
                        if parsed_value is not None:
                            current_check[k.strip()] = str(parsed_value)
                    continue

                if current_check is not None and ":" in stripped:
                    k, _, v = stripped.partition(":")
                    parsed_value = _coerce_value(v)
                    if parsed_value is not None:
                        current_check[k.strip()] = str(parsed_value)

            if current_check and current_check.get("command"):
                custom_checks.append(current_check)

            parsed["checks"] = custom_checks
            checks[key] = parsed
            continue

        for line in block.splitlines():
            stripped = line.strip()
            if not stripped or stripped.startswith("#") or ":" not in stripped:
                continue
            k, _, v = stripped.partition(":")
            parsed[k.strip()] = _coerce_value(v)
        checks[key] = parsed

    return checks


def _normalize_check_name(name: str) -> str:
    mapping = {
        "security_scanner": "security",
        "type_checker": "type_checker",
        "custom_checks": "custom_checks",
    }
    return mapping.get(name, name)


def _collect_runnable_checks(checks: dict[str, dict], allowed_checks: set[str]) -> list[tuple[str, str]]:
    runnable: list[tuple[str, str]] = []
    for raw_name, check_cfg in checks.items():
        normalized = _normalize_check_name(raw_name)
        if normalized not in allowed_checks:
            continue

        if normalized == "custom_checks":
            for custom_check in check_cfg.get("checks", []):
                if not isinstance(custom_check, dict):
                    continue
                command = custom_check.get("command")
                if not command:
                    continue
                name = custom_check.get("name") or "custom_check"
                runnable.append((str(name), str(command)))
            continue

        if not check_cfg.get("enabled"):
            continue

        command = check_cfg.get("command")
        if command:
            runnable.append((normalized, str(command)))

    return runnable


@click.command()
@click.option(
    "--mode",
    type=click.Choice(["quick", "full", "pr"], case_sensitive=False),
    default=None,
    help="Verification mode. Defaults to global config (defaults.verification_mode) or quick.",
)
def verify(mode: str | None):
    """Run configured verification checks for the current project."""
    root = Path.cwd()
    verification_file = root / "praxis" / "verification.md"

    if not verification_file.exists():
        console.print("[red]✗ praxis/verification.md not found.[/red] Run: praxis init")
        raise SystemExit(1)

    cfg = load_config()
    effective_mode = (mode or cfg.get("defaults", {}).get("verification_mode", "quick")).lower()
    allowed_checks = _MODE_TO_CHECKS.get(effective_mode, _MODE_TO_CHECKS["quick"])

    checks = _parse_verification_config(verification_file)
    runnable = _collect_runnable_checks(checks, allowed_checks)

    if not runnable:
        console.print(f"[yellow]⚠ No enabled checks found for mode '{effective_mode}'.[/yellow]")
        return

    console.print(f"[bold]Running PRAXIS verification ({effective_mode})[/bold]")
    results: list[tuple[str, str, int]] = []

    for name, command in runnable:
        console.print(f"\n[cyan]→ {name}[/cyan]: [dim]{command}[/dim]")
        proc = subprocess.run(command, shell=True)
        status = "PASS" if proc.returncode == 0 else "FAIL"
        results.append((name, command, proc.returncode))
        if proc.returncode == 0:
            console.print("[green]✓ Passed[/green]")
        else:
            console.print(f"[red]✗ Failed (exit {proc.returncode})[/red]")

    table = Table(title="Verification Summary")
    table.add_column("Check")
    table.add_column("Command")
    table.add_column("Result")
    for name, command, code in results:
        result = "[green]PASS[/green]" if code == 0 else f"[red]FAIL ({code})[/red]"
        table.add_row(name, command, result)

    console.print()
    console.print(table)

    failed = [r for r in results if r[2] != 0]
    if failed:
        raise SystemExit(1)


__all__ = ["verify"]
