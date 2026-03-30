# Structural Quality Review

## What This Skill Covers
Architectural and organizational quality — how code is arranged, how modules relate,
how concerns are separated. These issues don't cause bugs today but create the conditions
for bugs tomorrow.

## Checks (ref: checks-registry.json 62-70)

### Check 62 — Circular Dependencies
Trigger: module A imports from module B which (directly or transitively) imports from module A
Why it matters: circular dependencies make it impossible to reason about initialization order,
make testing harder (you must load everything to test anything), and couple modules that should
be independent.
Fix: extract the shared code into a third module that both A and B import.
Or invert one dependency using an interface/callback.

### Check 63 — Single Responsibility Violation
Trigger: a class or module that has more than one reason to change
Trigger: a module that handles both data persistence AND business logic AND API formatting
Trigger: a class that manages state AND renders output AND handles user events
Why it matters: coupling unrelated responsibilities means a change in one causes ripples
through the other, and tests for one must account for the other.
Fix: split along the axes of change. Each module owns one concern.

### Check 64 — Leaky Abstraction
Trigger: public API exposes implementation details (database IDs in API responses, SQL errors
surfaced to callers, internal model classes in API contracts)
Trigger: callers must know implementation internals to use the API correctly
Why it matters: callers become coupled to implementation details, making refactoring impossible
without breaking all callers.
Fix: define a stable public contract. Convert internal types before they cross module boundaries.

### Check 65 — Missing Error Handling
Trigger: async function with no error handling (missing try/catch or .catch())
Trigger: function receiving external input with no validation
Trigger: function that can throw but has no documentation of what it throws
Why it matters: unhandled errors in production are the leading cause of service outages
and data corruption. Every failure mode must be a designed path.
Fix: add explicit error handling. Every async operation has a catch. Every input is validated.

### Check 66 — Inconsistent Error Strategy
Trigger: some functions throw errors, others return null, others return error objects,
with no clear pattern in the codebase
Why it matters: callers must know which strategy each function uses, creating cognitive load
and making it easy to forget to check for errors in the return-null case.
Fix: choose one error strategy per module boundary and apply it consistently.
Document the convention in the module README or CLAUDE.md.

### Check 68 — Layer Violations
Trigger: UI component directly importing from database module
Trigger: API handler directly constructing SQL queries
Trigger: domain model importing from infrastructure layer
Why it matters: layer violations create coupling that makes it impossible to swap out
implementations (e.g., change databases, add caching, test without external services).
Fix: respect layer boundaries. UI calls service. Service calls repository. Repository calls database.
Each layer knows only the layer directly below it.
