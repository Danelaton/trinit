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

The installer has detection logic at each step to avoid unnecessary work. When run interactively (no skip/yes flags, real terminal), it first shows an arrow-key menu to choose the installation profile, then runs only the selected steps.

```mermaid
flowchart TD
    A["▶ Start\nirm ... | iex\ncurl ... | sh"] --> MENU

    subgraph "Profile selection"
        MENU{"Interactive\nconsole?"}
        MENU -->|Yes| M["Show arrow-key menu\nUp/Down + Enter"]
        MENU -->|No - redirected stdin\nor no /dev/tty| DEF["Default = option 3\n(full install)"]
        M --> S1{Option 1?\nExtension only}
        M --> S2{Option 2?\nOllama + Models}
        M --> S3{Option 3?\nFull - default}
    end

    S1 --> SKIP12["Skip Step 1 + 2"]
    S2 --> SKIP3["Skip Step 3"]
    S3 --> ALL["Run all steps"]
    DEF --> ALL
    SKIP12 --> STEP3
    SKIP3 --> STEP1
    ALL --> STEP1

    subgraph "Step 1/3: Ollama"
        STEP1{Is Ollama\non PATH?} -->|Yes| C["✅ Show detected\nversion"]
        STEP1 -->|No| D{"Install\nOllama?"}
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
        L --> M2["Read models.yaml\n(4 models)"]
        M2 --> N{"Is model already\ninstalled?"}
        N -->|Yes| O["✅ Skip"]
        N -->|No| P["ollama pull model"]
        O --> Q
        P --> Q["Next model"]
        Q --> R["✅ All models\nready"]
    end

    subgraph "Step 3/3: VS Code Extension"
        STEP3["Download trinit.vsix\nfrom GitHub Releases"]
        R --> STEP3
        STEP3 --> T["code --install-extension\ntrinit.vsix"]
        T --> U["✅ Setup complete"]
    end

    style I fill:#ff4444,color:#fff
    style U fill:#44aa44,color:#fff
```

### 2.1 Interactive install menu

When the installer is run **without** `--yes`/`-Yes`/`TRINIT_YES=1` and **without** any skip flag, and a real interactive terminal is available, it shows an arrow-key menu:

```
Select installation profile (Up/Down to move, Enter to select):

  > Trinit VS Code Extension
    Ollama + AI Models
    Trinit Extension + Ollama + AI Models (full)
```

| # | Option | Steps executed |
|---|---|---|
| 1 | Trinit VS Code Extension | Step 3 only (extension). |
| 2 | Ollama + AI Models | Steps 1 + 2 (Ollama + models), no extension. |
| 3 | Trinit Extension + Ollama + AI Models (full) | All three steps. **Default** (just press Enter). |

Navigation: **Up/Down** arrows move the `>` selector (with wrap-around), **Enter** confirms. The default selection is option 3, so pressing Enter immediately runs the full install.

**Per-platform behavior:**

- **Windows (`install.ps1`):** the menu uses `$host.UI.RawUI.ReadKey()` to read keystrokes from the console input buffer. It only appears when a real console is attached. Under `irm | iex`, stdin is redirected (`[Console]::IsInputRedirected = True`), so `ReadKey` cannot reliably read keystrokes; the installer detects this and falls back to the default (option 3, full install), printing instructions on how to get the interactive menu (download the script and run `.\install.ps1` directly). If `ReadKey` throws at runtime, it also falls back to option 3.

- **macOS / Linux (`install.sh`):** the menu reads keystrokes directly from `/dev/tty` (opened on file descriptor 3) rather than stdin, because under `curl | sh` stdin is the piped script and cannot be used for interactive input. Arrow keys are detected via their ANSI escape sequences (`ESC [ A` = Up, `ESC [ B` = Down); Enter is `CR` or `LF`. If `/dev/tty` is unavailable (CI, container, no controlling terminal) or reads fail, the installer falls back to a typed numeric menu (`1`/`2`/`3` + Enter read from `/dev/tty`); if that also cannot read input, it falls back to non-interactive full install (option 3).

The menu only decides **which** steps run; the internal logic of each step (detect / install / update / start Ollama, pull models, install extension) is unchanged.

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

The installer automatically detects whether it is running in non-interactive mode. In that case the **interactive menu is skipped** and option 3 (full install) is assumed:

- **Windows:** stdin redirected (`[Console]::IsInputRedirected = True`, e.g. `irm | iex`) → non-interactive.
- **macOS / Linux:** stdin not a TTY **and** `/dev/tty` not readable (CI, container, no controlling terminal) → non-interactive. Note that under `curl | sh` stdin is the piped script (not a TTY), but `/dev/tty` is still the user's terminal, so the menu **can** still be shown — non-interactive mode is only forced when there is no `/dev/tty` at all.

In non-interactive mode:

- **Ollama not installed:** installs automatically (default: Yes)
- **Ollama installed:** does not update (default: No)
- **Models:** downloads all missing ones without asking
- **Menu:** skipped, option 3 (full install) assumed

To explicitly force non-interactive mode (skip the menu, assume option 3):

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

A step can be skipped either because a skip flag was passed, or because the interactive menu selected a profile that excludes it. The message is the same in both cases:

```
[1/3] Ollama step skipped
[2/3] Model pull step skipped
[3/3] Installing Trinit VS Code extension...
```

When the menu is shown, the selected option is also printed:

```
Select installation profile (Up/Down to move, Enter to select):
  > Trinit VS Code Extension
    Ollama + AI Models
    Trinit Extension + Ollama + AI Models (full)

Selected: option 1
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
