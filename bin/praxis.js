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
  for (const sub of ['rules', 'skills', 'hooks']) {
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

  // Copy base/hooks/*.sh → ~/.claude/hooks/
  const hooksDir = path.join(PKG_DIR, 'base', 'hooks');
  if (fs.existsSync(hooksDir)) {
    let count = 0;
    for (const f of fs.readdirSync(hooksDir)) {
      if (f.endsWith('.sh')) {
        copyFile(path.join(hooksDir, f), path.join(CLAUDE_DIR, 'hooks', f));
        // Make executable
        fs.chmodSync(path.join(CLAUDE_DIR, 'hooks', f), 0o755);
        count++;
      }
    }
    ok(count + ' hooks installed');

    // Merge hooks configuration into settings.json
    const hooksConfig = path.join(hooksDir, 'settings-hooks.json');
    const settingsFile = path.join(CLAUDE_DIR, 'settings.json');
    if (fs.existsSync(hooksConfig)) {
      const hooksCfg = JSON.parse(fs.readFileSync(hooksConfig, 'utf8'));
      let settings = {};
      if (fs.existsSync(settingsFile)) {
        try { settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8')); } catch { /* invalid JSON — use empty defaults */ }
      }
      Object.assign(settings, hooksCfg);
      fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + '\n');
      ok('hooks configuration merged into settings.json');
    }
  }

  // Copy base/configs/ → ~/.claude/configs/
  const configsDir = path.join(PKG_DIR, 'base', 'configs');
  if (fs.existsSync(configsDir)) {
    fs.mkdirSync(path.join(CLAUDE_DIR, 'configs'), { recursive: true });
    copyDir(configsDir, path.join(CLAUDE_DIR, 'configs'));
    ok('linter configs installed');
  }

  // Copy kits/ → ~/.claude/kits/
  const kitsDir = path.join(PKG_DIR, 'kits');
  if (fs.existsSync(kitsDir)) {
    copyDir(kitsDir, path.join(CLAUDE_DIR, 'kits'));
    ok('kits installed');
  }

  // Orphan cleanup: deleted rules and legacy files
  const orphans = [
    'obsidian.md', 'security.md',
    'communication.md', 'architecture.md'
  ];
  for (const f of orphans) {
    const target = path.join(CLAUDE_DIR, 'rules', f);
    if (fs.existsSync(target)) {
      fs.unlinkSync(target);
      dim('removed legacy ' + f);
    }
  }

  // Orphan cleanup: old commands directory (v1.x)
  const oldCmdsDir = path.join(CLAUDE_DIR, 'commands');
  if (fs.existsSync(oldCmdsDir)) {
    const files = fs.readdirSync(oldCmdsDir);
    if (files.length > 0) {
      for (const f of files) {
        fs.unlinkSync(path.join(oldCmdsDir, f));
      }
      dim('cleaned up ' + files.length + ' legacy command files');
    }
  }

  // Vault configuration
  if (!fs.existsSync(CONFIG_FILE)) {
    header('Vault configuration');
    const readline = require('readline/promises');
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

    let vaultPath = await rl.question('  Obsidian vault path: ');
    rl.close();

    if (vaultPath) {
      vaultPath = vaultPath.replace(/^~/, os.homedir());
    }

    const config = {
      version: VERSION,
      vault_path: vaultPath || '',
      vault_backend: 'obsidian',
      repo_path: PKG_DIR
    };
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2) + '\n');
    ok('praxis.config.json written');
  } else {
    dim('praxis.config.json already exists — skipping');
  }

  // Tool checks
  header('Tool check');
  const baseTools = ['node', 'claude', 'jq', 'obsidian'];
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
  console.log('  Run: npx @esoteric-logic/praxis-harness health');
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

  // Skills
  console.log('\nSkills:');
  const skillsDir = path.join(PKG_DIR, 'base', 'skills');
  if (fs.existsSync(skillsDir)) {
    for (const entry of fs.readdirSync(skillsDir)) {
      check(fs.existsSync(path.join(CLAUDE_DIR, 'skills', entry)), 'skills/' + entry + ' installed');
    }
  }

  // Hooks
  console.log('\nHooks:');
  const hooksDir = path.join(PKG_DIR, 'base', 'hooks');
  if (fs.existsSync(hooksDir)) {
    for (const f of fs.readdirSync(hooksDir)) {
      if (f.endsWith('.sh')) {
        check(fs.existsSync(path.join(CLAUDE_DIR, 'hooks', f)), 'hooks/' + f + ' installed');
      }
    }
  }
  check(fs.existsSync(path.join(CLAUDE_DIR, 'settings.json')), 'settings.json with hooks configured');

  // Configs
  console.log('\nConfigs:');
  check(fs.existsSync(path.join(CLAUDE_DIR, 'configs')), 'configs directory installed');

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

  // Tools
  console.log('\nTools:');
  const healthTools = ['node', 'claude', 'jq', 'obsidian'];
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

  // Remove CLAUDE.md
  const claudeMd = path.join(CLAUDE_DIR, 'CLAUDE.md');
  if (fs.existsSync(claudeMd)) { fs.unlinkSync(claudeMd); ok('CLAUDE.md removed'); }

  // Remove rules
  const rulesDir = path.join(PKG_DIR, 'base', 'rules');
  if (fs.existsSync(rulesDir)) {
    for (const f of fs.readdirSync(rulesDir)) {
      const target = path.join(CLAUDE_DIR, 'rules', f);
      if (fs.existsSync(target)) fs.unlinkSync(target);
    }
    // Also remove legacy files
    for (const f of ['obsidian.md', 'security.md', 'communication.md', 'architecture.md']) {
      const target = path.join(CLAUDE_DIR, 'rules', f);
      if (fs.existsSync(target)) fs.unlinkSync(target);
    }
    ok('rules removed');
  }

  // Remove skills
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

  // Remove hooks
  const hooksDir = path.join(CLAUDE_DIR, 'hooks');
  if (fs.existsSync(hooksDir)) {
    for (const f of fs.readdirSync(hooksDir)) {
      if (f.endsWith('.sh')) {
        fs.unlinkSync(path.join(hooksDir, f));
      }
    }
    ok('hooks removed');
  }

  // Remove configs
  const configsTarget = path.join(CLAUDE_DIR, 'configs');
  if (fs.existsSync(configsTarget)) {
    fs.rmSync(configsTarget, { recursive: true, force: true });
    ok('linter configs removed');
  }

  // Remove kits
  const kitsTarget = path.join(CLAUDE_DIR, 'kits');
  if (fs.existsSync(kitsTarget)) {
    fs.rmSync(kitsTarget, { recursive: true, force: true });
    ok('kits removed');
  }

  // Remove legacy commands directory
  const oldCmdsDir = path.join(CLAUDE_DIR, 'commands');
  if (fs.existsSync(oldCmdsDir)) {
    fs.rmSync(oldCmdsDir, { recursive: true, force: true });
    ok('legacy commands directory removed');
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

Usage: npx @esoteric-logic/praxis-harness [command]

Commands:
  install     Copy rules, skills, hooks, and kits to ~/.claude/ (default)
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
