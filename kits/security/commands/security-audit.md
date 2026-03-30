---
description: "OWASP top 10 check against the current codebase"
---

# security:audit

## Steps

1. **Scan codebase** for OWASP Top 10 (2021) vulnerabilities:
   - A01: Broken Access Control
   - A02: Cryptographic Failures
   - A03: Injection (SQL, NoSQL, OS command, LDAP)
   - A04: Insecure Design
   - A05: Security Misconfiguration
   - A06: Vulnerable and Outdated Components
   - A07: Identification and Authentication Failures
   - A08: Software and Data Integrity Failures
   - A09: Security Logging and Monitoring Failures
   - A10: Server-Side Request Forgery (SSRF)
2. **Launch subagent** (follow `/subagent` protocol) with role: "Security auditor"
3. **Run external tools** if available (trivy, deepsource) for additional coverage
4. **Present findings** grouped by OWASP category with severity
5. **Write audit report** to vault `specs/security-audit-{date}.md`
