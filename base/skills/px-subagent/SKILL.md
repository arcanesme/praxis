---
name: px-subagent
disable-model-invocation: true
description: "Reference protocol for subagent dispatch. Defines how to package context, spawn, interpret results, and escalate findings. Not invoked directly — referenced by review, simplify, verify-app, and verify skills."
---

# Subagent Dispatch Protocol

This is a reference protocol, not a directly invocable skill. Skills that spawn subagents
(review, simplify, verify-app, verify) follow this protocol for consistency.

---

## Step 1 — Package Context

Subagents receive ONLY these inputs. Zero conversation history.

| Input | Source | Required |
|-------|--------|----------|
| Diff | `git diff` output scoped to the task | Yes |
| SPEC | `## SPEC` section from the active plan file | If available |
| Rules | Relevant `~/.claude/rules/*.md` based on file types in diff | Yes |
| Project config | Project CLAUDE.md `## Commands` and `## Code Style` | If available |

**Never include:**
- Conversation history
- User preferences or profile
- Vault state or session notes
- Full plan file (only SPEC section)

## Step 2 — Define Role

One sentence. The role constrains the subagent's perspective.

Examples:
- "You are a critical code reviewer."
- "You are a code simplification expert."
- "You are a regression analyst."
- "You are a security auditor."

## Step 3 — Define Task

Specific questions or analysis to perform. Include:
- What to look for (bugs, complexity, regressions, etc.)
- What NOT to do (don't suggest features, don't change behavior)
- Scope boundaries (only these files, only this diff)

## Step 4 — Define Output Format

All subagent findings use this structure:

```
{file}:{line} — {severity} — {category} — {description} — {fix}
```

**Severity levels** (consistent across all subagent types):
- **Critical** — Must fix before proceeding. Blocks merge/ship.
- **Major** — Should fix before merge. Recommend addressing.
- **Minor** — Note for future cleanup. Does not block.

**If the subagent finds nothing:** Output "No findings." (not an empty list)

## Step 5 — Spawn

Launch an Agent with:
- `subagent_type`: use `general-purpose` for review/analysis tasks
- `prompt`: role + task + inputs + output format
- Description: short (3-5 words) summary of what the subagent does

```
Agent(
  description: "Review diff for bugs",
  prompt: "{role}\n\n{task}\n\n## Diff\n{diff}\n\n## SPEC\n{spec}\n\n## Rules\n{rules}\n\n{output format}"
)
```

## Step 6 — Interpret Results

Parse the subagent output:
1. Group findings by severity (Critical → Major → Minor)
2. Count findings per severity
3. If output is unparseable: treat entire output as a single Minor finding

## Step 7 — Escalate

| Severity | Action |
|----------|--------|
| Critical (any) | Block. Address immediately before proceeding. |
| Major (any) | Recommend fixing before merge. |
| Minor only | Note for future cleanup. Proceed. |
| No findings | "Clean." Proceed. |

**Re-review threshold:** If >3 findings were addressed, re-run the subagent (max 3 rounds).

---

## Callers

| Skill | Subagent Role | Spawned At |
|-------|---------------|------------|
| `/review` | Critical code reviewer | Step 4 |
| `/simplify` | Code simplification expert | Phase 2 |
| `/verify-app` | Regression analyst | Phase 3 |
| `/verify` | Critical code reviewer (self-review) | Step 5 |
| `/repair` | (uses /verify internally, which spawns subagent) | — |

## Removal Condition
Remove when Claude Code provides a native subagent dispatch API with
structured input/output handling.
