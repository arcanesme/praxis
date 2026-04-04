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
- `/px-prompt --scan <project-name>` — scan project folder, suggest edits to existing prompts

---

## Initial Menu Behavior

**NEVER hardcode individual project names in the initial options menu.**
When the user runs `/px-prompt` without arguments, show ONLY these generic options:
1. Create new project
2. Sync all projects
3. Work on existing project → THEN dynamically list projects from `node bin/prompt-compile.js --list`

Do NOT show "Work on praxis" or "Work on maximus" or any project name — the engine is project-agnostic. Discover projects dynamically at runtime.

---

## Output File Naming Convention

Platform outputs use suffixed filenames so users can distinguish them at a glance:

| Platform | Output Filename | Budget |
|----------|----------------|--------|
| Source (Claude Projects) | `system-prompt.md` | 5,000 chars |
| Claude Desktop / Projects | `project-instructions-claude-desktop.md` | 2,500 chars |
| Perplexity Spaces | `space-instructions-perplexity.md` | 4,000 chars |
| Claude Code | `CLAUDE.md` | 250 lines |

All output files live in `prompts/projects/<project-name>/`.
Reference/knowledge files live in `prompts/projects/<project-name>/references/`.

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
  ├─ --scan flag?
  │   → ACTION: SCAN & EDIT (Step 6)
  │
  └─ --sync flag?
      → ACTION: SYNC ALL (Step 5)
```

---

## Step 1 — CREATE: New project scaffold

**Triggered when:** project folder doesn't exist.

### 1a. Single-question intake

Ask ONE question: **"Describe this project in 1-2 sentences."**

That's it. Infer everything else using the inference engine below.

### 1b. Inference engine — derive config from description

Run these rules against the description to auto-populate the project config:

**Role inference** (keywords → identity block):
- "architect", "design", "infrastructure", "cloud", "azure", "aws" → `solutions-architect`
- "engineer", "developer", "code", "build", "implement" → `senior-engineer`
- "research", "analysis", "investigate", "study" → `research-partner`
- "capture", "proposal", "federal", "deal", "RFP", "maximus" → `federal-deal-sa` (use `maximus-sa` profile)
- No match → `solutions-architect` (default)

**Domain inference** (keywords → domain blocks):
- "cloud", "azure", "aws", "terraform", "infrastructure" → `cloud-infrastructure`
- "federal", "govcon", "government", "compliance", "FedRAMP" → `govcon`
- "web", "react", "frontend", "UI", "design" → `web-development`
- "capture", "proposal", "RFP", "deal" → `govcon-capture`, `govcon-proposal`
- No existing block match → standalone mode (AI generates custom domain content from research)

**Platform inference:**
- Default: Claude Projects + Perplexity Spaces
- Add Claude Code if description contains: "code", "repo", "implement", "build", "develop", "engineering", "CLI"
- Perplexity-only if description contains: "research only", "analysis only", "investigation"

**Mode inference:**
- If description triggers `maximus-sa` profile → compiled with `maximus-sa`
- If ≥2 existing domain blocks match → compiled with matched blocks
- If description suggests multi-role, custom workflow, or complex agent → standalone
- If no domain blocks match → standalone with AI generation (Perplexity fills the gap)
- Default for unknown domains → standalone

**Research domain inference:**
- Derive from description keywords + matched domain names
- For standalone: use the full description as research seed
- Always generate at least 2 research queries

### 1c. Show confirmation card

Instead of asking more questions, show what was inferred:

```
Project: <project-name>

  Role:       <inferred identity block or "custom via research">
  Domains:    <matched blocks or "custom — AI-generated from research">
  Platforms:  <inferred list>
  Mode:       <compiled | standalone>
  Profile:    <matched profile or "none — custom blocks">
  Research:   <inferred research topics>
  Knowledge:  auto-generate from research

  [Proceed] [Edit]
