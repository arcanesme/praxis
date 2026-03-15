Read `praxis/context/techstack.md` for deployment configuration.

Push the current branch to a staging/preview environment.

## Step 1: Verify First
Run verify in full mode. If any checks fail:
- Report failures
- Ask the user: fix first or deploy anyway?
- Do NOT deploy without explicit approval on failures

## Step 2: Identify Environment
Check `praxis/context/techstack.md` for deployment config. If not defined, ask the user:
- What's the preview/staging environment? (Vercel, Netlify, Azure, AWS, Docker, custom)
- What's the deploy command?
- Any environment variables needed?

## Step 3: Deploy
Run the configured deploy command. Common patterns:

```bash
# Vercel
vercel --prebuilt

# Netlify
netlify deploy --dir=build

# Azure
az webapp up --name {app} --resource-group {rg}

# Docker
docker build -t {image} . && docker push {image}

# Custom
{configured command from techstack.md}
```

## Step 4: Report
```
🚀 PRAXIS DEPLOY-PREVIEW
━━━━━━━━━━━━━━━━━━━━━━━━

  Environment: {staging/preview}
  Branch: {current branch}
  Track: {active track or "none"}
  Verification: ✅ PASS | ⚠️ SKIPPED
  Deploy: ✅ SUCCESS | ❌ FAILED
  URL: {preview URL if available}
```

## Rules
- Never deploy to production — this is preview/staging only
- Always verify before deploying
- Report the preview URL if the platform provides one
- If deploy fails, capture the error output and suggest fixes
