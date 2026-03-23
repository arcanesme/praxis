---
name: secret-scan
description: >
  Canonical secret scanning skill. Scans files for credential patterns
  (API keys, tokens, connection strings). Called by pre-commit-lint and
  ship workflows. Also usable standalone for repo-wide audits. Replaces
  all inline secret scan regex instances with a single authoritative source.
---

# secret-scan Skill

## The Pattern

Single authoritative regex for all secret detection in Praxis:

```
(sk-|ghp_|pplx-|AKIA|Bearer [A-Za-z0-9+/]{20,}|DefaultEndpointsProtocol|AccountKey=)
```

Covers: OpenAI (`sk-`), GitHub PAT (`ghp_`), Perplexity (`pplx-`), AWS (`AKIA`),
Bearer tokens, Azure Storage connection strings.

## Modes

### Staged files (pre-commit)
```bash
rg "(sk-|ghp_|pplx-|AKIA|Bearer [A-Za-z0-9+/]{20,}|DefaultEndpointsProtocol|AccountKey=)" $(git diff --staged --name-only)
```

### Full repo audit
```bash
rg "(sk-|ghp_|pplx-|AKIA|Bearer [A-Za-z0-9+/]{20,}|DefaultEndpointsProtocol|AccountKey=)" --glob "!*.lock" .
```

### .env files check
```bash
git diff --staged --name-only | grep -E "\.env$|\.env\."
```

## Invocation

| Caller | When |
|--------|------|
| `secret-scan.sh` hook | PreToolUse on Write/Edit |
| `pre-commit-lint` skill | Before every commit |
| `/ship` workflow | Pre-flight Step 1 |
| Manual `/secret-scan` | On-demand repo audit |

## On Detection

1. Report file path and line number of each match.
2. BLOCK — do not proceed until the secret is removed or confirmed false positive.
3. If the match is in a regex pattern itself (e.g., in a rules file defining the scan):
   that is a false positive — skip it.

## Extending the Pattern

To add new credential patterns, update the regex in this skill.
All callers reference this skill as the canonical source.
