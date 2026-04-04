---
id: praxis-workflow
description: "Summarizes the Praxis discuss-plan-execute-verify-simplify-ship workflow"
category: context
platforms: [claude-code, claude-project]
char_estimate: 250
tags: [context, workflow, praxis]
---

## Workflow
Praxis owns the outer loop: discuss → plan → execute → verify → simplify → ship.
- Start feature work with `/px-discuss` or `/px-next`
- After implementation: run `/px-simplify` to clean up
- Use `/px-verify-app` for end-to-end checks
- Use `/px-ship` when ready to commit + push + PR
- Pure bugfixes: skip the full loop, use `/px-debug` directly
- Trivial changes: use `/px-fast` to skip planning

<!-- CONDENSED -->
Workflow: discuss → plan → execute → verify → simplify → ship. Start features with /px-discuss. Bugfixes skip to /px-debug.
