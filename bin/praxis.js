#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawnSync } = require('child_process');

const VERSION = require('../package.json').version;
const PKG_DIR = path.resolve(__dirname, '..');
const CLAUDE_DIR = path.join(os.homedir(), '.claude');
const CONFIG_FILE = path.join(CLAUDE_DIR, 'praxis.config.json');

// ── Helpers ──────────────────────────────────────────────────

function header(msg) { console.log('\n\x1b[1m\x1b[36m' + msg + '\x1b[0m'); }
function ok(msg)     { console.log('  \x1b[32m\u2713\x1b[0m ' + msg); }
function fail(msg)   { console.error('  \x1b[31m\u2717\x1b[0m ' + msg); }
function dim(msg)    { console.log('  \x1b[2m' + msg + '\x1b[0m'); }

function toolExists(name) {
  const r = spawnSync('which', [name], { stdio: 'pipe' });
  return r.status === 0;
}

function copyDir(src, dest) {
  fs.cpSync(src, dest, { recursive: true, force: true });
}

function copyFile(src, dest) {
  fs.cpSync(src, dest, { force: true });
}

// ── Install ──────────────────────────────────────────────────

async function install() {
  header('Praxis Harness v' + VERSION);

  // Ensure ~/.claude/ structure
  for (const sub of ['rules', 'commands', 'skills']) {
    fs.mkdirSync(path.join(CLAUDE_DIR, sub), { recursive: true });
  }

  // Copy base/CLAUDE.md → ~/.claude/CLAUDE.md
  const claudeMdSrc = path.join(PKG_DIR, 'base', 'CLAUDE.md');
  if (fs.existsSync(claudeMdSrc)) {
    copyFile(claudeMdSrc, path.join(CLAUDE_DIR, 'CLAUDE.md'));
    ok('CLAUDE.md installed');
  }

  // Copy base/rules/* → ~/.claude/rules/
  const rulesDir = path.join(PKG_DIR, 'base', 'rules');
  if (fs.existsSync(rulesDir)) {
    let count = 0;
    for (const f of fs.readdirSync(rulesDir)) {
      copyFile(path.join(rulesDir, f), path.join(CLAUDE_DIR, 'rules', f));
      count++;
    }
    ok(count + ' rules installed');
  }

  // Copy base/commands/* → ~/.claude/commands/
  const cmdsDir = path.join(PKG_DIR, 'base', 'commands');
  if (fs.existsSync(cmdsDir)) {
    let count = 0;
    for (const f of fs.readdirSync(cmdsDir)) {
      copyFile(path.join(cmdsDir, f), path.join(CLAUDE_DIR, 'commands', f));
      count++;
    }
    ok(count + ' commands installed');
  }

  // Copy base/skills/* → ~/.claude/skills/
  const skillsDir = path.join(PKG_DIR, 'base', 'skills');
  if (fs.existsSync(skillsDir)) {
    let count = 0;
    for (const entry of fs.readdirSync(skillsDir)) {
      const src = path.join(skillsDir, entry);
      const dest = path.join(CLAUDE_DIR, 'skills', entry);
      if (fs.statSync(src).isDirectory()) {
        copyDir(src, dest);
      } else {
        copyFile(src, dest);
      }
      count++;
    }
    ok(count + ' skills installed');
  }

  // Copy kits/ → ~/.claude/kits/
  const kitsDir = path.join(PKG_DIR, 'kits');
  if (fs.existsSync(kitsDir)) {
    copyDir(kitsDir, path.join(CLAUDE_DIR, 'kits'));
    ok('kits installed');
  }

  // Orphan cleanup: obsidian.md renamed to vault.md
  const legacyObsidian = path.join(CLAUDE_DIR, 'rules', 'obsidian.md');
  if (fs.existsSync(legacyObsidian)) {
    fs.unlinkSync(legacyObsidian);
    ok('Removed legacy obsidian.md (renamed to vault.md)');
  }

  // Vault configuration
  if (!fs.existsSync(CONFIG_FILE)) {
    header('Vault configuration');
    const readline = require('readline/promises');
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

    console.log('');
    console.log('  Choose a vault backend:');
    console.log('    [1] Obsidian (default)');
    console.log('    [2] Logseq');
    console.log('    [3] Plain markdown (~/.praxis-vault)');
    console.log('    [4] Custom path');
    console.log('');
    const backendChoice = await rl.question('  Choice [1]: ');
    const choice = (backendChoice || '1').trim();

    let vaultBackend = 'obsidian';
    let vaultPath = '';

    switch (choice) {
      case '1':
        vaultBackend = 'obsidian';
        vaultPath = await rl.question('  Obsidian vault path: ');
        break;
      case '2':
        vaultBackend = 'logseq';
        vaultPath = await rl.question('  Logseq vault path: ');
        break;
      case '3':
        vaultBackend = 'plain';
        vaultPath = path.join(os.homedir(), '.praxis-vault');
        fs.mkdirSync(vaultPath, { recursive: true });
        ok('Created ' + vaultPath);
        break;
      case '4':
        vaultBackend = 'custom';
        vaultPath = await rl.question('  Vault path: ');
        break;
      default:
        vaultBackend = 'obsidian';
        vaultPath = await rl.question('  Vault path: ');
        break;
    }
    rl.close();

    if (vaultPath) {
      vaultPath = vaultPath.replace(/^~/, os.homedir());
    }

    const config = {
      version: '1.1.0',
      vault_path: vaultPath || '',
      vault_backend: vaultBackend,
      repo_path: PKG_DIR
    };
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2) + '\n');
    ok('praxis.config.json written');
  } else {
    dim('praxis.config.json already exists — skipping');
  }

  // Tool checks (conditional on backend)
  header('Tool check');
  let vaultBackendForCheck = 'obsidian';
  if (fs.existsSync(CONFIG_FILE)) {
    try {
      const cfg = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
      vaultBackendForCheck = cfg.vault_backend || 'obsidian';
    } catch {}
  }

  const baseTools = ['node', 'claude', 'jq'];
  if (vaultBackendForCheck === 'obsidian' || vaultBackendForCheck === 'logseq') {
    baseTools.push('qmd');
  } else {
    baseTools.push('rg');
  }
  for (const tool of baseTools) {
    if (toolExists(tool)) {
      ok(tool + ' available');
    } else {
      fail(tool + ' not found (optional)');
    }
  }

  // Summary
  header('Install complete');
  console.log('  Files copied to ' + CLAUDE_DIR);
  console.log('  Run: npx praxis-harness health');
  console.log('');
}

