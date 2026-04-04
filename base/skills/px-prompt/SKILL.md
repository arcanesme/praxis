---
name: px-prompt
disable-model-invocation: true
description: "Unified prompt engine. Creates, generates, condenses, and syncs system prompts for Claude Projects, Perplexity Spaces, and Claude Code. Auto-detects what to do based on project state."
---

# px-prompt Skill

## Overview
Single entry point for the prompt engine. Detects what needs to happen based on project state and user intent.

## Invocation
- `/px-prompt <project-name>` — create, generate, or regenerate a project's prompts
- `/px-prompt --sync` — recompile all projects, report diffs and budgets
- `/px-prompt --list` — list all projects and their status

---

## Routing Logic

When invoked with a project name, detect the right action:

```
/px-prompt <project-name>
  │
  ├─ Project doesn't exist?
  │   → ACTION: CREATE (Step 1)
  │
  ├─ Project exists, mode: standalone, system-prompt.md missing?
  │   → ACTION: GENERATE FROM SCRATCH (Step 2)
  │
  ├─ Project exists, mode: standalone, system-prompt.md exists, platform outputs missing?
  │   → ACTION: CONDENSE (Step 3)
  │
  ├─ Project exists, mode: standalone, all files present?
  │   → ACTION: VALIDATE + offer to regenerate (Step 4)
  │
  ├─ Project exists, mode: compiled?
  │   → ACTION: COMPILE (Step 4)
  │
  └─ --sync flag?
      → ACTION: SYNC ALL (Step 5)
```

---

## Step 1 — CREATE: New project scaffold

**Triggered when:** project folder doesn't exist.

### 1a. Core intake (always ask)

1. **Description** — "Describe this project in one sentence."

2. **Role** — "Who is the AI in this project?"
   - Show available identity blocks: `node bin/prompt-blocks.js --category identity`
   - User can pick one OR describe a custom role

3. **Target platforms** — "Which platforms will you deploy to?"
   - Multi-select: Claude Projects, Perplexity Spaces, Claude Code
   - Default: Claude Projects + Perplexity Spaces

4. **Complexity** — Based on the description, recommend a mode:
   - Simple/standard project → **compiled** (block-based, continue to 1b)
   - Complex multi-role agent → **standalone** with AI generation (continue to 1c)
   - User already has a prompt → **standalone** paste-in (scaffold folder, skip to Step 3)

### 1b. Compiled project setup

5. **Domain expertise** — Show available domain blocks:
   ```bash
   node bin/prompt-blocks.js --category domains
   ```
   User picks from list or describes custom domains.
   For custom domains: create a new block file at `prompts/blocks/domains/<id>.md`.

6. **Research domains** (if Perplexity selected) — "What topics should Perplexity prioritize?"
   Suggest based on selected domains. User accepts or customizes.

7. **Knowledge files** — "Reference documents to upload alongside? (compliance matrices, standards, playbooks)"

8. **Claude Code extras** (only if Claude Code selected) — tech stack, commands, git identity

9. **Build project folder:**
   ```bash
   mkdir -p prompts/projects/<project-name>/references
   ```

   Write `prompt-config.yaml`:
   ```yaml
   project: <project-name>
   description: <from intake>
   mode: compiled
   version: "1.0"
   platforms: [claude-project, perplexity-space]
   profile: null
   blocks:
     identity: [<matched-block>]
     domains: [<selected-blocks>]
     behaviors: []
     formats: []
     context: [<auto-selected by platform>]
   research_domains: [<from intake>]
   knowledge_files: [<from intake>]
   ```

   **Auto-add context blocks by platform:**
   - Perplexity → `official-docs-first`, `flag-confidence`
   - Claude Code → `vault-integration`, `mcp-servers`, `praxis-workflow`

10. **Compile:** `node bin/prompt-compile.js <project-name>`

11. → Go to **Step 4** (results + deployment)

### 1c. Standalone project with AI generation

→ Go to **Step 2** (generate from scratch)

---

