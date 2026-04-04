'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const yaml = require('js-yaml');

const PKG_DIR = path.resolve(__dirname, '..');
const PROMPTS_DIR = path.join(PKG_DIR, 'prompts');
const BLOCKS_DIR = path.join(PROMPTS_DIR, 'blocks');
const PROFILES_DIR = path.join(PROMPTS_DIR, 'profiles');

const TARGETS = ['claude-code', 'claude-project', 'perplexity-space'];

/** Parse YAML frontmatter from markdown content. Returns { meta, body }. */
function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { meta: {}, body: content.trim() };
  return { meta: yaml.load(match[1]) || {}, body: match[2].trim() };
}

/** Read and merge praxis.config.json vars. */
function loadPraxisConfig() {
  const configPath = path.join(os.homedir(), '.claude', 'praxis.config.json');
  if (!fs.existsSync(configPath)) return {};
  try {
    return JSON.parse(fs.readFileSync(configPath, 'utf8'));
  } catch {
    return {};
  }
}

/** Merge base profile with child profile. Arrays concat + dedup. */
function mergeProfiles(base, child) {
  const merged = { ...base, ...child };
  if (base.blocks && child.blocks) {
    merged.blocks = {};
    const allCategories = new Set([
      ...Object.keys(base.blocks || {}),
      ...Object.keys(child.blocks || {}),
    ]);
    for (const cat of allCategories) {
      const baseBlocks = base.blocks[cat] || [];
      const childBlocks = child.blocks[cat] || [];
      merged.blocks[cat] = [...new Set([...baseBlocks, ...childBlocks])];
    }
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
        const invalid = meta.platforms.filter((p) => !TARGETS.includes(p));
        if (invalid.length > 0) {
          warn(`Invalid platform(s) in ${category}/${blockId}.md: ${invalid.join(', ')}. Valid: ${TARGETS.join(', ')}`);
        }
      }

      // Filter by platform
      const platforms = meta.platforms || TARGETS;
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

module.exports = {
  TARGETS,
  BLOCKS_DIR,
  PROFILES_DIR,
  PROMPTS_DIR,
  parseFrontmatter,
  loadPraxisConfig,
  mergeProfiles,
  loadProfile,
  extractVariants,
  loadBlocks,
  applyOverrides,
};
