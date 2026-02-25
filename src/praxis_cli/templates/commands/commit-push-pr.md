Read PRAXIS.md first.

Stage, commit, push, and open a PR with track context.

## Step 1: Identify Track
Check if there's an active track. If so, use it for PR context.

## Step 2: Run Verification
Run verify in full mode. If any checks fail:
- Report failures
- Ask the user: fix issues first, or proceed anyway?
- Do NOT proceed without explicit approval on failures

## Step 3: Stage Changes
Run `git status` and show the user what will be staged.
Ask for confirmation before staging.

```bash
git add -A
```

## Step 4: Commit
Generate a commit message from the track context:

```
{type}({track-name}): {one-line summary}

Phase {n}/{total}: {phase name}
Tasks completed: {list}

Track: praxis/tracks/{track-name}/
```

Show the commit message and ask for approval or edits.

```bash
git commit -m "{message}"
```

## Step 5: Push
```bash
git push origin $(git branch --show-current)
```

## Step 6: Open PR
Generate PR body from track spec and plan:

```markdown
## Summary
{Problem statement from spec.md}

## Approach
{Approach from spec.md}

## Changes
{Completed tasks from plan.md}

## Verification
{Last verify results}

## PRAXIS Track
- Track: `{track-name}` [{type}]
- Spec: `praxis/tracks/{track-name}/spec.md`
- Plan: `praxis/tracks/{track-name}/plan.md`
```

Open PR via `gh pr create` or show the user the command if `gh` is not installed.
