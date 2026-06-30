# Trinit One-Liner Installer — Windows
# Run: irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex

Write-Host "╔══════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      T R I N I T  Setup       ║" -ForegroundColor Cyan
Write-Host "║   Local LLMs + AI Agent Teams   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# ── Step 1: Install Ollama ────────────────────────────────

Write-Host "[1/3] Installing Ollama..." -ForegroundColor Yellow
$ollamaInstalled = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollamaInstalled) {
    irm https://ollama.com/install.ps1 | iex
    Write-Host "       Ollama installed" -ForegroundColor Green
} else {
    Write-Host "       Ollama already installed" -ForegroundColor Green
}

# ── Step 2: Pull models ────────────────────────────────────

Write-Host "[2/3] Pulling models..." -ForegroundColor Yellow
$models = @("glm-ocr:latest", "gemma4:e2b", "gemma4:e4b", "ornith:9b")
foreach ($model in $models) {
    Write-Host "       Pulling $model..." -ForegroundColor Yellow
    ollama pull $model
    Write-Host "       $model ready" -ForegroundColor Green
}

# ── Step 3: Install VS Code extension ──────────────────────

Write-Host "[3/3] Installing Trinit VS Code extension..." -ForegroundColor Yellow
$vsixUrl = "https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix"
$vsixPath = "$env:TEMP\trinit.vsix"
Invoke-WebRequest -Uri $vsixUrl -OutFile $vsixPath
code --install-extension $vsixPath
Remove-Item $vsixPath

Write-Host ""
Write-Host "╔══════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Trinit setup complete!         ║" -ForegroundColor Green
Write-Host "║   Open VS Code → Trinit sidebar  ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════╝" -ForegroundColor Green
