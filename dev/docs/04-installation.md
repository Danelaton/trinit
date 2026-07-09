# Trinit — Installation Experience

> Version: v0.1.0 · Date: 2026-07-04  
> Source: `install.ps1`, `install.sh`, `trinit-cli/src/index.ts`, `models.yaml`

---

## 1. One-liner per platform

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex
```

### macOS / Linux (bash/sh)

```bash
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh
```

That's it. One command installs Ollama (if absent), downloads the 4 models, and configures the VS Code extension.

---

## 2. Smart installer flow

The installer has detection logic at each step to avoid unnecessary work:

```mermaid
flowchart TD
    A["▶ Start\nirm ... | iex\ncurl ... | sh"] --> B

    subgraph "Step 1/3: Ollama"
        B{Is Ollama\non PATH?} -->|Yes| C["✅ Show detected\nversion"]
        B -->|No| D{"Install\nOllama?"}
        C --> E{"Update?"}
        E -->|Yes| F["winget upgrade /\nbrew upgrade /\ncurl install.sh"]
        E -->|No| G["Continue with\nexisting version"]
        D -->|Yes| H["Install Ollama\nfrom ollama.com"]
        D -->|No| I["❌ Exit\n(Ollama required)"]
        F --> J
        G --> J
        H --> J
        J{"Is Ollama\nrunning?"}
        J -->|No| K["ollama serve\nin background"]
        J -->|Yes| L["✅ Ready"]
        K --> L
    end

    subgraph "Step 2/3: Models"
        L --> M["Read models.yaml\n(4 models)"]
        M --> N{"Is model already\ninstalled?"}
        N -->|Yes| O["✅ Skip"]
        N -->|No| P["ollama pull model"]
        O --> Q
        P --> Q["Next model"]
        Q --> R["✅ All models\nready"]
    end

    subgraph "Step 3/3: VS Code Extension"
        R --> S["Download trinit.vsix\nfrom GitHub Releases"]
        S --> T["code --install-extension\ntrinit.vsix"]
        T --> U["✅ Setup complete"]
    end

    style I fill:#ff4444,color:#fff
    style U fill:#44aa44,color:#fff
```

---

## 3. What it installs exactly

### Step 1: Ollama

| Action | Condition |
|---|---|
| Detect Ollama on PATH | Always |
| Show detected version | If Ollama is installed |
| Ask to update | If Ollama is installed (default: No) |
| Install Ollama | If not installed (default: Yes) |
| Start `ollama serve` | If Ollama is not running |
| Wait up to 15 seconds | Until `http://localhost:11434` responds |

**Ollama installation methods per platform:**
- **Windows:** `winget upgrade --id Ollama.Ollama` (with fallback to `irm https://ollama.com/install.ps1 | iex`)
- **macOS:** `brew upgrade ollama` (with fallback to `curl -fsSL https://ollama.com/install.sh | sh`)
- **Linux:** `curl -fsSL https://ollama.com/install.sh | sh`

### Step 2: Models

The installer reads `models.yaml` to get the list of models. If it cannot read the file, it uses a hardcoded fallback list:

```
glm-ocr:latest   (2.2 GB)
gemma4:e2b       (7.2 GB)
gemma4:e4b       (9.6 GB)
ornith:9b        (5.6 GB)
```

For each model:
1. Queries `ollama list` to see if it is already installed
2. If installed: shows `✅ already installed` and continues
3. If not installed: runs `ollama pull <model>` with a progress bar

**Estimated download time** (100 Mbps connection):
- `glm-ocr:latest`: ~3 minutes
- `ornith:9b`: ~7 minutes
- `gemma4:e2b`: ~9 minutes
- `gemma4:e4b`: ~12 minutes
- **Total (first install):** ~30 minutes

### Step 3: VS Code extension

1. Downloads `trinit.vsix` from `https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix`
2. Runs `code --install-extension trinit.vsix`
3. Deletes the temporary `.vsix` file

**Artifact size:** `trinit.vsix` is **34,083,603 bytes (~34 MB)** — verified with HTTP 200 + `Content-Length` on the v0.1.0 release asset.

**Requirement:** VS Code must be installed and the `code` command available on PATH.

---

## 4. Non-interactive mode

The installer automatically detects whether it is running in non-interactive mode (when stdin is not a TTY, as happens when piping with `irm | iex` or `curl | sh`). In that case:

- **Ollama not installed:** installs automatically (default: Yes)
- **Ollama installed:** does not update (default: No)
- **Models:** downloads all missing ones without asking

To explicitly force non-interactive mode:

```powershell
# Windows
irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex -Yes
# or
$env:TRINIT_YES = "1"; irm ... | iex
```

```bash
# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --yes
# or
TRINIT_YES=1 curl -fsSL ... | sh
```

---

## 5. Skip flags — install only the extension

For users who already have Ollama + models set up, or who only want the VS Code extension, the installer exposes two skip flags. They can be combined with each other and with `--yes` / `-Yes`.

| Flag (Windows) | Flag (macOS/Linux) | Effect |
|---|---|---|
| `-SkipOllama` | `--skip-ollama` | Skips Step 1 entirely: no detect / install / update / start of Ollama. |
| `-SkipModels` | `--skip-models` | Skips Step 2 entirely: no `ollama pull` of any model. |

