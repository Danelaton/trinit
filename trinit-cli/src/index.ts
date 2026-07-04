import { OllamaClient, ModelManager, ModelDefinition } from 'trinit-core';
import * as path from 'path';
import * as os from 'os';
import * as readline from 'readline';
import { execSync, spawnSync } from 'child_process';

const MANIFEST_PATH = path.resolve(__dirname, '..', '..', 'models.yaml');
const OLLAMA_URL = 'http://localhost:11434';

const client = new OllamaClient(OLLAMA_URL);
const manager = new ModelManager(client, MANIFEST_PATH);

const RED = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';

function log(msg: string, color = '') {
  console.log(`${color}${msg}${RESET}`);
}

// ── Interactive prompts (non-interactive-safe) ───────────────

const NON_INTERACTIVE =
  process.argv.includes('--yes') ||
  process.argv.includes('-y') ||
  process.env.TRINIT_YES === '1' ||
  !process.stdin.isTTY;

function readYesNo(promptText: string, defaultYes: boolean): Promise<boolean> {
  const suffix = defaultYes ? '[Y/n]' : '[y/N]';
  if (NON_INTERACTIVE) {
    log(`${promptText} ${suffix} (non-interactive, using default)`, YELLOW);
    return Promise.resolve(defaultYes);
  }
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => {
    rl.question(`${promptText} ${suffix} `, (answer) => {
      rl.close();
      const trimmed = answer.trim();
      if (!trimmed) {
        resolve(defaultYes);
        return;
      }
      resolve(/^(y|yes)$/i.test(trimmed));
    });
  });
}

function getOllamaVersion(): string | null {
  try {
    const out = execSync('ollama --version', { encoding: 'utf-8' });
    const match = out.match(/([0-9]+\.[0-9]+\.[0-9]+)/);
    return match ? match[1] : null;
  } catch {
    return null;
  }
}

function isOllamaOnPath(): boolean {
  try {
    execSync(os.platform() === 'win32' ? 'where ollama' : 'command -v ollama', {
      stdio: 'ignore',
    });
    return true;
  } catch {
    return false;
  }
}

function banner() {
  console.log(`
${CYAN}${BOLD}  ╔══════════════════════════════════╗
  ║         T R I N I T              ║
  ║   Local LLMs + AI Agent Teams    ║
  ╚══════════════════════════════════╝${RESET}
`);
}

// ── Commands ──────────────────────────────────────────────

async function cmdStatus() {
  banner();

  // Check Ollama
  log('🔍 Checking Ollama...', CYAN);
  const health = await client.health();
  if (health.running) {
    log(`   ✅ Ollama running${health.version ? ` (v${health.version})` : ''}`, GREEN);
  } else {
    log(`   ❌ Ollama not running — ${health.error || 'install it first'}`, RED);
    log(`   👉 Run: trinit install`, YELLOW);
    return;
  }

  // Check models
  log('\n📦 Installed models:', CYAN);
  const status = await manager.modelStatus();
  for (const s of status) {
    const icon = s.installed ? '✅' : '❌';
    const color = s.installed ? GREEN : RED;
    log(`   ${icon} ${s.model.ollama_ref.padEnd(20)} ${s.model.size.padStart(8)}  — ${s.model.description}`, color);
  }

  const installed = status.filter((s) => s.installed).length;
  const total = status.length;
  log(`\n   ${installed}/${total} models installed`, installed === total ? GREEN : YELLOW);
}

function runOfficialInstaller() {
  const platform = os.platform();
  if (platform === 'win32') {
    log('   Running Windows installer...');
    try {
      execSync('powershell -Command "irm https://ollama.com/install.ps1 | iex"', {
        stdio: 'inherit',
        cwd: os.homedir(),
      });
    } catch {
      log('   ⚠️  Ollama install may have completed with warnings. Check manually if needed.', YELLOW);
    }
  } else if (platform === 'darwin') {
    log('   Running macOS installer...');
    execSync('curl -fsSL https://ollama.com/install.sh | sh', { stdio: 'inherit' });
  } else {
    log('   Running Linux installer...');
    execSync('curl -fsSL https://ollama.com/install.sh | sh', { stdio: 'inherit' });
  }
}

async function waitForOllamaDaemon() {
  log('\n⏳ Waiting for Ollama daemon...', CYAN);
  let attempts = 0;
  while (attempts < 30) {
    const running = await client.check();
    if (running) {
      log('   ✅ Ollama daemon ready', GREEN);
      return;
    }
    await new Promise((r) => setTimeout(r, 1000));
    attempts++;
  }
  log('   ⚠️  Could not confirm Ollama daemon is running — continuing anyway', YELLOW);
}

