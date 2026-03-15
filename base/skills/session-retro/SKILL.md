---
disable-model-invocation: true
description: End-of-session retrospective — log learnings, update progress
---

# /session-retro

**Non-negotiable.** Every session ends with this. This is how the harness compounds.

## Steps

1. **Read config**: Load `vault_path` from `~/.claude/praxis.config.json`

2. **Summarize session**:
   - What was accomplished
   - What was attempted but not completed
   - Decisions made and rationale
   - Blockers encountered

3. **Extract learnings**:
   - Identify patterns, surprises, or insights from this session
   - Format as `[LEARN:tag] Description`
   - Tags: `architecture`, `tooling`, `process`, `debugging`, `performance`, `security`, `testing`

4. **Update files**:
   - **Learnings log**: Append to `{vault_path}/01_Projects/Work/_active/{project}/notes/learnings.md`
   - **claude-progress.json**: Update `last_session`, add session entry, update track status

5. **Suggest next steps**:
   - What should the next session start with
   - Any prep work for the human

6. **Suggest `/clear`**: Remind the human to clear context for the next session.

## Output Format

```
SESSION RETRO — {project} — {date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ACCOMPLISHED
  - {item}

IN PROGRESS
  - {item}

LEARNINGS
  [LEARN:tag] {description}
  [LEARN:tag] {description}

NEXT SESSION
  - {suggestion}

→ Consider running /clear to reset context.
```

## Rules

- This skill is NOT optional. Run it at the end of every session.
- Write learnings to the vault — they compound over time.
- Be honest about what wasn't completed.
