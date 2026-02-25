"""Sync PRAXIS config to tool-specific instruction files."""

import json
import shutil
from pathlib import Path

from praxis_cli.utils.config import load_config


def sync_claude_code(root: Path) -> list[str]:
    """Generate CLAUDE.md and .claude/commands/ for Claude Code."""
    generated = []
    cfg = load_config()

    # CLAUDE.md
    rules = []
    if cfg.get("global", {}).get("always_ask_questions", True):
        rules.append(
            "- Always ask clarifying questions before building specs, plans, or deliverables. Never assume."
        )
    if cfg.get("global", {}).get("include_recommendations", True):
        rules.append("- Include a recommendation in every set of options presented.")

    commands_list = [
        "/setup", "/new-track", "/implement", "/review", "/status",
        "/verify", "/commit-push-pr", "/simplify", "/sync-context", "/deploy-preview",
    ]

    claude_md = "# Project Instructions\n\n"
    claude_md += "Read and follow the PRAXIS Protocol defined in PRAXIS.md.\n"
    claude_md += "All specs, plans, and context live in the praxis/ directory.\n\n"
    claude_md += "## PRAXIS Commands\n"
    for cmd in commands_list:
        claude_md += f"- {cmd}\n"
    claude_md += "\n## Global Rules\n"
    claude_md += "- Never write code without an approved spec and plan.\n"
    claude_md += "- Stop at phase checkpoints for human review.\n"
    claude_md += "- Run verify at every checkpoint and before PRs.\n"
    claude_md += "- Read praxis/context/ before starting any task.\n"
    for rule in rules:
        claude_md += f"{rule}\n"

    (root / "CLAUDE.md").write_text(claude_md)
    generated.append("CLAUDE.md")

    # .claude/commands/
    commands_src = root / "praxis" / "commands"
    commands_dst = root / ".claude" / "commands"
    if commands_src.exists():
        commands_dst.mkdir(parents=True, exist_ok=True)
        for cmd_file in commands_src.glob("*.md"):
            shutil.copy2(cmd_file, commands_dst / cmd_file.name)
        generated.append(".claude/commands/")

    # .claude/settings.json hooks (verification automation)
    settings_path = root / ".claude" / "settings.json"
    settings_path.parent.mkdir(parents=True, exist_ok=True)
    settings = {
        "hooks": {
            "PostToolUse": [
                {
                    "matcher": "Write|Edit|MultiEdit",
                    "hooks": [
                        {
                            "type": "command",
                            "command": "praxis verify --mode quick",
                        }
                    ],
                }
            ],
            "Stop": [
                {
                    "hooks": [
                        {
                            "type": "command",
                            "command": "praxis verify --mode full",
                        }
                    ]
                }
            ],
        }
    }
    settings_path.write_text(json.dumps(settings, indent=2) + "\n")
    generated.append(".claude/settings.json")

    return generated


def sync_openai_codex(root: Path) -> list[str]:
    """Generate AGENTS.md for OpenAI Codex."""
    cfg = load_config()
    generated = []

    rules = []
    if cfg.get("global", {}).get("always_ask_questions", True):
        rules.append(
            "- Always ask clarifying questions before building specs, plans, or deliverables. Never assume."
        )
    if cfg.get("global", {}).get("include_recommendations", True):
        rules.append("- Include a recommendation in every set of options presented.")

    command_map = {
        "praxis setup": "praxis/commands/setup.md",
        "praxis new-track": "praxis/commands/new-track.md",
        "praxis implement": "praxis/commands/implement.md",
        "praxis review": "praxis/commands/review.md",
        "praxis status": "praxis/commands/status.md",
        "praxis verify": "praxis/commands/verify.md",
        'praxis commit" or "praxis pr': "praxis/commands/commit-push-pr.md",
        "praxis simplify": "praxis/commands/simplify.md",
        "praxis sync": "praxis/commands/sync-context.md",
        "praxis deploy": "praxis/commands/deploy-preview.md",
    }

    agents_md = "# Project Instructions\n\n"
    agents_md += "Read and follow the PRAXIS Protocol defined in PRAXIS.md.\n"
    agents_md += "All specs, plans, and context live in the praxis/ directory.\n\n"
    agents_md += "## PRAXIS Commands\n"
    agents_md += "When I say one of the following, read the corresponding file and follow it exactly:\n\n"
    for trigger, path in command_map.items():
        agents_md += f'- "{trigger}" → {path}\n'
    agents_md += "\n## Global Rules\n"
    agents_md += "- Never write code without an approved spec and plan.\n"
    agents_md += "- Stop at phase checkpoints for human review.\n"
    agents_md += "- Run verify at every checkpoint and before PRs.\n"
    agents_md += "- Read praxis/context/ before starting any task.\n"
    for rule in rules:
        agents_md += f"{rule}\n"
    agents_md += "\n## PR Review Role\n"
    agents_md += "When triggered by a GitHub Action on a PR, act as a code reviewer:\n"
    agents_md += "1. Read PRAXIS.md and praxis/context/ for project standards\n"
    agents_md += "2. Read praxis/verification.md for check requirements\n"
    agents_md += "3. If the PR references a PRAXIS track, read the track's spec.md\n"
    agents_md += "4. Review for: spec compliance, guideline adherence, security, code quality\n"
    agents_md += "5. Post review comments with actionable feedback\n"

    (root / "AGENTS.md").write_text(agents_md)
    generated.append("AGENTS.md")

    return generated


