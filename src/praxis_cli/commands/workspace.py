"""praxis workspace — create and manage AI workspaces with system instructions, skills, and agents."""

import json
from datetime import date
from pathlib import Path

import click
from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.syntax import Syntax
from rich.prompt import Prompt, Confirm

from praxis_cli.utils.project import find_project_root, is_praxis_project

console = Console()


@click.group()
def workspace():
    """Create and manage AI workspaces with system instructions, skills, and agents."""
    pass


@workspace.command()
@click.option("--force", is_flag=True, help="Overwrite existing workspace config.")
def create(force: bool):
    """Interactively create a workspace with system instructions, skills, agents, and knowledge files.

    Generates everything needed for Claude.ai Projects, Claude Code,
    and OpenAI Codex — from a single interactive session.
    """
    root = find_project_root()
    if root is None:
        console.print("[red]❌ Not in a git repo or PRAXIS project.[/red]")
        raise SystemExit(1)

    ws_dir = root / "praxis" / "workspace"
    if ws_dir.exists() and not force:
        console.print(
            "[yellow]⚠ praxis/workspace/ already exists.[/yellow] Use --force to overwrite."
        )
        raise SystemExit(1)

    console.print(Panel("🏛  PRAXIS Workspace Creator", style="bold blue"))
    console.print()

    # ── Step 1: Project Context ────────────────────
    console.print("[bold]Step 1: Project Context[/bold]")
    console.print("[dim]Tell me about this workspace so I can tailor the system instructions.[/dim]")
    console.print()

    project_name = Prompt.ask("  Project name")
    project_purpose = Prompt.ask("  What does this project do? (1-2 sentences)")
    project_domain = Prompt.ask(
        "  Domain",
        choices=["code", "architecture", "federal", "content", "mixed"],
        default="mixed",
    )
    target_audience = Prompt.ask("  Who consumes the output? (e.g., developers, federal reviewers, readers)")
    key_constraints = Prompt.ask("  Key constraints or standards to follow (e.g., FedRAMP, Zero Trust, AP style)")

    console.print()

    # ── Step 2: AI Tool Behavior ───────────────────
    console.print("[bold]Step 2: AI Behavior Rules[/bold]")
    console.print("[dim]How should the AI behave in this workspace?[/dim]")
    console.print()

    always_ask = Confirm.ask("  Always ask clarifying questions before building?", default=True)
    include_recs = Confirm.ask("  Include recommendations in every set of options?", default=True)
    spec_before_code = Confirm.ask("  Require spec + plan before any implementation?", default=True)
    phase_gates = Confirm.ask("  Stop at phase boundaries for review?", default=True)
    tone = Prompt.ask(
        "  Communication tone",
        choices=["concise-technical", "detailed-explanatory", "formal-federal", "conversational"],
        default="concise-technical",
    )

    console.print()

    # ── Step 3: Skills ─────────────────────────────
    console.print("[bold]Step 3: Skills[/bold]")
    console.print("[dim]Skills are instruction files that tell the AI how to produce specific outputs.[/dim]")
    console.print()

    skills = []
    while True:
        add_skill = Confirm.ask(
            f"  Add a skill? ({len(skills)} added so far)",
            default=len(skills) == 0,
        )
        if not add_skill:
            break

        skill_name = Prompt.ask("    Skill name (e.g., azure-architecture, compliance-matrix)")
        skill_purpose = Prompt.ask("    What does this skill produce?")
        skill_triggers = Prompt.ask("    Trigger words (comma-separated, e.g., 'architecture, spec, diagram')")
        skill_output = Prompt.ask(
            "    Output format",
            choices=["markdown", "docx", "xlsx", "pptx", "code", "mixed"],
            default="markdown",
        )
        skill_instructions = Prompt.ask("    Key instructions for the AI (what rules to follow)")

        skills.append({
            "name": skill_name,
            "purpose": skill_purpose,
            "triggers": [t.strip() for t in skill_triggers.split(",")],
            "output_format": skill_output,
            "instructions": skill_instructions,
        })
        console.print(f"    [green]✅ Skill '{skill_name}' added.[/green]")
        console.print()

    console.print()

    # ── Step 4: Agents ─────────────────────────────
    console.print("[bold]Step 4: Agents / Subagents[/bold]")
    console.print("[dim]Agents are specialized roles the AI can assume (e.g., reviewer, simplifier, architect).[/dim]")
    console.print()

    agents = []
    # Suggest defaults based on domain
    default_agents = _suggest_agents(project_domain)
    if default_agents:
        console.print("  [dim]Suggested agents for your domain:[/dim]")
        for da in default_agents:
            console.print(f"    • {da['name']} — {da['purpose']}")
        console.print()
        use_defaults = Confirm.ask("  Add these suggested agents?", default=True)
        if use_defaults:
            agents.extend(default_agents)
            console.print(f"  [green]✅ {len(default_agents)} agents added.[/green]")
            console.print()

    while True:
        add_agent = Confirm.ask(
            f"  Add a custom agent? ({len(agents)} total so far)",
            default=False,
        )
        if not add_agent:
            break

        agent_name = Prompt.ask("    Agent name (e.g., security-reviewer, content-editor)")
        agent_purpose = Prompt.ask("    What does this agent do?")
        agent_role = Prompt.ask("    Role description (how should the AI behave as this agent?)")
        agent_trigger = Prompt.ask("    How to invoke (e.g., 'review security', 'simplify code')")

        agents.append({
            "name": agent_name,
            "purpose": agent_purpose,
            "role": agent_role,
            "trigger": agent_trigger,
        })
        console.print(f"    [green]✅ Agent '{agent_name}' added.[/green]")
        console.print()

    console.print()

    # ── Step 5: Knowledge Files ────────────────────
    console.print("[bold]Step 5: Knowledge Files[/bold]")
    console.print("[dim]Reference docs the AI should have access to in this workspace.[/dim]")
    console.print()

    knowledge_files = []
    while True:
        add_kf = Confirm.ask(
            f"  Add a knowledge file reference? ({len(knowledge_files)} added so far)",
            default=False,
        )
        if not add_kf:
            break

        kf_name = Prompt.ask("    File name or description (e.g., 'FedRAMP controls reference')")
        kf_path = Prompt.ask("    File path (relative to project root, or 'TBD' if not yet created)")
        kf_purpose = Prompt.ask("    How should the AI use this file?")

        knowledge_files.append({
            "name": kf_name,
            "path": kf_path,
            "purpose": kf_purpose,
        })
        console.print(f"    [green]✅ '{kf_name}' added.[/green]")
        console.print()

    console.print()

    # ── Step 6: Verification ───────────────────────
    console.print("[bold]Step 6: Verification[/bold]")
    console.print("[dim]What checks should run in this workspace?[/dim]")
    console.print()

    verification = {}
    for check_name, check_label, examples in [
        ("formatter", "Formatter", "prettier, black, gofmt"),
        ("linter", "Linter", "eslint, ruff, clippy"),
        ("type_checker", "Type checker", "tsc, mypy, pyright"),
        ("security", "Security scanner", "trivy, bandit, npm audit"),
        ("tests", "Test runner", "jest, pytest, go test"),
    ]:
        enabled = Confirm.ask(f"  Enable {check_label}?", default=False)
        if enabled:
            tool = Prompt.ask(f"    Which tool? ({examples})")
            command = Prompt.ask(f"    Command to run (e.g., 'npx eslint . --fix')")
            verification[check_name] = {
                "enabled": True,
                "tool": tool,
                "command": command,
            }
        else:
            verification[check_name] = {"enabled": False}

    console.print()

    # ── Generate Everything ────────────────────────
    console.print("[bold]Generating workspace...[/bold]")
    console.print()

    ws_dir.mkdir(parents=True, exist_ok=True)
    (ws_dir / "skills").mkdir(exist_ok=True)
    (ws_dir / "agents").mkdir(exist_ok=True)
    (ws_dir / "knowledge").mkdir(exist_ok=True)

    # Build context dict
    workspace_config = {
        "project_name": project_name,
        "project_purpose": project_purpose,
        "project_domain": project_domain,
        "target_audience": target_audience,
        "key_constraints": key_constraints,
        "behavior": {
            "always_ask_questions": always_ask,
            "include_recommendations": include_recs,
            "spec_before_code": spec_before_code,
            "phase_gates": phase_gates,
            "tone": tone,
        },
        "skills": [s["name"] for s in skills],
        "agents": [a["name"] for a in agents],
        "knowledge_files": [k["name"] for k in knowledge_files],
    }

    # workspace.md — config summary
    _write_workspace_config(ws_dir, workspace_config)
    console.print("  📄 praxis/workspace/workspace.md")

    # System instructions
    system_prompt = _generate_system_instructions(
        workspace_config, skills, agents, knowledge_files, verification
    )
    (ws_dir / "system-instructions.md").write_text(system_prompt)
    console.print("  📄 praxis/workspace/system-instructions.md")

    # Skills
    for skill in skills:
        _write_skill(ws_dir / "skills", skill)
        console.print(f"  📄 praxis/workspace/skills/{skill['name']}.md")

    # Agents
    for agent in agents:
        _write_agent(ws_dir / "agents", agent)
        console.print(f"  📄 praxis/workspace/agents/{agent['name']}.md")

    # Knowledge file placeholders
    for kf in knowledge_files:
        if kf["path"] == "TBD":
            placeholder = ws_dir / "knowledge" / f"{kf['name'].lower().replace(' ', '-')}.md"
            placeholder.write_text(
                f"# {kf['name']}\n\n"
                f"> Purpose: {kf['purpose']}\n\n"
                f"TODO: Add content here.\n"
            )
            console.print(f"  📄 praxis/workspace/knowledge/{placeholder.name}")

    # Verification config
    _write_verification(ws_dir, verification)
    console.print("  📄 praxis/workspace/verification.md")

    # Copyable system prompt block
    (ws_dir / "claude-project-prompt.txt").write_text(system_prompt)
    console.print("  📄 praxis/workspace/claude-project-prompt.txt")

    console.print()

    # ── Show copyable prompt ───────────────────────
    console.print(
        Panel(
            "[bold]Claude.ai Project Setup[/bold]\n\n"
            "Copy the contents of [bold]praxis/workspace/claude-project-prompt.txt[/bold]\n"
            "into your Claude.ai Project's system instructions.\n\n"
            "Upload any knowledge files from praxis/workspace/knowledge/ as project knowledge.",
            title="📋 Next: Create Claude.ai Project",
            style="cyan",
        )
    )

    # ── Summary ────────────────────────────────────
    table = Table(title="Workspace Summary", show_header=True)
    table.add_column("Component", style="bold")
    table.add_column("Count")
    table.add_column("Details")

    table.add_row("Skills", str(len(skills)), ", ".join(s["name"] for s in skills) or "None")
    table.add_row("Agents", str(len(agents)), ", ".join(a["name"] for a in agents) or "None")
    table.add_row("Knowledge Files", str(len(knowledge_files)), ", ".join(k["name"] for k in knowledge_files) or "None")

    enabled_checks = [k for k, v in verification.items() if v.get("enabled")]
    table.add_row("Verification", str(len(enabled_checks)), ", ".join(enabled_checks) or "None")

    console.print(table)

    console.print()
    console.print(
        Panel(
            "[bold green]✅ Workspace created.[/bold green]\n\n"
            "Files generated in praxis/workspace/\n\n"
            "Next steps:\n"
            "  1. Copy system-instructions.md into Claude.ai Project\n"
            "  2. Upload knowledge files to Claude.ai Project\n"
            "  3. Run [bold]praxis bootstrap[/bold] to sync tool configs\n"
            "  4. Run [bold]praxis doctor[/bold] to validate",
            title="Done",
            style="green",
        )
    )


