---
name: px-context-probe
disable-model-invocation: true
description: "Assess current context health and recommend action. Reads session data and conversation signals to estimate context bracket (FRESH/MODERATE/DEPLETED/CRITICAL)."
---

# context-probe Skill

You are assessing the current session's context health.

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`.

---

**Step 1 — Gather signals**

Assess these indicators (do NOT read external files just for this — use what you already know):

| Signal | How to assess |
|--------|--------------|
| Conversation length | Estimate from your sense of how much has been discussed |
| Tool calls made | Rough count of reads, writes, bash calls this session |
| Files touched | How many files have been read or edited |
| Corrections received | How many times the user corrected your output |
| Compaction occurred | Did you receive a compaction bootstrap? |
| Active task complexity | Simple (1-2 files) vs complex (5+ files, multi-milestone) |

**Step 2 — Estimate bracket**

| Bracket | Signals | Action |
|---------|---------|--------|
| **FRESH** | <10 tool calls, <5 files, no corrections, no compaction | Full speed. Batch aggressively. Load full context. |
| **MODERATE** | 10-30 tool calls, 5-15 files, 0-1 corrections | Re-read key requirements before decisions. Prefer concise output. |
| **DEPLETED** | 30+ tool calls, 15+ files, 2+ corrections, OR scope drift detected | Checkpoint to vault NOW. Write milestone summaries. Suggest `/session-retro` + `/clear`. |
| **CRITICAL** | Post-compaction, OR repeated corrections, OR instruction drift | STOP new work. Complete current milestone only. Write all state to vault. Start new session. |

**Step 3 — Report**

```
CONTEXT PROBE
━━━━━━━━━━━━━━━━━━━━━
Bracket:  {FRESH | MODERATE | DEPLETED | CRITICAL}
Signals:  {key indicators}
Action:   {recommendation}
━━━━━━━━━━━━━━━━━━━━━
```

**Step 4 — Act on DEPLETED/CRITICAL**

If DEPLETED or CRITICAL:
1. Update `{vault_path}/status.md` with current state
2. Write any in-progress decisions to the active plan file
3. Suggest: "Context is [bracket name]. Recommend `/session-retro` then `/clear` for a fresh start."

## Removal Condition
Remove when Claude Code exposes token count or context utilization metrics natively.
