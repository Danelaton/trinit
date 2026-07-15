# Trinit One-Liner Installer -- Windows
# Run: irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex
#
# Interactive menu: when run WITHOUT skip flags and WITHOUT -Yes, the installer
# shows a simple numeric menu (type 1/2/3 + Enter):
#   [1] Trinit VS Code Extension
#   [2] Ollama + AI Models
#   [3] Trinit Extension + Ollama + AI Models (full)   <- default (just Enter)
# The menu uses Read-Host, which works reliably even under `irm | iex` (stdin
# redirected), so the user can pick an option in remote one-liner installs too.
# Only if the environment is truly non-interactive (no $host.UI.RawUI, or
# Read-Host throws) does it fall back to option 3 (full install).
#
# Non-interactive mode: pass -Yes (or set $env:TRINIT_YES = "1") to skip the
# menu entirely and assume option 3 (full install), e.g.:
#   irm https://raw.githubusercontent.com/Danelaton/trinit/main/install.ps1 | iex -Yes
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
# -Yes / TRINIT_YES=1 explicitly force non-interactive mode (skip menu, option 3).
# We do NOT treat redirected stdin as non-interactive anymore: the numeric menu
# uses Read-Host, which reads from the real console even under `irm | iex`, so
# the user can choose even in remote one-liner installs.
$NonInteractive = $Yes -or ($env:TRINIT_YES -eq "1")

# -- Interactive numeric menu --
# Returns the chosen option number (1, 2, or 3). Prints the menu, asks the user
# to type 1/2/3 + Enter (empty Enter = 3, the default), and re-prompts on any
# invalid input. If the environment is truly non-interactive (no $host.UI.RawUI,
# or Read-Host throws), it falls back to option 3 with an explanatory message.
function Show-InstallMenu {
    $options = @(
        "Trinit VS Code Extension",
        "Ollama + AI Models",
        "Trinit Extension + Ollama + AI Models (full)"
    )

    # Probe interactivity: if there is no RawUI (headless host, restricted
    # runspace) we cannot read console input at all -> fall back to default.
    if ($null -eq $host.UI -or $null -eq $host.UI.RawUI) {
        Write-Host "Interactive menu is not available in this environment (no console UI)." -ForegroundColor Yellow
        Write-Host "Defaulting to full install (option 3)." -ForegroundColor Yellow
        Write-Host ""
        return 3
    }

    Write-Host ""
    Write-Host "Select installation profile:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $options.Count; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $options[$i]) -ForegroundColor Gray
    }
    Write-Host ""

    while ($true) {
        $answer = $null
        try {
            $answer = Read-Host "Select option [1-3] (default 3)"
        } catch {
            Write-Host "Could not read console input. Defaulting to full install (option 3)." -ForegroundColor Yellow
            return 3
        }

        $trimmed = "$answer".Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            return 3  # empty Enter -> default full
        }
        switch ($trimmed) {
            "1" { return 1 }
            "2" { return 2 }
            "3" { return 3 }
            default {
                Write-Host "Invalid option '$trimmed'. Please enter 1, 2, or 3 (or just press Enter for 3)." -ForegroundColor Yellow
            }
        }
    }
}

# -- Decide which steps to run --
# Default: full install (all three steps). Skip flags and the menu override this.
$DoOllama = -not $SkipOllama
$DoModels = -not $SkipModels
$DoExtension = $true

# If no skip flag was passed and we're not in non-interactive mode, show the menu.
# -Yes / TRINIT_YES / redirected stdin => skip menu, assume option 3 (full).
if (-not $SkipOllama -and -not $SkipModels -and -not $NonInteractive) {
    $choice = Show-InstallMenu
    switch ($choice) {
        1 { $DoOllama = $false; $DoModels = $false; $DoExtension = $true }
        2 { $DoOllama = $true;  $DoModels = $true;  $DoExtension = $false }
        3 { $DoOllama = $true;  $DoModels = $true;  $DoExtension = $true }
    }
    Write-Host ("Selected: option " + $choice) -ForegroundColor Cyan
    Write-Host ""
} elseif ($NonInteractive -and -not $SkipOllama -and -not $SkipModels) {
    Write-Host "Non-interactive mode: full install (option 3)." -ForegroundColor Yellow
    Write-Host ""
}

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

# -- Helpers for Step 1 --

# Ollama's Windows installer (Inno Setup, run via winget OR via ollama.com's
# install.ps1) is a large download and can take several minutes. It normally
# produces little visible output, so without feedback the user may think the
# installer has frozen. We stream the child process output line-by-line to the
# console so progress is visible in real time.
#
# After a successful install/upgrade, the Ollama installer launches the
# "ollama app.exe" tray app automatically, which on some systems pops up a
# window. That unexpected window confuses users into thinking the installer
# stalled. We close that auto-launched app after the upgrade so the Trinit
# installer stays in control of what is on screen.
function Stop-OllamaProcesses {
    $procs = Get-Process -Name "ollama","ollama app" -ErrorAction SilentlyContinue
    if (-not $procs) { return $false }
    Write-Host "       Closing the running Ollama app (it will restart after the update)..." -ForegroundColor Yellow
    foreach ($p in $procs) {
        try { Stop-Process -Id $p.Id -Force -ErrorAction Stop } catch {}
    }
    Start-Sleep -Seconds 2
    return $true
}

