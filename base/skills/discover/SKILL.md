---
name: discover
disable-model-invocation: true
description: Structured technical discovery — evaluate options, make recommendations with confidence levels. Use before /spec when you need to research before deciding.
---

You are running a structured technical discovery.

**Step 1 — Frame the question**
- Read vault_path from `~/.claude/praxis.config.json`
- What decision needs to be made? (one sentence)
- What are the constraints? (compliance, performance, compatibility, cost)
- What is already known? (run `obsidian search query="{topic}" limit=5`)

**Step 2 — Research options**
- Identify 2-4 viable options. For each:
  - Name and one-sentence description
  - Pros (concrete, measurable)
  - Cons (concrete, measurable)
  - Confidence: HIGH / MEDIUM / LOW (how certain are you this works?)
- Use Context7 for library/API evaluation. Use subagents for codebase exploration.
- Never recommend an option you haven't verified against constraints.

**Step 3 — Recommend**
- State the recommended option with rationale
- If confidence is LOW on all options: say so. Recommend a spike or prototype.
- Format:
  ```
  Recommendation: {option}
  Confidence: {HIGH/MEDIUM/LOW}
  Rationale: {why this over alternatives}
  Risk: {what could go wrong}
  ```

**Step 4 — Write to vault**
- Write `{vault_path}/research/{YYYY-MM-DD}_{kebab-topic}.md` with frontmatter:
  ```yaml
  ---
  tags: [research, {project-slug}]
  date: {YYYY-MM-DD}
  status: complete
  source: agent
  ---
  ```
- Include all options evaluated, recommendation, and confidence
- Report: "Discovery written. Run `/spec` to formalize as ADR, or `/discuss` to proceed."

**Rules:**
- Discovery is research, not implementation. Zero code output.
- If the question is already answered by an existing spec: point to it instead.
- Fills the gap between `/discuss` (problem framing) and `/spec` (formal decision).
