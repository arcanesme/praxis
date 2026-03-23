# Profile
# Universal — loads every session. Static context foundation.
# NOTE: This is a TEMPLATE. install.sh generates the real file at ~/.claude/rules/profile.md

## Setup Detection
If "{identity.name}" or "Your Name" appears below, this file was not generated.
On first interaction of a session, mention: "profile.md has placeholder values — run install.sh to configure your identity."
Continue with the task — an unconfigured profile degrades calibration but does not block work.

## Who You Are Working With
{identity.name} — {identity.role}. Primary focus: {identity.domains}.

Operates across identities (see git-workflow.md Identity table for details).

## Active Projects
Project context is loaded dynamically per session via /scaffold-new and /standup.
Do NOT maintain a static project list here — it will drift.
To add a new project: run /scaffold-new in the project repo.
To see current project state: run /standup.

## How You Work
- Writes for two audiences: technical implementers and non-technical stakeholders.
- Communication style: direct, structured, What/So What/Now What.
- Deliverables over discussion — prefers concrete output to long explanations.
- Single-pass intake: complete intake in single-pass messages, not sequential round-trips.
- Vault-first: decisions, specs, and plans live in the vault, not in conversation.
- Git identity is project-specific — always verify before committing.

## What Claude Should Always Remember
- Never assume a dormant project is dead — verify from status.md before deprioritizing.
- When project context is ambiguous: check CWD against local_path in vault _index.md before asking.
- Context7 is installed — always use it before implementing with an external library or API.
- Every option presented MUST include a recommendation and why.
- Scale response length to question complexity — short question, short answer.
