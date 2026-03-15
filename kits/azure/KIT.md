# Azure Kit

> Azure infrastructure, DevOps pipelines, Bicep/ARM, and cloud operations.

## Activation

```
/kit:azure
```

## What This Kit Provides

### Rules
- `rules/azure-ops.md` — IaC lifecycle, deployment patterns, cost management, monitoring, incident response

### Commands
- `/az-deploy` — Azure deployment workflow (Bicep/ARM/Terraform plan → validate → deploy)
- `/az-review` — Azure infrastructure review (security, cost, reliability, naming)

### MCP Servers
- **azure-devops** — Microsoft's official Azure DevOps MCP: work items, PRs, builds, wikis
- **azure-mcp** — Azure resource management: subscriptions, resource groups, deployments

## MCP Setup

Run `install.sh` or use the CLI to register MCP servers:

```bash
npx praxis-harness kit install azure
# or manually:
cd kits/azure
bash install.sh
```

### Azure DevOps MCP

Requires your Azure DevOps organization name:

```bash
claude mcp add azure-devops --scope user -- npx -y @azure-devops/mcp YOUR_ORG
```

Replace `YOUR_ORG` with your Azure DevOps organization (e.g., `Contoso`).

First tool execution triggers browser-based auth. Requires Node.js >= 20.

### Azure Resource MCP

```bash
claude mcp add azure-mcp --scope user -- npx -y azure-mcp
```

Uses your local Azure CLI credentials (`az login`).

## Commit Prefix

When this kit is active, prefix commits with `[az]`:
- `[az] Add Bicep module for App Service`
- `[az] Fix NSG rules on production subnet`
- `[az] Update Key Vault access policies`
