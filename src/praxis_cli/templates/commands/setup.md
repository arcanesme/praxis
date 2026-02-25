Read PRAXIS.md first.

Initialize the praxis context for this project.

## Step 1: Gather Context
Ask about each of the following. Do them one at a time, not all at once. Ask clarifying follow-up questions if answers are vague.

1. **Product** — What is this project? Who are the users? What are the goals? What problem does it solve?
2. **Tech Stack** — Languages, frameworks, cloud services, APIs, infrastructure, deployment targets
3. **Workflow** — Testing approach, documentation standards, review expectations, definition of done
4. **Guidelines** — Code style, naming conventions, writing tone, formatting rules, patterns to follow or avoid

## Step 2: Configure Verification
After gathering context, ask about each verification hook. For each, ask if it should be enabled and what tool/command to use:

1. **Formatter** — Prettier, Black, gofmt, or other?
2. **Linter** — ESLint, Ruff, clippy, or other?
3. **Type checker** — tsc, mypy, pyright, or none?
4. **Security scanner** — Trivy, Bandit, npm audit, or other?
5. **Tests** — Jest, pytest, go test, or other? Include coverage?
6. **Custom checks** — Any project-specific checks to add?

## Step 3: Generate Files
Generate:
- `praxis/context/product.md`
- `praxis/context/techstack.md`
- `praxis/context/workflow.md`
- `praxis/context/guidelines.md`
- Update `praxis/verification.md` with the configured checks

Each context file must include:
- A YAML-style header with `last_updated: {YYYY-MM-DD}`
- Clear sections with concise, actionable content
- No filler — every line should inform future track decisions

## Step 4: Confirm
Present a summary of all five files. Do NOT proceed until approved.
