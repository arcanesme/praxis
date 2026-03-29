---
tags: [learnings, {slug}]
date: {YYYY-MM-DD}
source: agent
---
# {Project Name} — Learnings

Agent corrections and discovered patterns for this project.
Uses the [LEARN:tag] schema from the execution engine.

Tags: `bugfix`, `convention`, `perf`, `security`, `tooling`, `arch`, `process`

<!-- Example entry:

## [LEARN:tooling] Terraform fmt must run before plan
- **What**: `terraform plan` succeeded but CI failed on formatting check
- **So What**: Wasted a full CI cycle on a preventable formatting error
- **Now What**: Always run `terraform fmt -recursive` before `terraform plan`.
- **Date**: 2026-03-12

-->
