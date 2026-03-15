#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');
const readline = require('readline');

// ── Paths ────────────────────────────────────────────────────────────────────

const PKG_DIR = path.resolve(__dirname, '..');
const PRAXIS_HOME = path.join(os.homedir(), '.praxis');
const CLAUDE_DIR = path.join(os.homedir(), '.claude');
const CONFIG_FILE = path.join(CLAUDE_DIR, 'praxis.config.json');
const VERSION_FILE = path.join(PRAXIS_HOME, '.version');
const PKG = JSON.parse(fs.readFileSync(path.join(PKG_DIR, 'package.json'), 'utf8'));

// Content directories to copy from package → ~/.praxis/
const CONTENT_DIRS = ['base', 'kits', 'templates', 'docs'];

// Symlinks: source (relative to PRAXIS_HOME) → destination (relative to CLAUDE_DIR)
const SYMLINKS = [
  { src: 'base/CLAUDE.md', dst: 'CLAUDE.md' },
  { src: 'base/rules',     dst: 'rules' },
  { src: 'base/commands',  dst: 'commands' },
  { src: 'base/skills',    dst: 'skills' },
];

// ── Logging ──────────────────────────────────────────────────────────────────

function log(icon, msg) {
  console.log(`  ${icon} ${msg}`);
}

// ── Helpers ──────────────────────────────────────────────────────────────────

function copyDirSync(src, dst) {
  fs.mkdirSync(dst, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const dstPath = path.join(dst, entry.name);
    if (entry.isDirectory()) {
      copyDirSync(srcPath, dstPath);
    } else {
      fs.copyFileSync(srcPath, dstPath);
    }
  }
}

function ensureSymlink(src, dst) {
  if (fs.lstatSync(dst, { throwIfNoEntry: false })?.isSymbolicLink()) {
    const current = fs.readlinkSync(dst);
    if (current === src) {
      log('\u2713', `${dst} (already linked)`);
      return;
    }
    fs.unlinkSync(dst);
  } else if (fs.existsSync(dst)) {
    log('\u26A0', `${dst} exists and is not a symlink \u2014 skipping (back up manually)`);
    return;
  }
  fs.symlinkSync(src, dst);
  log('\u2192', `${dst}`);
}

function removeSymlink(dst) {
  if (fs.lstatSync(dst, { throwIfNoEntry: false })?.isSymbolicLink()) {
    fs.unlinkSync(dst);
    log('\u2717', `Removed ${dst}`);
  } else if (fs.existsSync(dst)) {
    log('\u26A0', `${dst} is not a symlink \u2014 skipping`);
  } else {
    log('\u00B7', `${dst} not found \u2014 nothing to do`);
  }
}

function rmDirSync(dir) {
  if (fs.existsSync(dir)) {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

function readConfig() {
  try {
    return JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
  } catch {
    return {};
  }
}

function writeConfig(config) {
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2) + '\n');
}

function commandExists(cmd) {
  try {
    execSync(`command -v ${cmd}`, { stdio: 'pipe' });
    return true;
  } catch {
    return false;
  }
}

function ask(question) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

// ── Flag parsing ─────────────────────────────────────────────────────────────

function parseFlags(args) {
  const flags = { _: [] };
  let i = 0;
  while (i < args.length) {
    const arg = args[i];
    if (arg === '--vault' && args[i + 1]) {
      flags.vault = args[++i];
    } else if (arg === '--perplexity-key' && args[i + 1]) {
      flags.perplexityKey = args[++i];
    } else if (arg === '--org' && args[i + 1]) {
      flags.org = args[++i];
    } else if (arg === '--no-mcp') {
      flags.noMcp = true;
    } else if (arg === '--yes' || arg === '-y') {
      flags.yes = true;
    } else if (!arg.startsWith('-')) {
      flags._.push(arg);
    }
    i++;
  }
  // Env var fallbacks
  if (!flags.vault) flags.vault = process.env.PRAXIS_VAULT_PATH || '';
  if (!flags.perplexityKey) flags.perplexityKey = process.env.PERPLEXITY_API_KEY || '';
  if (!flags.org) flags.org = process.env.AZURE_DEVOPS_ORG || '';
  return flags;
}

// ── Commands ─────────────────────────────────────────────────────────────────

