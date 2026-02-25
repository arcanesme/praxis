Read PRAXIS.md first.

Review a completed or in-progress track.

## Step 1: Find Track
Scan `praxis/tracks/` for the most recently active track, or ask the user which track to review.

## Step 2: Read Everything
1. The track's `spec.md`
2. The track's `plan.md`
3. `praxis/context/guidelines.md`
4. `praxis/context/workflow.md`
5. `praxis/verification.md`

## Step 3: Run Full Verification
Execute all enabled checks from `praxis/verification.md` in full mode.

## Step 4: Generate Review
Create `praxis/tracks/{track-name}/review.md` using the review format defined in PRAXIS.md.

Include verification results as a dedicated section.

## Step 5: Update Track Status
- If PASS → update spec.md: `status: COMPLETED`, `completed: {YYYY-MM-DD}`
- If FAIL or PARTIAL → keep `status: ACTIVE`, note action items, ask user how to proceed