@workspace.command(name="show")
def show():
    """Show the current workspace configuration."""
    root = find_project_root()
    if root is None:
        console.print("[red]❌ Not in a PRAXIS project.[/red]")
        raise SystemExit(1)

    ws_dir = root / "praxis" / "workspace"
    if not ws_dir.exists():
        console.print("[yellow]No workspace configured.[/yellow] Run: praxis workspace create")
        raise SystemExit(1)

    # Show workspace config
    config_file = ws_dir / "workspace.md"
    if config_file.exists():
        console.print(Panel(config_file.read_text(), title="Workspace Config", style="blue"))

    # List skills
    skills_dir = ws_dir / "skills"
    if skills_dir.exists():
        skill_files = list(skills_dir.glob("*.md"))
        if skill_files:
            console.print(f"\n[bold]Skills ({len(skill_files)})[/bold]")
            for sf in sorted(skill_files):
                console.print(f"  📄 {sf.name}")

    # List agents
    agents_dir = ws_dir / "agents"
    if agents_dir.exists():
        agent_files = list(agents_dir.glob("*.md"))
        if agent_files:
            console.print(f"\n[bold]Agents ({len(agent_files)})[/bold]")
            for af in sorted(agent_files):
                console.print(f"  📄 {af.name}")

    # List knowledge
    knowledge_dir = ws_dir / "knowledge"
    if knowledge_dir.exists():
        kf_files = list(knowledge_dir.glob("*.md"))
        if kf_files:
            console.print(f"\n[bold]Knowledge Files ({len(kf_files)})[/bold]")
            for kf in sorted(kf_files):
                console.print(f"  📄 {kf.name}")

    # Show system prompt path
    prompt_file = ws_dir / "claude-project-prompt.txt"
    if prompt_file.exists():
        console.print(f"\n[bold]System Prompt[/bold]")
        console.print(f"  📋 {prompt_file.relative_to(root)}")
        console.print(f"  [dim]Copy into Claude.ai Project system instructions[/dim]")


