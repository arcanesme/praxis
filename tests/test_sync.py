"""Tests for sync functions."""

import json
from pathlib import Path
from unittest.mock import patch

from praxis_cli.utils.sync import sync_claude_code


def _make_project(tmp_path: Path):
    """Set up a minimal PRAXIS project structure."""
    (tmp_path / "PRAXIS.md").touch()
    (tmp_path / "praxis" / "commands").mkdir(parents=True)
    (tmp_path / "praxis" / "commands" / "setup.md").write_text("# Setup")


@patch("praxis_cli.utils.sync.load_config")
def test_generates_claude_md(mock_config, tmp_path):
    mock_config.return_value = {
        "global": {"always_ask_questions": True, "include_recommendations": True},
        "defaults": {"phase_gate": True},
        "verification": {},
    }
    _make_project(tmp_path)
    generated = sync_claude_code(tmp_path)
    assert "CLAUDE.md" in generated
    content = (tmp_path / "CLAUDE.md").read_text()
    assert "PRAXIS" in content
    assert "Stop at phase checkpoints" in content


@patch("praxis_cli.utils.sync.load_config")
def test_phase_gate_disabled(mock_config, tmp_path):
    mock_config.return_value = {
        "global": {"always_ask_questions": False, "include_recommendations": False},
        "defaults": {"phase_gate": False},
        "verification": {},
    }
    _make_project(tmp_path)
    sync_claude_code(tmp_path)
    content = (tmp_path / "CLAUDE.md").read_text()
    assert "informational" in content
    assert "Stop at phase checkpoints" not in content


@patch("praxis_cli.utils.sync.load_config")
def test_generates_settings_json_with_hooks(mock_config, tmp_path):
    mock_config.return_value = {
        "global": {"always_ask_questions": True, "include_recommendations": True},
        "defaults": {"phase_gate": True},
        "verification": {
            "formatter": {"enabled": True, "tool": "black", "command": "black ."},
            "linter": {"enabled": True, "tool": "ruff", "command": "ruff check ."},
        },
    }
    _make_project(tmp_path)
    generated = sync_claude_code(tmp_path)
    assert ".claude/settings.json" in generated

    settings = json.loads((tmp_path / ".claude" / "settings.json").read_text())
    assert "hooks" in settings
    assert "PostToolUse" in settings["hooks"]
    hooks = settings["hooks"]["PostToolUse"][0]["hooks"]
    commands = [h["command"] for h in hooks]
    assert "black ." in commands
    assert "ruff check ." in commands


@patch("praxis_cli.utils.sync.load_config")
def test_no_settings_json_when_nothing_enabled(mock_config, tmp_path):
    mock_config.return_value = {
        "global": {"always_ask_questions": True, "include_recommendations": True},
        "defaults": {"phase_gate": True},
        "verification": {
            "formatter": {"enabled": False},
        },
    }
    _make_project(tmp_path)
    generated = sync_claude_code(tmp_path)
    assert ".claude/settings.json" not in generated
    assert not (tmp_path / ".claude" / "settings.json").exists()


@patch("praxis_cli.utils.sync.load_config")
def test_merges_with_existing_settings(mock_config, tmp_path):
    mock_config.return_value = {
        "global": {"always_ask_questions": True, "include_recommendations": True},
        "defaults": {"phase_gate": True},
        "verification": {
            "formatter": {"enabled": True, "tool": "black", "command": "black ."},
        },
    }
    _make_project(tmp_path)

    # Pre-existing settings with custom keys
    settings_dir = tmp_path / ".claude"
    settings_dir.mkdir(parents=True, exist_ok=True)
    (settings_dir / "settings.json").write_text(json.dumps({
        "permissions": {"allow": ["Read"]},
        "custom_key": "preserved",
    }))

    sync_claude_code(tmp_path)

    settings = json.loads((tmp_path / ".claude" / "settings.json").read_text())
    # Custom keys preserved
    assert settings["custom_key"] == "preserved"
    assert settings["permissions"] == {"allow": ["Read"]}
    # Hooks added
    assert "hooks" in settings


@patch("praxis_cli.utils.sync.load_config")
def test_verification_hooks_section_in_claude_md(mock_config, tmp_path):
    mock_config.return_value = {
        "global": {"always_ask_questions": True, "include_recommendations": True},
        "defaults": {"phase_gate": True},
        "verification": {
            "formatter": {"enabled": True, "tool": "black", "command": "black ."},
        },
    }
    _make_project(tmp_path)
    sync_claude_code(tmp_path)
    content = (tmp_path / "CLAUDE.md").read_text()
    assert "Verification Hooks" in content
    assert "praxis verify --full" in content