async function cmdInstall() {
  banner();
  log('🔍 Checking for Ollama...', CYAN);

  const onPath = isOllamaOnPath();

  if (onPath) {
    const version = getOllamaVersion();
    log(`   ✅ Ollama ${version || '(version unknown)'} detected`, GREEN);

    const doUpdate = await readYesNo('   Update it?', false);
    if (doUpdate) {
      log('📥 Updating Ollama...', CYAN);
      const platform = os.platform();
      try {
        if (platform === 'win32') {
          execSync('winget upgrade --id Ollama.Ollama --silent --accept-package-agreements --accept-source-agreements', {
            stdio: 'inherit',
          });
        } else if (platform === 'darwin') {
          try {
            execSync('brew upgrade ollama', { stdio: 'inherit' });
          } catch {
            runOfficialInstaller();
          }
        } else {
          runOfficialInstaller();
        }
        log('   ✅ Ollama updated', GREEN);
      } catch {
        log('   ⚠️  Update may have failed. Continuing with existing install.', YELLOW);
      }
    } else {
      log('   Skipping update, continuing with existing install', GREEN);
    }
  } else {
    const doInstall = await readYesNo(
      "   Ollama is required for Trinit's local mode. Install it now?",
      true
    );
    if (!doInstall) {
      log('\n❌ Trinit local mode requires Ollama to run local models.', RED);
      log('   Install manually from https://ollama.com/download, then re-run this command.', YELLOW);
      process.exit(1);
    }
    log('📥 Installing Ollama...', CYAN);
    runOfficialInstaller();
    log('   ✅ Ollama installed', GREEN);
  }

  await waitForOllamaDaemon();
}

async function cmdPull(modelName?: string) {
  banner();

  const running = await client.check();
  if (!running) {
    log('❌ Ollama is not running. Run: trinit install', RED);
    return;
  }

  if (modelName) {
    // Pull specific model
    const models = manager.getModels();
    const model = models.find(
      (m) => m.ollama_ref === modelName || m.name === modelName || m.ollama_ref.startsWith(modelName)
    );
    if (!model) {
      log(`❌ Model "${modelName}" not found in manifest`, RED);
      log('   Available models:', YELLOW);
      for (const m of models) {
        log(`   • ${m.ollama_ref}`, CYAN);
      }
      return;
    }
    log(`📥 Pulling ${model.ollama_ref} (${model.size})...`, CYAN);
    await manager.pullModel(model, (progress) => {
      if (progress.status) {
        process.stdout.write(`\r   ${progress.status.padEnd(60)}`);
      }
    });
    console.log('');
    log(`   ✅ ${model.ollama_ref} pulled successfully`, GREEN);
  } else {
    // Pull all (skip models already installed)
    log('📥 Pulling all models from manifest...', CYAN);
    const models = manager.getModels();
    const installed = await manager.getInstalledModels();
    log(`   ${models.length} models defined\n`, YELLOW);

    for (const model of models) {
      if (installed.has(model.ollama_ref)) {
        log(`   ✅ ${model.ollama_ref} already installed`, GREEN);
        continue;
      }

      log(`\n📥 ${model.ollama_ref} (${model.size})`, CYAN);
      log(`   ${model.description}`, YELLOW);

      try {
        await manager.pullModel(model, (progress) => {
          if (progress.status) {
            process.stdout.write(`\r   ${progress.status.padEnd(60)}`);
          }
        });
        console.log('');
        log(`   ✅ Done`, GREEN);
      } catch (err: any) {
        log(`   ❌ Failed: ${err.message}`, RED);
      }
    }

    log('\n🎉 All models processed', GREEN);
  }
}

async function cmdList() {
  banner();
  const running = await client.check();
  if (!running) {
    log('❌ Ollama is not running', RED);
    return;
  }

  const response = await client.listModels();
  log('📦 Installed models:', CYAN);
  if (response.models.length === 0) {
    log('   (none)', YELLOW);
    log('   👉 Run: trinit pull', YELLOW);
    return;
  }
  for (const model of response.models) {
    const sizeGB = (model.size / 1e9).toFixed(1);
    log(`   • ${model.name.padEnd(25)} ${sizeGB} GB`, GREEN);
  }
}

async function cmdSetup() {
  banner();
  log('🚀 Trinit Full Setup\n', BOLD + CYAN);

  // Step 1: Install Ollama
  const health = await client.health();
  if (!health.running) {
    log('Step 1/3: Installing Ollama...', CYAN);
    await cmdInstall();
  } else {
    log('Step 1/3: ✅ Ollama already running', GREEN);
  }

  // Step 2: Pull models
  log('\nStep 2/3: Pulling models...', CYAN);
  await cmdPull();

  // Step 3: VS Code extension
  log('\nStep 3/3: Installing Trinit VS Code extension...', CYAN);
  try {
    execSync('code --install-extension trinit.trinit-vscode', { stdio: 'inherit' });
    log('   ✅ Extension installed (or marketplace pending)', GREEN);
  } catch {
    log('   ⚠️  Could not auto-install extension', YELLOW);
    log('   👉 Install manually from VS Code Marketplace: "Trinit"', YELLOW);
  }

  log('\n🎉 Trinit setup complete!', BOLD + GREEN);
  log('   Open VS Code and look for the Trinit sidebar.', CYAN);
}

// ── Main ──────────────────────────────────────────────────

async function main() {
  const args = process.argv.slice(2);
  const cmd = args[0] || 'status';

  switch (cmd) {
    case 'status':
      await cmdStatus();
      break;
    case 'install':
      await cmdInstall();
      break;
    case 'pull':
      await cmdPull(args[1]);
      break;
    case 'list':
      await cmdList();
      break;
    case 'setup':
      await cmdSetup();
      break;
    default:
      log(`Unknown command: ${cmd}`, RED);
      log('Commands: setup, install, pull [model], list, status', YELLOW);
  }
}

main().catch((err) => {
  log(`\n❌ Error: ${err.message}`, RED);
  process.exit(1);
});
