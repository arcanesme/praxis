"""Shared constants for the PRAXIS CLI."""

# Canonical command list — single source of truth.
# Used by sync (CLAUDE.md, AGENTS.md), doctor, and init.
COMMAND_FILES = [
    "setup.md",
    "new-track.md",
    "implement.md",
    "review.md",
    "status.md",
    "verify.md",
    "commit-push-pr.md",
    "simplify.md",
    "sync-context.md",
    "deploy-preview.md",
]

# Slash-command names (derived from file names)
SLASH_COMMANDS = [f"/{f.removesuffix('.md')}" for f in COMMAND_FILES]

# Verification check types and their display labels
CHECK_LABELS = {
    "formatter": "Formatter",
    "linter": "Linter",
    "type_checker": "Type Check",
    "security_scanner": "Security",
    "tests": "Tests",
}

QUICK_CHECKS = {"formatter", "linter"}


def build_global_rules(cfg: dict) -> list[str]:
    """Build global behaviour rules from config. Used by all sync targets."""
    rules = []
    if cfg.get("global", {}).get("always_ask_questions", True):
        rules.append(
            "- Always ask clarifying questions before building specs, plans, or deliverables. Never assume."
        )
    if cfg.get("global", {}).get("include_recommendations", True):
        rules.append(
            "- Include a recommendation in every set of options presented."
        )
    return rules
