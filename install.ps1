# Trinit One-Liner Installer -- Windows
# Run: irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex
#
# Non-interactive mode: pass -Yes (or set $env:TRINIT_YES = "1") to assume defaults
# (install Ollama if missing, do NOT update if already present) so the one-liner
# never hangs waiting for input, e.g.:
#   irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex -Yes
# Note: when piped through `irm | iex`, stdin is never a TTY, so prompts are
# automatically skipped and defaults are used even without -Yes.

param(
    [switch]$Yes
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
            try {
                winget upgrade --id Ollama.Ollama --silent --accept-package-agreements --accept-source-agreements
            } catch {
                Write-Host "       winget upgrade failed, falling back to official installer..." -ForegroundColor Yellow
                irm https://ollama.com/install.ps1 | iex
            }
        } else {
            irm https://ollama.com/install.ps1 | iex
        }
        Write-Host "       Ollama updated" -ForegroundColor Green
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

# -- Step 2: Pull models (read list from models.yaml) --

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

# -- Step 3: Install VS Code extension --

Write-Host "[3/3] Installing Trinit VS Code extension..." -ForegroundColor Yellow
$vsixUrl = "https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix"
$vsixPath = "$env:TEMP\trinit.vsix"
Invoke-WebRequest -Uri $vsixUrl -OutFile $vsixPath
code --install-extension $vsixPath
Remove-Item $vsixPath

Write-Host ""
Write-Host "...................................." -ForegroundColor Green
Write-Host "   Trinit setup complete!           " -ForegroundColor Green
Write-Host "   Open VS Code -> Trinit sidebar   " -ForegroundColor Green
Write-Host "...................................." -ForegroundColor Green
