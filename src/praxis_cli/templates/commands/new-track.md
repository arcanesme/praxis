Read PRAXIS.md first.

Start a new unit of work.

## Step 1: Read Context
Read these files before doing anything:
- `praxis/context/product.md`
- `praxis/context/techstack.md`
- `praxis/context/guidelines.md`
- `praxis/context/workflow.md`
- `praxis/verification.md`

If context files don't exist, tell the user to run setup first.

## Step 2: Choose Track Type
Ask the user to choose one:
- **code** — feature, bug fix, refactor
- **architecture** — spec, decision doc, diagram, compliance mapping
- **federal** — SOW, PWS, compliance matrix, proposal section, past performance
- **content** — digital garden seed, evergreen piece, blog post, documentation

## Step 3: Describe the Work
Ask the user to describe what needs to be done.

## Step 4: Clarify Before Generating
Ask clarifying questions about:
- Scope boundaries — what's in and out
- Audience — who will consume this
- Constraints — timeline, technical, compliance
- Success criteria — how do we know it's done
- Dependencies — what does this depend on or block

Do NOT generate spec or plan until you have clear answers.

## Step 5: Generate Track Files
Create `praxis/tracks/{track-name}/` with `spec.md` and `plan.md` using the formats defined in PRAXIS.md.

Rules for the plan:
- Every phase ends with a verify step: `- [ ] Run verify`
- Every phase ends with: `**⏸ CHECKPOINT — Stop for review before next phase**`
- Include estimated effort per phase
- Final phase always includes full verification and spec validation

## Step 6: Confirm
Present both files. Do NOT begin implementation until the user approves.
