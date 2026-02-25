"""Global config management for PRAXIS at ~/.praxis/config.toml."""

import sys
from pathlib import Path
from typing import Any

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

import tomli_w

PRAXIS_HOME = Path.home() / ".praxis"
CONFIG_FILE = PRAXIS_HOME / "config.toml"

DEFAULT_CONFIG: dict[str, Any] = {
    "global": {
        "always_ask_questions": True,
        "include_recommendations": True,
    },
    "tools": {
        "claude_code": True,
        "openai_codex": True,
    },
    "defaults": {
        "track_types": ["code", "architecture", "federal", "content"],
        "verification_mode": "quick",
        "phase_gate": True,
    },
    "verification": {
        "formatter": {"enabled": False, "tool": None, "command": None},
        "linter": {"enabled": False, "tool": None, "command": None},
        "type_checker": {"enabled": False, "tool": None, "command": None},
        "security_scanner": {"enabled": False, "tool": None, "command": None},
        "tests": {"enabled": False, "runner": None, "command": None, "coverage": False},
    },
}


def ensure_config_dir() -> Path:
    """Create ~/.praxis/ if it doesn't exist."""
    PRAXIS_HOME.mkdir(parents=True, exist_ok=True)
    return PRAXIS_HOME


def load_config() -> dict[str, Any]:
    """Load config from disk, or return defaults."""
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, "rb") as f:
            return tomllib.load(f)
    return DEFAULT_CONFIG.copy()


def save_config(cfg: dict[str, Any]) -> Path:
    """Write config to disk."""
    ensure_config_dir()
    with open(CONFIG_FILE, "wb") as f:
        tomli_w.dump(cfg, f)
    return CONFIG_FILE


def get_config_value(key: str) -> Any:
    """Get a dotted config key like 'global.always_ask_questions'."""
    cfg = load_config()
    parts = key.split(".")
    current = cfg
    for part in parts:
        if isinstance(current, dict) and part in current:
            current = current[part]
        else:
            return None
    return current


def set_config_value(key: str, value: Any) -> None:
    """Set a dotted config key."""
    cfg = load_config()
    parts = key.split(".")
    current = cfg
    for part in parts[:-1]:
        if part not in current:
            current[part] = {}
        current = current[part]
    current[parts[-1]] = value
    save_config(cfg)