// ── Update ───────────────────────────────────────────────────

async function update() {
  header('Updating Praxis Harness v' + VERSION);
  await install();
}

// ── Health ───────────────────────────────────────────────────

function health() {
  header('Praxis Health Check');
  let pass = 0;
  let total = 0;

  function check(condition, label) {
    total++;
    if (condition) { ok(label); pass++; }
    else { fail(label); }
  }

  // Core files
  console.log('\nCore:');
  check(fs.existsSync(path.join(CLAUDE_DIR, 'CLAUDE.md')), 'CLAUDE.md installed');

  // Rules
  console.log('\nRules:');
  const rulesDir = path.join(PKG_DIR, 'base', 'rules');
  if (fs.existsSync(rulesDir)) {
    for (const f of fs.readdirSync(rulesDir)) {
      check(fs.existsSync(path.join(CLAUDE_DIR, 'rules', f)), 'rules/' + f + ' installed');
    }
  }

  // Commands
  console.log('\nCommands:');
  const cmdsDir = path.join(PKG_DIR, 'base', 'commands');
  if (fs.existsSync(cmdsDir)) {
    for (const f of fs.readdirSync(cmdsDir)) {
      check(fs.existsSync(path.join(CLAUDE_DIR, 'commands', f)), 'commands/' + f + ' installed');
    }
  }

  // Skills
  console.log('\nSkills:');
  const skillsDir = path.join(PKG_DIR, 'base', 'skills');
  if (fs.existsSync(skillsDir)) {
    for (const entry of fs.readdirSync(skillsDir)) {
      check(fs.existsSync(path.join(CLAUDE_DIR, 'skills', entry)), 'skills/' + entry + ' installed');
    }
  }

  // Kits
  console.log('\nKits:');
  check(fs.existsSync(path.join(CLAUDE_DIR, 'kits')), 'kits directory installed');

  // Config
  console.log('\nConfig:');
  check(fs.existsSync(CONFIG_FILE), 'praxis.config.json exists');
  if (fs.existsSync(CONFIG_FILE)) {
    try {
      const cfg = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
      if (cfg.vault_path) {
        check(fs.existsSync(cfg.vault_path), 'vault_path (' + cfg.vault_path + ') exists');
      } else {
        total++; fail('vault_path not set in config');
      }
    } catch { total++; fail('praxis.config.json is invalid JSON'); }
  }

  // Tools (conditional on backend)
  console.log('\nTools:');
  let healthBackend = 'obsidian';
  if (fs.existsSync(CONFIG_FILE)) {
    try {
      const cfg = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
      healthBackend = cfg.vault_backend || 'obsidian';
    } catch {}
  }
  const healthTools = ['node', 'claude', 'jq'];
  if (healthBackend === 'obsidian' || healthBackend === 'logseq') {
    healthTools.push('qmd');
  } else {
    healthTools.push('rg');
  }
  for (const tool of healthTools) {
    check(toolExists(tool), tool + ' available');
  }

  // Summary
  console.log('\n' + '\u2501'.repeat(38));
  console.log('  Results: ' + pass + '/' + total + ' passed');
  if (pass < total) {
    console.log('  ' + (total - pass) + ' check(s) failed');
    process.exit(1);
  } else {
    console.log('  All checks passed');
  }
}

