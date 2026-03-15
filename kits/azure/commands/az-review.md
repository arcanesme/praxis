Azure infrastructure review — security, cost, reliability, and naming audit.

## Instructions

1. **Collect scope** (single prompt):
   - Resource group(s) or subscription to review
   - Review focus: security, cost, reliability, naming, or all
   - Known constraints or exceptions

2. **Security review**:
   - Public endpoints without WAF or IP restrictions
   - Resources missing Private Endpoints in production
   - Service principals used where Managed Identities could work
   - Missing encryption (at rest, in transit)
   - Overly broad NSG rules (0.0.0.0/0 inbound)
   - Key Vault access policies vs RBAC
   - Missing Defender for Cloud coverage
   - Diagnostic settings not enabled

3. **Cost review**:
   - Over-provisioned resources (low CPU/memory utilization)
   - Missing auto-shutdown on dev/test VMs
   - Candidates for Reserved Instances or Savings Plans
   - Orphaned resources (unattached disks, unused IPs, empty resource groups)
   - Missing budget alerts

4. **Reliability review**:
   - Single points of failure (single-instance VMs, no zone redundancy)
   - Missing health probes on load balancers
   - Backup configuration gaps
   - Disaster recovery readiness (geo-replication, failover groups)
   - SLA mismatches (resource SKUs vs required SLA)

5. **Naming & tagging review**:
   - Resources not following CAF naming convention
   - Missing required tags (Environment, Owner, Project, CostCenter)
   - Inconsistent naming across resource groups

6. **Output**:
   - Summary table: area | finding | severity (HIGH/MEDIUM/LOW) | recommendation
   - Severity counts
   - Top 3 action items
   - If Azure MCP is available, query live resource data to verify findings

## Rules

- Be specific — reference actual resource names and configurations.
- Every HIGH finding gets a concrete remediation step.
- Use Azure Advisor recommendations when available.
- Don't overwhelm — prioritize findings by business impact.
- Commit review notes with `[az]` prefix if saved to file.