```

- **Proceed** → run full pipeline (scaffold → research → generate → condense → results)
- **Edit** → ask ONE targeted follow-up on the specific field to change

### 1d. Build project and run pipeline

After confirmation:

1. **Scaffold folder:**
   ```bash
   mkdir -p prompts/projects/<project-name>/references
   ```

2. **Write `prompt-config.yaml`** with inferred values

3. **If compiled mode:** `node bin/prompt-compile.js <project-name>` → Step 4

4. **If standalone mode:** → Step 2 (Perplexity research + generation)

**Auto-add context blocks by platform (compiled mode):**
- Perplexity → `official-docs-first`, `flag-confidence`
- Claude Code → `vault-integration`, `mcp-servers`, `praxis-workflow`

---

## Step 2 — GENERATE: AI-powered system prompt creation

**Triggered when:** standalone project exists but `system-prompt.md` is empty/missing, OR user explicitly requests generation.

### 2a. Use inference from Step 1

All intake was gathered in Step 1 (description → inference engine → confirmation card).
Do NOT ask additional questions here. Use the confirmed config from Step 1c.

The description provides: role, domains, audience, platforms.
Behaviors default from `_base`. Knowledge files auto-generate from research.

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

Using intake + Perplexity research, generate following the 7-layer skeleton:

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

## Quality Controls
### Source Verification
- Cross-reference claims against uploaded knowledge files before presenting as fact
- When synthesizing from multiple sources, flag any contradictions
- Distinguish between: verified (from knowledge files), corroborated (multiple sources agree), inferred (logical deduction), and speculative (educated guess)

### Anti-Hallucination Protocol
- Never fabricate version numbers, dates, statistics, citations, URLs, or API signatures
- If you cannot find a specific fact in knowledge files or your training data, say so — do not approximate
- When quoting standards, frameworks, or regulations: cite the specific document name and section
- If a user asks about something not covered in knowledge files, explicitly state "this is not covered in the provided references" before offering general knowledge
- For numerical claims (costs, timelines, metrics): only state numbers you can trace to a source
- When information may be outdated (>12 months), flag it: "As of [date], [claim] — verify for current status"

### Output Quality
- Every recommendation includes rationale and tradeoffs
- Tables for comparisons, not paragraphs
- Structured outputs: use headers, bullets, numbered steps — not walls of text
- Self-check: before delivering, verify your response answers the specific question asked

## When Uncertain
State uncertainty explicitly. Ask one clarifying question rather than guessing.
Flag confidence level: HIGH (verified from sources), MEDIUM (corroborated), LOW (inferred or speculative).
```

**Generation rules:**
- Use terminology from Perplexity research, not training-data assumptions
- Positive framing: "Do X" over "Don't do Y"
- No few-shot examples (breaks Perplexity)
- Under 5,000 characters
- Quality Controls + When Uncertain sections are **mandatory** — never omit
- Anti-Hallucination Protocol is **mandatory** in all generated prompts

Write to `prompts/projects/<project-name>/system-prompt.md`.

### 2d. Auto-condense

→ Go to **Step 3** (condense to platform outputs)

### 2e. Generate knowledge files from Perplexity research

**Always runs by default** after prompt generation. Do not ask — just generate.
If the user declined in the confirmation card, skip this step.

For each research domain:

1. Run deep Perplexity queries per domain:
   ```
   perplexity_research: "Comprehensive overview of [domain]:
   key concepts, current standards, best practices, common terminology,
   frameworks, tools, and workflows. Include specific version numbers,
   dates, and authoritative sources."
   ```

2. Structure findings into a knowledge file:
   ```markdown
   ---
   domain: [domain-name]
   generated: [today]
   source: perplexity-research
   ---

   # [Domain] — Reference Guide

   ## Key Concepts & Terminology
   [Terms with definitions from research]

   ## Current Standards & Frameworks
   [Standards with version numbers and dates]

   ## Best Practices
   [Actionable practices from research]

   ## Common Workflows
   [Step-by-step workflows from research]

   ## Tools & Technologies
   [Relevant tools with current versions]

   ## Sources
   [Citations from Perplexity research]
   ```

3. Write to `prompts/projects/<project-name>/references/<domain-slug>.md`

4. Update `prompt-config.yaml` knowledge_files list

**Budget awareness:** Each knowledge file should be under 10,000 chars for Claude Projects upload limits. Split large domains into multiple files if needed.

---

## Step 3 — CONDENSE: Generate platform outputs from system-prompt.md

**Triggered when:** standalone project has `system-prompt.md` but missing `space-instructions-perplexity.md` or `CLAUDE.md`.

Read the full `system-prompt.md` as source.

### 3a. Generate Perplexity Space instructions

**Target:** `space-instructions-perplexity.md` | **Budget:** under 4,000 chars