## Step 2 — GENERATE: AI-powered system prompt creation

**Triggered when:** standalone project exists but `system-prompt.md` is empty/missing, OR user explicitly requests generation.

### 2a. Intake (if not already gathered in Step 1)

1. **Description** — 2-3 sentences about the project
2. **Role** — primary AI responsibility
3. **Domains** — expertise areas (free-form, not limited to existing blocks)
4. **Key behaviors** — rules beyond defaults
5. **Target audience** — who reads the output
6. **Knowledge files** — reference documents
7. **Target platforms** — deployment targets

### 2b. Domain research via Perplexity

**Mandatory before generating.** For each domain, run Perplexity queries:

**Query 1 — Best practices:**
```
perplexity_ask: "What are the current best practices for [domain]
AI assistants in 2025-2026? Key terminology, active standards,
common workflows, expert expectations."
```

**Query 2 — Standards:**
```
perplexity_search: "[domain] key frameworks standards certifications 2025"
```

**Query 3 — Use cases:**
```
perplexity_ask: "What are the most common tasks [target audience]
asks AI assistants to help with in [domain]? Top 10 use cases."
```

If Perplexity unavailable: state "Domain research could not be completed — prompt uses training data only. Review for currency." and proceed.

### 2c. Generate system-prompt.md

Using intake + Perplexity research, generate following the 5-layer skeleton:

```markdown
---
version: "1.0"
date: [today]
platform: claude-project
generated_by: px-prompt
---

## Role
[One-sentence role from intake, using current terminology from research]

## Behavioral Constraints
[_base defaults: no-flattery, verify-before-reporting, recommend-with-reasons, handle-uncertainty]
[Custom behaviors from intake]
[Domain-specific constraints from research]

## Domain Expertise
[Structured areas from research — current framework names, standard versions]

## Output Format
[Format rules for target audience]
[What/So What/Now What for analytical outputs]

## Common Tasks
[Top 5-10 use cases from Perplexity research]

## Knowledge Interaction Rules
[How to use reference files, when to cite, quote-before-answer]

## Accuracy Standards
- Flag confidence levels when synthesizing across sources
- Distinguish verified facts from analytical inferences
- If sources disagree, cite both and explain the discrepancy
- Never fabricate version numbers, citations, or references
- When information may be outdated, note this explicitly

## When Uncertain
State uncertainty explicitly. Ask one clarifying question rather than guessing.
```

**Generation rules:**
- Use terminology from Perplexity research, not training-data assumptions
- Positive framing: "Do X" over "Don't do Y"
- No few-shot examples (breaks Perplexity)
- Under 5,000 characters
- Include Accuracy Standards + When Uncertain (mandatory)

Write to `prompts/projects/<project-name>/system-prompt.md`.

### 2d. Auto-condense

→ Go to **Step 3** (condense to platform outputs)

---

## Step 3 — CONDENSE: Generate platform outputs from system-prompt.md

**Triggered when:** standalone project has `system-prompt.md` but missing `space-instructions.md` or `CLAUDE.md`.

Read the full `system-prompt.md` as source.

### 3a. Generate Perplexity Space instructions

**Target:** `space-instructions.md` | **Budget:** under 4,000 chars

**Include:** identity, domain expertise, research domains, source priority, answer format, key frameworks (by name only)
**Exclude:** internal templates, scoring matrices, reference file content, deployment details, full tables

**Output format:**
```markdown
## Purpose
## Domain Expertise
## Research Domains
## Source Priority
## How to Answer
## Accuracy Standards
```

**Perplexity guardrails:**
- No few-shot examples
- No URLs in instructions
- Replace absolute language with conditional ("if available", "when sources confirm")
- Search-friendly domain terms

### 3b. Generate Claude Code CLAUDE.md (if Claude Code is a target platform)

**Target:** `CLAUDE.md` | **Budget:** under 250 lines

**Include:** identity, behaviors, domain expertise, frameworks (one-line each), operating modes, quality controls
**Exclude:** full scoring matrices, templates, reference file content, corporate data tables

