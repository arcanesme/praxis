---
description: Validate the token pipeline — ensure design tokens flow correctly from definition through to component usage. Catches orphan tokens, missing references, and broken chains.
---

You are validating the design token pipeline.

**Step 1 — Locate token definitions**
Find token files:
```bash
find . -path "*/tokens/*" -o -path "*/design-system/*" | grep -E "\.(css|ts|js|json)$"
```
Also check: `tailwind.config.*` for theme extensions.

**Step 2 — Extract defined tokens**
Parse all token files. Build a list of defined token names:
- CSS custom properties (`--token-name`)
- Tailwind theme keys
- JS/TS token exports

**Step 3 — Find token usage in components**
```bash
# CSS var references
grep -rn "var(--" src/components/ | sed 's/.*var(--/--/' | sed 's/).*//' | sort -u

# Tailwind class usage (approximate — look for theme-derived classes)
grep -rn "className" src/components/ | grep -oE "[a-z]+-[a-z]+-[0-9]+" | sort -u
```

**Step 4 — Cross-reference**
- **Orphan tokens**: Defined but never used in any component → WARN
- **Missing tokens**: Referenced in components but not defined → BLOCK
- **Broken chain**: Semantic token references a primitive that doesn't exist → BLOCK
- **Shadow values**: Component uses a raw value that has a token equivalent → WARN

**Step 5 — Report**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TOKEN SYNC — {today_date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Defined tokens:   {count}
  Used tokens:      {count}
  Orphan tokens:    {count}  (defined, never used)
  Missing tokens:   {count}  (used, never defined) — BLOCKING
  Shadow values:    {count}  (raw value has token equivalent)

  {details for each finding}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
