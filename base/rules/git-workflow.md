---
description: Branch strategy, commit messages, PR workflow
---

# Git Workflow

## Commits

- Write commit messages in imperative mood: "Add feature" not "Added feature".
- First line: concise summary (≤72 chars). Body: why, not what.
- One logical change per commit. Don't bundle unrelated changes.
- Never commit secrets, credentials, or environment files.

## Branches

- Branch from `main` (or the project's default branch).
- Use descriptive branch names: `feature/add-auth`, `fix/null-pointer-crash`.
- Keep branches short-lived. Merge early, merge often.

## Pull Requests

- PR title: short, descriptive (≤70 chars).
- PR body: summary bullets + test plan.
- Every PR should be reviewable in one sitting.
- Don't force-push to shared branches.

## Human Controls Git

- Do not commit, push, or create branches unless explicitly asked.
- Do not amend published commits.
- Do not run destructive git operations (`reset --hard`, `push --force`, `clean -f`) without explicit confirmation.
