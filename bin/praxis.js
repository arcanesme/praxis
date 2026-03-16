#!/usr/bin/env node
'use strict';

const { spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

const INSTALL_DIR = path.join(os.homedir(), '.praxis');
const REPO_URL = 'https://github.com/arcanesme/praxis.git';
const VERSION = require('../package.json').version;

function run(cmd, args, opts) {
  return spawnSync(cmd, args, { stdio: 'inherit', ...opts });
}

function header(msg) { console.log('\n\x1b[1m\x1b[36m' + msg + '\x1b[0m'); }
function ok(msg)     { console.log('  \x1b[32m\u2713\x1b[0m ' + msg); }
function fail(msg)   { console.error('  \x1b[31m\u2717\x1b[0m ' + msg); }

function ensureInstalled() {
  if (!fs.existsSync(path.join(INSTALL_DIR, '.git'))) {
    fail('Praxis not installed. Run: npx praxis-harness');
    process.exit(1);
  }
}

function ensureGit() {
  const result = spawnSync('git', ['--version'], { stdio: 'pipe' });
  if (result.status !== 0) {
    fail('git is required but not found. Install git first.');
    process.exit(1);
  }
}

function install() {
  ensureGit();
  if (fs.existsSync(INSTALL_DIR)) {
    if (fs.existsSync(path.join(INSTALL_DIR, '.git'))) {
      header('Praxis already cloned at ' + INSTALL_DIR);
      ok('Pulling latest...');
      const pull = run('git', ['-C', INSTALL_DIR, 'pull', '--ff-only']);
      if (pull.status !== 0) {
        console.log('  git pull failed \u2014 using existing version');
      }
    } else {
      fail(INSTALL_DIR + ' exists but is not a git repo. Remove it and retry.');
      process.exit(1);
    }
  } else {
    header('Cloning Praxis to ' + INSTALL_DIR);
    const result = run('git', ['clone', REPO_URL, INSTALL_DIR]);
    if (result.status !== 0) {
      fail('Clone failed. Check your internet connection and try again.');
      process.exit(result.status || 1);
    }
    ok('Repo cloned');
  }

  header('Running install.sh');
  const result = run('bash', ['install.sh'], { cwd: INSTALL_DIR });
  process.exit(result.status || 0);
}

function update() {
  ensureInstalled();
  const result = run('bash', [path.join('scripts', 'update.sh')], { cwd: INSTALL_DIR });
  process.exit(result.status || 0);
}

function health() {
  ensureInstalled();
  const result = run('bash', [path.join('scripts', 'health-check.sh')], { cwd: INSTALL_DIR });
  process.exit(result.status || 0);
}

function uninstall() {
  ensureInstalled();
  const result = run('bash', ['uninstall.sh'], { cwd: INSTALL_DIR });
  process.exit(result.status || 0);
}

function printHelp() {
  console.log(`
praxis-harness v${VERSION}

Usage: npx praxis-harness [command]

Commands:
  install     Clone repo to ~/.praxis and run bootstrap (default)
  update      Pull latest and re-link
  health      Run health check
  uninstall   Remove Praxis symlinks from ~/.claude/

Flags:
  --help, -h      Show this help
  --version, -v   Show version
`);
}

// --- Main ---
const arg = process.argv[2] || 'install';
const commands = { install, update, health, uninstall };

if (arg === '--help' || arg === '-h') { printHelp(); }
else if (arg === '--version' || arg === '-v') { console.log(VERSION); }
else if (commands[arg]) { commands[arg](); }
else { fail('Unknown command: ' + arg); printHelp(); process.exit(1); }
