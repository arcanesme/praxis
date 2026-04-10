#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const {
  ALL_TARGETS,
  DEFAULT_TARGETS,
  PROMPTS_DIR,
  WORK_DIR,
  PERSONAL_DIR,
  loadPraxisConfig,
  loadProfile,
  mergeProfiles,
  loadBlocks,
  applyOverrides,
  loadClientConfig,
  discoverAllWorkProjects,
  resolveProject,
  mergeClientDealConfig,
} = require('../lib/loader');

const {
  interpolate,
  findUnresolved,
  assembleClaudeCode,
  assembleClaudeProject,
  assemblePerplexitySpace,
} = require('../lib/assemblers');

const PROJECTS_DIR = path.join(PROMPTS_DIR, 'projects');

/** Discover all compilable projects — clients hierarchy + legacy flat projects. */
function discoverAllProjects() {
  const results = [];

  // New hierarchy: work/*/projects/* + personal/*
  for (const entry of discoverAllWorkProjects()) {
    results.push({ name: entry.displayName, dir: entry.dealDir, client: entry.client, deal: entry.deal, clientDir: entry.clientDir });
  }

  // Legacy: projects/*/  (skip _template, skip projects that also exist in clients)
  if (fs.existsSync(PROJECTS_DIR)) {
    const dealNames = new Set(results.map((r) => r.deal));
    const legacyDirs = fs.readdirSync(PROJECTS_DIR)
      .filter((d) => d !== '_template' && fs.statSync(path.join(PROJECTS_DIR, d)).isDirectory())
      .filter((d) => !dealNames.has(d));

    for (const name of legacyDirs) {
      results.push({ name, dir: path.join(PROJECTS_DIR, name), client: null, deal: name, clientDir: null });
    }
  }
  return results;
}

const CHAR_BUDGETS = {
  'claude-code': Infinity,
  'claude-project': 5000,
  'perplexity-space': 4500,
};

function resolveConfiguredTargets(projectConfig) {
  if (!Array.isArray(projectConfig.platforms) || projectConfig.platforms.length === 0) {
    return DEFAULT_TARGETS;
  }

  const configuredTargets = projectConfig.platforms.filter((target) => ALL_TARGETS.includes(target));
  return configuredTargets.length > 0 ? configuredTargets : DEFAULT_TARGETS;
}

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

// ── Main ─────────────────────────────────────────────────────

/** Validate a standalone project — check files exist, report char budgets. Returns result rows for summary. */
function validateStandalone(projectName, projectDir, projectConfig) {
  console.log(`\nValidating standalone: ${projectName}`);

  const inventory = [
    { file: 'system-prompt.md', budget: 5000, required: true, label: 'System Prompt (Source)' },
    { file: 'space-instructions-perplexity.md', budget: CHAR_BUDGETS['perplexity-space'], required: false, label: 'Perplexity Space' },
    { file: 'claude-code.md', budget: CHAR_BUDGETS['claude-code'], required: false, label: 'Claude Code' },
  ];

  const results = [];
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
      const overBudget = charCount > item.budget;

      if (overBudget) {
        warn(`${item.file} exceeds budget: ${charCount} chars (limit: ${item.budget})`);
      } else {
        ok(`${item.file} — ${sizeInfo}`);
      }

      results.push({ project: projectName, target: item.label, chars: charCount, budget: item.budget, status: overBudget ? 'OVER' : 'ok' });
    } else if (item.required) {
      warn(`${item.file} MISSING — standalone projects require a system prompt`);
      results.push({ project: projectName, target: item.label, chars: 0, budget: item.budget, status: 'MISSING' });
    } else {
      missingGenerable.push(item.file);
    }
  }

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

  return { mode: 'standalone', results };
}

