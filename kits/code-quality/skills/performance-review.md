# Performance Pattern Review

## What This Skill Covers
Common performance anti-patterns detectable by code review — not micro-optimizations,
but structural patterns that cause performance problems at scale.

## Checks (ref: checks-registry.json 78-83)

### Check 78 — N+1 Queries
Trigger: a loop that issues database queries on each iteration
Pattern: fetch a list of items, then for each item fetch related data
```python
# N+1 pattern — WRONG
orders = db.query("SELECT * FROM orders WHERE user_id = ?", user_id)
for order in orders:
    items = db.query("SELECT * FROM items WHERE order_id = ?", order.id)  # N queries
```
Fix: use a JOIN, eager loading, or batch fetch
```python
# Fixed — 1 query
orders_with_items = db.query("""
    SELECT o.*, i.* FROM orders o
    JOIN items i ON i.order_id = o.id
    WHERE o.user_id = ?
""", user_id)
```

### Check 79 — Unbounded Queries
Trigger: SELECT query without LIMIT on a table that grows with user data
Trigger: API endpoint returning a list with no pagination
Why it matters: works fine in development with 100 rows, fails in production with 1M rows.
Fix: always add LIMIT. Implement cursor or offset pagination for list endpoints.

### Check 80 — Loading Everything Into Memory
Trigger: fetching entire result set to count, filter, or find one item
Trigger: loading large files entirely before processing
Why it matters: O(n) memory usage for operations that could be O(1).
Fix: use COUNT() in SQL, streaming file reads, or database-side filtering.

### Check 81 — Synchronous I/O in Async Context
Trigger: fs.readFileSync() in Node.js request handler
Trigger: time.sleep() in Python async function
Trigger: blocking HTTP call without await
Why it matters: blocks the event loop, preventing all other requests from being served.
Fix: use async equivalents: fs.readFile (promise), asyncio.sleep, await fetch.

### Check 82 — Missing Memoization / Stale Dependencies (React)
Trigger: expensive computation inside component render without useMemo
Trigger: function passed as prop created inline without useCallback
Trigger: useEffect with missing or incorrect dependency array
Why it matters: causes unnecessary re-renders, infinite render loops, or stale closures.
Fix: wrap expensive computations in useMemo, stable callbacks in useCallback,
verify useEffect dependency arrays are complete and accurate.

### Check 83 — Large Bundle Imports
Trigger: import of entire library when only one function is used
```javascript
// WRONG — imports entire lodash (~70KB)
import _ from 'lodash'
const result = _.debounce(fn, 300)

// RIGHT — imports one function (~2KB)
import debounce from 'lodash/debounce'
```
Fix: use named imports or path imports. Use bundle analyzers to verify impact.
