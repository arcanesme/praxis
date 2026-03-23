---
name: subagent-review
disable-model-invocation: true
description: Reusable code review subagent. Accepts a diff, optional spec, and rules
  files. Launches a subagent with zero conversation history to review for bugs,
  security, and convention violations. Called by /review and verify — never
  invoked directly by users.
allowed-tools: Bash, Read
---

# subagent-review Skill

## Purpose
Encapsulates the Self-Review Protocol as a reusable skill. Callers provide the
diff and context; this skill launches the subagent and returns structured findings.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| diff | Yes | — | The diff to review (string or file path) |
| spec_path | No | — | Path to the SPEC/plan for context |
| rules_files | No | `CLAUDE.md`, `coding.md`, `security.md` | Rules files to load |

## Acceptance
- [ ] Subagent launched with ONLY diff + spec + rules (zero conversation history)
- [ ] Findings returned in structured format
- [ ] Each finding rated Critical / Major / Minor

## Boundaries
Out of scope:
- Does NOT fix findings — callers handle remediation
- Does NOT write to vault — callers decide what to persist
- Does NOT interact with the user — callers present findings

---

## Phase 1 — Validate Inputs

- Diff must be non-empty. If empty: return `{ "findings": [], "status": "empty_diff" }`.
- If spec_path provided: verify the file exists. If not: proceed without spec.
- If rules_files not provided: default to:
  - `~/.claude/CLAUDE.md`
  - `~/.claude/rules/coding.md`
  - `~/.claude/rules/security.md`

## Phase 2 — Compose Subagent Prompt

Build the subagent prompt from these components ONLY:

```
You are a critical code reviewer. Review the following diff.

## Rules
{contents of each rules file}

## SPEC (if available)
{contents of spec file, or "No spec provided."}

## Diff
{the diff}

## Instructions
Review for:
1. Bugs and logic errors
2. Edge cases and off-by-one errors
3. Error handling gaps (missing catches, swallowed errors)
4. Security issues (injection, secrets, auth gaps)
5. Convention violations (from the Rules above)

Rate each finding: Critical / Major / Minor.
Format each as: `{file}:{line} — {severity} — {description} — {fix}`

If the diff is clean, say "No findings."
```

Do NOT include any conversation history, project context, or user preferences
beyond the explicitly provided inputs.

## Phase 3 — Launch Subagent

- Launch a subagent (Task tool) with the composed prompt.
- The subagent runs in isolation — fresh context, no memory of the current session.

## Phase 4 — Return Structured Findings

Parse the subagent output into:

```json
{
  "status": "findings" | "clean" | "empty_diff",
  "critical": [{ "file": "", "line": 0, "description": "", "fix": "" }],
  "major": [{ "file": "", "line": 0, "description": "", "fix": "" }],
  "minor": [{ "file": "", "line": 0, "description": "", "fix": "" }],
  "summary": "1 critical, 2 major, 0 minor"
}
```

Return this structure to the caller. The caller decides:
- Whether to present findings to the user
- Whether to trigger remediation
- Whether to re-run (max 3 rounds, managed by caller)

## Callers

| Caller | Context |
|--------|---------|
| `/review` (commit 6) | Manual review trigger, writes summary to vault |
| `verify` Step 5 | Post-milestone Self-Review Protocol |
| `execution-loop.md` | Self-Review Protocol description (future: replace inline with skill ref) |

Note: `execution-loop.md` and `verify.md` still contain inline descriptions of the
review pattern. Future cleanup can replace those with a reference to this skill. Both
approaches produce identical behavior — the duplication is accepted for now.

## Error Handling

| Condition | Action |
|-----------|--------|
| Empty diff | Return `empty_diff` status immediately |
| Subagent fails to launch | Return error to caller, do not retry |
| Subagent output unparseable | Return raw output as single Minor finding |
| Rules file missing | Warn, proceed with available rules |

## Removal Condition
Remove when code review is fully handled by a dedicated external service
integrated via MCP, making subagent-based review redundant.
