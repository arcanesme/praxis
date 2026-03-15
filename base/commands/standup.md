Generate a standup summary from claude-progress.json.

## Instructions

1. Read `claude-progress.json` from the current project directory
2. If the file doesn't exist, check the Obsidian vault project directory
3. Generate a standup in this format:

## Output Format

```
STANDUP — {project name} — {date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

YESTERDAY
  - {completed items from last session}

TODAY
  - {planned items / next tasks}

BLOCKERS
  - {any blockers or "None"}

CONTEXT
  - Active tracks: {list}
  - Verification: {last result}
```

## Rules

- Pull data from `claude-progress.json` — don't fabricate
- If no progress file exists, say so and suggest running `/scaffold-exist`
- Keep each section to 3-5 bullet points max
