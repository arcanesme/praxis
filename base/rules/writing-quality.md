# Writing Quality — Prose Generation Constraints
# Scope: All prose output — design docs, ADRs, READMEs, specs, PR descriptions,
#         commit messages, code comments, status reports
# Always active during prose generation

## The Prime Directive for Prose
Write for the engineer reading this at 11pm during an incident.
They have 90 seconds. Every word must earn its place.

## Invariants — BLOCK on violation

### Sentence limits
- Maximum 30 words per sentence. Count before writing long sentences.
- Maximum 5 sentences per paragraph.
- One idea per paragraph.

### Fluff kill list — never write these words or phrases
leverage (use: use), utilize (use: use), facilitate (use: enable, allow, help),
moving forward, going forward, at this point in time, comprehensive solution,
robust solution, seamlessly, cutting-edge, best-in-class,
in order to (use: to), due to the fact that (use: because),
at the end of the day, synergy, holistic, empower, streamline

For additional banned AI-filler phrases, see `px-communication-standards` skill.
That skill covers: "Certainly!", "Absolutely!", "Great question!", "I'd be happy to",
"It's worth noting that", "In conclusion", "To summarize the above".
Both lists are enforced. Neither is optional.

### Voice on decisions
- Active voice on decisions: "we decided" not "it was decided"
- Active voice on architecture: "this service handles X" not "X is handled by"
- Reserve passive voice for describing states: "the cache is invalidated when..."

### Hedging on decided things
- Decided things use "will", not "should" or "might"
- Uncertain things are labeled explicitly: "open question:", "to be decided:"
- Never hedge silently. If you are uncertain, say so.

## Document Structure — Mandatory Templates

### Design Doc (filename: DESIGN-*.md or *-design.md)
Required sections — none optional, none empty:

#### Problem
- What is broken, missing, or painful? Past tense. Specific.
- "The auth service does not rate-limit failed login attempts" — GOOD
- "We need better authentication" — BAD (not specific, not a problem statement)

#### Decision
- What are we building? Active voice. One paragraph.
- State what this is AND what it is NOT (explicit scope boundary).

#### Tradeoffs
- Minimum 2 items. For each: what we gain AND what we give up.
- Not "pros and cons of the overall approach" — tradeoffs of THIS decision vs alternatives.

#### Acceptance Criteria
- Verifiable statements. Observable outcomes. Present tense.
- GOOD: "The login endpoint returns 429 after 5 failed attempts within 60 seconds"
- BAD: "The system handles failed logins correctly"
- BAD: "Improved security posture"

### ADR (filename: ADR-NNN-*.md)
Required fields in this order:
```
# ADR-NNN: {title}
Status: Proposed | Accepted | Deprecated | Superseded by ADR-NNN
Date: YYYY-MM-DD

## Context
{past tense — what situation forced this decision}

## Decision
{active voice — what we decided}

## Consequences
### Positive
- {at least one}
### Negative
- {at least one — if no negatives, the decision is not analyzed}
```

### README (filename: README.md)
Required sections:
- First paragraph: what does this do (3 sentences max, no jargon)
- `## Install` or `## Setup` with exact commands
- `## Run` with exact commands — no `{placeholder}` in code blocks
- `## Test` with exact commands

### PR Description
Required sections:
- **What**: one sentence — what changed
- **Why**: one sentence — why this was needed
- **How to verify**: exact steps a reviewer takes to confirm it works
- **Breaking changes**: explicit "None" if none — do not omit

## Commit Messages
Format: `{type}({scope}): {what changed in imperative mood}`

Types: feat, fix, refactor, test, docs, chore, perf, ci
Scope: the module, package, or subsystem changed
Subject: present tense imperative — "add retry logic" not "added retry logic"

50-char subject limit. 72-char body line limit if body is present.
Body explains WHY the change was needed, not what the diff shows.

## Code Comments
- WHY not WHAT. The code shows what.
- GOOD: `// retry 3x — upstream returns 503 on cold start, recovers within 2s`
- BAD: `// increment counter`
- Zero tolerance for TODO/FIXME/HACK in committed code.
  Use `// QUALITY: {issue} — tracked in #{issue-number}` if deferring.
  See `refactor-triggers.md` for the QUALITY comment convention.

## Cross-References
- Document-level formatting (proposals, status reports, executive summaries): see `px-communication-standards` skill
- Commit standards and git workflow: see `git-workflow.md`
- Code comment rules: see `code-quality.md` § On comments

## Removal Condition
Remove when a prose linter (Vale or equivalent) runs as a generation-time hook
on all markdown and prose output.
