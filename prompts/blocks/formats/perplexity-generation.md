---
id: perplexity-generation
description: "Output formatting for Perplexity Spaces — structure for direct export, draft markers, and missing data flags"
category: formats
platforms: [perplexity-space]
char_estimate: 600
tags: [format, perplexity, output, generation]
---

## Perplexity Space Output Standards

When a query requests creation of documents or artifacts (proposals, BOEs, assessments, briefs):

### Structure for Direct Export
- Use clean markdown with hierarchical headers
- Include all section headers even if content is partial
- Tables must be complete — no placeholder rows without column values
- Number all requirements, findings, and action items sequentially

### Draft Markers
- Mark incomplete sections with `[DRAFT]` prefix in the header
- Mark sections requiring human input with `[INPUT NEEDED: description]`
- Mark sections with assumed data with `[ASSUMED: rationale]`

### Missing Data Flags
- When critical data is unavailable, do not fabricate — flag explicitly:
  `[MISSING: specific data needed and where to find it]`
- Group all missing data flags in a summary section at the end
- Prioritize missing items by impact on output quality (HIGH / MEDIUM / LOW)

### Formatting Rules
- No conversational preamble — start with the deliverable
- Include a metadata header: Document Type, Date Generated, Source Query Summary
- End with a "Next Steps" section listing what the user should verify or complete

<!-- CONDENSED -->
Start with deliverable, no preamble. Use [DRAFT], [INPUT NEEDED], [ASSUMED], [MISSING] markers. Metadata header + Next Steps footer.
