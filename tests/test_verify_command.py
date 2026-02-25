"""Tests for praxis verify CLI command."""

from unittest.mock import patch

from click.testing import CliRunner

from praxis_cli.commands.verify import verify


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.is_praxis_project")
@patch("praxis_cli.commands.verify.load_config")
def test_quick_mode_runs_formatter_and_linter(mock_config, mock_is_praxis, mock_root, tmp_path):
    mock_root.return_value = tmp_path
    mock_is_praxis.return_value = True

    mock_config.return_value = {
        "defaults": {"verification_mode": "quick"},
        "verification": {
            "formatter": {"enabled": True, "tool": "echo", "command": "echo ok"},
            "linter": {"enabled": True, "tool": "echo", "command": "echo ok"},
            "type_checker": {"enabled": True, "tool": "echo", "command": "echo ok"},
        },
    }

    runner = CliRunner()
    result = runner.invoke(verify)
    assert result.exit_code == 0
    # Quick mode should run formatter and linter
    assert "Formatter" in result.output
    assert "Linter" in result.output
    # Type checker should NOT appear in quick mode
    assert "Type Check" not in result.output


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.is_praxis_project")
@patch("praxis_cli.commands.verify.load_config")
def test_full_mode_runs_all(mock_config, mock_is_praxis, mock_root, tmp_path):
    mock_root.return_value = tmp_path
    mock_is_praxis.return_value = True

    mock_config.return_value = {
        "defaults": {"verification_mode": "quick"},
        "verification": {
            "formatter": {"enabled": True, "tool": "echo", "command": "echo ok"},
            "linter": {"enabled": True, "tool": "echo", "command": "echo ok"},
            "type_checker": {"enabled": True, "tool": "echo", "command": "echo ok"},
        },
    }

    runner = CliRunner()
    result = runner.invoke(verify, ["--full"])
    assert result.exit_code == 0
    assert "Formatter" in result.output
    assert "Linter" in result.output
    assert "Type Check" in result.output


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.is_praxis_project")
@patch("praxis_cli.commands.verify.load_config")
def test_failing_command_exits_nonzero(mock_config, mock_is_praxis, mock_root, tmp_path):
    mock_root.return_value = tmp_path
    mock_is_praxis.return_value = True

    mock_config.return_value = {
        "defaults": {"verification_mode": "quick"},
        "verification": {
            "formatter": {"enabled": True, "tool": "false", "command": "false"},
            "linter": {"enabled": False},
        },
    }

    runner = CliRunner()
    result = runner.invoke(verify)
    assert result.exit_code == 1
    assert "FAIL" in result.output


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.is_praxis_project")
@patch("praxis_cli.commands.verify.load_config")
def test_no_checks_enabled(mock_config, mock_is_praxis, mock_root, tmp_path):
    mock_root.return_value = tmp_path
    mock_is_praxis.return_value = True

    mock_config.return_value = {
        "defaults": {"verification_mode": "quick"},
        "verification": {
            "formatter": {"enabled": False},
            "linter": {"enabled": False},
        },
    }

    runner = CliRunner()
    result = runner.invoke(verify)
    assert result.exit_code == 0
    assert "No checks ran" in result.output


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.is_praxis_project")
@patch("praxis_cli.commands.verify.load_config")
def test_single_check_missing_from_config_skips(mock_config, mock_is_praxis, mock_root, tmp_path):
    """--check <name> on a known check absent from config should SKIP, not error."""
    mock_root.return_value = tmp_path
    mock_is_praxis.return_value = True

    # Config has no 'tests' entry at all (fresh/default state)
    mock_config.return_value = {
        "defaults": {"verification_mode": "quick"},
        "verification": {},
    }

    runner = CliRunner()
    result = runner.invoke(verify, ["--check", "tests"])
    assert result.exit_code == 0
    assert "Tests" in result.output
    assert "SKIP" in result.output


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.is_praxis_project")
@patch("praxis_cli.commands.verify.load_config")
def test_single_check_unknown_name_errors(mock_config, mock_is_praxis, mock_root, tmp_path):
    """--check <name> with a name not in CHECK_LABELS should error."""
    mock_root.return_value = tmp_path
    mock_is_praxis.return_value = True

    mock_config.return_value = {
        "defaults": {"verification_mode": "quick"},
        "verification": {},
    }

    runner = CliRunner()
    result = runner.invoke(verify, ["--check", "notarealcheck"])
    assert result.exit_code == 1
    assert "Unknown check" in result.output


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.is_praxis_project")
@patch("praxis_cli.commands.verify.load_config")
def test_single_check_mode(mock_config, mock_is_praxis, mock_root, tmp_path):
    mock_root.return_value = tmp_path
    mock_is_praxis.return_value = True

    mock_config.return_value = {
        "defaults": {"verification_mode": "quick"},
        "verification": {
            "formatter": {"enabled": True, "tool": "echo", "command": "echo ok"},
            "linter": {"enabled": True, "tool": "echo", "command": "echo ok"},
        },
    }

    runner = CliRunner()
    result = runner.invoke(verify, ["--check", "linter"])
    assert result.exit_code == 0
    assert "Linter" in result.output
    # Formatter should NOT appear when using --check linter
    assert "Formatter" not in result.output