// ── Uninstall ────────────────────────────────────────────────

function uninstall() {
  header('Uninstalling Praxis Harness');

  // Remove files that came from base/
  const claudeMd = path.join(CLAUDE_DIR, 'CLAUDE.md');
  if (fs.existsSync(claudeMd)) { fs.unlinkSync(claudeMd); ok('CLAUDE.md removed'); }

  // Remove rules from base/rules/
  const rulesDir = path.join(PKG_DIR, 'base', 'rules');
  if (fs.existsSync(rulesDir)) {
    for (const f of fs.readdirSync(rulesDir)) {
      const target = path.join(CLAUDE_DIR, 'rules', f);
      if (fs.existsSync(target)) fs.unlinkSync(target);
    }
    // Also remove legacy obsidian.md if present
    const legacyRule = path.join(CLAUDE_DIR, 'rules', 'obsidian.md');
    if (fs.existsSync(legacyRule)) fs.unlinkSync(legacyRule);
    ok('rules removed');
  }

  // Remove commands from base/commands/
  const cmdsDir = path.join(PKG_DIR, 'base', 'commands');
  if (fs.existsSync(cmdsDir)) {
    for (const f of fs.readdirSync(cmdsDir)) {
      const target = path.join(CLAUDE_DIR, 'commands', f);
      if (fs.existsSync(target)) fs.unlinkSync(target);
    }
    ok('commands removed');
  }

  // Remove skills from base/skills/
  const skillsDir = path.join(PKG_DIR, 'base', 'skills');
  if (fs.existsSync(skillsDir)) {
    for (const entry of fs.readdirSync(skillsDir)) {
      const target = path.join(CLAUDE_DIR, 'skills', entry);
      if (fs.existsSync(target)) {
        fs.rmSync(target, { recursive: true, force: true });
      }
    }
    ok('skills removed');
  }

  // Remove kits
  const kitsTarget = path.join(CLAUDE_DIR, 'kits');
  if (fs.existsSync(kitsTarget)) {
    fs.rmSync(kitsTarget, { recursive: true, force: true });
    ok('kits removed');
  }

  header('Uninstall complete');
  dim('Config file preserved: ' + CONFIG_FILE);
  dim('Run: rm ' + CONFIG_FILE + ' to remove config');
  console.log('');
}

// ── Help ─────────────────────────────────────────────────────

function printHelp() {
  console.log(`
praxis-harness v${VERSION}

Usage: npx praxis-harness [command]

Commands:
  install     Copy rules, commands, skills, and kits to ~/.claude/ (default)
  update      Re-copy from latest npm package version
  health      Verify install integrity
  uninstall   Remove Praxis-owned files from ~/.claude/

Flags:
  --help, -h      Show this help
  --version, -v   Show version
`);
}

// ── Main ─────────────────────────────────────────────────────

const arg = process.argv[2] || 'install';
const commands = { install, update, health, uninstall };

if (arg === '--help' || arg === '-h') { printHelp(); }
else if (arg === '--version' || arg === '-v') { console.log(VERSION); }
else if (commands[arg]) {
  const result = commands[arg]();
  if (result && typeof result.catch === 'function') {
    result.catch(err => { fail(err.message); process.exit(1); });
  }
}
else { fail('Unknown command: ' + arg); printHelp(); process.exit(1); }
