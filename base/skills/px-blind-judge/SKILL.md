---
name: duel
disable-model-invocation: true
description: "Parallel Alpha/Beta implementation comparison with blind scoring and synthesis. Use when two viable approaches exist and you need an objective winner."
---

# /duel — Blind Judge

Generates two competing implementations independently, scores them blindly, and synthesizes the best of both.

## When to Use
- Two or more viable implementation approaches exist
- You want objective comparison without anchoring bias
- The user asks "which approach is better?" and both have merit

## Step 1 — Frame the Problem

Extract from the user's request:
- **Problem statement**: What needs to be solved
- **Constraints**: Performance, compatibility, complexity limits
- **Acceptance criteria**: How to judge success

## Step 2 — Assign and Implement

Randomly assign labels using `$RANDOM % 2`:
- If result is 0: User's first-mentioned approach = Alpha, second = Beta
- If result is 1: Swap the assignment

**Never reveal the mapping until scoring is complete.**

Launch two subagents in parallel. Each receives ONLY:
- The problem statement and constraints
- Relevant project rules (from CLAUDE.md)
- NO knowledge of the other approach
- NO conversation history

Each subagent must produce:
- Complete implementation (not pseudocode)
- At least one test case
- Brief rationale for design choices

## Step 3 — Score Blindly

Present both solutions labeled only as **Alpha** and **Beta**.

Score each on 5 dimensions (0–4 per dimension):

| Score | Meaning |
|-------|---------|
| 0 | Fails completely |
| 1 | Significant issues |
| 2 | Acceptable, notable gaps |
| 3 | Good, minor issues |
| 4 | Excellent |

Dimensions:
1. **Correctness** — Does it solve the stated problem?
2. **Test coverage** — Are edge cases handled and tested?
3. **Security** — No injection, no exposed secrets, follows posture rules
4. **Maintainability** — Readable, documented where needed, follows complexity rules
5. **Performance** — No unnecessary bottlenecks, appropriate algorithm choices

## Step 4 — Verdict

- **Clear winner (>2 point gap)**: Winner contributes 80% of final implementation. Runner-up contributes 20% (best ideas only — error handling, edge cases, naming).
- **Close match (≤2 point gap)**: Declare undecided. Recommend `/deliberate` for structured decision analysis.
- Reveal the Alpha/Beta mapping only after scoring.

## Step 5 — Synthesize

Produce the final implementation:
- Start from the winner's code
- Cherry-pick specific improvements from the runner-up (cite which and why)
- Run the combined test suite
- Show the synthesis rationale

## Step 6 — Archive (if vault available)

Read `vault_path` from `~/.claude/praxis.config.json`.
If available, write to `{vault_path}/specs/duel-{YYYY-MM-DD}-{slug}.md`:
```yaml
---
tags: [duel, decision]
date: YYYY-MM-DD
source: agent
---
```
Include: problem, both approaches, score matrix, synthesis rationale, final code.
