# Observable Code — Instrumentation Constraints
# Scope: **/services/**, **/handlers/**, **/workers/**, **/middleware/**, **/cmd/**
# Active during code generation for service-layer code
# Cross-reference: api-quality.md covers request-level logging and correlation IDs.
#   This rule covers application-level observability: structured logging, metrics, traces.

Code is not production-ready if it cannot be debugged without attaching a debugger.
Observable code tells you what happened, when, and why — from logs, metrics, and traces alone.

## Invariants — BLOCK on violation

### Structured logging only
- All log statements use structured format (key-value pairs, not string interpolation)
- No `fmt.Println` / `console.log` / `print()` in production code paths — use the structured logger
- Log at the point of failure, not at the catch site (log once, propagate)

### Log levels are semantic
- ERROR: something failed and a human needs to know immediately
- WARN: something unexpected happened but the system recovered
- INFO: a significant state transition (service started, job completed, user authenticated)
- DEBUG: internal detail useful during development — must not appear in production by default

### Structured log format — mandatory fields
```json
{
  "timestamp": "ISO-8601 UTC",
  "level": "error|warn|info|debug",
  "service": "service-name",
  "correlation_id": "request or trace identifier",
  "message": "what happened — actionable, not generic",
  "context": { "relevant_key": "relevant_value" }
}
```

### What NOT to log
- Passwords, tokens, secrets, full credit card numbers
- Full request/response bodies in production (may contain PII)
- DEBUG logs in production services (log level must be configurable)
- The same event more than once in the same request path

### External call discipline
- Every external call (HTTP, DB, queue) has a timeout
- Every external call logs duration on completion
- Failed external calls log: target, duration, error type, and whether retry will occur

## Conventions — WARN on violation

### Metrics naming
Format: `{service}_{subsystem}_{name}_{unit}`
All lowercase, underscores as separators.

Mandatory metrics per service:
- `{service}_requests_total` — counter, labeled by method and status code
- `{service}_errors_total` — counter, labeled by error type
- `{service}_latency_seconds` — histogram, labeled by operation
- `{service}_active_connections` or `{service}_queue_depth` — gauge (if applicable)

GOOD: `auth_login_attempts_total`, `cache_hit_ratio`, `queue_messages_pending`
BAD: `loginAttempts`, `CacheHitRatio`, `queue-messages-pending`

### Trace spans (OpenTelemetry)
Span naming: `{service}/{operation}` — lowercase, slash separator
GOOD: `auth/validate-token`, `db/query-users`, `cache/get`
BAD: `validateToken`, `DB Query`, `GET /users`

Mandatory span attributes:
- `service.name`
- `http.method` and `http.status_code` for HTTP operations
- `db.system` and `db.operation` for database calls
- `error.type` and `error.message` on error spans

### Health endpoints
- Liveness: `/healthz` — "is the process alive?"
- Readiness: `/readyz` — "can the process serve traffic?"
- Both return structured JSON with component status

### The Observability Contract
An error is only production-observable if ALL three are true:
1. It appears in structured logs with correlation_id and context
2. It increments an error metric labeled by error type
3. It is captured in a trace span with error attributes

If only one or two are true: the code is not fully observable. Fix before shipping.

## Removal Condition
Remove when an observability linter or OpenTelemetry SDK auto-instrumentation
replaces these generation-time constraints entirely.