/** Compile a project. Returns { mode, results[] } for summary table. */
function compileProject(projectName, requestedTargets, projectDirOverride, clientDirOverride) {
  // Resolve project path — supports "client/deal", "deal", or direct dir override
  let projectDir;
  let clientDir = clientDirOverride || null;
  if (projectDirOverride) {
    projectDir = projectDirOverride;
  } else {
    const resolved = resolveProject(projectName);
    if (!resolved.dealDir || !fs.existsSync(resolved.dealDir)) {
      fail(`Project not found: ${projectName}\nRun /px-prompt <project-name> to create one.`);
    }
    projectDir = resolved.dealDir;
    clientDir = resolved.clientDir;
  }

  const configPath = path.join(projectDir, 'prompt-config.yaml');
  if (!fs.existsSync(configPath)) {
    fail(`Project config not found: ${configPath}\nRun /px-prompt <project-name> to create one.`);
  }

  let projectConfig = yaml.load(fs.readFileSync(configPath, 'utf8'));

  // Merge client config if in hierarchy
  if (clientDir) {
    const clientConfig = loadClientConfig(clientDir);
    if (clientConfig) {
      projectConfig = mergeClientDealConfig(clientConfig, projectConfig);
    }
  }

  if (projectConfig.mode === 'standalone') {
    return validateStandalone(projectName, projectDir, projectConfig);
  }

  const targets = requestedTargets || resolveConfiguredTargets(projectConfig);

  const praxisConfig = loadPraxisConfig();

  const vars = {
    ...praxisConfig,
    ...(projectConfig.vars || {}),
    project: projectConfig.project || projectName,
  };

  let profile;
  if (projectConfig.profile) {
    profile = loadProfile(projectConfig.profile, fail);
  } else if (projectConfig.blocks) {
    const base = loadProfile('_base', fail);
    profile = mergeProfiles(base, { blocks: projectConfig.blocks });
  } else {
    profile = loadProfile('_base', fail);
  }
  profile = applyOverrides(profile, projectConfig.overrides);

  const profileName = projectConfig.profile || 'project-local';
  console.log(`\nCompiling: ${projectName} (profile: ${profileName})`);

  const targetAssemblers = {
    'claude-code': assembleClaudeCode,
    'claude-project': assembleClaudeProject,
    'perplexity-space': assemblePerplexitySpace,
  };

  const outputNames = {
    'claude-code': 'claude-code.md',
    'claude-project': 'system-prompt.md',
    'perplexity-space': 'space-instructions-perplexity.md',
  };

  const results = [];

  for (const target of targets) {
    if (!targetAssemblers[target]) {
      fail(`Unknown target: ${target}. Valid targets: ${Object.keys(targetAssemblers).join(', ')}`);
    }
    const blocks = loadBlocks(profile, target, warn);
    let output = targetAssemblers[target](blocks, projectConfig, vars);

    output = interpolate(output, vars);

    const unresolved = findUnresolved(output);
    if (unresolved.length > 0) {
      if (STRICT_MODE) {
        fail(`[strict] Unresolved placeholders in ${target}: ${unresolved.join(', ')}`);
      }
      warn(`Unresolved placeholders in ${target}: ${unresolved.join(', ')}`);
    }

    const budget = CHAR_BUDGETS[target];
    const overBudget = output.length > budget;
    if (overBudget) {
      if (STRICT_MODE) {
        fail(`[strict] ${target} exceeds budget: ${output.length} chars (limit: ${budget})`);
      }
      warn(`${target} output exceeds budget: ${output.length} chars (limit: ${budget})`);
    }

    const outputPath = path.join(projectDir, outputNames[target]);
    let status = 'wrote';

    if (PREVIEW_MODE) {
      console.log(`\n--- ${outputNames[target]} (${output.length} chars) ---`);
      console.log(output);
      status = 'preview';
    } else if (DIFF_MODE && fs.existsSync(outputPath)) {
      const existing = fs.readFileSync(outputPath, 'utf8');
      if (existing === output) {
        ok(`${outputNames[target]} — unchanged (${output.length} chars)`);
        status = 'unchanged';
      } else {
        const existingLines = existing.split('\n');
        const outputLines = output.split('\n');
        const addedCount = outputLines.filter((l) => !existingLines.includes(l)).length;
        const removedCount = existingLines.filter((l) => !outputLines.includes(l)).length;
        console.log(`\n--- ${outputNames[target]} changed ---`);
        console.log(`  +${addedCount} lines added, -${removedCount} lines removed`);
        fs.writeFileSync(outputPath, output, 'utf8');
        ok(`${outputNames[target]} — ${output.length} chars → ${outputPath}`);
        status = 'updated';
      }
    } else {
      fs.writeFileSync(outputPath, output, 'utf8');
      ok(`${outputNames[target]} — ${output.length} chars → ${outputPath}`);
    }

    if (overBudget) status = 'OVER';
    results.push({ project: projectName, target, chars: output.length, budget, status });
  }

  return { mode: 'compiled', results };
}

