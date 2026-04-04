#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const yaml = require('js-yaml');

const PKG_DIR = path.resolve(__dirname, '..');
const PROMPTS_DIR = path.join(PKG_DIR, 'prompts');
const BLOCKS_DIR = path.join(PROMPTS_DIR, 'blocks');
const PROFILES_DIR = path.join(PROMPTS_DIR, 'profiles');
const PROJECTS_DIR = path.join(PROMPTS_DIR, 'projects');

const TARGETS = ['claude-code', 'claude-project', 'perplexity-space'];

const CHAR_BUDGETS = {
  'claude-code': Infinity,
  'claude-project': 2500,
  'perplexity-space': 4000,
};

// Global flags set by CLI parser
let PREVIEW_MODE = false;
let DIFF_MODE = false;
let STRICT_MODE = false;

// ── Helpers ──────────────────────────────────────────────────

function fail(msg) {
  console.error(`\x1b[31mERROR:\x1b[0m ${msg}`);
  process.exit(1);
}

function warn(msg) {
  console.error(`\x1b[33mWARN:\x1b[0m ${msg}`);
}

function ok(msg) {
  console.log(`\x1b[32m✓\x1b[0m ${msg}`);
}

/** Parse YAML frontmatter from markdown content. Returns { meta, body }. */
function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { meta: {}, body: content.trim() };
  return { meta: yaml.load(match[1]) || {}, body: match[2].trim() };
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

/** Replace {{var}} placeholders with values from vars map. */
function interpolate(text, vars) {
  return text.replace(/\{\{(\w+)\}\}/g, (_match, key) => {
    if (key in vars) return vars[key];
    return `{{${key}}}`;
  });
}