**Output format:**
```markdown
# [Project Name]
## Identity
## Behaviors
## Domain Expertise
## Frameworks
## Operating Modes
## Quality Controls
## References
```

**Claude Code guardrails:**
- Positive framing: "Do X" over "Don't do Y"
- No "CRITICAL: YOU MUST" language (Claude 4.6 overtriggers)
- Self-check block for quality-critical outputs
- Reference knowledge files by filename only

### 3c. Validate budgets

After generating, check:
- `space-instructions.md` under 4,000 chars
- `CLAUDE.md` under 250 lines

If over budget: flag and suggest sections to trim.

→ Go to **Step 4** (results)

---

## Step 4 — RESULTS: Validate + show deployment instructions

**Triggered when:** project has outputs to display (compiled or standalone).

### 4a. Run validator
```bash
node bin/prompt-compile.js <project-name>
```

### 4b. Show results table

```
| Output               | Chars  | Budget | Status |
|----------------------|--------|--------|--------|
| system-prompt.md     | X      | —      | Source |
| project-instructions | X      | 2,500  | OK     |
| space-instructions   | X      | 4,000  | OK     |
| CLAUDE.md            | X lines| 250 ln | OK     |
| references/          | N files| —      | Upload |
```

### 4c. Deployment instructions

**Claude Projects (claude.ai):**
1. Open project at claude.ai/projects → "Set project instructions"
2. Standalone: paste `system-prompt.md` | Compiled: paste `project-instructions.md`
3. If `references/` exists: upload each `.md` file as project knowledge
4. Save

**Perplexity Spaces:**
1. Open Space → Settings → Answer Instructions
2. Paste `space-instructions.md`
3. Save

**Claude Code:**
1. Copy `CLAUDE.md` to project repo root

### 4d. Offer next actions
- "Edit the prompt? I'll regenerate platform outputs after."
- "Want to regenerate? Run `/px-prompt <project-name>` again."

---

## Step 5 — SYNC: Recompile all projects

**Triggered when:** `/px-prompt --sync`

```bash
node bin/prompt-compile.js --all --diff
```

Show summary table:
```
| Project | CLAUDE.md | Project Instr. | Space Instr. | Changes |
|---------|-----------|----------------|--------------|---------|
| praxis  | 3,534     | 1,316 ✓        | 1,529 ✓      | none    |
| maximus | —         | —              | 3,977 ✓      | standalone |
```

For standalone projects, report validation status instead of compilation status.

Print deployment reminders for any project with changes.

---

## Rules

### Always
- `_base` behaviors (no-flattery, verify, recommend, handle-uncertainty) are included in every project — non-negotiable
- Accuracy Standards section is mandatory in all Perplexity outputs
- When Uncertain section is mandatory in all Claude Project outputs
- Never ask for repo URL, vault path, or git email unless Claude Code is a target platform

### Platform-specific
- **Perplexity**: no few-shot examples, no URLs, conditional language, search-friendly terms
- **Claude Code**: positive framing, no "CRITICAL YOU MUST", self-check blocks
- **Claude Projects**: 5-layer skeleton (Role, Constraints, Format, Knowledge Rules, Failure Handling)

### Generation
- ALWAYS run Perplexity research before generating system prompts (Step 2)
- Use current terminology from research, not training-data assumptions
- Generated prompts are starting points — tell user to review and refine
- If Perplexity unavailable: proceed with training data, flag for review

### Block matching (compiled mode)
- Role → identity block: "architect" → `solutions-architect`, "engineer" → `senior-engineer`, "researcher" → `research-partner`
- Domain keywords → domain blocks: "cloud/azure/aws" → `cloud-infrastructure`, "federal/govcon" → `govcon`, "web/react" → `web-development`
- If no match: create custom block on the fly
- Auto-add `official-docs-first` + `flag-confidence` for Perplexity targets
- Auto-add `vault-integration` + `mcp-servers` + `praxis-workflow` for Claude Code targets
