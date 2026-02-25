"""PRAXIS CLI entrypoint."""

import click
from rich.console import Console

from praxis_cli.commands.init import init
from praxis_cli.commands.config import config
from praxis_cli.commands.doctor import doctor
from praxis_cli.commands.bootstrap import bootstrap
from praxis_cli.commands.status import status
from praxis_cli.commands.workspace import workspace
from praxis_cli.commands.verify import verify

console = Console()


@click.group()
@click.version_option(package_name="praxis-cli")
def cli():
    """PRAXIS — Disciplined action protocol for AI-assisted development.

    Scaffolds, configures, and validates the PRAXIS protocol across any project
    and any AI coding tool (Claude Code, Gemini CLI, OpenAI Codex).
    """
    pass


cli.add_command(init)
cli.add_command(config)
cli.add_command(doctor)
cli.add_command(bootstrap)
cli.add_command(status)
cli.add_command(workspace)
cli.add_command(verify)


if __name__ == "__main__":
    cli()