# ── Helper Functions ───────────────────────────────


def _suggest_agents(domain: str) -> list[dict]:
    """Suggest default agents based on project domain."""
    base = [
        {
            "name": "verifier",
            "purpose": "Run verification checks and report results",
            "role": "You are a QA agent. Run all checks from verification config. Report pass/fail with details. Never auto-fix — only report.",
            "trigger": "verify",
        },
        {
            "name": "simplifier",
            "purpose": "Refactor code for clarity without changing behavior",
            "role": "You are a refactoring agent. Simplify code for readability and maintainability. Never change external behavior. Follow project guidelines.",
            "trigger": "simplify",
        },
    ]

    domain_agents = {
        "code": [
            {
                "name": "code-reviewer",
                "purpose": "Review code for quality, security, and style",
                "role": "You are a senior code reviewer. Check for bugs, security issues, style violations, and complexity. Be specific about file and line. Suggest concrete fixes.",
                "trigger": "review code",
            },
        ],
        "architecture": [
            {
                "name": "architecture-reviewer",
                "purpose": "Review architecture decisions for soundness and compliance",
                "role": "You are a senior solutions architect. Review for scalability, security, compliance (FedRAMP, Zero Trust), and alignment with project constraints. Challenge assumptions constructively.",
                "trigger": "review architecture",
            },
        ],
        "federal": [
            {
                "name": "compliance-checker",
                "purpose": "Verify federal compliance requirements are met",
                "role": "You are a federal compliance specialist. Check all deliverables against applicable standards (FedRAMP, NIST, FAR/DFARS). Flag gaps with specific control references. Suggest remediation.",
                "trigger": "check compliance",
            },
            {
                "name": "proposal-reviewer",
                "purpose": "Review proposal sections for strength and compliance",
                "role": "You are an SSEB reviewer. Score proposal sections against Section M evaluation criteria. Identify weaknesses, missing proof points, and non-compliant language. Suggest specific improvements.",
                "trigger": "review proposal",
            },
        ],
        "content": [
            {
                "name": "content-editor",
                "purpose": "Edit content for clarity, voice, and audience fit",
                "role": "You are a technical editor. Check for clarity, consistency, voice alignment, and audience appropriateness. Suggest rewrites for weak sections. Flag jargon that doesn't serve the reader.",
                "trigger": "edit content",
            },
        ],
        "mixed": [],
    }

    return base + domain_agents.get(domain, [])