**Include:** identity, domain expertise, research domains, source priority, answer format, key frameworks (by name only), accuracy standards, anti-hallucination rules
**Exclude:** internal templates, scoring matrices, reference file content, deployment details, full tables

**Output format:**
```markdown
## Purpose
## Domain Expertise
## Research Domains
## Source Priority
## How to Answer
## Quality & Accuracy Standards
```

**Mandatory quality section for Perplexity outputs:**
```markdown
## Quality & Accuracy Standards
- Flag confidence level: HIGH (multiple sources confirm), MEDIUM (single source), LOW (inferred)
- Never fabricate version numbers, statistics, citations, or URLs
- If sources disagree, cite both and explain the discrepancy
- When information may be outdated (>12 months), note the publication date
- If you cannot find reliable sources, state that clearly rather than speculating
- Distinguish verified facts from analytical inferences
```

**Perplexity guardrails:**
- No few-shot examples
- No URLs in instructions
- Replace absolute language with conditional ("if available", "when sources confirm")
- Search-friendly domain terms

### 3b. Generate Claude Code CLAUDE.md (if Claude Code is a target platform)

**Target:** `CLAUDE.md` | **Budget:** under 250 lines

**Include:** identity, behaviors, domain expertise, frameworks (one-line each), operating modes, quality controls, anti-hallucination rules
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

### 3c. Generate Claude Desktop project instructions (if Claude Projects is a target platform)

**Target:** `project-instructions-claude-desktop.md` | **Budget:** under 2,500 chars

**Include:** role, behavioral constraints, domain expertise (condensed), output format, quality controls, when uncertain
**Exclude:** full domain details (those go in knowledge files), reference content, deployment details

### 3d. Validate budgets