async function cmdInstall(flags) {
  console.log('');
  console.log('=== Praxis Installer ===');
  console.log('');

  // 1. Copy content to ~/.praxis/
  console.log(`Copying content to ${PRAXIS_HOME}/ \u2026`);
  for (const dir of CONTENT_DIRS) {
    const src = path.join(PKG_DIR, dir);
    if (fs.existsSync(src)) {
      copyDirSync(src, path.join(PRAXIS_HOME, dir));
      log('\u2713', `Copied ${dir}/`);
    }
  }
  fs.writeFileSync(VERSION_FILE, PKG.version);
  log('\u2713', `Version ${PKG.version}`);
  console.log('');

  // 2. Create symlinks in ~/.claude/
  console.log(`Linking into ${CLAUDE_DIR}/ \u2026`);
  fs.mkdirSync(CLAUDE_DIR, { recursive: true });
  for (const { src, dst } of SYMLINKS) {
    ensureSymlink(
      path.join(PRAXIS_HOME, src),
      path.join(CLAUDE_DIR, dst)
    );
  }
  console.log('');

  // 3. Config — vault path
  const existing = readConfig();
  let vaultPath = flags.vault;

  if (!vaultPath && !existing.vault_path) {
    if (process.stdin.isTTY && !flags.yes) {
      vaultPath = await ask('Obsidian vault path (e.g. ~/Documents/Obsidian): ');
      // Expand ~
      if (vaultPath.startsWith('~')) {
        vaultPath = path.join(os.homedir(), vaultPath.slice(1));
      }
    }
  }

  if (vaultPath) {
    // Expand ~ if provided via flag
    if (vaultPath.startsWith('~')) {
      vaultPath = path.join(os.homedir(), vaultPath.slice(1));
    }
    existing.vault_path = vaultPath;
    if (!fs.existsSync(vaultPath)) {
      log('\u26A0', `Directory does not exist: ${vaultPath}`);
      log(' ', 'Create it before using vault features.');
    }
  }

  if (Object.keys(existing).length > 0) {
    writeConfig(existing);
    log('\u2713', `Wrote ${CONFIG_FILE}`);
  } else {
    log('\u2218', 'No vault path configured (use --vault to set later)');
  }
  console.log('');

  // 4. MCP registration
  if (!flags.noMcp) {
    console.log('MCP servers \u2026');
    if (commandExists('claude')) {
      if (flags.perplexityKey) {
        try {
          execSync(
            `claude mcp add perplexity --scope user -e PERPLEXITY_API_KEY="${flags.perplexityKey}" -- npx -yq @perplexity-ai/mcp-server`,
            { stdio: 'pipe' }
          );
          log('\u2713', 'Registered MCP: perplexity');
        } catch (err) {
          log('\u26A0', 'MCP registration failed: perplexity');
          log(' ', 'Register manually: claude mcp add perplexity --scope user -e PERPLEXITY_API_KEY="your-key" -- npx -yq @perplexity-ai/mcp-server');
        }
      } else {
        log('\u2218', 'Skipped MCP: perplexity (no API key \u2014 use --perplexity-key or PERPLEXITY_API_KEY)');
      }
    } else {
      log('\u26A0', "'claude' CLI not found \u2014 skipped MCP registration. Install Claude Code first.");
    }
    console.log('');
  }

  console.log('=== Done ===');
  console.log('To activate a kit: /kit:web-designer');
  console.log('');
}

async function cmdUpdate(flags) {
  console.log('');
  console.log('=== Praxis Update ===');
  console.log('');

  // Check if already installed
  if (!fs.existsSync(PRAXIS_HOME)) {
    console.log('Praxis is not installed. Run: npx praxis-harness install');
    process.exit(1);
  }

  // Read old version
  let oldVersion = 'unknown';
  try { oldVersion = fs.readFileSync(VERSION_FILE, 'utf8').trim(); } catch {}

  // Re-copy content
  console.log(`Updating ${PRAXIS_HOME}/ \u2026`);
  for (const dir of CONTENT_DIRS) {
    const src = path.join(PKG_DIR, dir);
    if (fs.existsSync(src)) {
      copyDirSync(src, path.join(PRAXIS_HOME, dir));
      log('\u2713', `Updated ${dir}/`);
    }
  }
  fs.writeFileSync(VERSION_FILE, PKG.version);
  console.log('');

  // Verify symlinks
  console.log('Verifying symlinks \u2026');
  fs.mkdirSync(CLAUDE_DIR, { recursive: true });
  for (const { src, dst } of SYMLINKS) {
    ensureSymlink(
      path.join(PRAXIS_HOME, src),
      path.join(CLAUDE_DIR, dst)
    );
  }
  console.log('');

  console.log(`=== Updated: ${oldVersion} \u2192 ${PKG.version} ===`);
  console.log('');
}

async function cmdUninstall(flags) {
  console.log('');
  console.log('=== Praxis Uninstaller ===');
  console.log('');

  // Remove symlinks
  console.log('Removing symlinks \u2026');
  for (const { dst } of SYMLINKS) {
    removeSymlink(path.join(CLAUDE_DIR, dst));
  }
  console.log('');

  // Remove ~/.praxis/
  if (fs.existsSync(PRAXIS_HOME)) {
    rmDirSync(PRAXIS_HOME);
    log('\u2717', `Removed ${PRAXIS_HOME}/`);
  }
  console.log('');

  console.log(`Config preserved: ${CONFIG_FILE}`);
  console.log('Delete it manually if you want a clean slate.');
  console.log('');
  console.log('=== Done ===');
  console.log('');
}

