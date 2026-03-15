---
name: session-retro
disable-model-invocation: true
description: End-of-session retrospective. Invoke manually with /session-retro only.
  Writes [LEARN:tag] entries, proposes rule updates, updates claude-progress.json,
  triggers vault-gc lightweight check. Side-effect skill — never auto-triggers.
allowed-tools: Bash, Read, Write, Edit
---

# session-retro Skill

## Vault Path Resolution
Read vault_path from `~/.claude/praxis.config.json`. If missing: write to fallback location.

## DONE-WHEN
- [ ] Session summary written (3–5 bullets)
- [ ] Violations and corrections extracted
- [ ] [LEARN:tag] entries written to correct learnings.md
- [ ] Rule proposals surfaced (user approves before writing)
- [ ] `claude-progress.json` last_session updated
- [ ] vault-gc lightweight check triggered
- [ ] `/clear` suggested if session had >2 corrections or scope drift

## NON-GOALS
- Does not write rules without user approval
- Does not auto-close or modify open plan files
- Does not run full vault-gc audit (lightweight only)

---

## Phase 1 — Summarize Session

Review conversation. Produce 3–5 bullet summary:
- What was accomplished (concrete deliverables, decisions)
- What was attempted but not completed (and why)
- Any scope drift from original intent

## Phase 2 — Extract Violations and Corrections

Scan session for:
1. **Corrections**: times user corrected Claude's output
2. **Rule violations**: things a rules file should have blocked
3. **Missing rules**: patterns that recurred with no rule
4. **Process violations**: SPEC/PLAN/VALIDATE loop skipped

Classify each: type, tag (`bugfix|convention|perf|security|tooling|arch|process`), impact.

## Phase 3 — Write [LEARN:tag] Entries

For each finding with clear root cause:
- Project-specific → `{vault_path}/notes/learnings.md`
- Global/harness pattern → harness project learnings.md
- Check for duplicates via `qmd search` before writing

Format:
```markdown
## [LEARN:{tag}] {Short title}
- **What**: What went wrong or was discovered
- **So What**: Why this matters
- **Now What**: What to do instead
- **Date**: {YYYY-MM-DD}
```

Run `qmd update` after writing.

## Phase 4 — Propose Rule Updates

For findings where a rule SHOULD have blocked the behavior:
1. Identify which `~/.claude/rules/` file it belongs in
2. Draft as Invariant (BLOCK) or Convention (WARN)
3. Present to user with reason. **Do NOT write without approval.**
4. If declined: log decline in the [LEARN:tag] entry

## Phase 5 — Update claude-progress.json

Append session entry:
```json
{
  "date": "{YYYY-MM-DD}",
  "summary": "{1-line}",
  "accomplishments": [],
  "learn_entries": 0,
  "rule_proposals": 0,
  "corrections": 0
}
```

## Phase 6 — vault-gc Lightweight Check

Run inline staleness check across all `status.md` files in active projects.
- Silent if 0 stale
- One line if 1–2 stale
- Escalate if 3+ stale

## Phase 7 — Session Health Assessment

| Signal | Threshold | Action |
|--------|-----------|--------|
| Corrections from user | >2 | Suggest `/clear` |
| Scope drift | Any | Note in summary |
| Same correction repeated | 2+ | Rule proposal mandatory |

## Output Format
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SESSION RETRO — {today_date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Summary
  {bullets}

  Learnings: {n}  |  Rules: {n}  |  Corrections: {n}

  {vault-gc output if non-empty}
  {/clear suggestion if warranted}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Error Handling

| Condition | Action |
|-----------|--------|
| Can't detect project | Ask, or write to fallback |
| `claude-progress.json` missing | Create from template |
| `qmd update` fails | Warn only |
| User declines all proposals | Log declines, proceed |

## Removal Condition
Remove when session transcripts are parsed automatically and [LEARN:tag] entries generated without Claude.
