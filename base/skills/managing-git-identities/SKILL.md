---
name: managing-git-identities
description: >
  Guides setup and troubleshooting of multiple Git identities
  (SSH keys, commit author, GitHub CLI auth, includeIf directory
  routing). Activates when user discusses git accounts, commit
  identity mismatch, SSH key management, or gh auth switching.
---

## Two Independent Problems

Every commit stamps `user.name` and `user.email` into metadata.
This is separate from which credentials authenticate to the remote.
Solve both layers independently.

## Methods (ranked simplest → most flexible)

### 1. GitHub CLI (`gh auth switch`)
Requires gh >= 2.40.0. Stores OAuth tokens per account.

```bash
gh auth login                          # first account
gh auth login --hostname github.com    # second account
gh auth switch -u <username>
```

Set commit identity locally after clone:
```bash
git config --local user.name "Work Name"
git config --local user.email "work@company.com"
```

### 2. SSH Key Per Account
Map keys to host aliases in `~/.ssh/config`:

```
Host github.com-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_personal
  IdentitiesOnly yes

Host github.com-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_work
  IdentitiesOnly yes
```

Clone with alias: `git clone git@github.com-work:org/repo.git`

### 3. `includeIf` — Auto-Switch by Directory
Best when repos are organized by directory tree.

```gitconfig
# ~/.gitconfig
[user]
    name = Personal Name
    email = personal@gmail.com

[includeIf "gitdir:~/work/"]
    path = ~/work/.gitconfig
```

```gitconfig
# ~/work/.gitconfig
[user]
    name = Work Name
    email = work@company.com
```

### 4. HTTPS + Credential Manager + `useHttpPath`
For corporate proxy environments:

```gitconfig
[credential "https://github.com"]
    useHttpPath = true
    helper = manager
```

## Decision Matrix

| Scenario | Method |
|---|---|
| GitHub-only, minimal config | `gh auth switch` |
| Multi-platform (GitHub + GitLab) | SSH aliases |
| Directory-organized repos | `includeIf` + SSH or HTTPS |
| Corporate HTTPS-only | Credential Manager + `useHttpPath` |

## Praxis Integration

Praxis enforces identity at commit time via:
- `git-workflow.md` identity table (expected email per path)
- `identity-check.sh` hook (hard blocks on mismatch)
- `praxis.config.json` identity section (machine-local, never committed)

When setting up a new machine, run `install.sh` — it prompts for identity
details and generates `profile.md` and `git-workflow.md` from templates.
