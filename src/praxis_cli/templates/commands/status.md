Read PRAXIS.md first.

Show the current state of all praxis tracks.

## Step 1: Scan
Read every `spec.md` and `plan.md` in `praxis/tracks/*/`.

## Step 2: Generate Status Report
Use the status report format defined in PRAXIS.md. Include:
- All active tracks with current phase, next task, blockers, and last verification result
- All completed tracks with verdict and completion date
- Summary stats

## Step 3: Suggest Next Action
- Active tracks with unchecked tasks → suggest implement
- Active tracks fully checked but unreviewed → suggest review
- No active tracks → suggest new-track
- Blockers → highlight and ask how to resolve
