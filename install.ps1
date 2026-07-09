# Trinit One-Liner Installer -- Windows
# Run: irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex
#
# Non-interactive mode: pass -Yes (or set $env:TRINIT_YES = "1") to assume defaults
# (install Ollama if missing, do NOT update if already present) so the one-liner
# never hangs waiting for input, e.g.:
#   irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex -Yes
# Note: when piped through `irm | iex`, stdin is never a TTY, so prompts are
# automatically skipped and defaults are used even without -Yes.
#
# Skip flags (useful when Ollama + models are already set up, or you only want
# the VS Code extension). Custom params do NOT work with `irm | iex` directly
# because the pipe consumes stdin; download the script first, then run it:
#   irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 -OutFile install.ps1
#   .\install.ps1 -SkipOllama -SkipModels -Yes
#   .\install.ps1 -SkipOllama            # still pulls models
#   .\install.ps1 -SkipModels            # still installs/updates Ollama
#   .\install.ps1 -SkipOllama -SkipModels  # extension only

param(
    [switch]$Yes,
    [switch]$SkipOllama,
    [switch]$SkipModels
)

Write-Host "...................................." -ForegroundColor Cyan
Write-Host "      T R I N I T  Setup            " -ForegroundColor Cyan
Write-Host "   Local LLMs + AI Agent Teams      " -ForegroundColor Cyan
Write-Host "...................................." -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# -- Non-interactive detection --
# If stdin isn't a real console (e.g. piped via `irm | iex`), never block on Read-Host.
$NonInteractive = $Yes -or ($env:TRINIT_YES -eq "1") -or ([Console]::IsInputRedirected)

function Read-YesNo {
    param(
        [string]$Prompt,
        [bool]$DefaultYes
    )
    $suffix = if ($DefaultYes) { "[Y/n]" } else { "[y/N]" }
    if ($NonInteractive) {
        Write-Host "$Prompt $suffix (non-interactive, using default)" -ForegroundColor Yellow
        return $DefaultYes
    }
    $answer = Read-Host "$Prompt $suffix"
    if ([string]::IsNullOrWhiteSpace($answer)) {
        return $DefaultYes
    }
    return $answer -match '^(y|yes)$'
}

# -- Resolve models.yaml path (works in BOTH local and remote pipe mode) --
# When run via `irm | iex`, $PSScriptRoot is empty (no physical script file),
# so we cannot use Join-Path $PSScriptRoot "models.yaml". Instead:
#   - If a local models.yaml sits next to this script (local execution), use it.
#   - Otherwise (remote pipe execution), download it from the raw GitHub URL.
$ManifestRawUrl = "https://raw.githubusercontent.com/Danelaton/trinit/main/models.yaml"
function Resolve-ManifestPath {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $local = Join-Path $PSScriptRoot "models.yaml"
        if (Test-Path $local) { return $local }
    }
    $tmp = Join-Path $env:TEMP "trinit-models.yaml"
    try {
        Invoke-WebRequest -Uri $ManifestRawUrl -OutFile $tmp -UseBasicParsing
        if (Test-Path $tmp) { return $tmp }
    } catch {
        Write-Host "       Could not download models.yaml from remote -- will use default model list" -ForegroundColor Yellow
    }
    return $null
}

# -- Step 1: Detect / install / update Ollama --

if ($SkipOllama) {
    Write-Host "[1/3] Ollama step skipped (-SkipOllama)" -ForegroundColor Yellow
} else {
Write-Host "[1/3] Checking for Ollama..." -ForegroundColor Yellow

$ollamaCmd = Get-Command ollama -ErrorAction SilentlyContinue
$ollamaVersion = $null
if ($ollamaCmd) {
    try {
        $versionOutput = & ollama --version 2>&1 | Out-String
        if ($versionOutput -match '([0-9]+\.[0-9]+\.[0-9]+)') {
            $ollamaVersion = $matches[1]
        }
    } catch {
        $ollamaVersion = $null
    }
}

if ($ollamaCmd) {
    if ($ollamaVersion) {
        Write-Host "       Ollama $ollamaVersion detected" -ForegroundColor Green
    } else {
        Write-Host "       Ollama detected (version unknown)" -ForegroundColor Green
    }

    $doUpdate = Read-YesNo -Prompt "       Update Ollama?" -DefaultYes $false
    if ($doUpdate) {
        Write-Host "       Updating Ollama..." -ForegroundColor Yellow
        $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetCmd) {
            # winget emits localized UI text based on the OS display language
            # (e.g. Spanish on a Spanish Windows), and its --locale flag only
            # affects the Winget settings UI / BCP47 parsing -- it does NOT
            # force English output. To keep the installer log consistently in
            # English, we capture winget's native output and emit our own
            # messages based on the exit code.
            $wingetExit = 0
            try {
                $wingetOutput = & winget upgrade --id Ollama.Ollama --silent --accept-package-agreements --accept-source-agreements 2>&1 |
                    Out-String
                $wingetExit = $LASTEXITCODE
            } catch {
                $wingetExit = $LASTEXITCODE
            }
            if ($wingetExit -eq 0) {
                # winget returns 0 both when it upgraded and when no update was
                # available; distinguish by checking if "No update" style text
                # appears in any language. Heuristic: if the output contains no
                # version arrow / "installed" marker, treat as already current.
                $looksLikeNoUpdate = $wingetOutput -match '(No update|no hay versiones|ya est|already)'
                if ($looksLikeNoUpdate) {
                    Write-Host "       Ollama already up to date" -ForegroundColor Green
                } else {
                    Write-Host "       Ollama updated" -ForegroundColor Green
                }
            } else {
                Write-Host "       winget upgrade did not complete (exit $wingetExit), falling back to official installer..." -ForegroundColor Yellow
                irm https://ollama.com/install.ps1 | iex
                Write-Host "       Ollama updated" -ForegroundColor Green
            }
        } else {
            irm https://ollama.com/install.ps1 | iex
            Write-Host "       Ollama updated" -ForegroundColor Green
        }
    } else {
        Write-Host "       Skipping update, continuing with existing install" -ForegroundColor Green
    }
} else {
    $doInstall = Read-YesNo -Prompt "       Ollama is required for Trinit's local mode. Install it now?" -DefaultYes $true
    if ($doInstall) {
        Write-Host "       Installing Ollama..." -ForegroundColor Yellow
        irm https://ollama.com/install.ps1 | iex
        Write-Host "       Ollama installed" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Trinit local mode requires Ollama to run local models." -ForegroundColor Red
        Write-Host "Install it manually from https://ollama.com/download, then re-run this installer." -ForegroundColor Yellow
        exit 1
    }
}