When **both** flags are set, the installer jumps straight to Step 3 (VS Code extension only) and prints which steps were skipped.

### Windows (PowerShell)

Custom parameters do **not** work with `irm | iex` directly, because the pipe consumes stdin and PowerShell cannot pass arguments through `iex` to the streamed script. Download the script first, then run it with flags:

```powershell
irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 -OutFile install.ps1
.\install.ps1 -SkipOllama -SkipModels -Yes   # extension only
.\install.ps1 -SkipOllama -Yes               # still pulls models
.\install.ps1 -SkipModels -Yes               # still installs/updates Ollama
```

### macOS / Linux (bash)

Flags are passed through the pipe with `sh -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --skip-ollama --skip-models --yes
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --skip-ollama --yes
curl -fsSL https://raw.githubusercontent.com/Danelaton/trinit/main/install.sh | sh -s -- --skip-models --yes
```

### What gets printed when a step is skipped

```
[1/3] Ollama step skipped (-SkipOllama)
[2/3] Model pull step skipped (-SkipModels)
[3/3] Installing Trinit VS Code extension...
```

---

## 6. Trinit CLI (trinit-cli)

In addition to the installation scripts, Trinit includes a TypeScript CLI for advanced management:

```bash
# Install the CLI (requires Node.js)
npm install -g trinit-cli

# Available commands
trinit setup          # Full setup (Ollama + models + extension)
trinit install        # Only install/update Ollama
trinit pull           # Download all models from the manifest
trinit pull ornith:9b # Download a specific model
trinit list           # List models installed in Ollama
trinit status         # Status of Ollama and models
```

The CLI uses `trinit-core` (internal library) which exposes `OllamaClient` and `ModelManager` to interact with Ollama programmatically.

---

## 7. First extension activation

When opening VS Code after installation, the extension automatically performs:

1. **MCP seeding:** Writes 5 predefined MCP servers to `mcp_settings.json` (only if no servers are configured)
2. **Model profile seeding:** Creates Ollama profiles for each mode (`trinit-local-architect`, `trinit-local-ocr`, etc.)
3. **Mode binding:** Sets `modeApiConfigs` for each mode with its corresponding local model
4. **Full Local lock:** Initializes `modeApiConfigLocks` with all modes locked

All of this happens in the background during activation, without interrupting the user.

---

## 8. Common troubleshooting

### "code: command not found"

VS Code is not on PATH. Solutions:
- **Windows:** Reinstall VS Code checking "Add to PATH"
- **macOS:** Open VS Code → Command Palette → "Shell Command: Install 'code' command in PATH"
- **Linux:** Verify that `/usr/bin/code` or `/usr/local/bin/code` exists

### "Ollama installed but not running"

The installer tries to start Ollama automatically. If it fails:

```bash
# macOS/Linux
ollama serve &

# Windows (PowerShell)
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
```

### "Could not read models.yaml"

Happens when the installer is run from a directory different from the repository's. The installer has a hardcoded fallback with the 4 models, so installation continues normally.

### Partially downloaded model

If a download is interrupted, `ollama pull` can resume it. Simply run again:

```bash
ollama pull ornith:9b
```

### The extension does not appear in VS Code

1. Verify the installation completed: `code --list-extensions | grep trinit`
2. Reload VS Code: `Ctrl+Shift+P` → "Developer: Reload Window"
3. Reinstall manually: download `trinit.vsix` from GitHub Releases and run `code --install-extension trinit.vsix`

### Ollama not responding on `localhost:11434`

```bash
# Verify Ollama is running
curl http://localhost:11434

# If it doesn't respond, start it manually
ollama serve
```

### Insufficient disk space

The 4 models require ~24.5 GB. To install only the essential models:

```bash
# Only OCR and coding (minimum functional)
ollama pull glm-ocr:latest   # 2.2 GB
ollama pull ornith:9b        # 5.6 GB
# Total: ~7.8 GB
```

Then manually configure the `ask` mode to use `ornith:9b` instead of `gemma4:e2b`.

### Localized (non-English) output from winget

On a Windows whose display language is not English, `winget` emits its own messages in that language (e.g. Spanish: `No se ha encontrado ninguna actualización disponible`). This text comes from winget itself, not from the Trinit installer. winget's `--locale` flag only affects the Winget settings UI / BCP47 parsing and does **not** force English command output.

The installer captures winget's native output and emits its own English messages instead (`Ollama already up to date` / `Ollama updated` / `winget upgrade did not complete, falling back...`), so the installer log stays in English regardless of the OS language.

### `[DEP0169] DeprecationWarning: url.parse()` during extension install

This warning is printed by **VS Code's own bundled Node** when running `code --install-extension`. The `code` launcher shim runs VS Code's `Code.exe` with `ELECTRON_RUN_AS_NODE=1` executing its internal `cli.js`, which still uses the legacy `url.parse()` API. It is **not** from Trinit code — `trinit-cli` and `trinit-core` use the modern `new URL(...)` API and contain no `url.parse()` calls.

The installer scopes `NODE_OPTIONS=--no-deprecation` to the `code --install-extension` invocation only, so this third-party warning is silenced without hiding deprecation warnings from Trinit's own code.