async function cmdKit(flags) {
  const subCmd = flags._[1];
  const kitName = flags._[2];

  if (subCmd === 'list' || !subCmd) {
    console.log('');
    console.log('Available kits:');
    console.log('');
    const kitsDir = path.join(PRAXIS_HOME, 'kits');
    if (!fs.existsSync(kitsDir)) {
      console.log('  No kits installed. Run: npx praxis-harness install');
      return;
    }
    for (const entry of fs.readdirSync(kitsDir, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        const kitMd = path.join(kitsDir, entry.name, 'KIT.md');
        let desc = '';
        if (fs.existsSync(kitMd)) {
          const content = fs.readFileSync(kitMd, 'utf8');
          const match = content.match(/^>\s*(.+)/m);
          if (match) desc = ` \u2014 ${match[1]}`;
        }
        console.log(`  ${entry.name}${desc}`);
      }
    }
    console.log('');
    console.log('Activate in Claude Code: /kit:<name>');
    console.log('');
    return;
  }

  if (subCmd === 'install') {
    if (!kitName) {
      console.error('Usage: praxis-harness kit install <name>');
      process.exit(1);
    }
    const kitInstall = path.join(PRAXIS_HOME, 'kits', kitName, 'install.sh');
    if (!fs.existsSync(kitInstall)) {
      console.error(`Kit not found or has no install script: ${kitName}`);
      process.exit(1);
    }
    console.log(`Installing kit: ${kitName} \u2026`);
    try {
      // Build extra args for kit install scripts
      const extraArgs = [];
      if (flags.org) extraArgs.push('--org', flags.org);
      const argsStr = extraArgs.length > 0 ? ' ' + extraArgs.map(a => `"${a}"`).join(' ') : '';
      execSync(`bash "${kitInstall}"${argsStr}`, { stdio: 'inherit' });
    } catch (err) {
      log('\u26A0', `Kit install failed: ${kitName}`);
      process.exit(1);
    }
    return;
  }

  console.error(`Unknown kit command: ${subCmd}`);
  console.error('Usage: praxis-harness kit [list|install <name>]');
  process.exit(1);
}

async function cmdStatus() {
  console.log('');
  console.log('=== Praxis Status ===');
  console.log('');

  // Version
  let version = 'not installed';
  try { version = fs.readFileSync(VERSION_FILE, 'utf8').trim(); } catch {}
  console.log(`  Version: ${version}`);
  console.log(`  Home:    ${PRAXIS_HOME}`);
  console.log('');

  // Symlinks
  console.log('Symlinks:');
  for (const { src, dst } of SYMLINKS) {
    const dstPath = path.join(CLAUDE_DIR, dst);
    const srcPath = path.join(PRAXIS_HOME, src);
    if (fs.lstatSync(dstPath, { throwIfNoEntry: false })?.isSymbolicLink()) {
      const target = fs.readlinkSync(dstPath);
      const ok = target === srcPath;
      log(ok ? '\u2713' : '\u26A0', `${dstPath} \u2192 ${target}`);
    } else if (fs.existsSync(dstPath)) {
      log('\u26A0', `${dstPath} (exists but not a symlink)`);
    } else {
      log('\u2717', `${dstPath} (missing)`);
    }
  }
  console.log('');

  // Config
  console.log('Config:');
  const config = readConfig();
  if (Object.keys(config).length > 0) {
    for (const [k, v] of Object.entries(config)) {
      log('\u00B7', `${k}: ${v}`);
    }
  } else {
    log('\u00B7', 'No config file');
  }
  console.log('');
}

// ── Main ─────────────────────────────────────────────────────────────────────

function printUsage() {
  console.log(`
praxis-harness v${PKG.version}

Usage:
  praxis-harness install [options]    Install Praxis harness
  praxis-harness update               Update to latest version
  praxis-harness uninstall             Remove Praxis harness
  praxis-harness kit list              List available kits
  praxis-harness kit install <name>    Install a kit's MCP servers
  praxis-harness status                Show installation status

Options:
  --vault <path>            Obsidian vault path (or PRAXIS_VAULT_PATH env var)
  --perplexity-key <key>    Perplexity API key (or PERPLEXITY_API_KEY env var)
  --org <name>              Azure DevOps org (or AZURE_DEVOPS_ORG env var, for kit install azure)
  --no-mcp                  Skip MCP server registration
  --yes, -y                 Skip confirmation prompts
  --help, -h                Show this help
`);
}

async function main() {
  const args = process.argv.slice(2);
  const flags = parseFlags(args);
  const cmd = flags._[0];

  if (!cmd || args.includes('--help') || args.includes('-h')) {
    printUsage();
    process.exit(0);
  }

  switch (cmd) {
    case 'install':  await cmdInstall(flags); break;
    case 'update':   await cmdUpdate(flags); break;
    case 'uninstall': await cmdUninstall(flags); break;
    case 'kit':      await cmdKit(flags); break;
    case 'status':   await cmdStatus(); break;
    default:
      console.error(`Unknown command: ${cmd}`);
      printUsage();
      process.exit(1);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
