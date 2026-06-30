# Trinit One-Liner Installer — Windows
# Run: irm https://raw.githubusercontent.com/USER/Trinit/main/install.ps1 | iex

Write-Host "╔══════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      T R I N I T  Setup       ║" -ForegroundColor Cyan
Write-Host "║   Local LLMs + AI Agent Teams   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# ── Step 1: Install Ollama ────────────────────────────────

Write-Host "[1/4] Installing Ollama..." -ForegroundColor Yellow
$ollamaInstalled = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollamaInstalled) {
    irm https://ollama.com/install.ps1 | iex
    Write-Host "       Ollama installed" -ForegroundColor Green
} else {
    Write-Host "       Ollama already installed" -ForegroundColor Green
}

# ── Step 2: Clone Trinit repo ────────────────────────────

Write-Host "[2/4] Cloning Trinit..." -ForegroundColor Yellow
$trinitDir = "$env:USERPROFILE\Trinit"
if (Test-Path $trinitDir) {
    Write-Host "       Trinit directory exists, pulling latest..." -ForegroundColor Yellow
    Set-Location $trinitDir
    git pull
} else {
    git clone https://github.com/USER/Trinit.git $trinitDir
    Set-Location $trinitDir
}
Write-Host "       Trinit ready at $trinitDir" -ForegroundColor Green

# ── Step 3: Install dependencies & build ──────────────────

Write-Host "[3/4] Installing dependencies..." -ForegroundColor Yellow
Set-Location $trinitDir
npm install
npm run build
Write-Host "       Dependencies installed and built" -ForegroundColor Green

# ── Step 4: Pull models & install extension ───────────────

Write-Host "[4/4] Running Trinit setup (models + extension)..." -ForegroundColor Yellow
node trinit-cli/dist/index.js setup

Write-Host ""
Write-Host "Trinit setup complete!" -ForegroundColor Green
Write-Host "Open VS Code and look for the Trinit sidebar." -ForegroundColor Cyan
