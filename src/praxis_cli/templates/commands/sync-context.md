Read PRAXIS.md first.

Export or import the current track state for handoff between parallel AI instances.

## Export (default)
Generate a portable context summary at `praxis/tracks/{track-name}/sync.md`:

```markdown
---
exported: {YYYY-MM-DD HH:MM}
track: {track-name}
type: {type}
instance: {claude|gemini|codex}
---

# Sync: {Track Title}

## Current State
- Phase: {current}/{total} — {phase name}
- Last completed task: {description}
- Next task: {description}
- Blockers: {any or "None"}

## Key Decisions Made
{List any decisions or deviations from the original plan made during this session}

## Files Modified
{List of files touched in this session with brief description of changes}

## Verification Status
{Last verify result}

## Context for Next Instance
{Any important context the next instance needs to know — gotchas, workarounds, assumptions made}
```

## Import
When the user says "pick up from sync" or "continue from sync":
1. Read `praxis/tracks/{track-name}/sync.md`
2. Read the track's `spec.md` and `plan.md`
3. Read `praxis/context/` files
4. Resume from the next unchecked task in plan.md
5. Apply any context notes from the sync file

## Rules
- Always overwrite the previous sync.md (only one sync point per track)
- Include enough context that a cold instance can pick up without asking questions
- Never include sensitive data (API keys, credentials) in sync files
