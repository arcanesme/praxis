# Execution Loop — Rules
# Scope: All projects, all sessions
# Invariants only. Phase details live in the commands that implement them.

## Loop Order (reference — commands are authoritative)
`/discuss` → `/plan` → `/execute` → `/verify` → `/simplify` → `/ship`

Each command file contains its own steps. This file defines only the
cross-cutting invariants that apply regardless of which phase is active.

## Invariants — BLOCK on violation

### SPEC before code
No code or file changes until PROBLEM / DELIVERABLE / ACCEPTANCE / BOUNDARIES are answered.
`/discuss` synthesizes these from conversation. If discuss was skipped,
the implementer must answer all four before proceeding.

### Risk check gate
Run `/risk` before `/plan` if the task:
- Touches infrastructure files (`*.tf`, `*.bicep`, `*.yml` in `.github/workflows/`)
- Touches authentication, credentials, or secrets handling
- Modifies >3 files across different domains
- Has BOUNDARIES (out of scope) that explicitly defer something risky

### Plan before implementation
Do NOT begin implementation until a plan exists and is approved.
The plan is the sole implementation guide — not conversation history.

### One milestone at a time
Keep diffs scoped. Do not expand scope without explicit approval.
Never let uncommitted work span multiple milestones.

### Validate with evidence
After EACH milestone — show actual output, not assertions:
1. Test suite output
2. Linter output (fix ALL warnings)
3. Typecheck output (if applicable)
4. Build output (if applicable)
Report: PASS or FAIL with specifics.

### Stop-and-fix
If ANY validation fails: fix NOW, re-validate, then proceed.
If cannot fix in 3 attempts: STOP.
Report: **What** (full error + 3 attempts) → **So What** (root cause) → **Now What** (next steps)

### Commit at milestone boundaries
Commit when verify passes. See git-workflow.md.

### Log to vault
After each milestone: update status.md, mark milestone complete in plan file.
After ALL milestones: update _index.md goals if project direction changed.

## Self-Review Protocol
After ALL milestones, before reporting done:
1. Launch a subagent to review the full diff as a critical code reviewer.
   Subagent receives ONLY: the diff, the SPEC (from plan file), relevant rules.
   NOT the conversation history.
2. Address all Critical and Major findings.
3. Re-validate after fixes.
4. If reviewer found >3 issues: run review again (max 3 rounds).

## Context Management
See `~/.claude/rules/context-management.md` for:
Phase scoping, subagent discipline, context reset protocol.
