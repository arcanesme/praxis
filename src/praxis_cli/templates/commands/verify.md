Read `praxis/verification.md` for this project's configured checks.

Run verification checks against the current codebase.

## Modes

Determine mode from context:
- If invoked during a phase checkpoint → **quick** mode
- If invoked during review or track completion → **full** mode
- If invoked standalone → ask the user: quick or full?

### Quick Mode
Run only:
- Formatter (if enabled)
- Linter (if enabled)

### Full Mode
Run all enabled checks:
- Formatter
- Linter
- Type checker
- Security scanner
- Tests (with coverage if configured)
- Custom checks

## Execution
For each enabled check:
1. Run the configured command
2. Capture output
3. Report: ✅ PASS or ❌ FAIL with relevant output

## Report Format
```
🔍 PRAXIS VERIFY — {mode} mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Formatter:    ✅ PASS | ❌ FAIL
  Linter:       ✅ PASS | ❌ FAIL
  Type Check:   ✅ PASS | ❌ FAIL | ⏭ SKIPPED
  Security:     ✅ PASS | ❌ FAIL | ⏭ SKIPPED
  Tests:        ✅ PASS ({n}/{n}) | ❌ FAIL ({n}/{n})
  Custom:       ✅ PASS | ❌ FAIL | ⏭ SKIPPED

  Overall: ✅ ALL PASSED | ❌ {n} FAILED
```

## On Failure
- Report which checks failed with output
- Do NOT auto-fix unless the user asks
- Suggest specific fixes for each failure
