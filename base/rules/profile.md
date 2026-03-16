# Profile
# Universal — loads every session. Static context foundation.
# No paths: scoping — always in context

## Setup Detection
If "Your Name" or "Your Role" appears below, this file is not configured.
STOP and tell the user:
"profile.md is not configured. Fill in Who You Are Working With below before starting."
Do NOT proceed with an empty profile — it causes silent context gaps every session.

## Who You Are Working With
Your Name — Your Role. Primary focus: your domains.

## Active Projects
Project context is loaded dynamically per session via /scaffold-new and /standup.
Do NOT maintain a static project list here — it will drift.
To add a new project: run /scaffold-new in the project repo.
To see current project state: run /standup.

## How You Work
- Writes for two audiences: technical implementers and non-technical stakeholders.
- Communication style: direct, structured, What/So What/Now What.
- Deliverables over discussion — prefers concrete output to long explanations.
- Vault-first: decisions, specs, and plans live in the vault, not in conversation.
- Git identity is project-specific — always verify before committing.

## What Claude Should Always Remember
- Never assume a dormant project is dead — verify from status.md before deprioritizing.
- When project context is ambiguous: check CWD against local_path in vault _index.md before asking.
- Context7 is installed — always use it before implementing with an external library or API.
- Add any project-agnostic rules or constraints here (not project-specific — those go in repo CLAUDE.md).
