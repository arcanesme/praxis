# Code Excellence — Core Principles

These principles shape how you reason about code before writing a single character.
They are not a checklist — they are a worldview. They are always active.

## The Prime Directive
Write code that the next engineer will thank you for.
That engineer is you, six months from now, at 2am with a production incident.
Optimize for that moment.

## On Simplicity
The simplest solution that correctly solves the stated problem is always right.
Not the solution that solves the *anticipated* problem.
Not the solution that would *scale* if requirements changed.
Not the solution that demonstrates *skill*.
The solution to the problem in front of you, right now.

Before adding any abstraction, answer all three:
- Does this abstraction already have 2+ concrete use cases that exist TODAY?
- If removed, does anything break that exists today?
- Would a new engineer understand the code FASTER with this abstraction than without it?
If any answer is no — do not add it. Inline the logic.

Over-engineering red flags — stop and simplify if you see yourself writing:
- An interface/factory/strategy with exactly one implementation
- A wrapper function whose entire body is a single delegating call
- Unused type parameters, config options no caller sets, plugin systems with one plugin
- Observer/EventEmitter with 2 listeners, Singleton for a module variable, Builder for 3 fields
- A function with boolean flags that switch behavior — write two functions instead

## On Correctness
Correctness means the code does exactly what its name promises. Not more. Not less.
A function named `getUserById` returns a user by ID.
It does not log. It does not cache. It does not validate sessions. It does not send metrics.
If it does those things, rename it or split it.
Side effects that aren't in the name are the leading cause of bugs that take hours to find.

## On Naming
Names are the primary interface between code and the human reading it.
A name that requires a comment to explain has failed.
- Functions are named for what they DO (verb phrase): `validateEmailFormat`, `fetchOrderById`
- Variables are named for what they CONTAIN (noun phrase): `userRecord`, `retryCount`
- Booleans are named as assertions: `isValid`, `hasPermission`, `canRetry`
- Avoid: `data`, `info`, `temp`, `result`, `obj`, `val`, `x`
If you cannot name something clearly, you do not understand it well enough to write it yet.

## On Error Handling
Every function that can fail has two paths: success and failure. Both are designed.
Neither is an afterthought.
- Errors are never swallowed silently. Silent failures are the worst kind.
- Error messages tell the caller what happened AND what to do about it.
- Errors surface at the right level — don't catch what you can't handle.
- External input is always validated before use. Always.

## On Tests
Tests are the second consumer of your API. If the test is hard to write, the API is wrong.
Test behavior, not implementation:
- WRONG: "calls the repository with the user id"
- RIGHT: "returns null when the user does not exist in the database"
The test name is documentation. Write it first. Then write the code that makes it pass.
A test that can never fail is not a test — it's a ceremony.

## On Dependencies
Every dependency is a liability you will maintain forever.
Before adding one, answer:
- Can this be done in 10 lines with the standard library?
- Has this package had a commit in the last 6 months?
- Do you understand it well enough to debug it without its documentation?
If any answer is no — find an alternative or write it yourself.

## On Comments
Comments explain WHY, not WHAT. The code explains what.
A comment that says `// increment counter` above `counter++` is noise.
A comment that says `// retry three times because the upstream API returns 503 on cold start`
is knowledge that cannot be inferred from the code alone.
Delete the first kind. Write more of the second kind.

---

## Reference Codebases — What Excellence Looks Like

When you need a reference for what excellent code looks like, use these:

| Domain | Reference | What to study |
| ------ | --------- | ------------- |
| C / systems | SQLite source (`sqlite.org/src`) | Discipline: 590x test-to-source ratio, 100% branch coverage, zero external deps |
| C / network | Redis `src/ae.c`, `src/dict.c` | Naming, readability, data structures that document themselves |
| Go | Go standard library (`pkg.go.dev/std`) | Idiomatic naming, error design, interface sizing — one method where possible |
| Rust | `rustc_errors` crate | Error message design: what failed, where, what to do next |
| Error messages | Elm compiler output | Kindest, most actionable errors in any compiled language |
| API design | Stripe API (`docs.stripe.com`) | Naming consistency, versioning discipline, error schema |
| Documentation | Go stdlib `net/http` package docs | Every exported symbol explained by what it does for the caller |

When uncertain if code is good enough: "Would this survive a review from the SQLite team?"
If the answer is no — simplify first.

The SQLite standard: every line has a reason. Every function has one job.
Every error has a message a human can act on.
