Azure deployment workflow — validate, plan, deploy with rollback.

## Instructions

1. **Collect requirements** (single prompt):
   - Target resource group and subscription
   - IaC type (Bicep, ARM, Terraform)
   - Environment (dev, staging, prod)
   - Deployment scope (resource group, subscription, management group)

2. **Validate phase**:
   - Lint the template (`az bicep lint` for Bicep, `terraform validate` for TF)
   - Run what-if / plan to preview changes
   - Check for breaking changes (resource deletions, SKU downgrades)
   - Flag any security concerns (public endpoints, missing encryption, broad NSGs)
   - Present summary for human approval — **do NOT proceed without approval**

3. **Deploy phase** (after approval):
   - Run the deployment command
   - Monitor deployment status
   - Verify resource health post-deploy (health probes, connectivity checks)
   - Confirm deployment succeeded with resource summary

4. **Rollback plan**:
   - Document what to run if deployment fails
   - For App Services: swap back to previous slot
   - For IaC: redeploy previous version of template
   - For data changes: restore from backup

## Rules

- **What-if is mandatory.** Never deploy without previewing changes first.
- **Production requires explicit approval.** Always stop and wait for human confirmation before deploying to prod.
- **Tag every resource.** Deployment must include required tags (Environment, Owner, Project, CostCenter).
- **Lock after deploy.** Apply `CanNotDelete` lock to production resource groups after successful deployment.
- Commit with `[az]` prefix.
