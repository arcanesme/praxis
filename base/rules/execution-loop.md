---
description: Execution discipline — stop-and-fix, phase gates, single-reply intake
---

# Execution Loop

## Stop-and-Fix

If the current state cannot be verified, stop. Do not advance to the next phase. Fix gaps first, then proceed.

## Phase Gates

Every implementation plan has phases. At each phase boundary:

1. Run verification checks
2. Summarize what was done
3. **Stop and wait for human review** before proceeding

Never skip a phase gate. Never combine phases without explicit approval.

## Single-Reply Intake

When a skill or command needs input, collect ALL required metadata in a single structured prompt. No sequential question chains.

## Verification First

Before declaring any unit of work complete:

1. Run applicable verification (lint, format, type-check, tests)
2. Confirm output matches spec success criteria
3. Surface any discrepancies — don't hide them

## Self-Reported State Is a Risk

Never trust a description of file state. Always verify against actual files:
- Check file existence with glob/find
- Read file contents to confirm structure
- Run tests to confirm behavior

## Context Rot

See `rules/context-management.md` for the full anti-rot protocol: GSD phase discipline, Ralph story sizing, compaction recovery. The short version: **files are the memory, not the conversation.** Write state to disk at every phase boundary. Re-read files instead of relying on recall. Use `/context-reset` when drift is visible.