def _write_workspace_config(ws_dir: Path, config: dict):
    """Write workspace.md summary."""
    today = date.today().isoformat()
    content = f"""---
last_updated: {today}
---

# Workspace: {config['project_name']}

## Project
- **Purpose:** {config['project_purpose']}
- **Domain:** {config['project_domain']}
- **Audience:** {config['target_audience']}
- **Constraints:** {config['key_constraints']}

## Behavior
- Ask before building: {'Yes' if config['behavior']['always_ask_questions'] else 'No'}
- Include recommendations: {'Yes' if config['behavior']['include_recommendations'] else 'No'}
- Spec before code: {'Yes' if config['behavior']['spec_before_code'] else 'No'}
- Phase gates: {'Yes' if config['behavior']['phase_gates'] else 'No'}
- Tone: {config['behavior']['tone']}

## Components
- **Skills:** {', '.join(config['skills']) or 'None'}
- **Agents:** {', '.join(config['agents']) or 'None'}
- **Knowledge Files:** {', '.join(config['knowledge_files']) or 'None'}
"""
    (ws_dir / "workspace.md").write_text(content)


def _generate_system_instructions(
    config: dict,
    skills: list[dict],
    agents: list[dict],
    knowledge_files: list[dict],
    verification: dict,
) -> str:
    """Generate the full system instructions for Claude.ai Projects and other tools."""
    today = date.today().isoformat()

    tone_map = {
        "concise-technical": "Be concise and technical. Lead with the answer. Skip preamble.",
        "detailed-explanatory": "Be thorough and explanatory. Walk through reasoning. Include context.",
        "formal-federal": "Use formal, professional language appropriate for federal audiences. Follow government writing standards.",
        "conversational": "Be conversational and approachable. Use clear, everyday language.",
    }

    lines = []
    lines.append(f"# {config['project_name']}")
    lines.append("")
    lines.append(f"> {config['project_purpose']}")
    lines.append(f"> Generated by PRAXIS on {today}")
    lines.append("")

    # Core identity
    lines.append("## Role")
    lines.append(f"You are an AI assistant working on **{config['project_name']}**.")
    lines.append(f"Your audience is: {config['target_audience']}.")
    lines.append(f"Domain: {config['project_domain']}.")
    if config["key_constraints"]:
        lines.append(f"You must follow these constraints: {config['key_constraints']}.")
    lines.append("")

    # Behavior rules
    lines.append("## Rules")
    if config["behavior"]["always_ask_questions"]:
        lines.append("1. **Ask before building.** Always ask clarifying questions before generating specs, plans, or deliverables. Never assume scope, format, audience, or priorities.")
    if config["behavior"]["include_recommendations"]:
        lines.append("2. **Include recommendations.** When presenting options, always include a recommendation with reasoning.")
    if config["behavior"]["spec_before_code"]:
        lines.append("3. **Spec before code.** Never write code or content without an approved spec and plan.")
    if config["behavior"]["phase_gates"]:
        lines.append("4. **Phase gates.** Stop at phase boundaries for human review. Never skip checkpoints.")
    lines.append("5. **No scope creep.** If new scope emerges, suggest a new track. Never expand existing work.")
    lines.append("")

    # Tone
    lines.append("## Tone")
    lines.append(tone_map.get(config["behavior"]["tone"], tone_map["concise-technical"]))
    lines.append("")

    # PRAXIS protocol
    lines.append("## PRAXIS Protocol")
    lines.append("This project follows the PRAXIS protocol. Read PRAXIS.md for full rules.")
    lines.append("All work is organized into tracks in praxis/tracks/.")
    lines.append("Always read praxis/context/ before starting any task.")
    lines.append("")

    # Skills
    if skills:
        lines.append("## Skills")
        lines.append("The following skills are available. Use them when their trigger conditions are met.")
        lines.append("")
        for skill in skills:
            triggers = ", ".join(skill["triggers"])
            lines.append(f"### {skill['name']}")
            lines.append(f"- **Purpose:** {skill['purpose']}")
            lines.append(f"- **Triggers:** {triggers}")
            lines.append(f"- **Output:** {skill['output_format']}")
            lines.append(f"- **Instructions:** {skill['instructions']}")
            lines.append(f"- **Reference:** praxis/workspace/skills/{skill['name']}.md")
            lines.append("")

    # Agents
    if agents:
        lines.append("## Agents")
        lines.append("You can operate in the following specialized roles when invoked.")
        lines.append("")
        for agent in agents:
            lines.append(f"### {agent['name']}")
            lines.append(f"- **Purpose:** {agent['purpose']}")
            lines.append(f"- **Invoke with:** \"{agent['trigger']}\"")
            lines.append(f"- **Role:** {agent['role']}")
            lines.append(f"- **Reference:** praxis/workspace/agents/{agent['name']}.md")
            lines.append("")

    # Knowledge files
    if knowledge_files:
        lines.append("## Knowledge Files")
        lines.append("The following reference documents are available in this workspace.")
        lines.append("")
        for kf in knowledge_files:
            lines.append(f"- **{kf['name']}** ({kf['path']}): {kf['purpose']}")
        lines.append("")

    # Verification
    enabled = {k: v for k, v in verification.items() if v.get("enabled")}
    if enabled:
        lines.append("## Verification")
        lines.append("Run these checks at phase checkpoints and before completing tracks:")
        lines.append("")
        for name, cfg in enabled.items():
            lines.append(f"- **{name}:** `{cfg.get('command', 'N/A')}` ({cfg.get('tool', 'N/A')})")
        lines.append("")

    return "\n".join(lines)