# Close any "ollama app.exe" window that the installer auto-launched at the end
# of an upgrade. We only close the GUI tray app, NOT the headless ollama.exe
# server (which Step 1 below explicitly starts if needed). This prevents the
# confusing extra window without breaking the running server.
function Close-OllamaTrayApp {
    $tray = Get-Process -Name "ollama app" -ErrorAction SilentlyContinue
    if ($tray) {
        foreach ($p in $tray) {
            try { Stop-Process -Id $p.Id -Force -ErrorAction Stop } catch {}
        }
        Start-Sleep -Seconds 1
    }
}

# Run a command and stream its stdout to the console line-by-line so the user
# sees live progress instead of a silent hang. Returns a hashtable with
# ExitCode, Output and Error. Compatible with Windows PowerShell 5.1 (the
# default `powershell.exe` used by `irm | iex` on Windows).
function Invoke-StreamingCommand {
    param(
        [string]$FilePath,
        [string[]]$Arguments
    )
    # Build a single argument string, quoting each token that contains spaces.
    $argString = ($Arguments | ForEach-Object {
        if ($_ -match '\s') { "`"$_`"" } else { "$_" }
    }) -join ' '

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.Arguments = $argString
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()

    # Read stderr on a background thread so it cannot deadlock against stdout.
    $errTask = $proc.StandardError.ReadToEndAsync()

    # Stream stdout line-by-line to the console. winget writes its progress and
    # status messages to stdout, so this is what the user sees in real time.
    $outBuilder = New-Object System.Text.StringBuilder
    while (-not $proc.StandardOutput.EndOfStream) {
        $line = $proc.StandardOutput.ReadLine()
        if ($line) {
            Write-Host "         $line" -ForegroundColor DarkGray
            [void]$outBuilder.AppendLine($line)
        }
    }
    $proc.WaitForExit()

    $errOutput = ""
    try { $errOutput = $errTask.Result } catch {}
    $exit = $proc.ExitCode
    try { $proc.Close() } catch {}

    return @{ ExitCode = $exit; Output = $outBuilder.ToString(); Error = "$errOutput" }
}

# Run the official Ollama installer (ollama.com/install.ps1) with streaming
# output. ollama's install.ps1 uses $ProgressPreference="SilentlyContinue" and
# /VERYSILENT, so it emits very little; we still surface whatever it prints.
function Invoke-OllamaOfficialInstaller {
    Write-Host "       Downloading and running the official Ollama installer..." -ForegroundColor Yellow
    Write-Host "       (this downloads ~500MB+ and may take several minutes -- please wait)" -ForegroundColor DarkGray
    # We invoke the remote script in the current scope so its Write-Host output
    # streams directly to our console. Errors propagate as exceptions.
    & ([scriptblock]::Create((Invoke-WebRequest -Uri "https://ollama.com/install.ps1" -UseBasicParsing).Content))
}

# -- Step 1: Detect / install / update Ollama --

if (-not $DoOllama) {
    Write-Host "[1/3] Ollama step skipped" -ForegroundColor Yellow
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
        Write-Host "       NOTE: this can take several minutes (large download). Please do NOT close this window." -ForegroundColor Cyan
        Write-Host "       Output from the updater will appear below as it progresses:" -ForegroundColor DarkGray

        # Close any running Ollama app/server so the installer can replace the
        # binaries cleanly. The installer would otherwise either prompt or wait.
        $null = Stop-OllamaProcesses

        $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
        $updateDone = $false
        if ($wingetCmd) {
            # winget emits localized UI text based on the OS display language
            # (e.g. Spanish on a Spanish Windows), and its --locale flag only
            # affects the Winget settings UI / BCP47 parsing -- it does NOT
            # force English output. We stream winget's native output verbatim
            # so the user sees live progress, then interpret the exit code.
            #
            # --disable-interactivity prevents winget from ever prompting on
            # stdin (which would freeze the `irm | iex` pipe).
            $wingetArgs = @('upgrade','--id','Ollama.Ollama','--silent','--disable-interactivity','--accept-package-agreements','--accept-source-agreements')
            $result = Invoke-StreamingCommand -FilePath $wingetCmd.Source -Arguments $wingetArgs
            $wingetExit = $result.ExitCode
            $wingetOutput = $result.Output + "`n" + $result.Error

            # winget exit codes:
            #   0                         -> upgraded (or already current, older winget)
            #   -1978335189 (0x8A150011)  -> APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE
            #                               "no update available" -- NOT an error
            #   other non-zero           -> real failure, fall back
            $noUpdateExitCode = -1978335189
            if ($wingetExit -eq 0 -or $wingetExit -eq $noUpdateExitCode) {
                # Distinguish "already up to date" from "actually upgraded"
                # by scanning winget's localized output for no-update markers.
                $looksLikeNoUpdate = ($wingetExit -eq $noUpdateExitCode) -or
                    ($wingetOutput -match '(No update|no hay versiones|ya est|already|ninguna actualizaci)')
                if ($looksLikeNoUpdate) {
                    Write-Host "       Ollama already up to date" -ForegroundColor Green
                } else {
                    Write-Host "       Ollama updated" -ForegroundColor Green
                }
                $updateDone = $true
            } else {
                Write-Host "       winget upgrade did not complete (exit $wingetExit), falling back to official installer..." -ForegroundColor Yellow
            }
        } else {
            Write-Host "       winget not available -- using official installer..." -ForegroundColor Yellow
        }

        if (-not $updateDone) {
            # Fallback: official ollama.com/install.ps1 (also Inno Setup /VERYSILENT).
            try {
                Invoke-OllamaOfficialInstaller
                Write-Host "       Ollama updated" -ForegroundColor Green
                $updateDone = $true
            } catch {
                Write-Host "       Ollama update failed: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "       You can download the latest installer manually from https://ollama.com/download." -ForegroundColor Yellow
            }
        }

        # The Ollama installer auto-launches the tray app ("ollama app.exe")
        # at the end of a successful install/upgrade, which pops up a window
        # and confuses users. Close that auto-launched window; Step 1 below
        # will start the headless server if it is not already running.
        if ($updateDone) {
            Close-OllamaTrayApp
        }
    } else {
        Write-Host "       Skipping update, continuing with existing install" -ForegroundColor Green
    }
} else {
    $doInstall = Read-YesNo -Prompt "       Ollama is required for Trinit's local mode. Install it now?" -DefaultYes $true
    if ($doInstall) {
        Write-Host "       Installing Ollama..." -ForegroundColor Yellow
        Write-Host "       NOTE: this can take several minutes (large download). Please do NOT close this window." -ForegroundColor Cyan
        Write-Host "       Output from the installer will appear below as it progresses:" -ForegroundColor DarkGray
        # Fresh install: Ollama is not present, so no running processes to stop.
        try {
            Invoke-OllamaOfficialInstaller
            Write-Host "       Ollama installed" -ForegroundColor Green
            # Same auto-launch behavior on fresh install -- close the tray window.
            Close-OllamaTrayApp
        } catch {
            Write-Host "       Ollama install failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "       Please download the installer manually from https://ollama.com/download," -ForegroundColor Yellow
            Write-Host "       run it, then re-run this Trinit installer." -ForegroundColor Yellow
            exit 1
        }
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

# After a fresh install/upgrade, the Ollama directory may not yet be in THIS
# process's PATH (the official installer updates the user/system PATH, but that
# only takes effect for NEW processes). Add the default install location
# explicitly so `ollama` resolves in Steps 1/2 even in the current session.
$ollamaInstallDir = Join-Path $env:LOCALAPPDATA "Programs\Ollama"
if ((Test-Path $ollamaInstallDir) -and (($env:PATH -split ';') -notcontains $ollamaInstallDir)) {
    $env:PATH = "$ollamaInstallDir;$env:PATH"
}
} # end if ($DoOllama)

# -- Step 2: Pull models (read list from models.yaml) --

if (-not $DoModels) {
    Write-Host "[2/3] Model pull step skipped" -ForegroundColor Yellow
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
} # end if ($DoModels)

# -- Step 3: Install VS Code extension --

if (-not $DoExtension) {
    Write-Host "[3/3] VS Code extension step skipped" -ForegroundColor Yellow
} else {
Write-Host "[3/3] Installing Trinit VS Code extension..." -ForegroundColor Yellow
$vsixUrl = "https://github.com/Danelaton/trinit/releases/latest/download/trinit.vsix"
$vsixPath = "$env:TEMP\trinit.vsix"

# Remove any previously downloaded .vsix so curl/Invoke-WebRequest writes a fresh copy
# rather than silently appending or reusing a stale cached file.
Remove-Item -Force -ErrorAction SilentlyContinue $vsixPath

Invoke-WebRequest -Uri $vsixUrl -OutFile $vsixPath

# Uninstall any previous version of the extension to ensure no stale cached
# code or state survives across updates. Without this, `code --install-extension`
# may leave old files in place, and VSCode can load the stale version.
$extensionId = "DanElaton.trinit"
$codeArgs = @("--uninstall-extension", $extensionId)
& code @codeArgs 2>$null
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
} # end if ($DoExtension)

Write-Host ""
Write-Host "...................................." -ForegroundColor Green
Write-Host "   Trinit setup complete!           " -ForegroundColor Green
Write-Host "   Open VS Code -> Trinit sidebar   " -ForegroundColor Green
Write-Host "...................................." -ForegroundColor Green