def sync_github_action(root: Path) -> list[str]:
    """Generate GitHub Action for Codex PR reviews."""
    generated = []

    workflows_dir = root / ".github" / "workflows"
    workflows_dir.mkdir(parents=True, exist_ok=True)

    action_yml = """name: PRAXIS PR Review (Codex)

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  codex-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run Codex PR Review
        uses: openai/codex-github-action@v1
        with:
          openai_api_key: ${{ secrets.OPENAI_API_KEY }}
          model: "codex-5.3"
          instructions: |
            You are a code reviewer following the PRAXIS protocol.
            Read PRAXIS.md and praxis/context/ for project standards.
            Read praxis/verification.md for check requirements.
            If the PR description references a PRAXIS track, read the track's spec.md and plan.md.

            Review for:
            1. Spec compliance
            2. Guideline adherence (praxis/context/guidelines.md)
            3. Security — hardcoded secrets, unsafe inputs, PII exposure
            4. Code quality — complexity, duplication, naming, dead code
            5. Simplification opportunities

            Post actionable review comments. Be specific about file and line.
            End with an overall assessment: APPROVE, REQUEST_CHANGES, or COMMENT.
"""

    (workflows_dir / "praxis-pr-review.yml").write_text(action_yml)
    generated.append(".github/workflows/praxis-pr-review.yml")

    return generated


def sync_global_claude() -> Path:
    """Generate global ~/.claude/CLAUDE.md from PRAXIS config."""
    cfg = load_config()
    claude_dir = Path.home() / ".claude"
    claude_dir.mkdir(parents=True, exist_ok=True)

    rules = ["## Requirements Gathering"]
    if cfg.get("global", {}).get("always_ask_questions", True):
        rules.append(
            "Always ask clarifying questions before building specs, plans, deliverables, or any non-trivial output."
        )
        rules.append("Never assume scope, format, audience, or priorities — gather requirements first.")
    if cfg.get("global", {}).get("include_recommendations", True):
        rules.append("Present options as structured choices when the decision is bounded (2-4 options).")
        rules.append("Always include a recommendation in each option presented.")
    rules.append("Use open-ended questions only when the answer is truly freeform.")

    content = "# Global Rules\n\n"
    content += "\n".join(rules)
    content += "\n\n## PRAXIS Protocol\n"
    content += "If a project contains a PRAXIS.md file, read and follow it.\n"
    content += "All praxis commands are defined in praxis/commands/ — read the corresponding file when invoked.\n"

    output = claude_dir / "CLAUDE.md"
    output.write_text(content)
    return output


def sync_all(root: Path) -> dict[str, list[str]]:
    """Sync all tool-specific files."""
    cfg = load_config()
    results = {}

    if cfg.get("tools", {}).get("claude_code", True):
        results["Claude Code"] = sync_claude_code(root)
    if cfg.get("tools", {}).get("openai_codex", True):
        results["OpenAI Codex"] = sync_openai_codex(root)

    results["GitHub Action"] = sync_github_action(root)

    return results
