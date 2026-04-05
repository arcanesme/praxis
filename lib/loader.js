'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const yaml = require('js-yaml');

const PKG_DIR = path.resolve(__dirname, '..');
const PROMPTS_DIR = path.join(PKG_DIR, 'prompts');
const BLOCKS_DIR = path.join(PROMPTS_DIR, 'blocks');
const PROFILES_DIR = path.join(PROMPTS_DIR, 'profiles');

const WORK_DIR = path.join(PROMPTS_DIR, 'work');
const PERSONAL_DIR = path.join(PROMPTS_DIR, 'personal');

const ALL_TARGETS = ['claude-code', 'claude-project', 'perplexity-space'];
const DEFAULT_TARGETS = ['claude-code', 'claude-project', 'perplexity-space'];

/** Parse YAML frontmatter from markdown content. Returns { meta, body }. */
function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { meta: {}, body: content.trim() };
  return { meta: yaml.load(match[1]) || {}, body: match[2].trim() };
}

/** Read and merge praxis.config.json vars with defaults. */
function loadPraxisConfig() {
  const defaults = {
    mcp_servers: 'context7 (live library docs), github (PRs/issues), perplexity (web search)',
  };
  const configPath = path.join(os.homedir(), '.claude', 'praxis.config.json');
  if (!fs.existsSync(configPath)) return defaults;
  try {
    return { ...defaults, ...JSON.parse(fs.readFileSync(configPath, 'utf8')) };
  } catch {
    return defaults;
  }
}

/** Merge base profile with child profile. Arrays concat + dedup. */
function mergeProfiles(base, child) {
  const merged = { ...base, ...child };
  const baseBlks = base.blocks || {};
  const childBlks = child.blocks || {};
  merged.blocks = {};
  const allCategories = new Set([
    ...Object.keys(baseBlks),
    ...Object.keys(childBlks),
  ]);
  for (const cat of allCategories) {
    const baseList = baseBlks[cat] || [];
    const childList = childBlks[cat] || [];
    merged.blocks[cat] = [...new Set([...baseList, ...childList])];
  }
  return merged;
}

/** Load a profile by name, resolving recursive extends with cycle detection. */
function loadProfile(profileName, fail, _visited = new Set()) {
  if (_visited.has(profileName)) {
    fail(`Circular profile inheritance: ${[..._visited, profileName].join(' → ')}`);
  }
  _visited.add(profileName);

  const profilePath = path.join(PROFILES_DIR, `${profileName}.yaml`);
  if (!fs.existsSync(profilePath)) {
    fail(`Profile not found: ${profilePath}`);
  }
  const profile = yaml.load(fs.readFileSync(profilePath, 'utf8'));

  if (profile.extends) {
    const base = loadProfile(profile.extends, fail, _visited);
    return mergeProfiles(base, profile);
  }
  return profile;
}

/** Extract FULL and CONDENSED sections from block body. */
function extractVariants(body) {
  const marker = '<!-- CONDENSED -->';
  const idx = body.indexOf(marker);
  if (idx === -1) return { full: body, condensed: body };
  return {
    full: body.slice(0, idx).trim(),
    condensed: body.slice(idx + marker.length).trim(),
  };
}

/** Resolve block IDs to file paths, read content, parse. */
function loadBlocks(profile, target, warn) {
  const blocks = [];
  const blockEntries = profile.blocks || {};

  for (const [category, blockIds] of Object.entries(blockEntries)) {
    for (const blockId of blockIds) {
      const blockPath = path.join(BLOCKS_DIR, category, `${blockId}.md`);
      if (!fs.existsSync(blockPath)) {
        warn(`Block not found: ${category}/${blockId}.md — skipping`);
        continue;
      }
      const content = fs.readFileSync(blockPath, 'utf8');
      const { meta, body } = parseFrontmatter(content);

      // Validate platform values in frontmatter
      if (meta.platforms) {
        const invalid = meta.platforms.filter((p) => !ALL_TARGETS.includes(p));
        if (invalid.length > 0) {
          warn(`Invalid platform(s) in ${category}/${blockId}.md: ${invalid.join(', ')}. Valid: ${ALL_TARGETS.join(', ')}`);
        }
      }

      // Filter by platform
      const platforms = meta.platforms || ALL_TARGETS;
      if (!platforms.includes(target)) continue;

      const variants = extractVariants(body);
      const useCondensed = target !== 'claude-code';
      blocks.push({
        id: meta.id || blockId,
        category,
        content: useCondensed ? variants.condensed : variants.full,
        meta,
      });
    }
  }
  // Sort by optional order field (default 999 — preserves declaration order for unordered blocks)
  blocks.sort((a, b) => (a.meta.order ?? 999) - (b.meta.order ?? 999));
  return blocks;
}

/** Apply project overrides: add/remove blocks. */
function applyOverrides(profile, overrides) {
  if (!overrides) return profile;
  const modified = { ...profile, blocks: { ...profile.blocks } };

  if (overrides.add_blocks) {
    for (const [cat, ids] of Object.entries(overrides.add_blocks)) {
      if (!Array.isArray(ids)) continue;
      modified.blocks[cat] = [...new Set([...(modified.blocks[cat] || []), ...ids])];
    }
  }

  if (overrides.remove_blocks && Array.isArray(overrides.remove_blocks)) {
    for (const blockId of overrides.remove_blocks) {
      for (const cat of Object.keys(modified.blocks)) {
        modified.blocks[cat] = modified.blocks[cat].filter((id) => id !== blockId);
      }
    }
  }

  return modified;
}