# Make sure the Ollama service/app is actually running (it may be installed
# but not started, e.g. right after a fresh install or if the app was closed).
function Test-OllamaRunning {
    try {
        Invoke-RestMethod -Uri "http://localhost:11434" -TimeoutSec 3 -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-OllamaRunning)) {
    Write-Host "       Ollama installed but not running -- starting it..." -ForegroundColor Yellow
    try {
        Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
    } catch {
        # ignore; some installs run Ollama as a background app/service already
    }
    $attempts = 0
    while ($attempts -lt 15 -and -not (Test-OllamaRunning)) {
        Start-Sleep -Seconds 1
        $attempts++
    }
    if (Test-OllamaRunning) {
        Write-Host "       Ollama is running" -ForegroundColor Green
    } else {
        Write-Host "       Could not confirm Ollama is running -- continuing anyway" -ForegroundColor Yellow
    }
} else {
    Write-Host "       Ollama is running" -ForegroundColor Green
}
} # end if (-not $SkipOllama)

# -- Step 2: Pull models (read list from models.yaml) --

if ($SkipModels) {
    Write-Host "[2/3] Model pull step skipped (-SkipModels)" -ForegroundColor Yellow
} else {
Write-Host "[2/3] Pulling models..." -ForegroundColor Yellow

$manifestPath = Resolve-ManifestPath
$models = @()
if ($manifestPath -and (Test-Path $manifestPath)) {
    $manifestContent = Get-Content $manifestPath -Raw
    $modelMatches = [regex]::Matches($manifestContent, 'ollama_ref:\s*(\S+)')
    foreach ($m in $modelMatches) {
        $models += $m.Groups[1].Value.Trim()
    }
}

if ($models.Count -eq 0) {
    Write-Host "       Could not read models.yaml -- falling back to default model list" -ForegroundColor Yellow
    $models = @("glm-ocr:latest", "gemma4:e2b", "gemma4:e4b", "ornith:9b")
}

$installedModels = @()
try {
    $listOutput = & ollama list 2>&1 | Out-String
    $installedModels = ($listOutput -split "`n") | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
        ($_ -split '\s+')[0]
    }
} catch {
    $installedModels = @()
}

foreach ($model in $models) {
    if ($installedModels -contains $model) {
        Write-Host "       $model already installed" -ForegroundColor Green
        continue
    }
    Write-Host "       Pulling $model..." -ForegroundColor Yellow
    ollama pull $model
    Write-Host "       $model ready" -ForegroundColor Green
}
} # end if (-not $SkipModels)

# -- Step 3: Install VS Code extension --

Write-Host "[3/3] Installing Trinit VS Code extension..." -ForegroundColor Yellow
$vsixUrl = "https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix"
$vsixPath = "$env:TEMP\trinit.vsix"
Invoke-WebRequest -Uri $vsixUrl -OutFile $vsixPath
# `code` is a shim that runs VS Code's bundled Node (ELECTRON_RUN_AS_NODE=1)
# executing its own cli.js. That internal Node code uses the legacy url.parse()
# API and emits `[DEP0169] DeprecationWarning: url.parse()`. This is NOT from
# Trinit code (trinit-cli/trinit-core use `new URL(...)` and have no url.parse
# calls). We scope NODE_OPTIONS=--no-deprecation to THIS command only so the
# noisy third-party warning is silenced without hiding deprecation warnings
# from our own code elsewhere.
$prevNodeOptions = $env:NODE_OPTIONS
$env:NODE_OPTIONS = if ([string]::IsNullOrWhiteSpace($prevNodeOptions)) { "--no-deprecation" } else { "$prevNodeOptions --no-deprecation" }
try {
    code --install-extension $vsixPath
} finally {
    $env:NODE_OPTIONS = $prevNodeOptions
}
Remove-Item $vsixPath

Write-Host ""
Write-Host "...................................." -ForegroundColor Green
Write-Host "   Trinit setup complete!           " -ForegroundColor Green
Write-Host "   Open VS Code -> Trinit sidebar   " -ForegroundColor Green
Write-Host "...................................." -ForegroundColor Green
