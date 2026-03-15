Read PRAXIS.md first.

Execute an active track's plan.

## Step 1: Find Active Track
Scan `praxis/tracks/` for tracks with `status: ACTIVE` in their spec.md.

- If multiple active tracks exist, ask the user which one to work on.
- If no active tracks exist, suggest running new-track.

## Step 2: Read Context
Read in this order:
1. The track's `spec.md`
2. The track's `plan.md`
3. `praxis/context/guidelines.md`
4. `praxis/context/techstack.md`
5. `praxis/verification.md`

## Step 3: Resume from Current Position
Find the first unchecked task (`- [ ]`) in plan.md. Begin there.

## Step 4: Execute
Work through tasks sequentially within the current phase:
- Check off each task (`- [x]`) in plan.md as completed
- Update `current_phase` in plan.md header when moving to a new phase
- Follow guidelines.md strictly

## Step 5: Phase Boundary
When you reach a `⏸ CHECKPOINT`:
1. Run quick verification (format + lint from verification.md)
2. **STOP**
3. Summarize what was completed in this phase
4. Report verification results
5. List any issues, blockers, or deviations from the spec
6. Wait for the user to approve continuing

## Step 6: Track Completion
When all phases are done:
1. Run full verification (all checks from verification.md)
2. Verify all tasks are checked
3. Confirm all success criteria from spec.md are met
4. Report verification results
5. Suggest running review

## Rules
- Never skip a checkpoint
- Never modify the spec without asking
- If a task is blocked, note it in plan.md and move to the next unblocked task
- If scope creep emerges, flag it and suggest a new track
- Always run verify before clearing a checkpoint