/** Check for unresolved {{...}} placeholders. */
function findUnresolved(text) {
  const matches = text.match(/\{\{(\w+)\}\}/g);
  return matches ? [...new Set(matches)] : [];
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

// ── Core ─────────────────────────────────────────────────────

/** Load a profile by name, resolving single-level extends. */
function loadProfile(profileName) {
  const profilePath = path.join(PROFILES_DIR, `${profileName}.yaml`);
  if (!fs.existsSync(profilePath)) {
    fail(`Profile not found: ${profilePath}`);
  }
  const profile = yaml.load(fs.readFileSync(profilePath, 'utf8'));

  if (profile.extends) {
    const basePath = path.join(PROFILES_DIR, `${profile.extends}.yaml`);
    if (!fs.existsSync(basePath)) {
      fail(`Base profile not found: ${basePath}`);
    }
    const base = yaml.load(fs.readFileSync(basePath, 'utf8'));
    return mergeProfiles(base, profile);
  }
  return profile;
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

/** Resolve block IDs to file paths, read content, parse. */
function loadBlocks(profile, target) {
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

// ── Assemblers ───────────────────────────────────────────────

function assembleClaudeCode(blocks, projectConfig, vars) {
  const lines = [];
  const today = new Date().toISOString().slice(0, 10);
  lines.push(`# ${vars.project || vars.repo_name || 'Project'}`);
  lines.push(`<!-- Generated by Praxis prompt-compile | profile: ${projectConfig.profile} | ${today} -->`);
  lines.push('');

  // Identity
  const identityBlocks = blocks.filter((b) => b.category === 'identity');
  if (identityBlocks.length > 0) {
    lines.push('## Identity');
    for (const block of identityBlocks) lines.push(block.content, '');
  }

  // Global Rules reference
  lines.push('## Global Rules');
  lines.push('Inherits execution engine from `~/.claude/CLAUDE.md`.');
  lines.push('');

  // Git Identity
  if (vars.git_email || vars.git_identity) {
    lines.push('## Git Identity');
    if (vars.git_identity) lines.push(`- **Type**: ${vars.git_identity}`);
    if (vars.git_email) lines.push(`- **Email**: ${vars.git_email}`);
    lines.push('');
  }

  // Behaviors
  const behaviorBlocks = blocks.filter((b) => b.category === 'behaviors');
  if (behaviorBlocks.length > 0) {
    lines.push('## Behaviors');
    for (const block of behaviorBlocks) lines.push(block.content, '');
  }

  // Domains
  const domainBlocks = blocks.filter((b) => b.category === 'domains');
  if (domainBlocks.length > 0) {
    lines.push('## Domain Expertise');
    for (const block of domainBlocks) lines.push(block.content, '');
  }

  // Formats
  const formatBlocks = blocks.filter((b) => b.category === 'formats');
  if (formatBlocks.length > 0) {
    lines.push('## Output Format');
    for (const block of formatBlocks) lines.push(block.content, '');
  }

  // Tech Stack + Commands (from claude_code_append)
  const append = (projectConfig.overrides || {}).claude_code_append || {};
  if (append.tech_stack) {
    lines.push('## Tech Stack');
    lines.push(append.tech_stack.trim(), '');
  }
  if (append.commands) {
    lines.push('## Commands');
    lines.push('```bash');
    lines.push(append.commands.trim());
    lines.push('```', '');
  }

  // Context
  const contextBlocks = blocks.filter((b) => b.category === 'context');
  if (contextBlocks.length > 0) {
    for (const block of contextBlocks) lines.push(block.content, '');
  }

  // Extra notes
  if (append.extra_notes) {
    lines.push('## Important Notes');
    lines.push(append.extra_notes.trim(), '');
  }

  // Vault Project
  if (vars.vault_project_path) {
    lines.push('## Vault Project');
    lines.push(`- **Vault path**: ${vars.vault_project_path}`);
    lines.push('');
  }

  // Standard footer
  lines.push('## Verification');
  lines.push('- Before marking any task complete, run the test suite');
  lines.push('- Check logs before claiming a bug is fixed');
  lines.push('');
  lines.push('## Conventions');
  lines.push('- **Commits**: conventional commits (feat:, fix:, docs:, refactor:, test:, chore:)');
  lines.push('- **Branches**: `feat/description` or `fix/description`');
  lines.push('');
  lines.push('## Error Learning');
  lines.push('<!-- Add project-specific learnings below -->');
  lines.push('');

  return lines.join('\n');
}

function assembleClaudeProject(blocks, projectConfig, vars) {
  const lines = [];

  // Layer 1: Role
  const identityBlocks = blocks.filter((b) => b.category === 'identity');
  lines.push('## Role');
  if (projectConfig.description) lines.push(projectConfig.description);
  for (const block of identityBlocks) lines.push(block.content);
  lines.push('');

  // Layer 2: Behavioral Constraints
  const behaviorBlocks = blocks.filter((b) => b.category === 'behaviors');
  if (behaviorBlocks.length > 0) {
    lines.push('## Behavioral Constraints');
    for (const block of behaviorBlocks) lines.push('- ' + block.content);
    lines.push('');
  }

  // Layer 3: Domain Expertise
  const domainBlocks = blocks.filter((b) => b.category === 'domains');
  if (domainBlocks.length > 0) {
    lines.push('## Domain Expertise');
    for (const block of domainBlocks) lines.push('- ' + block.content);
    lines.push('');
  }

  // Layer 3b: Output Format
  const formatBlocks = blocks.filter((b) => b.category === 'formats');
  if (formatBlocks.length > 0) {
    lines.push('## Output Format');
    for (const block of formatBlocks) lines.push('- ' + block.content);
    lines.push('');
  }

  // Additional context
  const append = (projectConfig.overrides || {}).claude_project_append || {};
  if (append.additional_context) {
    lines.push(append.additional_context.trim(), '');
  }

  // Layer 4: Quality Gates
  if (append.quality_gates) {
    lines.push('## Quality Gates');
    lines.push(append.quality_gates.trim(), '');
  }

  // Context blocks (workflow, etc.)
  const contextBlocks = blocks.filter((b) => b.category === 'context');
  if (contextBlocks.length > 0) {
    for (const block of contextBlocks) lines.push(block.content);
    lines.push('');
  }

  // Layer 4b: Knowledge Files (if project has them)
  const knowledgeFiles = projectConfig.knowledge_files || [];
  if (knowledgeFiles.length > 0) {
    lines.push('## Knowledge Files');
    lines.push('Upload these alongside this prompt:');
    for (const kf of knowledgeFiles) {
      lines.push(`- **${kf.file}** — ${kf.description}`);
    }
    lines.push('');
  }

  // Layer 5: Failure Handling (always present)
  lines.push('## When Uncertain');
  lines.push('State uncertainty explicitly. Ask one clarifying question rather than guessing.');
  lines.push('');

  return lines.join('\n');
}

function assemblePerplexitySpace(blocks, projectConfig, vars) {
  const lines = [];

  // Purpose
  const identityBlocks = blocks.filter((b) => b.category === 'identity');
  lines.push('## Purpose');
  if (projectConfig.description) lines.push(projectConfig.description);
  for (const block of identityBlocks) lines.push(block.content);
  lines.push('');

  // Source Priority
  const sourceBlocks = blocks.filter(
    (b) => b.category === 'context' && (b.meta.tags || []).includes('sources')
  );
  if (sourceBlocks.length > 0) {
    lines.push('## Source Priority');
    for (const block of sourceBlocks) lines.push(block.content);
    lines.push('');
  }

  // Domain Expertise
  const domainBlocks = blocks.filter((b) => b.category === 'domains');
  if (domainBlocks.length > 0) {
    lines.push('## Domain Expertise');
    for (const block of domainBlocks) lines.push(block.content);
    lines.push('');
  }

  // Research Domains
  const append = (projectConfig.overrides || {}).perplexity_space_append || {};
  if (append.research_domains) {
    lines.push('## Research Domains');
    lines.push(append.research_domains.trim(), '');
  }

  // How to Answer
  const behaviorBlocks = blocks.filter((b) => b.category === 'behaviors');
  const formatBlocks = blocks.filter((b) => b.category === 'formats');
  if (behaviorBlocks.length > 0 || formatBlocks.length > 0) {
    lines.push('## How to Answer');
    for (const block of behaviorBlocks) lines.push(block.content);
    for (const block of formatBlocks) lines.push(block.content);
    lines.push('');
  }

  // Anti-hallucination layer (auto-injected for all Perplexity outputs)
  lines.push('## Accuracy Standards');
  lines.push('- Flag your confidence level when synthesizing across sources');
  lines.push('- Distinguish verified facts from analytical inferences');
  lines.push('- If sources disagree, cite both and explain the discrepancy');
  lines.push('- Never fabricate version numbers, API signatures, URLs, or code examples');
  lines.push('- When information may be outdated (>12 months), note the publication date');
  lines.push('- If you cannot find reliable sources, state that clearly rather than speculating');
  lines.push('');

  return lines.join('\n');
}

// ── Main ─────────────────────────────────────────────────────

/** Validate a standalone project — check files exist, report char budgets. */
function validateStandalone(projectName, projectDir, projectConfig) {
  console.log(`\nValidating standalone: ${projectName}`);

  // Required, expected, and optional files with their budgets
  const inventory = [
    { file: 'system-prompt.md', budget: Infinity, required: true, label: 'System Prompt (Claude Projects)' },
    { file: 'CLAUDE.md', budget: Infinity, required: false, label: 'Claude Code' },
    { file: 'space-instructions.md', budget: CHAR_BUDGETS['perplexity-space'], required: false, label: 'Perplexity Space' },
    { file: 'project-instructions.md', budget: CHAR_BUDGETS['claude-project'], required: false, label: 'Claude Project' },
  ];

  let missingGenerable = [];

  for (const item of inventory) {
    const filePath = path.join(projectDir, item.file);
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf8');
      const charCount = content.length;
      const lineCount = content.split('\n').length;
      const sizeInfo = item.budget < Infinity
        ? `${charCount} chars (budget: ${item.budget})`
        : `${charCount} chars, ${lineCount} lines`;

      if (charCount > item.budget) {
        warn(`${item.file} exceeds budget: ${charCount} chars (limit: ${item.budget})`);
      } else {
        ok(`${item.file} — ${sizeInfo}`);
      }
    } else if (item.required) {
      warn(`${item.file} MISSING — standalone projects require a system prompt`);
    } else {
      missingGenerable.push(item.file);
    }
  }

  // Report missing generable files
  if (missingGenerable.length > 0) {
    console.log(`\n  Missing platform outputs: ${missingGenerable.join(', ')}`);
    console.log('  Run /px-prompt ' + projectName + ' to auto-generate from system-prompt.md');
  }

  // Version consistency check
  const systemPromptPath = path.join(projectDir, 'system-prompt.md');
  if (fs.existsSync(systemPromptPath) && projectConfig.version) {
    const spContent = fs.readFileSync(systemPromptPath, 'utf8');
    const versionMatch = spContent.match(/^version:\s*["']?([^"'\n]+)/m);
    if (versionMatch && versionMatch[1].trim() !== String(projectConfig.version).trim()) {
      warn(`Version mismatch: prompt-config.yaml says "${projectConfig.version}" but system-prompt.md says "${versionMatch[1].trim()}"`);
    }
  }

  // Check for reference files
  const refsDir = path.join(projectDir, 'references');
  if (fs.existsSync(refsDir)) {
    const refs = fs.readdirSync(refsDir).filter((f) => f.endsWith('.md'));
    if (refs.length > 0) {
      ok(`${refs.length} reference file(s): ${refs.join(', ')}`);
    }
  }
}

function compileProject(projectName, targets) {
  const projectDir = path.join(PROJECTS_DIR, projectName);
  const configPath = path.join(projectDir, 'prompt-config.yaml');

  if (!fs.existsSync(configPath)) {
    fail(`Project config not found: ${configPath}\nRun /px-prompt <project-name> to create one.`);
  }

  const projectConfig = yaml.load(fs.readFileSync(configPath, 'utf8'));

  // Standalone mode: validate files, report budgets, skip compilation
  if (projectConfig.mode === 'standalone') {
    validateStandalone(projectName, projectDir, projectConfig);
    return;
  }

  const praxisConfig = loadPraxisConfig();

  // Build vars map: project vars + praxis config + project name
  const vars = {
    ...praxisConfig,
    ...(projectConfig.vars || {}),
    project: projectConfig.project || projectName,
  };

  // Load profile: from named profile, project-local blocks, or _base fallback
  let profile;
  if (projectConfig.profile) {
    profile = loadProfile(projectConfig.profile);
  } else if (projectConfig.blocks) {
    // Project-local blocks — merge with _base
    const base = loadProfile('_base');
    profile = mergeProfiles(base, { blocks: projectConfig.blocks });
  } else {
    profile = loadProfile('_base');
  }
  profile = applyOverrides(profile, projectConfig.overrides);

  const profileName = projectConfig.profile || 'project-local';
  console.log(`\nCompiling: ${projectName} (profile: ${profileName})`);

  for (const target of targets) {
    const blocks = loadBlocks(profile, target);
    let output;

    if (target === 'claude-code') {
      output = assembleClaudeCode(blocks, projectConfig, vars);
    } else if (target === 'claude-project') {
      output = assembleClaudeProject(blocks, projectConfig, vars);
    } else {
      output = assemblePerplexitySpace(blocks, projectConfig, vars);
    }

    // Interpolate variables
    output = interpolate(output, vars);

    // Validate no unresolved placeholders
    const unresolved = findUnresolved(output);
    if (unresolved.length > 0) {
      if (STRICT_MODE) {
        fail(`[strict] Unresolved placeholders in ${target}: ${unresolved.join(', ')}`);
      }
      warn(`Unresolved placeholders in ${target}: ${unresolved.join(', ')}`);
    }

    // Check character budget
    const budget = CHAR_BUDGETS[target];
    if (output.length > budget) {
      if (STRICT_MODE) {
        fail(`[strict] ${target} exceeds budget: ${output.length} chars (limit: ${budget})`);
      }
      warn(`${target} output exceeds budget: ${output.length} chars (limit: ${budget})`);
    }

    // Determine output filename
    const outputNames = {
      'claude-code': 'CLAUDE.md',
      'claude-project': 'project-instructions.md',
      'perplexity-space': 'space-instructions.md',
    };
    const outputPath = path.join(projectDir, outputNames[target]);

    // Preview mode: print to stdout instead of writing
    if (PREVIEW_MODE) {
      console.log(`\n--- ${outputNames[target]} (${output.length} chars) ---`);
      console.log(output);
      continue;
    }

    // Diff mode: show diff against existing file before writing
    if (DIFF_MODE && fs.existsSync(outputPath)) {
      const existing = fs.readFileSync(outputPath, 'utf8');
      if (existing === output) {
        ok(`${outputNames[target]} — unchanged (${output.length} chars)`);
        continue;
      }
      console.log(`\n--- ${outputNames[target]} changed ---`);
      const existingLines = existing.split('\n');
      const outputLines = output.split('\n');
      const addedCount = outputLines.filter((l) => !existingLines.includes(l)).length;
      const removedCount = existingLines.filter((l) => !outputLines.includes(l)).length;
      console.log(`  +${addedCount} lines added, -${removedCount} lines removed`);
    }

    fs.writeFileSync(outputPath, output, 'utf8');
    ok(`${outputNames[target]} — ${output.length} chars → ${outputPath}`);
  }
}

// ── CLI ──────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help')) {
    console.log('Usage: prompt-compile <project-name|--all> [options]');
    console.log('Options:');
    console.log('  --target <target>  claude-code|claude-project|perplexity-space|all');
    console.log('  --preview          Print output to stdout without writing files');
    console.log('  --diff             Show what changed before writing');
    console.log('  --strict           Exit with error on budget overruns or unresolved vars');
    console.log('  --list             List all projects with mode and file status');
    process.exit(0);
  }

  // --list mode: show all projects
  if (args.includes('--list')) {
    const projectDirs = fs.readdirSync(PROJECTS_DIR)
      .filter((d) => d !== '_template' && fs.statSync(path.join(PROJECTS_DIR, d)).isDirectory());
    if (projectDirs.length === 0) {
      console.log('No projects found.');
      process.exit(0);
    }
    console.log(`${'Project'.padEnd(20)} ${'Mode'.padEnd(12)} ${'System Prompt'.padEnd(15)} ${'Claude Proj'.padEnd(15)} ${'Perplexity'.padEnd(15)} ${'CLAUDE.md'.padEnd(12)} Refs`);
    console.log('-'.repeat(95));
    for (const name of projectDirs) {
      const dir = path.join(PROJECTS_DIR, name);
      const cfgPath = path.join(dir, 'prompt-config.yaml');
      const cfg = fs.existsSync(cfgPath) ? yaml.load(fs.readFileSync(cfgPath, 'utf8')) : {};
      const mode = cfg.mode || 'compiled';
      const fileStatus = (f) => {
        const p = path.join(dir, f);
        if (!fs.existsSync(p)) return '—';
        return `${fs.readFileSync(p, 'utf8').length} chars`;
      };
      const refsDir = path.join(dir, 'references');
      const refCount = fs.existsSync(refsDir)
        ? fs.readdirSync(refsDir).filter((f) => f.endsWith('.md')).length
        : 0;
      console.log(
        `${name.padEnd(20)} ${mode.padEnd(12)} ${fileStatus('system-prompt.md').padEnd(15)} ${fileStatus('project-instructions.md').padEnd(15)} ${fileStatus('space-instructions.md').padEnd(15)} ${fileStatus('CLAUDE.md').padEnd(12)} ${refCount}`
      );
    }
    process.exit(0);
  }

  // Parse global flags
  PREVIEW_MODE = args.includes('--preview');
  DIFF_MODE = args.includes('--diff');
  STRICT_MODE = args.includes('--strict');

  // Parse --target flag
  const targetIdx = args.indexOf('--target');
  let targets = TARGETS;
  if (targetIdx !== -1 && args[targetIdx + 1]) {
    const targetArg = args[targetIdx + 1];
    if (targetArg === 'all') {
      targets = TARGETS;
    } else if (TARGETS.includes(targetArg)) {
      targets = [targetArg];
    } else {
      fail(`Unknown target: ${targetArg}. Use: ${TARGETS.join(', ')}, all`);
    }
  }

  // Determine project(s) to compile
  const flagValues = new Set();
  if (targetIdx !== -1 && args[targetIdx + 1]) {
    flagValues.add(args[targetIdx + 1]);
  }
  const projectArg = args.find((a) => !a.startsWith('--') && !flagValues.has(a));

  if (projectArg === '--all' || args.includes('--all')) {
    const projectDirs = fs.readdirSync(PROJECTS_DIR)
      .filter((d) => d !== '_template' && fs.statSync(path.join(PROJECTS_DIR, d)).isDirectory());

    if (projectDirs.length === 0) {
      fail('No projects found in prompts/projects/');
    }

    for (const projectName of projectDirs) {
      compileProject(projectName, targets);
    }
  } else if (projectArg) {
    compileProject(projectArg, targets);
  } else {
    fail('Specify a project name or use --all');
  }

  console.log('\nDone.');
}

main();
