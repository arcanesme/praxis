---
name: px-deepsource-review
description: Review DeepSource findings for the current repo or specific files. Triages by severity, proposes fixes for actionable issues.
disable-model-invocation: false
---

# DeepSource Review

## Steps

1. **Check prerequisites**
   - Verify `deepsource` CLI is installed and authenticated: `deepsource auth status`
   - If not ready: suggest running `/px-deepsource-setup`

2. **Fetch findings**
   - If a specific file is provided: `deepsource issues --path <file> --limit 50`
   - If filtering by severity: `deepsource issues --severity critical,major`
   - If filtering by category: `deepsource issues --category security,bug-risk`
   - If no file specified: `deepsource issues --limit 20` for overview
   - For full dashboard view: `deepsource repo view`
   - For JSON output: `deepsource issues --output json`

3. **Triage findings**
   - Group by severity: CRITICAL → MAJOR → MINOR
   - For each finding:
     - Read the flagged code
     - Classify: **real issue** vs **false positive** vs **style nit**
     - For real issues: propose a fix
     - For false positives: explain why and suggest suppression

4. **Fix actionable issues**
   - Apply fixes for confirmed real issues
   - Run `/px-self-verify` on each fixed function
   - Do not fix style nits unless they violate `code-quality.md` constraints

5. **Report**
   ```
   DeepSource Review
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Total:           {count}
   Fixed:           {count}
   False positives: {count}
   Deferred:        {count}
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

## Rules
- Never auto-fix without reading the surrounding code first
- False positives should be explained, not silently skipped
- CRITICAL findings always block — fix before proceeding
