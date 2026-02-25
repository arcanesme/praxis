"""Tests for praxis verify CLI command."""

from unittest.mock import patch

from click.testing import CliRunner

from praxis_cli.commands.verify import verify


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.load_config")
def test_quick_mode_runs_formatter_and_linter(mock_config, mock_root, tmp_path):
    mock_root.return_value = tmp_path

    mock_config.return_value = {
        "verification": {
            "formatter": {"enabled": True, "command": "echo ok"},
            "linter": {"enabled": True, "command": "echo ok"},
            "type_checker": {"enabled": True, "command": "echo ok"},
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
@patch("praxis_cli.commands.verify.load_config")
def test_full_mode_runs_all(mock_config, mock_root, tmp_path):
    mock_root.return_value = tmp_path

    mock_config.return_value = {
        "verification": {
            "formatter": {"enabled": True, "command": "echo ok"},
            "linter": {"enabled": True, "command": "echo ok"},
            "type_checker": {"enabled": True, "command": "echo ok"},
        },
    }

    runner = CliRunner()
    result = runner.invoke(verify, ["--full"])
    assert result.exit_code == 0
    assert "Formatter" in result.output
    assert "Linter" in result.output
    assert "Type Check" in result.output


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.load_config")
def test_failing_command_exits_nonzero(mock_config, mock_root, tmp_path):
    mock_root.return_value = tmp_path

    mock_config.return_value = {
        "verification": {
            "formatter": {"enabled": True, "command": "false"},
            "linter": {"enabled": False},
        },
    }

    runner = CliRunner()
    result = runner.invoke(verify)
    assert result.exit_code == 1
    assert "FAIL" in result.output


@patch("praxis_cli.commands.verify.find_project_root")
@patch("praxis_cli.commands.verify.load_config")
def test_no_checks_enabled(mock_config, mock_root, tmp_path):
    mock_root.return_value = tmp_path

    mock_config.return_value = {
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
@patch("praxis_cli.commands.verify.load_config")
def test_single_check_mode(mock_config, mock_root, tmp_path):
    mock_root.return_value = tmp_path

    mock_config.return_value = {
        "verification": {
            "formatter": {"enabled": True, "command": "echo ok"},
            "linter": {"enabled": True, "command": "echo ok"},
        },
    }

    runner = CliRunner()
    result = runner.invoke(verify, ["--check", "linter"])
    assert result.exit_code == 0
    assert "Linter" in result.output
    # Formatter should NOT appear when using --check linter
    assert "Formatter" not in result.output
