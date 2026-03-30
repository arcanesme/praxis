# Over-Engineering Detection

## What This Skill Covers
Patterns that add complexity without adding current value. The test:
would removing this make the code simpler AND still solve the stated problem?
If yes — it's over-engineering.

## Checks (ref: checks-registry.json 40-49)

### Check 40 — Premature Abstraction
Trigger: interface/protocol/abstract class with exactly one concrete implementation
Trigger: factory that creates exactly one type
Trigger: strategy pattern with exactly one strategy
Trigger: dependency injection for a dependency that never changes
Why it matters: abstractions have a cognitive cost that only pays off when there are
multiple implementations. A single-implementation interface is a complexity tax with no dividend.
Fix: inline the implementation, delete the interface. Reintroduce when second case arrives.

### Check 41 — Unnecessary Indirection
Trigger: wrapper function whose entire body is a single delegating call
Trigger: class where every public method immediately delegates to a private method
Trigger: adapter between two things that have compatible interfaces already
Why it matters: indirection costs are real — debugging requires tracing through layers
that add no logic and carry no meaning.
Fix: remove the wrapper/adapter, call the underlying thing directly.

### Check 42 — Speculative Generality
Trigger: unused type parameters
Trigger: configuration options with no current callers that set them
Trigger: plugin/extension system with one plugin
Trigger: feature flags that are never evaluated to the non-default value
Why it matters: code written for imagined future requirements is almost always wrong
when those requirements actually arrive. You pay the complexity cost twice: once now,
once when you refactor the wrong abstraction.
Fix: delete the unused generality. Solve the specific problem in front of you.

### Check 43 — God Class / God Function
Trigger: class body exceeds 300 lines
Trigger: function body exceeds 30 lines of logic
Trigger: module with more than 10 public exports
Trigger: function description requires "and" to state its purpose
Why it matters: large units are harder to understand, test, and modify. They attract
more changes (because "it's already in there") and become coordination bottlenecks.
Fix: split along natural responsibility boundaries. The split is right when each piece
has a name that describes its single responsibility.

### Check 44 — Deep Nesting
Trigger: any block nested deeper than 3 levels
Trigger: nested ternary expressions (ternary inside ternary)
Trigger: callback pyramid (function inside function inside function inside function)
Why it matters: cognitive load increases non-linearly with nesting depth. At 4+ levels,
most humans cannot hold the full context stack.
Fix: use early returns (guard clauses) to invert conditions and exit early.
Extract inner blocks into named helper functions.

### Check 45 — Excessive Parameterization
Trigger: function with more than 4 parameters
Trigger: function with boolean flag parameters that switch fundamental behavior
Trigger: options object with more than 8 keys where fewer than half are commonly set
Why it matters: functions with many parameters are harder to call correctly,
harder to read at call sites, and accumulate more parameters over time (it's "safe" to add one more).
Fix: group related parameters into a typed config/options object.
Split functions with boolean flags into two purpose-specific functions.

### Check 46 — Unnecessary Design Patterns
Trigger: Observer/EventEmitter with exactly 2 listeners
Trigger: Singleton for something that should just be a module-level variable
Trigger: Builder pattern for an object with 3 or fewer fields
Trigger: Command pattern for a single simple operation
Why it matters: design patterns solve recurring problems in specific contexts.
Applied outside their context, they add ceremony without solving anything.
Fix: replace the pattern with its direct, simpler equivalent for your specific case.
