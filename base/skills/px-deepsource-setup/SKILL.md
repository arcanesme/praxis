---
name: px-deepsource-setup
description: Configure DeepSource for a project repo. Creates .deepsource.toml, validates config, checks repo activation status.
disable-model-invocation: false
---

# DeepSource Setup

## Steps

1. **Check prerequisites**
   - Verify `deepsource` CLI is installed: `command -v deepsource`
   - If missing: `curl -fsSL https://cli.deepsource.com/install | sh`
   - Check auth: `deepsource auth status`
   - If not authenticated: `deepsource auth login`

2. **Detect project stack**
   - Scan repo for language files: `git ls-files | sed 's/.*\.//' | sort -u`
   - Map extensions to DeepSource analyzers:
     - `.js`, `.ts`, `.jsx`, `.tsx` → `javascript`
     - `.py` → `python`
     - `.go` → `go`
     - `.rs` → `rust`
     - `.rb` → `ruby`
     - `.java`, `.kt` → `java` / `kotlin`
     - `.tf` → `terraform`
     - `Dockerfile` → `docker`
     - `.sh` → `shell`
   - Always enable `secrets` analyzer

3. **Generate .deepsource.toml**
   - If `.deepsource.toml` exists: validate with `deepsource config validate`
   - If missing: generate with `deepsource config generate`, then customize:
     - Set `environment = ["nodejs"]` for JS projects
     - Set `dialect = "bash"` for shell analyzer
     - Add standard `exclude_patterns` (node_modules, vendor, .terraform, target, dist, build)
     - Add `test_patterns` based on detected test files

4. **Validate and activate**
   - Check repo status: `deepsource repo status`
   - If not activated: open dashboard with `deepsource repo view`
   - Run initial analysis check: `deepsource issues --limit 5`

5. **Report**
   ```
   DeepSource configured
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Config:     .deepsource.toml ✓
   Analyzers:  {list of enabled analyzers}
   Repo:       {activated | not activated}
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

## Rules
- Never overwrite an existing `.deepsource.toml` without showing diff first
- Always validate config before reporting success