// ── CLI ──────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help')) {
    console.log('Usage: prompt-compile <project-name|--all|--sync> [options]');
    console.log('Options:');
    console.log('  --target <target>  claude-code|claude-project|perplexity-space|all');
    console.log('  --preview          Print output to stdout without writing files');
    console.log('  --diff             Show what changed before writing');
    console.log('  --strict           Exit with error on budget overruns or unresolved vars');
    console.log('  --sync             Compile all projects with diff, show summary table');
    console.log('  --dashboard        Rich project index with budgets and staleness');
    console.log('  --list             List all projects with mode and file status');
    process.exit(0);
  }

  // --list mode: show all projects
  if (args.includes('--list')) {
    const allProjects = discoverAllProjects();
    if (allProjects.length === 0) {
      console.log('No projects found.');
      process.exit(0);
    }
    console.log(`${'Project'.padEnd(28)} ${'Mode'.padEnd(12)} ${'System Prompt'.padEnd(15)} ${'Perplexity'.padEnd(15)} ${'Claude Code'.padEnd(15)} Refs`);
    console.log('-'.repeat(100));
    for (const proj of allProjects) {
      const cfgPath = path.join(proj.dir, 'prompt-config.yaml');
      const cfg = fs.existsSync(cfgPath) ? yaml.load(fs.readFileSync(cfgPath, 'utf8')) : {};
      const mode = cfg.mode || 'compiled';
      const fileStatus = (f) => {
        const p = path.join(proj.dir, f);
        if (!fs.existsSync(p)) return '—';
        return `${fs.readFileSync(p, 'utf8').length} chars`;
      };
      const refsDir = path.join(proj.dir, 'references');
      const refCount = fs.existsSync(refsDir)
        ? fs.readdirSync(refsDir).filter((f) => f.endsWith('.md')).length
        : 0;
      console.log(
        `${proj.name.padEnd(28)} ${mode.padEnd(12)} ${fileStatus('system-prompt.md').padEnd(15)} ${fileStatus('space-instructions-perplexity.md').padEnd(15)} ${fileStatus('claude-code.md').padEnd(15)} ${refCount}`
      );
    }
    process.exit(0);
  }

  // --dashboard mode: rich project index with staleness and budgets
  if (args.includes('--dashboard')) {
    const allProjects = discoverAllProjects();
    if (allProjects.length === 0) {
      console.log('No projects found.');
      process.exit(0);
    }

    const STALE_DAYS = 30;
    const now = Date.now();

    console.log('\n\x1b[1mPROMPT ENGINE DASHBOARD\x1b[0m');
    console.log('\x1b[90m' + '━'.repeat(110) + '\x1b[0m');
    console.log(
      `${'Project'.padEnd(24)} ${'Mode'.padEnd(12)} ${'System Prompt'.padEnd(14)} ${'Perplexity'.padEnd(14)} ${'Refs'.padEnd(6)} ${'Updated'.padEnd(12)} Stale?`
    );
    console.log('\x1b[90m' + '─'.repeat(110) + '\x1b[0m');

    for (const proj of allProjects) {
      const cfgPath = path.join(proj.dir, 'prompt-config.yaml');
      const cfg = fs.existsSync(cfgPath) ? yaml.load(fs.readFileSync(cfgPath, 'utf8')) : {};
      const mode = cfg.mode || 'compiled';

      const fileBudget = (f, budget) => {
        const p = path.join(proj.dir, f);
        if (!fs.existsSync(p)) return '\x1b[90m—\x1b[0m';
        const chars = fs.readFileSync(p, 'utf8').length;
        const icon = chars > budget ? '\x1b[33m⚠\x1b[0m' : '\x1b[32m✓\x1b[0m';
        return `${chars} ${budget < Infinity ? icon : ''}`;
      };

      const refsDir = path.join(proj.dir, 'references');
      const refCount = fs.existsSync(refsDir)
        ? fs.readdirSync(refsDir).filter((f) => f.endsWith('.md')).length
        : 0;

      let latestMtime = 0;
      const allFiles = fs.readdirSync(proj.dir).filter((f) => f.endsWith('.md') || f.endsWith('.yaml'));
      for (const f of allFiles) {
        const stat = fs.statSync(path.join(proj.dir, f));
        if (stat.mtimeMs > latestMtime) latestMtime = stat.mtimeMs;
      }
      const updated = latestMtime > 0 ? new Date(latestMtime).toISOString().slice(0, 10) : '—';
      const daysSince = latestMtime > 0 ? Math.floor((now - latestMtime) / 86400000) : 999;
      const stale = daysSince > STALE_DAYS ? '\x1b[31mYes\x1b[0m' : '\x1b[32mNo\x1b[0m';

      console.log(
        `${proj.name.padEnd(24)} ${mode.padEnd(12)} ${fileBudget('system-prompt.md', CHAR_BUDGETS['claude-project']).padEnd(23)} ${fileBudget('space-instructions-perplexity.md', CHAR_BUDGETS['perplexity-space']).padEnd(23)} ${String(refCount).padEnd(6)} ${updated.padEnd(12)} ${stale}`
      );
    }

    console.log('\x1b[90m' + '━'.repeat(110) + '\x1b[0m');
    console.log('\x1b[90mStaleness: >30 days since last file change. Budgets: ✓ under, ⚠ over.\x1b[0m\n');
    process.exit(0);
  }

  // Parse global flags
  PREVIEW_MODE = args.includes('--preview');
  DIFF_MODE = args.includes('--diff');
  STRICT_MODE = args.includes('--strict');

  // Parse --target flag
  const targetIdx = args.indexOf('--target');
  let requestedTargets = null;
  if (targetIdx !== -1 && args[targetIdx + 1]) {
    const targetArg = args[targetIdx + 1];
    if (ALL_TARGETS.includes(targetArg)) {
      requestedTargets = [targetArg];
    } else if (targetArg === 'all') {
      requestedTargets = ALL_TARGETS;
    } else {
      fail(`Unknown target: ${targetArg}. Use: ${ALL_TARGETS.join(', ')}, all`);
    }
  }

  // Determine project(s) to compile
  const flagValues = new Set();
  if (targetIdx !== -1 && args[targetIdx + 1]) {
    flagValues.add(args[targetIdx + 1]);
  }
  const projectArg = args.find((a) => !a.startsWith('--') && !flagValues.has(a));

  const isSync = args.includes('--sync');
  if (isSync) {
    DIFF_MODE = true;
  }

  if (args.includes('--all') || isSync) {
    const allProjects = discoverAllProjects();

    if (allProjects.length === 0) {
      fail('No projects found.');
    }

    const allResults = [];
    for (const proj of allProjects) {
      const result = compileProject(proj.name, requestedTargets, proj.dir, proj.clientDir);
      if (result) allResults.push(result);
    }

    printSummaryTable(allResults);
  } else if (projectArg) {
    compileProject(projectArg, requestedTargets);
  } else {
    fail('Specify a project name or use --all / --sync');
  }

  console.log('\nDone.');
}

/** Print a summary table after --all or --sync compilation. */
function printSummaryTable(projectResults) {
  if (projectResults.length === 0) return;

  console.log('\n\x1b[1m── Summary ──────────────────────────────────────────────────────\x1b[0m');
  console.log(
    `${'Project'.padEnd(16)} ${'Mode'.padEnd(12)} ${'Target'.padEnd(18)} ${'Chars'.padEnd(10)} ${'Budget'.padEnd(10)} Status`
  );
  console.log('-'.repeat(78));

  for (const { mode, results } of projectResults) {
    for (const row of results) {
      const budgetStr = row.budget === Infinity ? '—' : String(row.budget);
      const statusColor = row.status === 'OVER' || row.status === 'MISSING' ? '\x1b[31m' :
        row.status === 'unchanged' ? '\x1b[90m' : '\x1b[32m';
      console.log(
        `${row.project.padEnd(16)} ${mode.padEnd(12)} ${row.target.padEnd(18)} ${String(row.chars).padEnd(10)} ${budgetStr.padEnd(10)} ${statusColor}${row.status}\x1b[0m`
      );
    }
  }
}

main();
