---
name: discuss
disable-model-invocation: true
description: Entry point for all feature work. Conversational problem framing — listen first, then synthesize scope. Use before /plan.
---

You are starting the discuss phase — a conversation to frame the problem before planning.

**Step 1 — Load minimal context**
- Read vault_path from `~/.claude/praxis.config.json`
- Detect project from CWD matching `local_path` in vault `_index.md`
- If no project detected: ask which project before continuing
- Read `{vault_path}/status.md` — current state and blockers
- If `current_plan:` is set: skim the active plan objectives only
- Read `~/.claude/rules/profile.md` — user context (soft-fail if unconfigured)

Do NOT load rules, kit context, or session history at this phase.

**Step 2 — Listen**
Ask ONE open question: "What are we working on?"
Wait for the user to describe the problem in their own words.
Do NOT present a template or form. Let them talk.

**Step 3 — Search for related work**
After the user describes the task, search vault for prior art:
Run: `obsidian search query="{topic}" limit=5`
If related specs, plans, or research exist: mention them briefly.
If nothing exists: proceed silently.

**Step 4 — Clarify gaps conversationally**
From the user's description, identify which of these four dimensions are unclear:
- **PROBLEM**: Why are we doing this? What's broken or missing?
- **DELIVERABLE**: What concrete thing will exist when done?
- **ACCEPTANCE**: What specific checks prove completion?
- **BOUNDARIES**: What's in scope and what's out?

Ask ONLY about what's missing or ambiguous — do not re-ask what the user already stated.
Frame questions naturally, not as a checklist. Examples:
- "What's the actual problem this solves?"
- "What does 'done' look like for this?"
- "Anything we should explicitly leave out?"

If the user's initial description covers all four: skip to Step 5.

**Step 5 — Synthesize and frame**
Write a SPEC block that captures the four dimensions from the conversation:

```
SPEC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROBLEM:      {why we're doing this}
DELIVERABLE:  {concrete output}
ACCEPTANCE:   {checks that prove completion}
BOUNDARIES:
  In:  {what's in scope}
  Out: {what's explicitly excluded}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then output a 1-paragraph problem framing (max 200 words):
- What exists today (from status.md / vault search)
- What gap or need the user described
- Recommendation: proceed to `/plan` or write a `/spec` first

**Step 5b — Persist to vault**
- Write the SPEC block to `{vault_path}/plans/{YYYY-MM-DD}_{slug}-context.md` with frontmatter:
  ```yaml
  ---
  tags: [context, {project-slug}]
  date: {YYYY-MM-DD}
  source: agent
  ---
  ```
- Append one-line summary to `{vault_path}/notes/discussion-log.md`:
  `{date} | {project} | {problem summary} | → /plan`
- If `discussion-log.md` doesn't exist: create it with a `# Discussion Log` header.
- The `/plan` command reads this file if the conversation SPEC block is lost to compaction.

**Step 5c — Scope guard**
- If the framing implies >5 milestones or >3 file groups: flag as scope explosion
  risk and recommend splitting before `/plan`.
- After framing: list what is NOT being decided in this discuss phase.
- Never output implementation code, pseudocode, or file-level changes.
  This phase produces a problem statement, not a solution.

**Step 6 — Handoff**
End with: "Run `/plan` to continue, or `/spec` if this needs a design spec first."

The SPEC block from Step 5 is the artifact that `/plan` consumes — it replaces
the need for `/plan` to re-ask what the task is.

**Rules:**
- This is a conversation, not a form. Listen first, synthesize second.
- Problem framing is a paragraph, not a design doc.
- If scope exceeds 5 milestones: recommend splitting into multiple passes.
- The SPEC block is the discuss→plan handoff artifact. `/plan` reads it from conversation.
