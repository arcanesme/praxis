# Context Management — Rules
# Scope: All projects, all sessions
# Prevents context rot via phase discipline

## Phase Discipline — Invariants (BLOCK on violation)

### Phase-scoped context loading
- Load ONLY context required for the current phase.
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
# Verify active plan file exists and has phase summaries
ls -la {vault_path}/plans/

# Check status.md was updated this session
stat -f "%Sm" {vault_path}/status.md
```

---

## Removal Condition
Permanent. Context rot is inherent to LLM context windows.
Remove only if the underlying model architecture eliminates attention decay.