def _write_skill(skills_dir: Path, skill: dict):
    """Write a SKILL.md file."""
    today = date.today().isoformat()
    triggers = ", ".join(skill["triggers"])
    content = f"""---
name: {skill['name']}
created: {today}
triggers: [{triggers}]
output_format: {skill['output_format']}
---

# Skill: {skill['name']}

## Purpose
{skill['purpose']}

## Triggers
Activate this skill when the user mentions: {triggers}

## Output Format
{skill['output_format']}

## Instructions
{skill['instructions']}

## Process
1. Read project context from praxis/context/ before starting
2. Ask clarifying questions if scope is ambiguous
3. Generate output following the instructions above
4. Present output for review before finalizing
"""
    (skills_dir / f"{skill['name']}.md").write_text(content)


def _write_agent(agents_dir: Path, agent: dict):
    """Write an agent .md file."""
    today = date.today().isoformat()
    content = f"""---
name: {agent['name']}
created: {today}
trigger: "{agent['trigger']}"
---

# Agent: {agent['name']}

## Purpose
{agent['purpose']}

## Role
{agent['role']}

## Invocation
Activate when the user says: "{agent['trigger']}"

## Behavior
- Read project context from praxis/context/ before acting
- Read praxis/workspace/workspace.md for workspace rules
- Stay in role for the duration of the task
- Report findings clearly with specific references (file, line, section)
- Never auto-fix unless explicitly asked — report and suggest
- Return to normal mode when the task is complete
"""
    (agents_dir / f"{agent['name']}.md").write_text(content)


def _write_verification(ws_dir: Path, verification: dict):
    """Write workspace-specific verification.md."""
    today = date.today().isoformat()
    lines = [
        f"---",
        f"last_updated: {today}",
        f"---",
        f"",
        f"# Workspace Verification Rules",
        f"",
    ]

    for name, cfg in verification.items():
        enabled = cfg.get("enabled", False)
        lines.append(f"## {name.replace('_', ' ').title()}")
        lines.append(f"- Enabled: {'Yes' if enabled else 'No'}")
        if enabled:
            lines.append(f"- Tool: {cfg.get('tool', 'N/A')}")
            lines.append(f"- Command: `{cfg.get('command', 'N/A')}`")
        lines.append("")

    (ws_dir / "verification.md").write_text("\n".join(lines))
