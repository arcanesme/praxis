---
description: Ralph autonomous execution command. Runs multi-story iterations from a PRD with fresh context per story. Use for >5 independent stories or overnight execution.
---

You are running Ralph — autonomous multi-story execution.

**Step 1 — Read state**
- Read vault_path from `~/.claude/praxis.config.json`
- Read `{vault_path}/claude-progress.json` → check `ralph_state`
- If `ralph_state.mode` is `"active"` and `current_story` is set: resume that story
- If `ralph_state.mode` is `"idle"`: begin new iteration (Step 2)

**Step 2 — PRD validation**
- Read the PRD file at `ralph_state.prd_path`
- Validate each story against size constraints:
  - Must be completable in ~10k output tokens
  - Must touch ≤3 file groups
  - Must require ≤1 architectural decision
- Reject stories that exceed constraints. Report which stories need splitting.
- Stories requiring cross-story reasoning belong in GSD, not Ralph.

**Step 3 — State bridge**
- `ralph_state` in `claude-progress.json` is the ONLY state between iterations
- Never reference conversation history as source of truth
- Read `ralph_state` at iteration start, write at iteration end
- Fields:
  - `mode`: "idle" | "active"
  - `prd_path`: path to PRD file
  - `current_story`: story identifier currently being executed
  - `completed_stories`: array of finished story identifiers
  - `blocked_stories`: array of stories that could not complete
  - `learnings`: array of [LEARN:tag] entries discovered during iterations
  - `last_iteration`: ISO timestamp of last completed iteration
  - `session_count`: number of iterations completed

**Step 4 — Iteration bootstrap**
For each story, in a fresh context:
1. Read project CLAUDE.md (always first)
2. Read `claude-progress.json` → `ralph_state` (authoritative)
3. Read PRD → current story ONLY (not full PRD)
4. Activate kit if specified in project CLAUDE.md (`## Active kit`)
5. Execute the story using GSD execute + verify phases

**Step 5 — Iteration end**
After each story completes:
1. Run session-retro in Ralph-auto mode (summary + learnings, skip user-facing phases)
2. Update `ralph_state`:
   - Push `current_story` to `completed_stories`
   - Set `current_story` to next story (or null if done)
   - Update `last_iteration` timestamp
   - Increment `session_count`
3. Git commit the story's changes
4. Advance to next story or report completion

**Step 6 — Decision table**

| Condition | Use Ralph | Use GSD |
|-----------|-----------|---------|
| >5 independent stories | Yes | - |
| Overnight/unattended execution | Yes | - |
| Mechanical transformations (migrations, renames) | Yes | - |
| Cross-story reasoning required | - | Yes |
| Architectural decisions span stories | - | Yes |
| Human checkpoints needed | - | Yes |

**Rules:**
- Kit activation is idempotent via `/kit:<name>` — safe to activate every iteration.
- Ralph never asks for user input mid-story. If blocked: add to `blocked_stories`, skip, continue.
- Default to GSD. Use Ralph only when stories are clearly independent and well-scoped.
