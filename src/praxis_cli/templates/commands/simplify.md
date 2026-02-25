Read `praxis/context/guidelines.md` first.

Refactor and simplify targeted code without changing behavior.

## Step 1: Identify Target
Ask the user what to simplify:
- A specific file
- A specific function or class
- A directory
- "Whatever needs it most" (scan for complexity)

## Step 2: Analyze
Read the target code. Identify:
- Unnecessary complexity
- Duplicated logic
- Overly long functions (>50 lines)
- Deep nesting (>3 levels)
- Dead code
- Unclear naming
- Missing or excessive abstraction

## Step 3: Propose Changes
Present a summary of proposed simplifications. For each:
- What changes
- Why it's simpler
- Risk level: LOW (rename/reformat) | MEDIUM (restructure) | HIGH (change logic flow)

Do NOT make changes until the user approves.

## Step 4: Execute
Apply approved changes. After each file is modified:
- Run quick verify (format + lint)
- Confirm behavior is unchanged (suggest running tests)

## Step 5: Report
```
🔧 PRAXIS SIMPLIFY
━━━━━━━━━━━━━━━━━━

  Files modified: {n}
  Changes applied: {list}
  Verification: ✅ PASS | ❌ FAIL
  Behavior change: None expected
```

## Rules
- Never change external behavior
- Never simplify test files unless explicitly asked
- Follow guidelines.md for all style decisions
- If a simplification would change the public API, flag it and ask
