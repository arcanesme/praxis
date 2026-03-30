---
name: px-deepsource-coverage
description: Run tests with coverage and report results to DeepSource. Detects test framework and coverage tool from project stack.
disable-model-invocation: false
---

# DeepSource Coverage Report

## Steps

1. **Check prerequisites**
   - Verify `deepsource` CLI is installed and authenticated
   - Verify `DEEPSOURCE_DSN` is set (required for reporting)
   - If missing: find DSN in DeepSource repo settings → Settings → Reporting

2. **Detect coverage tool**
   - **Go**: `go test -coverprofile=coverage.out ./...` → key: `go`
   - **Python**: `pytest --cov --cov-report=xml` → key: `python`
   - **JavaScript**: `npx jest --coverage` or `npx vitest --coverage` → key: `javascript`
   - **Rust**: `cargo tarpaulin --out xml` → key: `rust`
   - Read test command from project CLAUDE.md `## Commands` section if available

3. **Run tests with coverage**
   - Execute the appropriate coverage command
   - Verify coverage file was generated

4. **Report to DeepSource**
   ```bash
   deepsource report \
     --analyzer=test-coverage \
     --key={language_key} \
     --value-file={coverage_file}
   ```

5. **Report**
   ```
   Coverage reported to DeepSource
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Language:  {language}
   File:      {coverage_file}
   Status:    uploaded ✓
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

## Rules
- Always run the full test suite, not a subset
- If tests fail: report the failure, do not upload partial coverage
- Coverage file paths: `coverage.out` (Go), `coverage.xml` (Python/Rust), `coverage/lcov.info` (JS)
