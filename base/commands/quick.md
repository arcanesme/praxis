---
description: Ad-hoc task with full quality guarantees in a single compressed flow. Use for tasks that need planning but aren't worth the full loop.
---

You are running a quick task — full guarantees, compressed flow.

**Step 1 — Capture the task**
The user describes the task inline with the command (e.g., `/quick add error handling to the API route`).
If no description provided: ask "What's the task?"

**Step 2 — Inline SPEC**
Synthesize from the description (do not ask the user to fill out a form):
- PROBLEM: why this needs doing
- DELIVERABLE: what will change
- ACCEPTANCE: how to verify
- BOUNDARIES: what's out of scope

Output the SPEC block, then proceed immediately — no separate discuss or plan phase.

**Step 3 — Inline plan**
Generate a 1-3 milestone plan. Do NOT write to vault — keep it in conversation only.
Each milestone: description + files + verification command.

**Step 4 — Execute**
Implement each milestone in sequence. Follow the same rules as `/execute`:
- Declare file group before editing
- One milestone at a time
- No scope expansion without approval

**Step 5 — Verify**
After all milestones: run lint + test. Show output.
If failing: fix immediately (stop-and-fix rule applies).

**Step 6 — Commit**
On pass: commit with conventional commit format. Update `status.md` briefly.

**Rules:**
- This is a compressed full loop, not a shortcut that skips verification.
- No vault plan file written — this is for tasks that don't need persistent tracking.
- If the task turns out to need >3 milestones: stop and suggest `/discuss` instead.
