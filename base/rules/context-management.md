# Context Management — Rules
# Scope: All projects, all sessions
# Prevents context rot via GSD phase discipline and Ralph story sizing

## GSD Phase Discipline — Invariants (BLOCK on violation)

### Phase-scoped context loading
- Load ONLY context required for the current GSD phase.
  SPEC needs requirements and constraints — not implementation details.
  IMPLEMENT needs the plan and relevant source files — not research notes.
- At the end of each phase: write a phase summary to the active plan file.
  The summary replaces conversation memory — files are the record.
- Never carry raw conversation reasoning forward across phases.
  If it matters, it is written to a file. If it is not written, it does not persist.
- One feature per session. Do not mix unrelated tasks.

### File-based handoff at phase boundaries
- Phase transitions produce artifacts, not conversation continuity.
  SPEC → PLAN: the plan file captures all decisions from the spec phase.
  PLAN → IMPLEMENT: the approved plan is the sole implementation guide.
  IMPLEMENT → VALIDATE: test output and lint output are the evidence.
- Use subagents for exploration, research, and review to protect the main context.

## Ralph Story Sizing — Invariants (BLOCK on violation)

### Size constraint
- Each Ralph PRD story must be completable in a single context window (~10k output tokens).
- Right-sized stories: add one component, one migration, one service method,
  one test suite, or one configuration change.
- Too large: any story requiring >3 file groups or >1 architectural decision.
  Split before execution.
- Stories requiring cross-story reasoning belong in GSD, not Ralph.
  Ralph stories must be independently verifiable.

### State contract
- `claude-progress.json` is the ONLY state bridge between Ralph iterations.
- The `ralph_state` object is authoritative:
  ```json
  {
    "mode": "idle | active",
    "prd_path": null,
    "completed_stories": [],
    "current_story": null
  }
  ```
- Ralph reads `ralph_state` at iteration start, writes at iteration end.
- Never reference conversation history as source of truth in Ralph mode.

## When to Use GSD vs Ralph — Conventions (WARN on violation)

| Trigger | Use | Reason |
|---------|-----|--------|
| <5 stories, needs reasoning continuity | GSD | Decisions compound across stories |
| Architectural decisions required | GSD | Context must persist through tradeoff analysis |
| Exploratory or ambiguous scope | GSD | Needs human-in-the-loop at phase gates |
| >5 independent stories | Ralph | Parallelizable, no cross-story dependencies |
| Overnight/unattended execution | Ralph | Fresh context per story prevents drift |
| Mechanical transformations (migrations, renames) | Ralph | Repetitive, well-scoped, low judgment |

Default to GSD. Use Ralph only when stories are clearly independent and well-scoped.

## Compaction Safety — Invariants (BLOCK on violation)

### Ralph mid-run takes precedence
- If `claude-progress.json` → `.ralph_state.current_story` is set, ALWAYS read it — even if an active plan exists.
- Ralph mid-run state is authoritative over plan state. The story must complete or be explicitly blocked before plan-level work resumes.

## Subagent Discipline — Conventions (WARN on violation)

### Subagent scope
- Use subagents for exploration, research, and review — never for the main implementation thread.
- Subagents protect the main context window from excessive results.
- Each subagent receives ONLY the context it needs (diff, SPEC, relevant rules). NOT the full conversation history.
- Do not spawn subagents for tasks that take fewer tokens than the subagent overhead.

## Context Reset Protocol — Conventions (WARN on violation)

### When to reset
- Repeated corrections on the same issue (model is not incorporating feedback)
- Loop behavior (attempting the same failed approach)
- Instruction drift (ignoring rules that were followed earlier in the session)
- After 2 failed corrections: suggest `/context-reset` and `/clear`

### How to reset
1. Run `/context-reset` to checkpoint current state to vault files
2. Run `/clear` to reset the conversation
3. Re-bootstrap from project CLAUDE.md — the files contain everything needed
4. The vault drives work. Conversation is the interface, not the record.

## Context Brackets — Conventions (WARN on violation)

Adapt behavior based on estimated remaining context. Detect bracket by
conversation length heuristic (not token count — we cannot read session JSONL).

### FRESH (early session, <30% of typical session length)
- Batch aggressively — minimize round trips
- Lean output — trust that recent context is available
- Load full plan context if needed — budget is high

### MODERATE (mid-session, ~30-60%)
- Re-read key requirements before implementation decisions
- Reinforce constraint awareness — re-state SPEC if drifting
- Prefer concise output — save context for implementation

### DEPLETED (late session, >60%)
- Checkpoint progress to vault files before continuing
- Write milestone summaries proactively (don't wait for verify)
- Suggest `/session-retro` + `/clear` if remaining work is substantial
- Prepare handoff: ensure status.md and plan file capture all state

### CRITICAL (after compaction or context warning)
- Use DEPLETED rules
- STOP new work. Complete current milestone only.
- Write all state to vault immediately
- Suggest new session for remaining milestones

---

## Verification Commands

```bash
# Check that claude-progress.json has ralph_state field
jq '.ralph_state' {vault_path}/claude-progress.json

# Verify active plan file exists and has phase summaries
ls -la {vault_path}/plans/

# Check status.md was updated this session
stat -f "%Sm" {vault_path}/status.md
```

---

## Removal Condition
Permanent. Context rot is inherent to LLM context windows.
Remove only if the underlying model architecture eliminates attention decay.