// ── Client/Deal Hierarchy ───────────────────────────────────

/** Load a client-config.yaml from a client directory. */
function loadClientConfig(clientDir) {
  const configPath = path.join(clientDir, 'client-config.yaml');
  if (!fs.existsSync(configPath)) return null;
  return yaml.load(fs.readFileSync(configPath, 'utf8'));
}

/**
 * Discover all projects across work/ (client → deals) and personal/ (flat).
 * Returns array of { client, deal, dealDir, clientDir, displayName }.
 */
function discoverAllWorkProjects() {
  const results = [];

  // Work projects: work/<client>/deals/<deal>/
  if (fs.existsSync(WORK_DIR)) {
    const clients = fs.readdirSync(WORK_DIR)
      .filter((d) => fs.statSync(path.join(WORK_DIR, d)).isDirectory());

    for (const client of clients) {
      const clientDir = path.join(WORK_DIR, client);
      const dealsDir = path.join(clientDir, 'projects');
      if (!fs.existsSync(dealsDir)) continue;

      const deals = fs.readdirSync(dealsDir)
        .filter((d) => d !== '_template' && fs.statSync(path.join(dealsDir, d)).isDirectory());

      for (const deal of deals) {
        results.push({
          client,
          deal,
          dealDir: path.join(dealsDir, deal),
          clientDir,
          displayName: `${client}/${deal}`,
        });
      }
    }
  }

  // Personal projects: personal/<project>/ (flat, no client nesting)
  if (fs.existsSync(PERSONAL_DIR)) {
    const projects = fs.readdirSync(PERSONAL_DIR)
      .filter((d) => d !== '_template' && fs.statSync(path.join(PERSONAL_DIR, d)).isDirectory());

    for (const project of projects) {
      results.push({
        client: 'personal',
        deal: project,
        dealDir: path.join(PERSONAL_DIR, project),
        clientDir: null,
        displayName: `personal/${project}`,
      });
    }
  }

  return results;
}

/**
 * Resolve a project identifier to its directory and configs.
 * Accepts: "deal-name", "client/deal-name", or "personal/project-name".
 * Searches work/ hierarchy and personal/ flat structure.
 */
function resolveProject(identifier) {
  // Handle explicit "client/deal" or "personal/project" format
  if (identifier.includes('/')) {
    const [scope, name] = identifier.split('/', 2);

    if (scope === 'personal') {
      const projectDir = path.join(PERSONAL_DIR, name);
      if (fs.existsSync(projectDir)) {
        return { client: 'personal', deal: name, dealDir: projectDir, clientDir: null, legacy: false };
      }
    } else {
      const dealDir = path.join(WORK_DIR, scope, 'projects', name);
      const clientDir = path.join(WORK_DIR, scope);
      if (fs.existsSync(dealDir)) {
        return { client: scope, deal: name, dealDir, clientDir, legacy: false };
      }
    }
  }

  // Search all projects for a matching name
  const allDeals = discoverAllWorkProjects();
  const match = allDeals.find((d) => d.deal === identifier);
  if (match) {
    return { client: match.client, deal: match.deal, dealDir: match.dealDir, clientDir: match.clientDir, legacy: false };
  }

  // Fall back to legacy prompts/projects/ structure
  const legacyDir = path.join(PROMPTS_DIR, 'projects', identifier);
  if (fs.existsSync(legacyDir)) {
    return { client: null, deal: identifier, dealDir: legacyDir, clientDir: null, legacy: true };
  }

  // Not found anywhere — return the new-style path (for creation)
  return { client: null, deal: identifier, dealDir: null, clientDir: null, legacy: false };
}

/**
 * Merge client config with deal config.
 * Client provides defaults; deal overrides specific fields.
 */
function mergeClientDealConfig(clientConfig, dealConfig) {
  if (!clientConfig) return dealConfig;
  const merged = { ...dealConfig };

  // Inherit profile from client if deal doesn't specify
  if (!merged.profile && clientConfig.profile) {
    merged.profile = clientConfig.profile;
  }

  // Merge vars: client < deal
  merged.vars = { ...(clientConfig.vars || {}), ...(merged.vars || {}) };

  // Merge knowledge_packs: client packs + deal packs (deal can override by output name)
  const clientPacks = clientConfig.knowledge_packs || [];
  const dealPacks = merged.knowledge_packs || [];
  const dealOutputNames = new Set(dealPacks.map((p) => p.output));
  merged.knowledge_packs = [
    ...clientPacks.filter((p) => !dealOutputNames.has(p.output)),
    ...dealPacks,
  ];

  // Merge shared_references from client into knowledge_files
  const clientRefs = (clientConfig.shared_references || []).map((ref) => ({
    file: ref,
    description: path.basename(ref, '.md'),
  }));
  merged.knowledge_files = [...clientRefs, ...(merged.knowledge_files || [])];

  return merged;
}

module.exports = {
  ALL_TARGETS,
  DEFAULT_TARGETS,
  BLOCKS_DIR,
  WORK_DIR,
  PERSONAL_DIR,
  PROFILES_DIR,
  PROMPTS_DIR,
  parseFrontmatter,
  loadPraxisConfig,
  mergeProfiles,
  loadProfile,
  extractVariants,
  loadBlocks,
  applyOverrides,
  loadClientConfig,
  discoverAllWorkProjects,
  resolveProject,
  mergeClientDealConfig,
};
