"""Tests for Claude Code hook generation from verification config."""

from praxis_cli.utils.sync import _build_claude_hooks


def test_no_hooks_when_nothing_enabled():
    cfg = {
        "verification": {
            "formatter": {"enabled": False},
            "linter": {"enabled": False},
        }
    }
    result = _build_claude_hooks(cfg)
    assert result == {}


def test_no_hooks_when_verification_missing():
    cfg = {}
    result = _build_claude_hooks(cfg)
    assert result == {}


def test_hooks_for_enabled_formatter():
    cfg = {
        "verification": {
            "formatter": {"enabled": True, "tool": "prettier", "command": "npx prettier --write ."},
            "linter": {"enabled": False},
        }
    }
    result = _build_claude_hooks(cfg)
    assert "hooks" in result
    assert "PostToolUse" in result["hooks"]
    groups = result["hooks"]["PostToolUse"]
    assert len(groups) == 1
    assert groups[0]["matcher"] == "Edit|Write"
    assert len(groups[0]["hooks"]) == 1
    assert groups[0]["hooks"][0]["command"] == "npx prettier --write ."


def test_hooks_for_multiple_checks():
    cfg = {
        "verification": {
            "formatter": {"enabled": True, "tool": "black", "command": "black ."},
            "linter": {"enabled": True, "tool": "ruff", "command": "ruff check ."},
            "type_checker": {"enabled": True, "tool": "mypy", "command": "mypy src/"},
            "security_scanner": {"enabled": False},
        }
    }
    result = _build_claude_hooks(cfg)
    hooks = result["hooks"]["PostToolUse"][0]["hooks"]
    assert len(hooks) == 3
    commands = [h["command"] for h in hooks]
    assert "black ." in commands
    assert "ruff check ." in commands
    assert "mypy src/" in commands


def test_tests_excluded_from_hooks():
    """Tests are too slow for per-edit hooks — they should be excluded."""
    cfg = {
        "verification": {
            "formatter": {"enabled": True, "tool": "black", "command": "black ."},
            "tests": {"enabled": True, "runner": "pytest", "command": "pytest"},
        }
    }
    result = _build_claude_hooks(cfg)
    hooks = result["hooks"]["PostToolUse"][0]["hooks"]
    commands = [h["command"] for h in hooks]
    assert "black ." in commands
    assert "pytest" not in commands


def test_skips_enabled_but_no_command():
    cfg = {
        "verification": {
            "formatter": {"enabled": True, "tool": "prettier", "command": None},
            "linter": {"enabled": True, "tool": "ruff", "command": "ruff check ."},
        }
    }
    result = _build_claude_hooks(cfg)
    hooks = result["hooks"]["PostToolUse"][0]["hooks"]
    assert len(hooks) == 1
    assert hooks[0]["command"] == "ruff check ."


def test_hook_timeout():
    cfg = {
        "verification": {
            "formatter": {"enabled": True, "tool": "black", "command": "black ."},
        }
    }
    result = _build_claude_hooks(cfg)
    hook = result["hooks"]["PostToolUse"][0]["hooks"][0]
    assert hook["timeout"] == 30


def test_hook_label_uses_tool_field():
    cfg = {
        "verification": {
            "formatter": {"enabled": True, "tool": "prettier", "command": "npx prettier --write ."},
            "linter": {"enabled": True, "command": "ruff check ."},
        }
    }
    result = _build_claude_hooks(cfg)
    hooks = result["hooks"]["PostToolUse"][0]["hooks"]
    labels = {h["label"] for h in hooks}
    assert "prettier" in labels
    assert "linter" in labels
