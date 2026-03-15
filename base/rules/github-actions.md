---
description: GitHub Actions workflow patterns, security, best practices
paths:
  - ".github/**"
---

# GitHub Actions

## Workflow Structure

- One workflow per concern (CI, deploy, release).
- Use descriptive workflow and job names.
- Pin action versions to full SHA, not tags: `uses: actions/checkout@<sha>`.

## Security

- Never expose secrets in logs. Use `::add-mask::` for dynamic values.
- Minimize `permissions:` — use least-privilege.
- Never use `pull_request_target` with checkout of PR code unless you understand the risks.
- Pin third-party actions to specific commits.

## Performance

- Use caching (`actions/cache`) for dependencies.
- Use `concurrency` to cancel redundant runs.
- Keep jobs focused — parallelize where possible.

## Secrets

- Store in GitHub Secrets, never in workflow files.
- Use environment-scoped secrets for production.
- Rotate secrets regularly.
