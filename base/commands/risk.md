Generate a risk register for the current task or track.

## Instructions

1. Analyze the current work context (active track, spec, plan)
2. Identify risks across these categories:
   - **Technical** — complexity, dependencies, unknowns
   - **Security** — vulnerabilities, data exposure, access control
   - **Schedule** — scope creep, blocking dependencies, estimation accuracy
   - **Operational** — deployment, monitoring, rollback

3. Rate each risk: **LOW** / **MEDIUM** / **HIGH**
4. Propose mitigations

## Output Format

```
RISK REGISTER — {track or task name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| # | Risk | Category | Severity | Mitigation |
|---|------|----------|----------|------------|
| 1 | {description} | Technical | HIGH | {mitigation} |
| 2 | {description} | Security | MEDIUM | {mitigation} |

SUMMARY
  High: {n}  Medium: {n}  Low: {n}
  Top concern: {highest severity risk}
```

## Rules

- Be specific — generic risks ("something might break") are useless
- Every HIGH risk must have a concrete mitigation
- If you can't assess risk without more context, ask
