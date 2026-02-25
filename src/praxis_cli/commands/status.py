"""praxis status — show all tracks and progress with Rich formatting."""

from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

from praxis_cli.utils.project import find_project_root, is_praxis_project, list_tracks

console = Console()


@click.command()
def status():
    """Show all PRAXIS tracks and their current progress.

    Displays active and completed tracks with phase progress,
    task counts, and suggested next actions.
    """
    root = find_project_root()
    if root is None or not is_praxis_project():
        console.print("[red]❌ Not in a PRAXIS project.[/red] Run 'praxis init' first.")
        raise SystemExit(1)

    # Get project name from product.md if it exists
    product_file = root / "praxis" / "context" / "product.md"
    project_name = root.name
    if product_file.exists():
        for line in product_file.read_text().split("\n"):
            if line.startswith("# "):
                project_name = line[2:].strip()
                break

    tracks = list_tracks(root)

    if not tracks:
        console.print(
            Panel(
                "[dim]No tracks found.[/dim]\n\n"
                "Run the [bold]new-track[/bold] command in your AI tool to create one.",
                title=f"📋 PRAXIS STATUS — {project_name}",
                style="blue",
            )
        )
        return

    active = [t for t in tracks if t["status"] == "ACTIVE"]
    completed = [t for t in tracks if t["status"] == "COMPLETED"]
    other = [t for t in tracks if t["status"] not in ("ACTIVE", "COMPLETED")]

    total_tasks = sum(t["tasks_total"] for t in tracks)
    done_tasks = sum(t["tasks_done"] for t in tracks)
    pct = (done_tasks / total_tasks * 100) if total_tasks > 0 else 0

    console.print()
    console.print(f"[bold]📋 PRAXIS STATUS — {project_name}[/bold]")
    console.print("━" * 50)

    # Active tracks
    if active:
        console.print()
        console.print("[bold green]🟢 ACTIVE TRACKS[/bold green]")

        table = Table(show_header=True, header_style="bold", box=None, pad_edge=False)
        table.add_column("Track", style="bold")
        table.add_column("Type")
        table.add_column("Phase")
        table.add_column("Tasks")
        table.add_column("Progress")

        for t in active:
            phase_str = f"{t['current_phase']}/{t['total_phases']}" if t["total_phases"] > 0 else "—"
            task_str = f"{t['tasks_done']}/{t['tasks_total']}"
            task_pct = (
                t["tasks_done"] / t["tasks_total"] * 100 if t["tasks_total"] > 0 else 0
            )

            # Progress bar
            filled = int(task_pct / 5)
            bar = "█" * filled + "░" * (20 - filled)
            progress = f"{bar} {task_pct:.0f}%"

            table.add_row(t["name"], t["type"], phase_str, task_str, progress)

        console.print(table)

    # Completed tracks
    if completed:
        console.print()
        console.print("[bold]🏁 COMPLETED TRACKS[/bold]")

        table = Table(show_header=True, header_style="bold", box=None, pad_edge=False)
        table.add_column("Track", style="bold")
        table.add_column("Type")
        table.add_column("Tasks")
        table.add_column("Review")

        for t in completed:
            task_str = f"{t['tasks_done']}/{t['tasks_total']}"
            review = "✅" if t["has_review"] else "—"
            table.add_row(t["name"], t["type"], task_str, review)

        console.print(table)

    # Other (unknown status)
    if other:
        console.print()
        console.print("[bold yellow]❓ OTHER[/bold yellow]")
        for t in other:
            console.print(f"  {t['name']} [{t['type']}] — status: {t['status']}")

    # Summary
    console.print()
    console.print("━" * 50)
    console.print(
        f"[bold]📊 SUMMARY[/bold]  "
        f"Active: {len(active)}  "
        f"Completed: {len(completed)}  "
        f"Tasks: {done_tasks}/{total_tasks} ({pct:.0f}%)"
    )

    # Suggested next action
    console.print()
    if active:
        has_unchecked = any(t["tasks_done"] < t["tasks_total"] for t in active)
        has_fully_checked = any(
            t["tasks_done"] == t["tasks_total"] and t["tasks_total"] > 0 and not t["has_review"]
            for t in active
        )
        if has_fully_checked:
            console.print("[bold]💡 NEXT:[/bold] Run [bold]review[/bold] — active tracks are fully implemented")
        elif has_unchecked:
            console.print("[bold]💡 NEXT:[/bold] Run [bold]implement[/bold] — active tracks have pending tasks")
    else:
        console.print("[bold]💡 NEXT:[/bold] Run [bold]new-track[/bold] — no active tracks")
