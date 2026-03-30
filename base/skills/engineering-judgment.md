# Engineering Judgment — Reasoning About Hard Decisions

This skill provides a framework for reasoning through non-obvious engineering decisions.
Apply it before writing anything that feels complex, uncertain, or requires a tradeoff.

## The Five Questions (ask before writing anything non-trivial)

**1. What is the exact problem I'm solving?**
Write it in one sentence. Not the category of problem — the specific problem.
"Users need to reset passwords" is not specific enough.
"Users who forget their password need to verify identity via email and create a new one" is.
If you cannot write the sentence, stop and clarify before writing code.

**2. What is the simplest thing that could possibly work?**
Start there. Always. Complexity is additive — you can always add it later.
Complexity is almost never removable once it exists, because people build on top of it.
A direct implementation that solves today's problem beats a flexible framework
that solves tomorrow's hypothetical problems.

**3. What will break when requirements change?**
Identify the parts of your design that are tightly coupled to current requirements.
Isolate those parts behind boundaries (functions, modules, interfaces).
Do not protect everything — just the things that are genuinely likely to change.
Protecting stable things is overhead. Protecting volatile things is architecture.

**4. Who reads this code next?**
They have your codebase, no Slack history, no memory of your decisions, and a deadline.
What do they absolutely need to understand?
- What this code does: conveyed by naming
- Why it exists: conveyed by comments
- How to change it safely: conveyed by tests
Make sure all three are present. Everything else is optional.

**5. What would you cut if you had to ship in half the time?**
Cut it now. If the answer is "nothing," your scope is already minimal.
If the answer is "the caching layer" or "the plugin system" or "the admin dashboard,"
those things are not part of the core problem. Ship the core. Add the rest when needed.

## The YAGNI Test
"You Aren't Gonna Need It" is not pessimism — it's empirical engineering.
Studies consistently show that 70%+ of speculative features are never used.
Every hour on YAGNI code is an hour not spent on things users actually need.
Apply it ruthlessly to: abstractions, configuration, generalization, future-proofing.

## When to Refactor
Refactor when ONE of these is true:
1. You are adding a feature and the existing structure makes it harder
2. You have seen the same pattern 3 times and can now name it correctly
Not before. Premature refactoring creates abstractions that don't fit the actual problem
discovered later. The Rule of Three exists for good reason — once is an instance,
twice is coincidence, three times is a pattern worth naming.

## On Technical Debt
Not all debt is bad. Deliberate shortcuts with known payoff timelines are engineering
decisions. Document them: what was cut, why, and when it should be paid back.
The only debt worth preventing is accidental complexity — code that is harder than
it needs to be because no one asked "can we simplify this?"

## The Reversibility Test
Before any significant decision, ask: how hard is this to undo?
- Easy to undo → move fast, decide now
- Hard to undo → move deliberately, decide with evidence
Two-way doors get opened quickly. One-way doors require the Five Questions above.

## On Code Review
When reviewing code (your own or others), ask these in order:
1. Does it correctly solve the stated problem?
2. Is it as simple as it could be while remaining correct?
3. Will the next engineer understand it?
4. Are the failure paths handled?
If all four pass, approve. Style differences below this threshold are preferences, not correctness.
