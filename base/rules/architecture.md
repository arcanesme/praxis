# Architecture Rules
<!-- Universal — applies when designing systems, documenting decisions, writing proposals -->

## Invariants — BLOCK on violation

### Decision capture
- Architecture decisions affecting system design, network topology, identity model,
  data residency, security posture, or compliance scope MUST be written to
  `{vault_path}/specs/` as an ADR before implementation.
- Never leave a significant decision only in conversation.
- ADR minimum structure: Decision / Context / Options Considered / Consequences.

### What / So What / Now What
- Every status update, blocker report, and spec summary MUST follow this structure:
  - **What**: Facts only. What exists, what was done, what failed.
  - **So What**: Why it matters. Risk, dependency, compliance gap, or opportunity.
  - **Now What**: Ordered actions informed by the above.
- Never write a What without a So What. Facts without implications are incomplete.

### Vault vs repo boundary
- Code and configuration: repo. Decisions, rationale, risk context, research: vault.
- If in doubt: repo = what runs, vault = why it runs that way.
- Never put credentials, client-specific data, or engagement PII in the repo.

---

## Conventions — WARN on violation

### Specs before implementation
- Significant changes need a spec before implementation begins. A single ADR is sufficient.

### Phase and milestone tracking
- Active engagements with defined phases must track completion in `claude-progress.json`.
- Phase completion criteria documented before the phase begins — not retroactively.
- 99% complete is not complete. One remaining blocker = log it, don't round to done.

---

## Verification Commands
```bash
# Check for ADRs missing required sections
grep -rL "## Decision\|## Context\|## Consequences" {vault_path}/specs/ 2>/dev/null

# Find specs older than 90 days that may be stale
find {vault_path}/specs/ -name "*.md" -mtime +90 -ls 2>/dev/null
```

---

## Removal Condition
Permanent. These are workflow guardrails, not project-specific.
