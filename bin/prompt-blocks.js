#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const PKG_DIR = path.resolve(__dirname, '..');
const BLOCKS_DIR = path.join(PKG_DIR, 'prompts', 'blocks');
const PROFILES_DIR = path.join(PKG_DIR, 'prompts', 'profiles');

/** Parse YAML frontmatter from markdown. */
function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { meta: {}, body: content.trim() };
  return { meta: yaml.load(match[1]) || {}, body: match[2].trim() };
}

/** Collect all blocks from the blocks directory. */
function loadAllBlocks() {
  const blocks = [];
  if (!fs.existsSync(BLOCKS_DIR)) return blocks;

  for (const category of fs.readdirSync(BLOCKS_DIR)) {
    const catDir = path.join(BLOCKS_DIR, category);
    if (!fs.statSync(catDir).isDirectory()) continue;

    for (const file of fs.readdirSync(catDir)) {
      if (!file.endsWith('.md')) continue;
      const content = fs.readFileSync(path.join(catDir, file), 'utf8');
      const { meta, body } = parseFrontmatter(content);
      const hasCondensed = body.includes('<!-- CONDENSED -->');
      blocks.push({
        id: meta.id || file.replace('.md', ''),
        category,
        platforms: meta.platforms || [],
        charEstimate: meta.char_estimate || null,
        description: meta.description || '',
        tags: meta.tags || [],
        hasCondensed,
        actualChars: body.length,
        file: `prompts/blocks/${category}/${file}`,
      });
    }
  }
  return blocks;
}

/** Collect all profiles and their block references. */
function loadAllProfiles() {
  const profiles = {};
  if (!fs.existsSync(PROFILES_DIR)) return profiles;

  for (const file of fs.readdirSync(PROFILES_DIR)) {
    if (!file.endsWith('.yaml')) continue;
    const name = file.replace('.yaml', '');
    const content = yaml.load(fs.readFileSync(path.join(PROFILES_DIR, file), 'utf8'));
    const blockIds = [];
    if (content.blocks) {
      for (const ids of Object.values(content.blocks)) {
        if (Array.isArray(ids)) blockIds.push(...ids);
      }
    }
    profiles[name] = { ...content, blockIds };
  }
  return profiles;
}

// ── CLI ──────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);

  if (args.includes('--help')) {
    console.log('Usage: prompt-blocks [options]');
    console.log('Options:');
    console.log('  --category <cat>   Filter by category (identity, behaviors, domains, formats, context)');
    console.log('  --profile <name>   Show blocks used by a specific profile');
    console.log('  --unused           Show blocks not referenced by any profile');
    console.log('  --tags             Group output by tags');
    process.exit(0);
  }

  const blocks = loadAllBlocks();
  const profiles = loadAllProfiles();

  // Resolve profile inheritance to get full block lists
  for (const [name, profile] of Object.entries(profiles)) {
    if (profile.extends && profiles[profile.extends]) {
      const baseIds = profiles[profile.extends].blockIds || [];
      profile.blockIds = [...new Set([...baseIds, ...profile.blockIds])];
    }
  }

  // All block IDs referenced by any profile
  const allProfileBlockIds = new Set();
  for (const profile of Object.values(profiles)) {
    for (const id of profile.blockIds) allProfileBlockIds.add(id);
  }

  // Filter by category
  const catIdx = args.indexOf('--category');
  let filtered = blocks;
  if (catIdx !== -1 && args[catIdx + 1]) {
    const cat = args[catIdx + 1];
    filtered = blocks.filter((b) => b.category === cat);
  }

  // Filter by profile
  const profIdx = args.indexOf('--profile');
  if (profIdx !== -1 && args[profIdx + 1]) {
    const profName = args[profIdx + 1];
    const profile = profiles[profName];
    if (!profile) {
      console.error(`Profile not found: ${profName}`);
      process.exit(1);
    }
    const profileIds = new Set(profile.blockIds);
    filtered = blocks.filter((b) => profileIds.has(b.id));
  }

  // Unused mode
  if (args.includes('--unused')) {
    filtered = blocks.filter((b) => !allProfileBlockIds.has(b.id));
    if (filtered.length === 0) {
      console.log('All blocks are referenced by at least one profile.');
      return;
    }
    console.log(`${filtered.length} unused block(s):\n`);
  }

  // Display
  console.log(`${'ID'.padEnd(28)} ${'Category'.padEnd(12)} ${'Platforms'.padEnd(35)} ${'Chars'.padEnd(8)} Condensed`);
  console.log('-'.repeat(95));

  for (const block of filtered) {
    const platforms = block.platforms.join(', ') || 'all';
    const chars = block.charEstimate ? String(block.charEstimate) : '—';
    const condensed = block.hasCondensed ? 'yes' : '—';
    console.log(
      `${block.id.padEnd(28)} ${block.category.padEnd(12)} ${platforms.padEnd(35)} ${chars.padEnd(8)} ${condensed}`
    );
  }

  console.log(`\nTotal: ${filtered.length} blocks`);

  // Show profile usage summary
  if (!args.includes('--unused') && profIdx === -1) {
    console.log('\nProfile usage:');
    for (const [name, profile] of Object.entries(profiles)) {
      if (name === '_base') continue;
      console.log(`  ${name}: ${profile.blockIds.length} blocks`);
    }
  }
}

main();
