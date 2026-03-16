Checkpoint current state to disk and prepare for a fresh context.

Use this when context rot is visible: repeated instructions, forgotten constraints, contradicting earlier decisions, or spec violations.

## Instructions

1. **Read config**: Load `vault_path` from `~/.claude/praxis.config.json`

2. **Identify current state**:
   - Active spec (if any)
   - Current plan phase (if any)
   - Last 3 significant decisions
   - Current blockers or open questions

3. **Write checkpoint to vault**:
   - File: `{vault_path}/01_Projects/Work/_active/{project}/notes/context-checkpoint.md`
   - Overwrite any existing checkpoint (there should only ever be one active)

4. **Update claude-progress.json**:
   - Set `last_session` to today
   - Update `active_tracks` with current state
   - Add session entry with what was accomplished so far

5. **Output the bootstrap block**:
   - A summary block the user can paste into a fresh session after `/clear`
   - Must include: project name, active spec reference, current plan phase, key constraints, last checkpoint file path

## Output Format

```
CONTEXT CHECKPOINT — {project} — {date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CURRENT STATE
  Phase: {n} of {total} — {phase name}
  Spec: {spec file or "none"}
  Track: {track name}

DECISIONS (last 3)
  1. {decision}
  2. {decision}
  3. {decision}

BLOCKERS
  - {blocker or "none"}

✓ Checkpoint written to: {path}
✓ claude-progress.json updated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BOOTSTRAP BLOCK — paste into fresh session:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Continuing work on {project}.
Read these files to resume:
  1. {spec path}
  2. {plan path}
  3. {checkpoint path}
  4. claude-progress.json

Current phase: {n} — {phase name}
Key constraints: {constraints summary}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Run /clear, then paste the bootstrap block above.
```

## Rules

- Always write the checkpoint to disk before suggesting `/clear`
- The checkpoint file is the source of truth for resumption — not this conversation
- Include enough context in the bootstrap block that a fresh session can continue without re-reading the full conversation
- If no spec or plan is active, still checkpoint decisions and progress
