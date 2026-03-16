---
description: Context rot prevention — GSD phase discipline, Ralph story sizing, compaction recovery
---

# Context Management

Context rot is the degradation in adherence and precision as the context window fills. Earlier instructions lose attention weight and the model drifts. This rule exists to prevent that.

## The Two Modes

| Mode | Scope | Memory | Use when |
|------|-------|--------|----------|
| **GSD** | Intra-session | Phase summaries on disk | Interactive work requiring cross-step reasoning |
| **Ralph** | Inter-session | `claude-progress.json` + git | >5 independent stories, overnight runs, repetitive patterns |

GSD and Ralph are complementary. GSD controls drift *within* a session. Ralph eliminates it *between* sessions by starting fresh.

## GSD Phase Discipline

- **Load only what the current phase needs.** Don't preload specs, plans, and code for all phases at once. Read files on-demand as each phase begins.
- **Write phase summaries to disk.** At the end of each phase, before the checkpoint gate, write a summary of what was done, decisions made, and current state to the vault or project directory. This is the handoff — not conversation history.
- **Files are the memory.** If it's not written to a file, it doesn't survive compaction. Treat every phase boundary as a potential context reset.
- **Re-read, don't recall.** If you need information from a previous phase, re-read the file — don't rely on what you remember from earlier in the conversation.
- **Confirm constraints at each gate.** At every phase gate, re-state the key constraints from the spec before proceeding. This catches drift before it compounds.

## Ralph Story Sizing

Each story must be completable in a single context window.

**Right-sized stories:**
- Add one component with tests
- Add one database migration
- Add one API endpoint or service method
- Fix one bug with regression test
- Refactor one module

**Too large (split required):**
- Requires >3 file groups (e.g. frontend + backend + infra + tests)
- Requires >1 architectural decision
- Touches >10 files
- Estimated >10k output tokens

## When to Use Ralph (Not GSD)

- **>5 independent stories** that don't require cross-story reasoning
- **Overnight or unattended** execution
- **Repetitive patterns** (e.g. "add CRUD for these 8 entities")
- **After context degradation** — if GSD performance has visibly dropped, switch to Ralph

## Ralph State Contract

`claude-progress.json` is the **ONLY** state bridge between Ralph iterations.

- Read it at the start of every iteration
- Write it at the end of every iteration
- Never reference conversation history as a source of truth
- The file must contain: completed stories, current story, active tracks, learnings

```json
{
  "project": "my-project",
  "last_session": "2026-03-16",
  "active_tracks": ["track-name"],
  "completed_tracks": [],
  "sessions": [
    {
      "date": "2026-03-16",
      "completed": ["story-1", "story-2"],
      "current": "story-3",
      "learnings": ["[LEARN:process] Smaller phases catch issues earlier"]
    }
  ]
}
```

## Context Window Hygiene

- **Summarize decisions before they scroll out.** If a significant decision was made 20+ messages ago, write it to a file or re-state it.
- **Watch for drift signals:** repeating instructions that were already given, contradicting earlier decisions, forgetting constraints, generating code that violates the spec.
- **When drift is detected:** stop, re-read the spec and plan, re-state current phase and constraints, then continue. Don't push through.
- **Use `/context-reset` as the escape hatch.** If the session is too degraded, checkpoint to disk and start fresh.

## After Compaction

When the system compresses conversation history:

1. Read `claude-progress.json` for current project state
2. Read the active spec and plan (if any)
3. Re-read this rule (`rules/context-management.md`)
4. State what phase you're in and what the current objective is
5. Ask for confirmation before continuing work