After generating, check:
- `space-instructions-perplexity.md` under 4,000 chars
- `project-instructions-claude-desktop.md` under 2,500 chars
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
| Output                                   | Chars  | Budget | Status |
|------------------------------------------|--------|--------|--------|
| system-prompt.md                         | X      | —      | Source |
| project-instructions-claude-desktop.md   | X      | 2,500  | OK     |
| space-instructions-perplexity.md         | X      | 4,000  | OK     |
| CLAUDE.md                                | X lines| 250 ln | OK     |
| references/                              | N files| —      | Upload |
```

### 4c. Deployment instructions

**Claude Desktop / Projects (claude.ai):**
1. Open project at claude.ai/projects → "Set project instructions"
2. Standalone: paste `system-prompt.md` | Compiled: paste `project-instructions-claude-desktop.md`
3. If `references/` exists: upload each `.md` file as project knowledge
4. Save

**Perplexity Spaces:**
1. Open Space → Settings → Answer Instructions
2. Paste `space-instructions-perplexity.md`
3. Save

**Claude Code:**
1. Copy `CLAUDE.md` to project repo root

### 4d. Offer next actions
- "Edit the prompt? I'll regenerate platform outputs after."
- "Want to regenerate? Run `/px-prompt <project-name>` again."
- "Generate knowledge files from research? I'll create reference docs from Perplexity."
- "Scan project folder for recommended changes? Run `/px-prompt --scan <project-name>`."

---

## Step 5 — SYNC: Recompile all projects

**Triggered when:** `/px-prompt --sync`

```bash
node bin/prompt-compile.js --all --diff
```

Show summary table:
```
| Project      | CLAUDE.md | Claude Desktop    | Perplexity       | Changes    |
|--------------|-----------|-------------------|------------------|------------|
| praxis       | 3,534     | 1,316 ✓           | 1,529 ✓          | none       |
| maximus      | —         | —                 | 3,977 ✓          | standalone |
```

For standalone projects, report validation status instead of compilation status.

Print deployment reminders for any project with changes.

---

## Step 6 — SCAN & EDIT: Analyze and update existing project prompts

**Triggered when:** `/px-prompt --scan <project-name>` or user asks to review/update existing prompts.

### 6a. Read all project files
1. Read `prompt-config.yaml` for project metadata
2. Read `system-prompt.md` (source of truth)
3. Read all platform outputs (`space-instructions-perplexity.md`, `project-instructions-claude-desktop.md`, `CLAUDE.md`)
4. Read all files in `references/` directory
5. List any other files in the project folder

### 6b. Analyze for issues
Check each file against these criteria:

**Quality checks:**
- Does system-prompt.md include Quality Controls section?
- Does system-prompt.md include Anti-Hallucination Protocol?
- Does system-prompt.md include When Uncertain section?
- Are platform outputs in sync with system-prompt.md content?
- Are file naming conventions correct (platform suffixes)?
- Are all referenced knowledge files present in references/?

**Budget checks:**
- `space-instructions-perplexity.md` under 4,000 chars?
- `project-instructions-claude-desktop.md` under 2,500 chars?
- `CLAUDE.md` under 250 lines?

**Currency checks (via Perplexity):**
- Are domain-specific terms, standards, and versions still current?
- Have any referenced frameworks been updated or renamed?

### 6c. Present findings and offer edits
Show a structured report:
```
| Check                     | Status | Details                           |
|---------------------------|--------|-----------------------------------|
| Quality Controls section  | PASS   | Present in system-prompt.md       |
| Anti-Hallucination        | FAIL   | Missing — will add                |
| Budget: Perplexity        | PASS   | 2,392 / 4,000 chars              |
| File naming               | FAIL   | Uses old convention — will rename |
| Knowledge files           | WARN   | 0 reference files — consider adding |
```

For each FAIL:
- Show the specific fix needed
- Apply the fix (with user confirmation for content changes)
- Regenerate affected platform outputs

### 6d. Reference existing files for future changes
After scanning, maintain awareness of:
- Which sections of the prompt cover which domains
- What knowledge files exist and what they contain
- What the version history looks like (from prompt-config.yaml)

Use this context when the user asks for changes — edit in place rather than regenerating from scratch.

---

## Rules

### Always
- `_base` behaviors (no-flattery, verify, recommend, handle-uncertainty) are included in every project — non-negotiable
- Quality Controls section with Anti-Hallucination Protocol is **mandatory** in all generated prompts
- Accuracy Standards section is mandatory in all Perplexity outputs
- When Uncertain section with confidence levels is mandatory in all outputs
- Never ask for repo URL, vault path, or git email unless Claude Code is a target platform
- **Never hardcode project names in menus or options** — discover dynamically

### Platform-specific
- **Perplexity**: no few-shot examples, no URLs, conditional language, search-friendly terms
- **Claude Code**: positive framing, no "CRITICAL YOU MUST", self-check blocks
- **Claude Desktop / Projects**: 7-layer skeleton (Role, Constraints, Expertise, Format, Knowledge Rules, Quality Controls, When Uncertain)

### File naming
- **Always** use platform-suffixed filenames: `space-instructions-perplexity.md`, `project-instructions-claude-desktop.md`
- `CLAUDE.md` keeps its name (convention for Claude Code)
- `system-prompt.md` keeps its name (it's the source of truth, not platform-specific)

### Quality defaults (mandatory in all generated prompts)
- Anti-Hallucination Protocol: never fabricate, cite sources, flag confidence, distinguish fact from inference
- Source Verification: cross-reference knowledge files, flag contradictions
- Output Quality: rationale with recommendations, structured outputs, self-check before delivery
- Confidence Levels: HIGH (verified), MEDIUM (corroborated), LOW (inferred/speculative)

### Knowledge file generation
- Always generate knowledge files from Perplexity research by default — don't ask
- Each knowledge file under 10,000 chars (Claude Projects upload limit)
- Structure: Key Concepts, Standards, Best Practices, Workflows, Tools, Sources
- Write to `references/<domain-slug>.md`

### Project folder scanning
- Read all existing project files before suggesting changes
- Edit in place rather than regenerating when the user requests specific changes
- Track what each section covers so future edits are surgical
- Flag outdated terminology, missing quality sections, budget overruns

### Generation
- ALWAYS run Perplexity research before generating system prompts (Step 2)
- Use current terminology from research, not training-data assumptions
- Generated prompts are starting points — tell user to review and refine
- If Perplexity unavailable: proceed with training data, flag for review

### Inference and block matching
- See Step 1b for full inference rules (role, domain, platform, mode, research domains)
- If no domain blocks match → standalone mode with AI generation, not compiled with empty blocks
- Auto-add `official-docs-first` + `flag-confidence` for Perplexity targets (compiled mode)
- Auto-add `vault-integration` + `mcp-servers` + `praxis-workflow` for Claude Code targets (compiled mode)
- **Maximum 1 question** for new projects (description). Show confirmation card, not a questionnaire.
