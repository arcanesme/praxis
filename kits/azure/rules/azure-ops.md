---
description: Azure operations — IaC lifecycle, deployment patterns, cost, monitoring, incidents
---

# Azure Operations Rules

## Infrastructure as Code Lifecycle

- **Bicep first.** Prefer Bicep over raw ARM JSON. Use ARM only when Bicep lacks support.
- **Module per resource group.** Each resource group gets its own Bicep module.
- **Parameter files per environment.** Separate `.bicepparam` or `parameters.json` for dev/staging/prod.
- **Never `az` CLI for permanent infra.** Ad-hoc commands are for troubleshooting, not provisioning. If you create a resource with `az`, codify it in Bicep immediately.
- **What-if before deploy.** Always run `az deployment group what-if` before `az deployment group create`.
- **Lock production resources.** Apply `CanNotDelete` locks to production resource groups.

## Deployment Patterns

- **Blue/green for App Services.** Use deployment slots with auto-swap.
- **Canary for AKS.** Use Flagger or progressive delivery controllers.
- **Ring-based for multi-region.** Deploy to region 1 → validate → region 2 → validate → all regions.
- **Rollback plan is mandatory.** Every deployment must have a documented rollback — no exceptions.
- **Health probes before traffic.** Never route traffic to an instance that hasn't passed health checks.

## Cost Management

- **Tag everything.** `Environment`, `Owner`, `Project`, `CostCenter` on every resource — no exceptions.
- **Right-size first.** Check utilization before scaling up. Use Azure Advisor recommendations.
- **Reserved Instances** for predictable workloads (VMs, SQL, Cosmos). Commit for 1-year minimum.
- **Auto-shutdown dev/test.** Non-production VMs must have auto-shutdown configured.
- **Budget alerts.** Set Azure Cost Management budgets with alerts at 80% and 100%.
- **Spot VMs** for batch, CI/CD, and fault-tolerant workloads.

## Monitoring & Observability

- **Application Insights** on every web app and API. No exceptions.
- **Log Analytics workspace** per environment. Centralize logs from all resources.
- **Alerts on SLO breach.** Define SLOs first, then create alerts when SLOs are threatened.
- **Dashboards.** Every production service gets an Azure Dashboard with key metrics.
- **Diagnostic settings.** Enable on all PaaS resources — send to Log Analytics.

## Incident Response

- **Runbooks in Azure Automation.** Document recovery steps as runbooks, not wiki pages.
- **Correlation IDs.** Trace requests across services using Application Insights correlation.
- **Post-incident review.** After every P1/P2: timeline, root cause, action items, learnings.
- **Test failover.** Regularly test geo-failover and backup restoration. Untested backups are not backups.

## Networking

- **Private Endpoints** for all PaaS services in production. No public endpoints.
- **NSG flow logs** enabled on all subnets. Store in Log Analytics.
- **Hub-spoke topology** for multi-VNet architectures. Shared services in hub.
- **DNS zones.** Use Azure Private DNS for internal name resolution.
- **WAF on all public-facing services.** Azure Front Door or Application Gateway with WAF.

## Identity & Access

- **Managed Identities** over service principals. System-assigned for single-resource, user-assigned for shared.
- **Least privilege.** Custom roles over built-in when built-in is too broad.
- **PIM for elevated access.** Just-in-time activation for admin roles.
- **Conditional Access** on all management plane access.
- **No shared credentials.** Every service, person, and pipeline gets its own identity.
