---
description: Skip planning for trivial changes. Edit, verify, commit. Use for typos, config tweaks, single-line fixes, and other changes too small for a plan.
---

You are running a fast task — no planning, just edit/verify/commit.

**Step 1 — Understand the change**
The user describes the change inline (e.g., `/fast fix typo in README`).
If no description provided: ask "What's the change?"

**Step 2 — Make the edit**
Apply the change directly. No SPEC, no plan, no milestones.
Keep the diff minimal — if the change touches >3 files, stop and suggest `/quick` instead.

**Step 3 — Verify**
Run lint and test commands from project CLAUDE.md `## Commands` section.
Show output. If failing: fix immediately.

**Step 4 — Commit**
On pass: commit with conventional commit format.
No vault writes, no status.md update, no plan file.

**Rules:**
- This is for genuinely trivial changes. If you need to think about the approach, use `/quick`.
- Maximum 3 files changed. Beyond that: escalate to `/quick` or `/discuss`.
- Pre-commit checks (secrets, identity) still apply — never skip those.
