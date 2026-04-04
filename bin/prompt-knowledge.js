#!/usr/bin/env node
'use strict';

/**
 * Renders knowledge-file templates for a project.
 *
 * Reads `knowledge_packs` from the project's prompt-config.yaml.
 * Each entry specifies a template and vars. Renders to projects/<name>/knowledge/.
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { interpolate, findUnresolved } = require('../lib/assemblers');
const { parseFrontmatter, loadPraxisConfig } = require('../lib/loader');

const PKG_DIR = path.resolve(__dirname, '..');
const TEMPLATES_DIR = path.join(PKG_DIR, 'prompts', 'templates', 'knowledge');
const PROJECTS_DIR = path.join(PKG_DIR, 'prompts', 'projects');

function fail(msg) {
  console.error(`\x1b[31mERROR:\x1b[0m ${msg}`);
  process.exit(1);
}

function warn(msg) {
  console.error(`\x1b[33mWARN:\x1b[0m ${msg}`);
}

function ok(msg) {
  console.log(`\x1b[32m\u2713\x1b[0m ${msg}`);
}

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help')) {
    console.log('Usage: prompt-knowledge <project-name> [--preview] [--diff] [--list-templates]');
    process.exit(0);
  }

  if (args.includes('--list-templates')) {
    if (!fs.existsSync(TEMPLATES_DIR)) {
      console.log('No templates found.');
      process.exit(0);
    }
    const templates = fs.readdirSync(TEMPLATES_DIR).filter((f) => f.endsWith('.md'));
    if (templates.length === 0) {
      console.log('No templates found.');
      process.exit(0);
    }
    console.log('\nAvailable knowledge templates:\n');
    for (const t of templates) {
      const content = fs.readFileSync(path.join(TEMPLATES_DIR, t), 'utf8');
      const { meta } = parseFrontmatter(content);
      console.log(`  ${(meta.id || t).padEnd(28)} ${meta.description || '(no description)'}`);
      if (meta.vars) {
        console.log(`    vars: ${meta.vars.join(', ')}`);
      }
    }
    console.log('');
    process.exit(0);
  }

  const preview = args.includes('--preview');
  const diff = args.includes('--diff');
  const projectName = args.find((a) => !a.startsWith('--'));

  if (!projectName) fail('Specify a project name.');

  const projectDir = path.join(PROJECTS_DIR, projectName);
  const configPath = path.join(projectDir, 'prompt-config.yaml');

  if (!fs.existsSync(configPath)) {
    fail(`Project config not found: ${configPath}`);
  }

  const projectConfig = yaml.load(fs.readFileSync(configPath, 'utf8'));
  const praxisConfig = loadPraxisConfig();
  const globalVars = {
    ...praxisConfig,
    ...(projectConfig.vars || {}),
    project: projectConfig.project || projectName,
  };

  const packs = projectConfig.knowledge_packs || [];
  if (packs.length === 0) {
    console.log(`No knowledge_packs defined in ${configPath}`);
    process.exit(0);
  }

  const knowledgeDir = path.join(projectDir, 'knowledge');
  if (!preview && !fs.existsSync(knowledgeDir)) {
    fs.mkdirSync(knowledgeDir, { recursive: true });
  }

  console.log(`\nRendering knowledge packs for: ${projectName}\n`);

  for (const pack of packs) {
    const templatePath = path.join(TEMPLATES_DIR, `${pack.template}.md`);
    if (!fs.existsSync(templatePath)) {
      warn(`Template not found: ${pack.template} \u2014 skipping`);
      continue;
    }

    const templateContent = fs.readFileSync(templatePath, 'utf8');
    const { body } = parseFrontmatter(templateContent);

    const vars = { ...globalVars, ...(pack.vars || {}) };
    const output = interpolate(body, vars);

    const unresolved = findUnresolved(output);
    if (unresolved.length > 0) {
      warn(`Unresolved in ${pack.output}: ${unresolved.join(', ')} \u2014 these become placeholders for manual fill`);
    }

    const outputPath = path.join(knowledgeDir, pack.output);

    if (preview) {
      console.log(`--- ${pack.output} (${output.length} chars, targets: ${(pack.targets || ['all']).join(', ')}) ---`);
      console.log(output);
      console.log('');
    } else if (diff && fs.existsSync(outputPath)) {
      const existing = fs.readFileSync(outputPath, 'utf8');
      if (existing === output) {
        ok(`${pack.output} \u2014 unchanged`);
      } else {
        fs.writeFileSync(outputPath, output, 'utf8');
        ok(`${pack.output} \u2014 updated (${output.length} chars)`);
      }
    } else {
      fs.writeFileSync(outputPath, output, 'utf8');
      ok(`${pack.output} \u2014 ${output.length} chars \u2192 ${outputPath}`);
    }
  }

  console.log('\nDone.');
}

main();
