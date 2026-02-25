"""Project detection and praxis file management."""

from pathlib import Path


def find_project_root(start: Path | None = None) -> Path | None:
    """Walk up from start (or cwd) looking for PRAXIS.md."""
    current = start or Path.cwd()
    for parent in [current, *current.parents]:
        if (parent / "PRAXIS.md").exists():
            return parent
        if parent == parent.parent:
            break
    return None


def get_praxis_dir(root: Path) -> Path:
    """Return the praxis/ directory for a project."""
    return root / "praxis"


def get_tracks_dir(root: Path) -> Path:
    """Return the praxis/tracks/ directory."""
    return root / "praxis" / "tracks"


def get_context_dir(root: Path) -> Path:
    """Return the praxis/context/ directory."""
    return root / "praxis" / "context"


def get_commands_dir(root: Path) -> Path:
    """Return the praxis/commands/ directory."""
    return root / "praxis" / "commands"


def list_tracks(root: Path) -> list[dict]:
    """List all tracks with their status."""
    tracks_dir = get_tracks_dir(root)
    if not tracks_dir.exists():
        return []

    tracks = []
    for track_dir in sorted(tracks_dir.iterdir()):
        if not track_dir.is_dir() or track_dir.name.startswith("."):
            continue

        spec_file = track_dir / "spec.md"
        plan_file = track_dir / "plan.md"
        review_file = track_dir / "review.md"

        track_info = {
            "name": track_dir.name,
            "path": track_dir,
            "has_spec": spec_file.exists(),
            "has_plan": plan_file.exists(),
            "has_review": review_file.exists(),
            "status": "UNKNOWN",
            "type": "unknown",
            "current_phase": 0,
            "total_phases": 0,
            "tasks_done": 0,
            "tasks_total": 0,
        }

        # Parse spec header
        if spec_file.exists():
            content = spec_file.read_text()
            for line in content.split("\n"):
                line = line.strip()
                if line.startswith("status:"):
                    track_info["status"] = line.split(":", 1)[1].strip()
                elif line.startswith("type:"):
                    track_info["type"] = line.split(":", 1)[1].strip()

        # Parse plan for progress
        if plan_file.exists():
            content = plan_file.read_text()
            for line in content.split("\n"):
                line = line.strip()
                if line.startswith("current_phase:"):
                    try:
                        track_info["current_phase"] = int(line.split(":", 1)[1].strip())
                    except ValueError:
                        pass
                elif line.startswith("total_phases:"):
                    try:
                        track_info["total_phases"] = int(line.split(":", 1)[1].strip())
                    except ValueError:
                        pass
                elif line.startswith("- [x]") or line.startswith("- [X]"):
                    track_info["tasks_done"] += 1
                    track_info["tasks_total"] += 1
                elif line.startswith("- [ ]"):
                    track_info["tasks_total"] += 1

        tracks.append(track_info)

    return tracks
